protocol PhotosRepositoryProtocol {
    func fetchPhotos() async throws -> [Photo]
    func fetchPhotos(page: Int, perPage: Int) async throws -> [Photo]
    func searchPhotos(query: String, page: Int, perPage: Int) async throws -> [Photo]
}
