import Foundation

protocol APIClientProtocol {
    func get<T: Decodable>(path: String) async throws -> T
    func get<T: Decodable>(path: String, queryItems: [URLQueryItem]) async throws -> T
}
