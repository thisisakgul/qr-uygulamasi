import ComposableArchitecture
import UIKit

@Reducer
struct RedirectionFormFeature {
    struct State: Equatable {
        @PresentationState var alert: AlertState<Action.Alert>?
        var redirection: RedirectionModel
        @BindingState var focusedField: Field?
        @BindingState var name: String = ""
        @BindingState var redirectTo: String = ""
        var loading: Bool = false

        enum Field: String, Hashable {
            case name, redirectTo
        }

        init(redirection: RedirectionModel) {
            self.redirection = redirection
            self.name = redirection.name
            self.redirectTo = redirection.redirectTo
            self.focusedField = .name
        }

        init() {
            self.redirection = RedirectionModel(name: "", redirectTo: "")
        }
    }

    enum Action: Equatable, BindableAction {
        case saveButtonTapped
        case cancelButtonTapped
        case deleteButtonTapped
        case delegate(Delegate)
        case alert(PresentationAction<Alert>)
        case binding(BindingAction<State>)
        case saveRedirectionResponse(TaskResult<RedirectionModel>)
        case deleteRedirectionResponse(TaskResult<Bool>)

        enum Delegate: Equatable {
            case redirectionSaved(RedirectionModel)
            case redirectionDeleted(RedirectionModel.ID)
        }
        enum Alert: Equatable {
            case confirmDeletion
        }
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.redirectionClient) var redirectionClient

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .run { _ in await self.dismiss() }
            case .saveButtonTapped:
                state.redirection.name = state.name
                state.redirection.redirectTo = state.redirectTo
                state.loading = true
                return .run { [redirection = state.redirection] send in
                    await send(.saveRedirectionResponse(TaskResult {
                        try await self.redirectionClient.save(redirection)
                    }))
                }
            case .deleteButtonTapped:
                state.alert = AlertState {
                    TextState("Are you sure delete the \(state.redirection.name)?")
                } actions: {
                    ButtonState(role: .destructive, action: .confirmDeletion) {
                        TextState("Delete")
                    }
                }
                return .none
            case .alert(.presented(.confirmDeletion)):
                return .run { [id = state.redirection.id] send in
                    await send(.deleteRedirectionResponse(TaskResult {
                        try await self.redirectionClient.delete(id!)
                    }))
                }
            case .alert:
                return .none
            case .delegate:
                return .none
            case .binding(_):
                return .none
            case .saveRedirectionResponse(.success(let redirection)):
                state.loading = false
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                return .run { [redirection = redirection] send in
                    await send(.delegate(.redirectionSaved(redirection)))
                    await self.dismiss()
                }
            case .saveRedirectionResponse(.failure):
                state.loading = false
                return .none
            case .deleteRedirectionResponse(.success):
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                return .run { [id = state.redirection.id] send in
                    await send(.delegate(.redirectionDeleted(id)))
                    await self.dismiss()
                }
            case .deleteRedirectionResponse(.failure):
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
}
