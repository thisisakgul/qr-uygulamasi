import ComposableArchitecture

@Reducer
struct HomeFeature {
    struct State: Equatable {
        @PresentationState var destination: Destination.State?
        @BindingState var query: String = ""
        var redirects: IdentifiedArrayOf<RedirectionModel> = []
        var path = StackState<RedirectionDetailFeature.State>()
        var loading: Bool = true

        var sortedRedirects: [RedirectionModel] {
            if self.query.isEmpty {
                self.redirects.sorted { $0.name < $1.name }
            } else {
                self.redirects.filter { $0.name.lowercased().contains(self.query.lowercased()) }.sorted { $0.name < $1.name }
            }
        }
    }

    enum Action: Equatable, BindableAction {
        case loadRedirects
        case addButtonTapped
        case deleteButtonTapped(RedirectionModel.ID)
        case destination(PresentationAction<Destination.Action>)
        case path(StackAction<RedirectionDetailFeature.State, RedirectionDetailFeature.Action>)
        case fetchIndexResponse(TaskResult<[RedirectionModel]>)
        case deleteRedirectionResponse(TaskResult<Bool>)
        case binding(BindingAction<State>)

        enum Alert: Equatable {
             case confirmDeletion(id: RedirectionModel.ID)
         }
    }

    @Dependency(\.redirectionClient) var redirectionClient

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .loadRedirects:
                return .run { send in
                    await send(.fetchIndexResponse(TaskResult {
                        try await self.redirectionClient.index()
                    }))
                }
            case .addButtonTapped:
                state.destination = .saveRedirection(
                    RedirectionFormFeature.State()
                )
                return .none
            case .deleteButtonTapped(let id):
                state.destination = .alert(
                    AlertState {
                        TextState("Are you sure?")
                    } actions: {
                        ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                            TextState("Delete")
                        }
                    }
                )
                return .none
            case .destination(.presented(.saveRedirection(.delegate(.redirectionSaved(let redirection))))):
                state.redirects.updateOrAppend(redirection)
                state.path.append(RedirectionDetailFeature.State(redirection: redirection))
                return .none
            case .destination(.presented(.saveRedirection(.delegate(.redirectionDeleted(let id))))):
                state.redirects.remove(id: id)
                return .none
            case .destination(.presented(.alert(.confirmDeletion(let id)))):
                state.redirects.remove(id: id)
                return .run { [id = id] send in
                    await send(.deleteRedirectionResponse(TaskResult {
                        try await self.redirectionClient.delete(id!)
                    }))
                }
            case .destination:
                return .none
            case .path(.element(id: _, action: .delegate(.redirectionDeleted(let id)))):
                state.redirects.remove(id: id)
                return .none
            case .path(.element(id: _, action: .delegate(.redirectionSaved(let redirection)))):
                state.redirects.updateOrAppend(redirection)
                return .none
            case .path:
                return .none
            case .fetchIndexResponse(.success(let redirects)):
                state.redirects = IdentifiedArrayOf(uniqueElements: redirects)
                state.loading = false
                return .none
            case .fetchIndexResponse:
                state.loading = false
                return .none
            case .deleteRedirectionResponse:
                return .none
            case .binding(_):
                return .none
            }
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
        .forEach(\.path, action: /Action.path) {
            RedirectionDetailFeature()
        }
    }
}

extension HomeFeature {
    struct Destination: Reducer {
        enum State: Equatable {
            case saveRedirection(RedirectionFormFeature.State)
            case alert(AlertState<HomeFeature.Action.Alert>)
        }

        enum Action: Equatable {
            case saveRedirection(RedirectionFormFeature.Action)
            case alert(HomeFeature.Action.Alert)
        }

        var body: some ReducerOf<Self> {
            Scope(state: /State.saveRedirection, action: /Action.saveRedirection) {
                RedirectionFormFeature()
            }
        }
    }
}
