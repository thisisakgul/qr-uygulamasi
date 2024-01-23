import ComposableArchitecture
import XCTest
@testable import binqr

@MainActor
final class HomeFeatureTests: XCTestCase {
    func testHome() async {
        let redirects = [
            RedirectionModel(
                id: UUID.init(),
                name: "Personal Website",
                slug: UUID.init(),
                redirectTo: "https://google.com"
            )
        ]
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.redirectionClient.index = { redirects }
        }

        await store.send(.loadRedirects)

        await store.receive(.fetchIndexResponse(TaskResult.success(redirects))) {
            $0.redirects = IdentifiedArrayOf(uniqueElements: redirects)
            $0.loading = false
        }
    }
}
