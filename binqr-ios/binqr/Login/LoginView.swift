import AuthenticationServices
import ComposableArchitecture
import Combine
import SwiftUI

struct LoginView: View {
    let store: StoreOf<LoginFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Spacer()
                Text("Welcome to binQR")
                    .font(.title)
                    .fontWeight(.heavy)
                    .foregroundStyle(.white)

                Spacer()

                SignInWithAppleButton(
                    .continue,
                    onRequest: { request in
                        request.requestedScopes = [.email]
                    },
                    onCompletion: { result in
                        viewStore.send(.handleOnCompletion(result))
                    }
                )
                .frame(height: 45)

                Spacer()
            }
            .padding()
            .background(.accent.opacity(0.6))
        }
    }
}

#Preview {
    LoginView(store: StoreOf<LoginFeature>(initialState: LoginFeature.State()) {
        LoginFeature()
    })
}
