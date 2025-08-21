public struct LoadPhotosUseCase {
    let repository: PhotosRepositoryProtocol

    init(repository: PhotosRepositoryProtocol) {
        self.repository = repository
    }

    // 写真一覧を取得する
    public func callAsFunction() async throws -> [Photo] {
        try await repository.fetchPhotos()
    }

    // 写真一覧をページネーションで取得する
    public func callAsFunction(page: Int) async throws -> [Photo] {
        try await repository.fetchPhotos(page: page)
    }

    // 写真を検索する
    public func search(query: String, page: Int) async throws -> [Photo] {
        try await repository.searchPhotos(query: query, page: page)
    }
}
