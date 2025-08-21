protocol PhotosRepositoryProtocol {
    func fetchPhotos() async throws -> [Photo]
    func fetchPhotos(page: Int) async throws -> [Photo]
    func searchPhotos(query: String, page: Int) async throws -> [Photo]
}
