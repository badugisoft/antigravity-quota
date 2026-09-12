import Foundation
import AntigravityQuotaCore

/// Errors that can occur when communicating with the Antigravity language_server quota service.
public enum QuotaServiceError: LocalizedError {
    case serverNotFound
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    
    public var errorDescription: String? {
        let lang = AppLanguage.currentPreference
        switch self {
        case .serverNotFound:
            return LocalizedStringKey.errorServerNotFound.string(for: lang)
        case .invalidResponse:
            return LocalizedStringKey.errorInvalidResponse.string(for: lang)
        case .httpError(let code):
            return LocalizedStringKey.errorHttp(code: code).string(for: lang)
        case .decodingError(let error):
            return LocalizedStringKey.errorDecoding(details: error.localizedDescription).string(for: lang)
        case .networkError(let error):
            return LocalizedStringKey.errorNetwork(details: error.localizedDescription).string(for: lang)
        }
    }
}

/// Protocol defining quota summary fetching capabilities.
public protocol QuotaServiceProtocol {
    func fetchQuotaSummary() async throws -> QuotaResponseData
}

/// Service responsible for executing Connect RPC requests to the local language_server.
public final class QuotaService: QuotaServiceProtocol {
    public static let shared = QuotaService()
    
    private let discovery: LanguageServerDiscovery
    
    public init(discovery: LanguageServerDiscovery = .shared) {
        self.discovery = discovery
    }
    
    /// Fetches the live quota summary from the discovered local language_server.
    public func fetchQuotaSummary() async throws -> QuotaResponseData {
        guard let endpoint = await discovery.discoverEndpoint() else {
            throw QuotaServiceError.serverNotFound
        }
        
        guard let url = endpoint.baseUrl?.appendingPathComponent("exa.language_server_pb.LanguageServerService/RetrieveUserQuotaSummary") else {
            throw QuotaServiceError.serverNotFound
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 3.0
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(endpoint.csrfToken, forHTTPHeaderField: "x-codeium-csrf-token")
        request.httpBody = "{}".data(using: .utf8)
        
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 3.0
        let session = URLSession(configuration: config, delegate: SelfSignedDelegate(), delegateQueue: nil)
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw QuotaServiceError.networkError(error)
        }
        
        guard let httpRes = response as? HTTPURLResponse else {
            throw QuotaServiceError.invalidResponse
        }
        
        guard httpRes.statusCode == 200 else {
            throw QuotaServiceError.httpError(statusCode: httpRes.statusCode)
        }
        
        do {
            let envelope = try JSONDecoder().decode(QuotaEnvelope.self, from: data)
            guard let responseData = envelope.response else {
                throw QuotaServiceError.invalidResponse
            }
            return responseData
        } catch {
            throw QuotaServiceError.decodingError(error)
        }
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
