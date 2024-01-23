import Foundation
import ComposableArchitecture

class AuthService {
    @Published var currentUser: CurrentUser
    
    static let shared = AuthService()
    
    init() {
        self.currentUser = CurrentUser(isLoggedIn: false, accessToken: "", email: "")
        Task(priority: .high) {
            await self.me()
        }
    }
    
    @Dependency(\.sessionClient) var sessionClient
    @Dependency(\.keyChainService) var keyChainService
    
    @MainActor
    func loginWithApple(_ token: String) async -> Bool {
        do {
            let response = try await self.sessionClient.login(SessionRequest(code: token))
            _ = try await self.keyChainService.add(response)
            let user = try await self.sessionClient.me(response.token)
            
            self.currentUser = self.currentUserWithToken(response.token, email: user.email)
        } catch {
            self.currentUser = self.emptyCurrentUser()
            return false
        }
        
        return true
    }
    
    @MainActor
    func logout() async -> Bool {
        do {
            _ = try await self.sessionClient.logout(self.currentUser.accessToken)
            _ = try await self.keyChainService.destroy()
            
        } catch {
        }
        
        self.currentUser = self.emptyCurrentUser()
        return true
    }
    
    @MainActor
    func me() async -> Bool {
        do {
            let token = try await self.keyChainService.get()
            let user = try await self.sessionClient.me(token)

            self.currentUser = self.currentUserWithToken(token, email: user.email)
        } catch {
            self.currentUser = self.emptyCurrentUser()
            return false
        }
        
        return true
    }
    
    private func emptyCurrentUser() -> CurrentUser {
        return CurrentUser(isLoggedIn: false, accessToken: "", email: "")
    }
    
    private func currentUserWithToken(_ accessToken: String, email: String) -> CurrentUser {
        return CurrentUser(isLoggedIn: true, accessToken: accessToken, email: email)
    }
}
