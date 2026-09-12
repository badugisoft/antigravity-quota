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
                return httpCandidate
            }
        }
        
        cachedEndpoint = nil
        return nil
    }
    
    // MARK: - Process & Port Discovery
    
    /// Inspects running processes via `/bin/ps` to find `language_server` and extract its PID and `--csrf_token`.
    private func findLanguageServerProcess() -> (pid: Int32, csrfToken: String)? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/ps")
        task.arguments = ["-eo", "pid,command"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        
        do {
            try task.run()
            // Read data before waitUntilExit to prevent pipe buffer deadlocks
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            guard let output = String(data: data, encoding: .utf8) else { return nil }
            
            let lines = output.components(separatedBy: "\n")
            for line in lines {
                if line.contains("language_server") && line.contains("--csrf_token") {
                    // Extract PID and token
                    let trimmed = line.trimmingCharacters(in: .whitespaces)
                    let components = trimmed.components(separatedBy: .whitespaces)
                    guard let first = components.first, let pid = Int32(first) else { continue }
                    
                    if let tokenRange = line.range(of: "--csrf_token\\s+([a-zA-Z0-9-]+)", options: .regularExpression) {
                        let sub = String(line[tokenRange])
                        let parts = sub.components(separatedBy: .whitespaces)
                        if parts.count >= 2 {
                            let token = parts[1]
                            return (pid, token)
                        }
                    }
                }
            }
        } catch {
            print("[Discovery] Error running ps: \(error)")
        }
        
        return nil
    }
    
    /// Finds TCP listening ports for the specified PID using `/usr/sbin/netstat` in sub-milliseconds.
    private func findListeningPorts(for pid: Int32) -> [Int] {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/netstat")
        task.arguments = ["-anv", "-p", "tcp"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        
        var ports: [Int] = []
        
        do {
            try task.run()
            // Read data before waitUntilExit to avoid pipe deadlocks
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            guard let output = String(data: data, encoding: .utf8) else { return ports }
            
            let lines = output.components(separatedBy: "\n")
            let pidTarget = ":\(pid)"
            
            for line in lines {
                guard line.contains("LISTEN") && line.contains(pidTarget) else { continue }
                
                // Example: tcp4 0 0 127.0.0.1.58169 *.* LISTEN ... language_server:14762 ...
                let tokens = line.split(whereSeparator: { $0.isWhitespace })
                guard tokens.count >= 4 else { continue }
                let address = String(tokens[3])
                
                // The port number follows the last dot
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
