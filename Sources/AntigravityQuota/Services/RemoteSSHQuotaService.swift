import Foundation
import AntigravityQuotaCore

/// Errors that can occur during remote SSH quota fetching.
public enum RemoteSSHError: LocalizedError {
    case emptyHost
    case sshFailed(code: Int32, message: String)
    case remoteLanguageServerNotFound
    case remotePortNotFound(pid: String, tokenSnippet: String)
    case endpointNotReachable(details: String)
    case emptyResponse(message: String)
    case invalidResponse
    case decodingError(Error)
    
    public var errorDescription: String? {
        let lang = AppLanguage.currentPreference
        switch self {
        case .emptyHost:
            return "SSH host is not configured."
        case .sshFailed(_, let message):
            return LocalizedStringKey.testConnectionFailed(details: message.trimmingCharacters(in: .whitespacesAndNewlines)).string(for: lang)
        case .remoteLanguageServerNotFound:
            return LocalizedStringKey.errorServerNotFound.string(for: lang)
        case .remotePortNotFound(let pid, let token):
            return "language_server 실행 중(PID: \(pid))이나 리스닝 포트를 찾을 수 없습니다. (토큰: \(token))"
        case .endpointNotReachable(let details):
            return "엔드포인트 호출 실패: \(details)"
        case .emptyResponse(let message):
            let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? LocalizedStringKey.errorInvalidResponse.string(for: lang) : trimmed
        case .invalidResponse:
            return LocalizedStringKey.errorInvalidResponse.string(for: lang)
        case .decodingError(let err):
            return LocalizedStringKey.errorDecoding(details: err.localizedDescription).string(for: lang)
        }
    }
}

/// Service responsible for fetching Antigravity quota from a remote machine via SSH.
public final class RemoteSSHQuotaService: Sendable {
    public static let shared = RemoteSSHQuotaService()
    
    public init() {}
    
    /// Remote shell command executed on the target host.
    /// Robustly discovers language_server PID and CSRF token, iterates all listening TCP ports, and tests RetrieveUserQuotaSummary.
    private static var remoteCommand: String {
        """
        export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
        [ -n "$ZSH_VERSION" ] && setopt shwordsplit 2>/dev/null
        PID=$(pgrep -f 'language_server.*csrf_token' 2>/dev/null | head -n 1)
        if [ -z "$PID" ]; then
          PID=$(pgrep -f 'language_server' 2>/dev/null | head -n 1)
        fi
        if [ -z "$PID" ]; then
          PID=$(ps aux 2>/dev/null | grep '[l]anguage_server' | awk '{print $2}' | head -n 1)
        fi
        if [ -z "$PID" ]; then
          echo '{"error":"LANGUAGE_SERVER_NOT_RUNNING"}'
          exit 1
        fi
        LINE=$(ps -ww -p "$PID" -o command= 2>/dev/null || ps -p "$PID" -o args= 2>/dev/null || ps aux | grep "$PID" | head -n 1)
        TOKEN=$(echo "$LINE" | grep -oE 'csrf_token[= ][^ ]+' | head -n 1 | sed 's/csrf_token[= ]*//' | tr -d '"'"'")
        PORTS=$( (lsof -Pan -p "$PID" -iTCP -sTCP:LISTEN 2>/dev/null | awk 'NR>1 {print $9}' | awk -F: '{print $NF}'; netstat -anv -p tcp 2>/dev/null | grep LISTEN | grep ":$PID" | awk '{print $4}' | awk -F. '{print $NF}'; ss -tlnp 2>/dev/null | grep "pid=$PID," | awk '{print $4}' | awk -F: '{print $NF}') | grep -E '^[0-9]+$' | sort -u )
        if [ -z "$PORTS" ]; then
          echo "{\\"error\\":\\"PORT_NOT_FOUND\\",\\"pid\\":\\"$PID\\",\\"token\\":\\"${TOKEN:0:6}...\\"}"
          exit 2
        fi
        LAST_ERR=""
        for PORT in $(echo "$PORTS" | tr '\n' ' '); do
          for PROTO in http https; do
            RESP=$(curl -k -s --max-time 2 -X POST "$PROTO://127.0.0.1:$PORT/exa.language_server_pb.LanguageServerService/RetrieveUserQuotaSummary" -H "Content-Type: application/json" -H "x-codeium-csrf-token: $TOKEN" -d '{}' 2>/dev/null)
            if echo "$RESP" | grep -q '"groups"'; then
              echo "$RESP"
              exit 0
            fi
            if [ -n "$RESP" ]; then
              LAST_ERR="$RESP"
            fi
          done
        done
        CLEAN_ERR=$(echo "$LAST_ERR" | tr '\\n' ' ' | cut -c 1-120)
        echo "{\\"error\\":\\"ENDPOINT_NOT_REACHABLE\\",\\"details\\":\\"ports=[$PORTS] token=${TOKEN:0:6}... resp=$CLEAN_ERR\\"}"
        exit 3
        """
    }
    
    /// Fetches quota data from the remote host using `/usr/bin/ssh`.
    public func fetchQuotaSummary(host: String) async throws -> QuotaResponseData {
        let trimmedHost = host.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedHost.isEmpty else {
            throw RemoteSSHError.emptyHost
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let task = Process()
                task.executableURL = URL(fileURLWithPath: "/usr/bin/ssh")
                task.arguments = [
                    "-q",
                    "-o", "BatchMode=yes",
                    "-o", "ConnectTimeout=5",
                    "-o", "StrictHostKeyChecking=accept-new",
                    trimmedHost,
                    Self.remoteCommand
                ]
                
                let outPipe = Pipe()
                let errPipe = Pipe()
                task.standardOutput = outPipe
                task.standardError = errPipe
                
                do {
                    try task.run()
                    let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
                    let errData = errPipe.fileHandleForReading.readDataToEndOfFile()
                    task.waitUntilExit()
                    
                    let stdoutStr = String(data: outData, encoding: .utf8) ?? ""
                    let stderrStr = String(data: errData, encoding: .utf8) ?? ""
                    
                    if stdoutStr.contains("LANGUAGE_SERVER_NOT_RUNNING") {
                        continuation.resume(throwing: RemoteSSHError.remoteLanguageServerNotFound)
                        return
                    }
                    if stdoutStr.contains("PORT_NOT_FOUND") {
                        let pid = Self.extractField(from: stdoutStr, field: "pid") ?? "unknown"
                        let token = Self.extractField(from: stdoutStr, field: "token") ?? "unknown"
                        continuation.resume(throwing: RemoteSSHError.remotePortNotFound(pid: pid, tokenSnippet: token))
                        return
                    }
                    if stdoutStr.contains("ENDPOINT_NOT_REACHABLE") {
                        let details = Self.extractField(from: stdoutStr, field: "details") ?? stdoutStr
                        continuation.resume(throwing: RemoteSSHError.endpointNotReachable(details: details))
                        return
                    }
                    
                    if task.terminationStatus != 0 {
                        let msg = stderrStr.isEmpty ? stdoutStr : stderrStr
                        continuation.resume(throwing: RemoteSSHError.sshFailed(code: task.terminationStatus, message: msg.isEmpty ? "Exit code \(task.terminationStatus)" : msg))
                        return
                    }
                    
                    guard let jsonSubstring = Self.extractJSON(from: stdoutStr),
                          let jsonData = jsonSubstring.data(using: .utf8) else {
                        continuation.resume(throwing: RemoteSSHError.emptyResponse(message: stdoutStr.isEmpty ? stderrStr : stdoutStr))
                        return
                    }
                    
                    // Decode wrapped envelope or direct response data
                    if let envelope = try? JSONDecoder().decode(QuotaEnvelope.self, from: jsonData),
                       let responseData = envelope.response {
                        continuation.resume(returning: responseData)
                        return
                    }
                    
                    if let directData = try? JSONDecoder().decode(QuotaResponseData.self, from: jsonData) {
                        continuation.resume(returning: directData)
                        return
                    }
                    
                    continuation.resume(throwing: RemoteSSHError.invalidResponse)
                } catch {
                    continuation.resume(throwing: RemoteSSHError.decodingError(error))
                }
            }
        }
    }
    
    /// Tests SSH connectivity and quota retrieval for a specified host.
    public func testConnection(host: String) async -> Result<QuotaResponseData, Error> {
        do {
            let data = try await fetchQuotaSummary(host: host)
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
    
    /// Helper to isolate JSON substring in case SSH output contains surrounding noise.
    private static func extractJSON(from text: String) -> String? {
        guard let start = text.firstIndex(of: "{"),
              let end = text.lastIndex(of: "}") else {
            return nil
        }
        guard start <= end else { return nil }
        return String(text[start...end])
    }
    
    /// Helper to extract string values from simple JSON string.
    private static func extractField(from text: String, field: String) -> String? {
        guard let range = text.range(of: "\"\(field)\":\"([^\"]+)\"", options: .regularExpression) else {
            return nil
        }
        let matched = String(text[range])
        return matched.replacingOccurrences(of: "\"\(field)\":\"", with: "").replacingOccurrences(of: "\"", with: "")
    }
}
