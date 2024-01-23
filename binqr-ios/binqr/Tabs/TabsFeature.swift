import ComposableArchitecture

@Reducer
struct TabsFeature {
    struct State {
        var home = HomeFeature.State()
        var settings = SettingsFeature.State()
        var profile = ProfileFeature.State()
        var selectedTab: Tab = Tab.home
    }

    enum Action {
        case home(HomeFeature.Action)
        case settings(SettingsFeature.Action)
        case profile(ProfileFeature.Action)
        case tabSelected
    }

    enum Tab {
        case home
        case settings
        case profile
    }

    var body: some Reducer<State, Action> {
        Reduce { _, _ in
            return .none
        }

        Scope(state: \.home, action: /Action.home) {
            HomeFeature()
        }
        Scope(state: \.settings, action: /Action.settings) {
            SettingsFeature()
        }
        Scope(state: \.profile, action: /Action.profile) {
            ProfileFeature()
        }
    }
}
