import Foundation
@testable import PexelsApp
import Testing

struct PhotosRepositoryImplTests {
    // MARK: - Mock API Client

    actor MockAPIClient: APIClientProtocol {
        private var getResult: Result<Any, Error> = .success(())
        private var getCalls: [(path: String, queryItems: [URLQueryItem]?)] = []

        func setGetResult<T: Decodable>(_ result: Result<T, Error>) {
            getResult = result.map { $0 as Any }
        }
        
        func setGetFailure(_ error: Error) {
            getResult = .failure(error)
        }

        func getGetCalls() -> [(path: String, queryItems: [URLQueryItem]?)] {
            return getCalls
        }

        func get<T: Decodable>(path: String) async throws -> T {
            getCalls.append((path: path, queryItems: nil))
            switch getResult {
            case let .success(data):
                if let typedData = data as? T {
                    return typedData
                } else {
                    throw NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Type mismatch"])
                }
            case let .failure(error):
                throw error
            }
        }

        func get<T: Decodable>(path: String, queryItems: [URLQueryItem]) async throws -> T {
            getCalls.append((path: path, queryItems: queryItems))
            switch getResult {
            case let .success(data):
                if let typedData = data as? T {
                    return typedData
                } else {
                    throw NSError(domain: "MockError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Type mismatch"])
                }
            case let .failure(error):
                throw error
            }
        }
    }

    // MARK: - Test Data

    private func createMockPhotoDTO(id: Int = 1) -> PhotoDTO {
        PhotoDTO(
            id: id,
            width: 400,
            height: 600,
            url: URL(string: "https://example.com/photo")!,
            photographer: "Test Photographer",
            photographerURL: URL(string: "https://example.com/photographer")!,
            photographerID: 123,
            avgColorHex: "#FF0000",
            src: SrcDTO(
                original: URL(string: "https://example.com/original")!,
                large2x: URL(string: "https://example.com/large2x")!,
                large: URL(string: "https://example.com/large")!,
                medium: URL(string: "https://example.com/medium")!,
                small: URL(string: "https://example.com/small")!,
                portrait: URL(string: "https://example.com/portrait")!,
                landscape: URL(string: "https://example.com/landscape")!,
                tiny: URL(string: "https://example.com/tiny")!
            ),
            liked: false,
            alt: "Test Photo"
        )
    }

    private func createMockSearchResponse(photos: [PhotoDTO]) -> SearchPhotosResponseDTO {
        SearchPhotosResponseDTO(
            page: 1,
            perPage: 15,
            photos: photos,
            totalResults: photos.count,
            nextPage: nil
        )
    }

    // MARK: - Tests

    @Test("リポジトリが写真の取得に成功する")
    func fetchPhotosSuccess() async throws {
        let mockAPIClient = MockAPIClient()
        let mapper = PhotosMapper()
        let repository = PhotosRepositoryImpl(apiClient: mockAPIClient, mapper: mapper)

        let mockPhotoDTOs = [createMockPhotoDTO(id: 1), createMockPhotoDTO(id: 2)]
        let mockResponse = createMockSearchResponse(photos: mockPhotoDTOs)
        await mockAPIClient.setGetResult(.success(mockResponse))

        let result = try await repository.fetchPhotos()

        #expect(result.count == 2)
        #expect(result.first?.id == 1)
        #expect(result.last?.id == 2)
        #expect(result.first?.photographerName == "Test Photographer")
        #expect(result.first?.aspectRatio == 400.0 / 600.0)

        let calls = await mockAPIClient.getGetCalls()
        #expect(calls.count == 1)
        #expect(calls.first?.path == APIPath.popularPhotos)
        #expect(calls.first?.queryItems == nil)
    }

    @Test("リポジトリが写真の取得エラーを処理する")
    func fetchPhotosError() async throws {
        let mockAPIClient = MockAPIClient()
        let mapper = PhotosMapper()
        let repository = PhotosRepositoryImpl(apiClient: mockAPIClient, mapper: mapper)

        let expectedError = NSError(domain: "NetworkError", code: 404, userInfo: nil)
        await mockAPIClient.setGetFailure(expectedError)

        await #expect(throws: Error.self) {
            try await repository.fetchPhotos()
        }

        let calls = await mockAPIClient.getGetCalls()
        #expect(calls.count == 1)
    }

    @Test("リポジトリがページ指定で写真の取得に成功する")
    func fetchPhotosWithPageSuccess() async throws {
        let mockAPIClient = MockAPIClient()
        let mapper = PhotosMapper()
        let repository = PhotosRepositoryImpl(apiClient: mockAPIClient, mapper: mapper)

        let mockPhotoDTOs = [createMockPhotoDTO(id: 3), createMockPhotoDTO(id: 4)]
        let mockResponse = createMockSearchResponse(photos: mockPhotoDTOs)
        await mockAPIClient.setGetResult(.success(mockResponse))

        let result = try await repository.fetchPhotos(page: 2)

        #expect(result.count == 2)
        #expect(result.first?.id == 3)
        #expect(result.last?.id == 4)

        let calls = await mockAPIClient.getGetCalls()
        #expect(calls.count == 1)
        #expect(calls.first?.path == APIPath.popularPhotos)
        #expect(calls.first?.queryItems?.first?.name == "page")
        #expect(calls.first?.queryItems?.first?.value == "2")
    }

    @Test("リポジトリが写真の検索に成功する")
    func searchPhotosSuccess() async throws {
        let mockAPIClient = MockAPIClient()
        let mapper = PhotosMapper()
        let repository = PhotosRepositoryImpl(apiClient: mockAPIClient, mapper: mapper)

        let mockPhotoDTOs = [createMockPhotoDTO(id: 5), createMockPhotoDTO(id: 6)]
        let mockResponse = createMockSearchResponse(photos: mockPhotoDTOs)
        await mockAPIClient.setGetResult(.success(mockResponse))

        let result = try await repository.searchPhotos(query: "nature", page: 1)

        #expect(result.count == 2)
        #expect(result.first?.id == 5)
        #expect(result.last?.id == 6)

        let calls = await mockAPIClient.getGetCalls()
        #expect(calls.count == 1)
        #expect(calls.first?.path == APIPath.searchPhotos)

        let queryItems = calls.first?.queryItems ?? []
        let queryParam = queryItems.first { $0.name == "query" }
        let pageParam = queryItems.first { $0.name == "page" }

        #expect(queryParam?.value == "nature")
        #expect(pageParam?.value == "1")
    }

    @Test("リポジトリが写真の検索エラーを処理する")
    func searchPhotosError() async throws {
        let mockAPIClient = MockAPIClient()
        let mapper = PhotosMapper()
        let repository = PhotosRepositoryImpl(apiClient: mockAPIClient, mapper: mapper)

        let expectedError = NSError(domain: "NetworkError", code: 500, userInfo: nil)
        await mockAPIClient.setGetFailure(expectedError)

        await #expect(throws: Error.self) {
            try await repository.searchPhotos(query: "nature", page: 1)
        }

        let calls = await mockAPIClient.getGetCalls()
        #expect(calls.count == 1)
    }

    @Test("リポジトリがDTOからドメインモデルへの変換を正しく行う")
    func dTOMapping() async throws {
        let mockAPIClient = MockAPIClient()
        let mapper = PhotosMapper()
        let repository = PhotosRepositoryImpl(apiClient: mockAPIClient, mapper: mapper)

        let mockPhotoDTO = PhotoDTO(
            id: 999,
            width: 1920,
            height: 1080,
            url: URL(string: "https://example.com/photo")!,
            photographer: "John Doe",
            photographerURL: URL(string: "https://example.com/john")!,
            photographerID: 456,
            avgColorHex: "#00FF00",
            src: SrcDTO(
                original: URL(string: "https://example.com/original")!,
                large2x: URL(string: "https://example.com/large2x")!,
                large: URL(string: "https://example.com/large")!,
                medium: URL(string: "https://example.com/medium")!,
                small: URL(string: "https://example.com/small")!,
                portrait: URL(string: "https://example.com/portrait")!,
                landscape: URL(string: "https://example.com/landscape")!,
                tiny: URL(string: "https://example.com/tiny")!
            ),
            liked: true,
            alt: "Beautiful Photo"
        )

        let mockResponse = createMockSearchResponse(photos: [mockPhotoDTO])
        await mockAPIClient.setGetResult(.success(mockResponse))

        let result = try await repository.fetchPhotos()

        #expect(result.count == 1)
        let photo = result.first!

        #expect(photo.id == 999)
        #expect(photo.width == 1920)
        #expect(photo.height == 1080)
        #expect(photo.aspectRatio == 1920.0 / 1080.0)
        #expect(photo.photographerName == "John Doe")
        #expect(photo.photographerURL.absoluteString == "https://example.com/john")
        #expect(photo.avgColorHex == "#00FF00")
        #expect(photo.alt == "Beautiful Photo")
        #expect(photo.liked == true)

        // Test URL mapping
        #expect(photo.urls.original.absoluteString == "https://example.com/original")
        #expect(photo.urls.large.absoluteString == "https://example.com/large")
        #expect(photo.urls.medium.absoluteString == "https://example.com/medium")
        #expect(photo.urls.small.absoluteString == "https://example.com/small")
    }
}
