import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

struct SessionClient {
    var login: @Sendable (SessionRequest) async throws -> SessionResponse
    var logout: @Sendable (String) async throws -> Bool
    var me: @Sendable (String) async throws -> UserModel
}

extension DependencyValues {
    var sessionClient: SessionClient {
        get { self[SessionClient.self] }
        set { self[SessionClient.self] = newValue }
    }
}

extension SessionClient: DependencyKey {
    static let liveValue = Self(
        login: { sessionData in
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try encoder.encode(sessionData)

            var request = URLRequest(url: URL(string: "https://binqr.io/api/users/oauth/log_in")!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData

            let (data, _) = try await URLSession.shared.data(for: request)

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response: ServiceResponse<SessionResponse> = try decoder.decode(ServiceResponse<SessionResponse>.self, from: data)
            return response.data
        },
        logout: { accessToken in
            var request = URLRequest(url: URL(string: "https://binqr.io/api/users/log_out")!)
            request.httpMethod = "DELETE"
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            let (_, _) = try await URLSession.shared.data(for: request)

            return true
         },
        me: { accessToken in
            var request = URLRequest(url: URL(string: "https://binqr.io/api/users/me")!)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response: ServiceResponse<UserServiceRequest> = try decoder.decode(ServiceResponse<UserServiceRequest>.self, from: data)

            return response.data.user
        }
    )

    static let testValue = Self(
        login: { code in
            return SessionResponse(token: code.provider + code.code)
        },
        logout: { _ in
            return true
        },
        me: { _ in
            return UserModel.init(email: "test@test.com", confirmedAt: "")
        }
    )
}
