import Dependencies
import Foundation

extension DependencyValues {
    var loadMorePhotos: LoadPhotosUseCase {
        get { self[LoadMorePhotosKey.self] }
        set { self[LoadMorePhotosKey.self] = newValue }
    }
}

private enum LoadMorePhotosKey: DependencyKey {
    static let liveValue: LoadPhotosUseCase = {
        let apiClient = APIClient(baseURL: URL(string: APIEndpoints.baseURL)!)
        let repository = PhotosRepositoryImpl(apiClient: apiClient, mapper: PhotosMapper())
        return LoadPhotosUseCase(repository: repository)
    }()

    static let previewValue: LoadPhotosUseCase = {
        class StubPhotosRepository: PhotosRepositoryProtocol {
            func fetchPhotos() async throws -> [Photo] {
                return []
            }

            func fetchPhotos(page: Int) async throws -> [Photo] {
                return []
            }

            func searchPhotos(query: String, page: Int) async throws -> [Photo] {
                return []
            }
        }

        return LoadPhotosUseCase(repository: StubPhotosRepository())
    }()
}
