import Foundation

struct APIClient: APIClientProtocol {
    func get<T>(path: String) async throws -> T where T: Decodable {
        try await get(path: path, queryItems: [])
    }

    let baseURL: URL
    private let apiKey: String

    init(baseURL: URL = URL(string: APIEndpoints.baseURL)!, apiKey: String = (Bundle.main.object(forInfoDictionaryKey: "PEXELS_API_KEY") as? String) ?? "") {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }

    func get<T: Decodable>(path: String, queryItems: [URLQueryItem] = []) async throws -> T {
        // baseURL + path + query の組み立て
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems.isEmpty ? nil : queryItems

        guard let url = components?.url else {
            throw URLError(.badURL)
        }

        // Request 作成
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")

//        print("Request URL: \(url)")
//        print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
//        print("apiKey: \(apiKey)")

        // 通信
        let (data, response) = try await URLSession.shared.data(for: request)
//        print(String(data: data, encoding: .utf8) ?? "non-utf8")

        // ステータスコードチェック
        guard let http = response as? HTTPURLResponse,
              (200 ..< 300).contains(http.statusCode)
        else {
            print("Bad Server Response - Status Code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            throw URLError(.badServerResponse)
        }

        // デコード
        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            throw error
        }
    }
}

// import Foundation
//
// struct APIClient: APIClientProtocol {
//    let baseURL: String
//
//    init(baseURL: String = APIEndpoints.baseURL) {
//        self.baseURL = baseURL
//    }
//
//    func get<T: Decodable>(path: String) async throws -> T {
//        guard let url = URL(string: path) else {
//            throw URLError(.badURL)
//        }
//
//        let (data, response) = try await URLSession.shared.data(from: url)
//
//        guard let http = response as? HTTPURLResponse, (200 ..< 300).contains(http.statusCode) else {
//            print("Bad Server Response - Status Code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
//            throw URLError(.badServerResponse)
//        }
//
//        let decoder = JSONDecoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//        do {
//            return try decoder.decode(T.self, from: data)
//        } catch {
//            print("Decoding error: \(error)")
//            throw error
//        }
//    }
// }
