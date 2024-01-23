import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay

struct RedirectionClient {
    var index: @Sendable () async throws -> [RedirectionModel]
    var show: @Sendable (UUID) async throws -> RedirectionModel
    var save: @Sendable (RedirectionModel) async throws -> RedirectionModel
    var delete: @Sendable (UUID) async throws -> Bool
}

extension DependencyValues {
    var redirectionClient: RedirectionClient {
        get { self[RedirectionClient.self] }
        set { self[RedirectionClient.self] = newValue }
    }
}

extension RedirectionClient: DependencyKey {
    static let liveValue = Self(
        index: {
            @Dependency(\.keyChainService) var keyChainService
            let accessToken:String = try await keyChainService.get()
            var request = URLRequest(url: URL(string: "https://binqr.io/api/redirects")!)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response: ServiceResponse<[RedirectionModel]> = try decoder.decode(ServiceResponse<[RedirectionModel]>.self, from: data)

            return response.data
        },
        show: { redirectionId in
            @Dependency(\.keyChainService) var keyChainService
            let accessToken:String = try await keyChainService.get()
            var request = URLRequest(url: URL(string: "https://binqr.io/api/redirects/\(redirectionId)")!)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response: ServiceResponse<RedirectionModel> = try decoder.decode(ServiceResponse<RedirectionModel>.self, from: data)

            return response.data
        },
        save: { redirection in
            @Dependency(\.keyChainService) var keyChainService
            let accessToken:String = try await keyChainService.get()

            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let jsonData = try encoder.encode(RedirectionServiceRequest(redirection: redirection))

            var request: URLRequest
            if redirection.id == nil {
                request = URLRequest(url: URL(string: "https://binqr.io/api/redirects/")!)
                request.httpMethod = "POST"
            } else {
                request = URLRequest(url: URL(string: "https://binqr.io/api/redirects/\(redirection.id!)")!)
                request.httpMethod = "PUT"
            }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.httpBody = jsonData

            let (data, _) = try await URLSession.shared.data(for: request)

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let response: ServiceResponse<RedirectionModel> = try decoder.decode(ServiceResponse<RedirectionModel>.self, from: data)

            return response.data
        },
        delete: { redirectionId in
            @Dependency(\.keyChainService) var keyChainService
            let accessToken:String = try await keyChainService.get()

            var request = URLRequest(url: URL(string: "https://binqr.io/api/redirects/\(redirectionId)")!)
            request.httpMethod = "DELETE"
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            let (_, _) = try await URLSession.shared.data(for: request)

            return true
        }
    )

    static let testValue = Self(
        index: {
            return [
                RedirectionModel(id: UUID.init(),
                                 name: "Personal Website",
                                 slug: UUID.init(),
                                 redirectTo: "https://google.com")
            ]
        },
        show: { redirectionId in
            return RedirectionModel(id: UUID.init(),
                                    name: "Personal Website",
                                    slug: UUID.init(),
                                    redirectTo: "https://google.com")
        },
        save: { _ in
            return RedirectionModel(id: UUID.init(),
                                    name: "Personal Website",
                                    slug: UUID.init(),
                                    redirectTo: "https://google.com")
        },
        delete: { _ in
            return true
        }
    )
}
