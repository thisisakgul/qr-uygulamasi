import ComposableArchitecture
import UIKit

@Reducer
struct RedirectionCustomizeFeature {
    struct State: Equatable {
        var redirection: RedirectionModel
        @BindingState var selectedConfigOption: RedirectionConfigurationModel.ConfigOptions
        @BindingState var selectedShapeOnPixels: RedirectionConfigurationModel.QRCodePixelShapes
        @BindingState var selectedShapeEye: RedirectionConfigurationModel.QRCodeEyeShapes
        var loading: Bool = false
        
        init(redirection: RedirectionModel) {
            self.redirection = redirection
            
            let configuration: RedirectionConfigurationModel = redirection.configuration ?? RedirectionConfigurationModel()
            self.selectedShapeOnPixels = configuration.shapeOnPixels
            self.selectedShapeEye = configuration.shapeEye
            self.selectedConfigOption = .shapeEye
        }
    }

    enum Action: Equatable, BindableAction {
        case cancelButtonTapped
        case saveButtonTapped
        case delegate(Delegate)
        case binding(BindingAction<State>)
        case saveRedirectionResponse(TaskResult<RedirectionModel>)

        enum Delegate: Equatable {
            case redirectionSaved(RedirectionModel)
        }
    }

    @Dependency(\.dismiss) var dismiss
    @Dependency(\.redirectionClient) var redirectionClient

    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .delegate(_):
                return .none
            case .binding(_):
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                return .none
            case .cancelButtonTapped:
                return .run { _ in await self.dismiss() }
            case .saveButtonTapped:
                state.redirection.setDesign(
                    shapeEye: state.selectedShapeEye,
                    shapeOnPixels: state.selectedShapeOnPixels)
                state.loading = true
                return .run { [redirection = state.redirection] send in
                    await send(.saveRedirectionResponse(TaskResult {
                        try await self.redirectionClient.save(redirection)
                    }))
                }
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
            }
        }
    }
}
