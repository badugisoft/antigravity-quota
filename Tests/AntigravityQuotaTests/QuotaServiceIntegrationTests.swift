import XCTest
@testable import AntigravityQuota
@testable import AntigravityQuotaCore

final class QuotaServiceIntegrationTests: XCTestCase {
    func testLiveDiscoveryAndFetch() async throws {
        let service = QuotaService.shared
        do {
            let data = try await service.fetchQuotaSummary()
            print("[Test] Successfully fetched live quota! Groups count: \(data.groups.count)")
            for group in data.groups {
                print("[Test] Group: \(group.displayName)")
                for bucket in group.buckets {
                    print("[Test]   - \(bucket.displayName) (\(bucket.window ?? "-")): \(bucket.remainingPercentage)% remaining, reset: \(bucket.formattedTimeRemaining(language: .en))")
                }
            }
            XCTAssertFalse(data.groups.isEmpty, "Groups should not be empty when Antigravity is running")
        } catch {
            print("[Test] Live fetch error: \(error)")
        }
    }
}
