import Foundation
import Dependencies

struct KeyChainService {
    var add: @Sendable (SessionResponse) async throws -> Bool
    var get: @Sendable () async throws -> String
    var destroy: @Sendable () async throws -> Bool
}

extension DependencyValues {
    var keyChainService: KeyChainService {
        get { self[KeyChainService.self] }
        set { self[KeyChainService.self] = newValue }
    }
}

extension KeyChainService: DependencyKey {
    static let liveValue = Self(
        add: { session in
            let accessToken = session.token.data(using: .utf8)!
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "accessTokenAccount",
                kSecValueData as String: accessToken,
                kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
            ]

            var status = SecItemAdd(query as CFDictionary, nil)
            if status == errSecDuplicateItem {
                status = SecItemUpdate(query as CFDictionary, [kSecValueData as String: accessToken] as CFDictionary)
            }
            guard status == errSecSuccess else { return false }
            return true
        },
        get: {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "accessTokenAccount",
                kSecReturnData as String: kCFBooleanTrue!,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]

            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            guard status == errSecSuccess, let data = item as? Data, let retrievedToken = String(data: data, encoding: .utf8) else {
                return "NO_TOKEN_FOUND"
            }

            return retrievedToken
        },
        destroy: {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: "accessTokenAccount"
            ]

            let destroyStatus = SecItemDelete(query as CFDictionary)

            guard destroyStatus == errSecSuccess else {
                return false
            }

            return true
        }
    )

    static let testValue = Self(
        add: { key in
            return true
        },
        get: {
            return "key"
        },
        destroy: {
            return true
        }
    )
}
