import Dependencies
import Foundation

extension DependencyValues {
    var loadPhotos: LoadPhotosUseCase {
        get { self[LoadPhotosKey.self] }
        set { self[LoadPhotosKey.self] = newValue }
    }
}

private enum LoadPhotosKey: DependencyKey {
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

            func fetchPhotos(page: Int, perPage: Int) async throws -> [Photo] {
                return []
            }

            func searchPhotos(query: String, page: Int, perPage: Int) async throws -> [Photo] {
                return []
            }

//            func fetchPhotos() async throws -> [Photo] {
//                return try await fetchPhotos(page: 1)
//            }
//
//            func fetchPhotos(page: Int) async throws -> [Photo] {
//                // ダミーデータを返す
//                let allData = [
//                    Photo(id: "1", width: 1200, height: 1200, aspectRatio: 1, photographerName: "photographer1", photographerURL: URL(string: "")!, avgColorHex: "", urls: URLs(page: URL(string: "")!, small: URL(string: "")!, regular: URL(string: "")!, full: URL(string: "")!), alt: "", liked: false),
//
//                ]
//
//                return allData
//            }
        }

        return LoadPhotosUseCase(repository: StubPhotosRepository())
    }()
}
