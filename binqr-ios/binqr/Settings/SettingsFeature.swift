import ComposableArchitecture

@Reducer
struct SettingsFeature {
    struct State {

    }

    enum Action {

    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            return .none
        }
    }
}
