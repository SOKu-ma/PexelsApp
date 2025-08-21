import Foundation
@testable import PexelsApp
import Testing

struct LoadPhotosUseCaseTests {
    // MARK: - Mock Repository

    actor MockPhotosRepository: PhotosRepositoryProtocol {
        private var fetchPhotosResult: Result<[Photo], Error> = .success([])
        private var fetchPhotosPageResult: Result<[Photo], Error> = .success([])
        private var searchPhotosResult: Result<[Photo], Error> = .success([])

        private var fetchPhotosCalls: [Void] = []
        private var fetchPhotosPageCalls: [Int] = []
        private var searchPhotosCalls: [(query: String, page: Int)] = []

        func setFetchPhotosResult(_ result: Result<[Photo], Error>) {
            fetchPhotosResult = result
        }

        func setFetchPhotosPageResult(_ result: Result<[Photo], Error>) {
            fetchPhotosPageResult = result
        }

        func setSearchPhotosResult(_ result: Result<[Photo], Error>) {
            searchPhotosResult = result
        }

        func getFetchPhotosCalls() -> [Void] {
            return fetchPhotosCalls
        }

        func getFetchPhotosPageCalls() -> [Int] {
            return fetchPhotosPageCalls
        }

        func getSearchPhotosCalls() -> [(query: String, page: Int)] {
            return searchPhotosCalls
        }

        func fetchPhotos() async throws -> [Photo] {
            fetchPhotosCalls.append(())
            switch fetchPhotosResult {
            case let .success(photos):
                return photos
            case let .failure(error):
                throw error
            }
        }

        func fetchPhotos(page: Int) async throws -> [Photo] {
            fetchPhotosPageCalls.append(page)
            switch fetchPhotosPageResult {
            case let .success(photos):
                return photos
            case let .failure(error):
                throw error
            }
        }

        func searchPhotos(query: String, page: Int) async throws -> [Photo] {
            searchPhotosCalls.append((query: query, page: page))
            switch searchPhotosResult {
            case let .success(photos):
                return photos
            case let .failure(error):
                throw error
            }
        }
    }

    // MARK: - Test Data

    private func createMockPhoto(id: Int = 1) -> Photo {
        Photo(
            id: id,
            width: 400,
            height: 600,
            aspectRatio: 400.0 / 600.0,
            photographerName: "Test Photographer",
            photographerURL: URL(string: "https://example.com/photographer")!,
            avgColorHex: "#FF0000",
            urls: Photo.URLs(
                original: URL(string: "https://example.com/original")!,
                large: URL(string: "https://example.com/large")!,
                large2x: URL(string: "https://example.com/large2x")!,
                medium: URL(string: "https://example.com/medium")!,
                small: URL(string: "https://example.com/small")!,
                portrait: URL(string: "https://example.com/portrait")!,
                landscape: URL(string: "https://example.com/landscape")!,
                tiny: URL(string: "https://example.com/tiny")!
            ),
            alt: "Test Photo",
            liked: false
        )
    }

    // MARK: - Tests

    @Test("UseCaseが写真の取得に成功する")
    func fetchPhotosSuccess() async throws {
        let mockRepository = MockPhotosRepository()
        let mockPhotos = [createMockPhoto(id: 1), createMockPhoto(id: 2)]
        await mockRepository.setFetchPhotosResult(.success(mockPhotos))

        let useCase = LoadPhotosUseCase(repository: mockRepository)

        let result = try await useCase()

        #expect(result.count == 2)
        #expect(result.first?.id == 1)
        #expect(result.last?.id == 2)

        let calls = await mockRepository.getFetchPhotosCalls()
        #expect(calls.count == 1)
    }

    @Test("UseCaseが写真の取得エラーを処理する")
    func fetchPhotosError() async throws {
        let mockRepository = MockPhotosRepository()
        let expectedError = NSError(domain: "TestError", code: 404, userInfo: nil)
        await mockRepository.setFetchPhotosResult(.failure(expectedError))

        let useCase = LoadPhotosUseCase(repository: mockRepository)

        await #expect(throws: Error.self) {
            try await useCase()
        }

        let calls = await mockRepository.getFetchPhotosCalls()
        #expect(calls.count == 1)
    }

    @Test("UseCaseがページ指定で写真の取得に成功する")
    func fetchPhotosWithPageSuccess() async throws {
        let mockRepository = MockPhotosRepository()
        let mockPhotos = [createMockPhoto(id: 3), createMockPhoto(id: 4)]
        await mockRepository.setFetchPhotosPageResult(.success(mockPhotos))

        let useCase = LoadPhotosUseCase(repository: mockRepository)

        let result = try await useCase(page: 2)

        #expect(result.count == 2)
        #expect(result.first?.id == 3)
        #expect(result.last?.id == 4)

        let calls = await mockRepository.getFetchPhotosPageCalls()
        #expect(calls.count == 1)
        #expect(calls.first == 2)
    }

    @Test("UseCaseがページ指定での写真取得エラーを処理する")
    func fetchPhotosWithPageError() async throws {
        let mockRepository = MockPhotosRepository()
        let expectedError = NSError(domain: "TestError", code: 500, userInfo: nil)
        await mockRepository.setFetchPhotosPageResult(.failure(expectedError))

        let useCase = LoadPhotosUseCase(repository: mockRepository)

        await #expect(throws: Error.self) {
            try await useCase(page: 2)
        }

        let calls = await mockRepository.getFetchPhotosPageCalls()
        #expect(calls.count == 1)
        #expect(calls.first == 2)
    }

    @Test("UseCaseが写真の検索に成功する")
    func searchPhotosSuccess() async throws {
        let mockRepository = MockPhotosRepository()
        let mockPhotos = [createMockPhoto(id: 5), createMockPhoto(id: 6)]
        await mockRepository.setSearchPhotosResult(.success(mockPhotos))

        let useCase = LoadPhotosUseCase(repository: mockRepository)

        let result = try await useCase.search(query: "nature", page: 1)

        #expect(result.count == 2)
        #expect(result.first?.id == 5)
        #expect(result.last?.id == 6)

        let calls = await mockRepository.getSearchPhotosCalls()
        #expect(calls.count == 1)
        #expect(calls.first?.query == "nature")
        #expect(calls.first?.page == 1)
    }

    @Test("UseCaseが写真の検索エラーを処理する")
    func searchPhotosError() async throws {
        let mockRepository = MockPhotosRepository()
        let expectedError = NSError(domain: "TestError", code: 400, userInfo: nil)
        await mockRepository.setSearchPhotosResult(.failure(expectedError))

        let useCase = LoadPhotosUseCase(repository: mockRepository)

        await #expect(throws: Error.self) {
            try await useCase.search(query: "nature", page: 1)
        }

        let calls = await mockRepository.getSearchPhotosCalls()
        #expect(calls.count == 1)
        #expect(calls.first?.query == "nature")
        #expect(calls.first?.page == 1)
    }
}
