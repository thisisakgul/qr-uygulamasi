import ComposableArchitecture

@Reducer
struct ProfileFeature {
    struct State: Equatable {
        var email: String
        
        init() {
            self.email = AuthService.shared.currentUser.email
        }
    }

    enum Action {
        case logoutButtonTapped
    }

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .logoutButtonTapped:
                return .run { _ in
                    _ = await AuthService.shared.logout()
                }
            }
        }
    }
}
