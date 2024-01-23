import AuthenticationServices
import ComposableArchitecture
import SwiftUI

@Reducer
struct LoginFeature {
    struct State: Equatable {
    }

    enum Action {
        case handleOnCompletion(Result<ASAuthorization, Error>)
        case sessionLogin(TaskResult<Bool>)
        case sessionMe(TaskResult<Bool>)
        case successLogin
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .handleOnCompletion(.success(let authorization)):
                guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                      let tokenData = credential.authorizationCode,
                      let token = String(data: tokenData, encoding: .utf8)
                else { return .none }

                return .run { send in
                    await send(.sessionLogin(TaskResult {
                        await AuthService.shared.loginWithApple(token)
                    }))
                }
            case .handleOnCompletion(.failure(let error)):
                print(error)
                return .run { _ in
                    _ = await AuthService.shared.logout()
                }
            case .sessionLogin(.success(_)):
                return .none
            case .sessionLogin(.failure(let error)):
                print(error)
                return .run { _ in
                    _ = await AuthService.shared.logout()
                }
            case .successLogin:
                return .none
            case .sessionMe(_):
                return .none
            }
        }
    }
}
