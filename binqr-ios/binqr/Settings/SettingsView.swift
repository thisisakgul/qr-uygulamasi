import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    let store: StoreOf<SettingsFeature>

    var body: some View {
        Text("Hello World")
    }
}

#Preview {
    SettingsView(store: StoreOf<SettingsFeature>(initialState: SettingsFeature.State()) {
        SettingsFeature()
    })
}
