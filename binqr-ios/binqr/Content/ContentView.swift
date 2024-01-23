import ComposableArchitecture
import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ContentViewModel()

    var body: some View {
        if viewModel.currentUser != nil && viewModel.currentUser!.isLoggedIn {
            TabsView(store: Store(initialState: TabsFeature.State()) {
                TabsFeature()
                    .signpost()
//                    ._printChanges()
             })
            .background(.thinMaterial)
        } else {
            LoginView(store: Store(initialState: LoginFeature.State()) {
                LoginFeature()
                    .signpost()
//                    ._printChanges()
             })
        }
    }
}

#Preview {
    ContentView()
}
