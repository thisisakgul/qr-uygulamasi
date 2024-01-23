struct ServiceResponse<T : Codable> : Codable {
    let data: T
}
