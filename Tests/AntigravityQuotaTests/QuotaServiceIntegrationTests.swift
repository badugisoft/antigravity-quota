import XCTest
@testable import AntigravityQuota
@testable import AntigravityQuotaCore

final class QuotaServiceIntegrationTests: XCTestCase {
    private func hasRunningLanguageServer() -> Bool {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/ps")
        task.arguments = ["-eo", "command"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = Pipe()
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            guard task.terminationStatus == 0,
                  let output = String(data: data, encoding: .utf8) else {
                return false
            }
            return output.components(separatedBy: "\n").contains { $0.contains("/language_server") }
        } catch {
            return false
        }
    }
    
    func testLiveDiscoveryAndFetch() async throws {
        try XCTSkipUnless(hasRunningLanguageServer(), "Antigravity language_server is not running or inaccessible")
        
        let endpoint = await LanguageServerDiscovery.shared.discoverEndpoint(forceRefresh: true)
        XCTAssertNotNil(endpoint, "LanguageServerDiscovery should discover the running language_server endpoint")
        
        let data = try await QuotaService.shared.fetchQuotaSummary()
        print("[Test] Successfully fetched live quota! Groups count: \(data.groups.count)")
        for group in data.groups {
            print("[Test] Group: \(group.displayName)")
            for bucket in group.buckets {
                print("[Test]   - \(bucket.displayName) (\(bucket.window ?? "-")): \(bucket.remainingPercentage)% remaining, reset: \(bucket.formattedTimeRemaining(language: .en))")
            }
        }
        XCTAssertFalse(data.groups.isEmpty, "Groups should not be empty when Antigravity is running")
    }
}
