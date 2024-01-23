import Foundation

class CurrentUser: ObservableObject {
    let isLoggedIn: Bool
    let accessToken: String
    let email: String

    init(isLoggedIn: Bool, accessToken: String, email: String) {
        self.isLoggedIn = isLoggedIn
        self.accessToken = accessToken
        self.email = email
    }
}
