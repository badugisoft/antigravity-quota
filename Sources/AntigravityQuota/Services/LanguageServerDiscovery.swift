import Foundation

/// Represents a discovered local language_server endpoint.
public struct LanguageServerEndpoint {
    public let port: Int
    public let csrfToken: String
    public let isHttps: Bool
    
    public var baseUrl: URL? {
        let scheme = isHttps ? "https" : "http"
        return URL(string: "\(scheme)://127.0.0.1:\(port)")
    }
}

/// Discovers the local Antigravity language_server process, its listening TCP port, and CSRF authentication token.
public final class LanguageServerDiscovery {
    public static let shared = LanguageServerDiscovery()
    
    private var cachedEndpoint: LanguageServerEndpoint?
    private var lastCheckTime: Date = .distantPast
    
    public init() {}
    
    /// Discovers the active Antigravity language_server endpoint.
    /// Cached endpoint is verified before returning to minimize overhead.
    public func discoverEndpoint(forceRefresh: Bool = false) async -> LanguageServerEndpoint? {
        if !forceRefresh, let cached = cachedEndpoint, Date().timeIntervalSince(lastCheckTime) < 30 {
            // Verify if the cached endpoint is still alive
            if await testEndpoint(cached) {
                return cached
            }
        }
        
        guard let (pid, csrfToken) = findLanguageServerProcess() else {
            cachedEndpoint = nil
            return nil
        }
        
        let ports = findListeningPorts(for: pid)
        
        // Test candidate ports to find the working endpoint
        for port in ports {
            // Try HTTP first
            let httpCandidate = LanguageServerEndpoint(port: port, csrfToken: csrfToken, isHttps: false)
            if await testEndpoint(httpCandidate) {
                cachedEndpoint = httpCandidate
                lastCheckTime = Date()
                return httpCandidate
            }
            
            // Try HTTPS if HTTP fails
            let httpsCandidate = LanguageServerEndpoint(port: port, csrfToken: csrfToken, isHttps: true)
            if await testEndpoint(httpsCandidate) {
                cachedEndpoint = httpsCandidate
                lastCheckTime = Date()
                return httpsCandidate
            }
        }
        
        cachedEndpoint = nil
        return nil
    }
    
    // MARK: - Process & Port Discovery
    
    /// Extracts the CSRF token from a process command line or environment string.
    /// Supports both environment variable (`ANTIGRAVITY_SERVER_CSRF_TOKEN=<token>`)
    /// and legacy CLI flag (`--csrf_token <token>` / `-csrf_token=<token>`).
    public static func extractCsrfToken(from text: String) -> String? {
        let patterns = [
            "ANTIGRAVITY_SERVER_CSRF_TOKEN=[\"']?([a-zA-Z0-9-]+)[\"']?",
            "--?csrf_token(?:=|\\s+)[\"']?([a-zA-Z0-9-]+)[\"']?"
        ]
        
        let fullRange = NSRange(text.startIndex..<text.endIndex, in: text)
        for pattern in patterns {
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: text, range: fullRange),
                  match.numberOfRanges >= 2,
                  let tokenRange = Range(match.range(at: 1), in: text) else {
                continue
            }
            return String(text[tokenRange])
        }
        
        return nil
    }
    
    /// Inspects running processes via `/bin/ps` to find `language_server` and extract its PID and CSRF token.
    /// Checks CLI arguments first (`--csrf_token`), then falls back to environment variables (`ps eww -p <pid>`).
    private func findLanguageServerProcess() -> (pid: Int32, csrfToken: String)? {
        guard let output = runPs(arguments: ["-eo", "pid,command"]) else {
            return nil
        }
        
        var directCandidates: [Int32] = []
        var secondaryCandidates: [Int32] = []
        
        let lines = output.components(separatedBy: "\n")
        for line in lines {
            guard line.contains("language_server") else { continue }
            
            let tokens = line.split(whereSeparator: { $0.isWhitespace })
            guard let first = tokens.first, let pid = Int32(first) else { continue }
            
            // Legacy format: --csrf_token passed directly in CLI arguments
            if let token = Self.extractCsrfToken(from: line) {
                return (pid, token)
            }
            
            // Prioritize processes whose executable token itself references language_server
            if tokens.count >= 2 && tokens[1].contains("language_server") {
                directCandidates.append(pid)
            } else {
                secondaryCandidates.append(pid)
            }
        }
        
        // Antigravity 2.34.0+ passes CSRF token via ANTIGRAVITY_SERVER_CSRF_TOKEN environment variable
        for pid in directCandidates + secondaryCandidates {
            if let envOutput = runPs(arguments: ["eww", "-p", "\(pid)"]),
               let token = Self.extractCsrfToken(from: envOutput) {
                return (pid, token)
            }
        }
        
        return nil
    }
    
    private func runPs(arguments: [String]) -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/ps")
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        
        do {
            try task.run()
            // Read data before waitUntilExit to prevent pipe buffer deadlocks
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            return String(data: data, encoding: .utf8)
        } catch {
            print("[Discovery] Error running ps \(arguments.joined(separator: " ")): \(error)")
            return nil
        }
    }
    
    /// Finds TCP listening ports for the specified PID using `/usr/sbin/lsof` with `/usr/sbin/netstat` fallback.
    private func findListeningPorts(for pid: Int32) -> [Int] {
        var ports = findListeningPortsViaLsof(for: pid)
        if ports.isEmpty {
            ports = findListeningPortsViaNetstat(for: pid)
        }
        return ports
    }
    
    private func findListeningPortsViaLsof(for pid: Int32) -> [Int] {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/lsof")
        task.arguments = ["-iTCP", "-sTCP:LISTEN", "-n", "-P", "-a", "-p", "\(pid)"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        
        var ports: [Int] = []
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            guard let output = String(data: data, encoding: .utf8) else { return ports }
            
            let lines = output.components(separatedBy: "\n")
            for line in lines {
                guard line.contains("LISTEN") else { continue }
                let tokens = line.split(whereSeparator: { $0.isWhitespace })
                for token in tokens {
                    let str = String(token)
                    if let colonIndex = str.lastIndex(of: ":") {
                        let portStr = String(str[str.index(after: colonIndex)...])
                        if let port = Int(portStr), !ports.contains(port) {
                            ports.append(port)
                        }
                    }
                }
            }
        } catch {
            print("[Discovery] Error running lsof: \(error)")
        }
        
        return ports
    }
    
    private func findListeningPortsViaNetstat(for pid: Int32) -> [Int] {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/netstat")
        task.arguments = ["-anv", "-p", "tcp"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        
        var ports: [Int] = []
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            guard let output = String(data: data, encoding: .utf8) else { return ports }
            
            let lines = output.components(separatedBy: "\n")
            let pidTarget = ":\(pid)"
            
            for line in lines {
                guard line.contains("LISTEN") && line.contains(pidTarget) else { continue }
                
                let tokens = line.split(whereSeparator: { $0.isWhitespace })
                guard tokens.count >= 4 else { continue }
                let address = String(tokens[3])
                
                if let lastDotIndex = address.lastIndex(of: ".") {
                    let portString = String(address[address.index(after: lastDotIndex)...])
                    if let port = Int(portString), !ports.contains(port) {
                        ports.append(port)
                    }
                }
            }
        } catch {
            print("[Discovery] Error running netstat: \(error)")
        }
        
        return ports
    }
    
    // MARK: - Validation
    
    /// Validates endpoint connectivity by performing a lightweight Connect RPC ping with CSRF token.
    private func testEndpoint(_ endpoint: LanguageServerEndpoint) async -> Bool {
        guard let url = endpoint.baseUrl?.appendingPathComponent("exa.language_server_pb.LanguageServerService/RetrieveUserQuotaSummary") else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 1.0
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(endpoint.csrfToken, forHTTPHeaderField: "x-codeium-csrf-token")
        request.httpBody = "{}".data(using: .utf8)
        
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 1.0
        
        let session = URLSession(configuration: config, delegate: SelfSignedDelegate(), delegateQueue: nil)
        
        do {
            let (_, response) = try await session.data(for: request)
            if let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200 {
                return true
            }
        } catch {
            // Connection failed
        }
        
        return false
    }
}

/// URLSession delegate allowing local self-signed certificates.
private final class SelfSignedDelegate: NSObject, URLSessionDelegate {
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}
