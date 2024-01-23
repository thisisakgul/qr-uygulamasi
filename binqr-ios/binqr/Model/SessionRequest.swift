import Foundation

struct SessionRequest: Encodable {
    var code: String
    var provider: String = "apple"
}
