import Foundation

public class PhotosRepositoryImpl: PhotosRepositoryProtocol {
    let apiClient: APIClientProtocol
    let mapper: PhotosMapper

    init(apiClient: APIClientProtocol, mapper: PhotosMapper) {
        self.apiClient = apiClient
        self.mapper = mapper
    }

    func fetchPhotos() async throws -> [Photo] {
        let response: SearchPhotosResponseDTO = try await apiClient.get(path: APIPath.popularPhotos)
        return response.photos.map { mapper.fromDetail($0) }
    }

    func fetchPhotos(page: Int, perPage: Int) async throws -> [Photo] {
        return []
    }

    func searchPhotos(query: String, page: Int, perPage: Int) async throws -> [Photo] {
        return []
    }
}
