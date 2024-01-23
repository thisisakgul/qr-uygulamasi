import ComposableArchitecture

@Reducer
struct RedirectionDetailFeature {
    struct State: Equatable {
        @PresentationState var destination: Destination.State?
        var redirection: RedirectionModel
    }

    enum Action: Equatable {
        case loadRedirection
        case serviceResponse(TaskResult<RedirectionModel>)
        case destination(PresentationAction<Destination.Action>)
        case editButtonTapped
        case showButtonTapped
        case customizeButtonTapped
        case delegate(Delegate)

        enum Delegate: Equatable {
            case redirectionSaved(RedirectionModel)
            case redirectionDeleted(RedirectionModel.ID)
        }
    }

    @Dependency(\.redirectionClient) var redirectionClient
    @Dependency(\.dismiss) var dismiss

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadRedirection:
                return .run { [id = state.redirection.id] send in
                    await send(.serviceResponse(TaskResult { try await self.redirectionClient.show(id!) }))
                }
            case .serviceResponse(.success(let redirection)):
                state.redirection = redirection
                return .none
            case .serviceResponse(_):
                return .none
            case .destination(.presented(.editRedirection(.delegate(.redirectionDeleted(let id))))):
                return .run { [id = id] send in
                    await send(.delegate(.redirectionDeleted(id)))
                    await self.dismiss()
                }
            case .destination(.presented(.editRedirection(.delegate(.redirectionSaved(let redirection))))):
                state.redirection = redirection
                return .run { [redirection = redirection] send in
                    await send(.delegate(.redirectionSaved(redirection)))
                 }
            case .destination(.presented(.customizeRedirection(.delegate(.redirectionSaved(let redirection))))):
                state.redirection = redirection
                return .run { [redirection = redirection] send in
                    await send(.delegate(.redirectionSaved(redirection)))
                 }
            case .destination(_):
                return .none
            case .editButtonTapped:
                state.destination = .editRedirection(RedirectionFormFeature.State(redirection: state.redirection))
                return .none
            case .showButtonTapped:
                return .none
            case .customizeButtonTapped:
                state.destination = .customizeRedirection(RedirectionCustomizeFeature.State(redirection: state.redirection))
                return .none
            case .delegate(_):
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
    }
}

extension RedirectionDetailFeature {
    struct Destination: Reducer {
        enum State: Equatable {
            case editRedirection(RedirectionFormFeature.State)
            case customizeRedirection(RedirectionCustomizeFeature.State)
        }

        enum Action: Equatable {
            case editRedirection(RedirectionFormFeature.Action)
            case customizeRedirection(RedirectionCustomizeFeature.Action)
        }

        var body: some ReducerOf<Self> {
            Scope(state: /State.editRedirection, action: /Action.editRedirection) {
                RedirectionFormFeature()
            }
            Scope(state: /State.customizeRedirection, action: /Action.customizeRedirection) {
                RedirectionCustomizeFeature()
            }
         }
    }
}
