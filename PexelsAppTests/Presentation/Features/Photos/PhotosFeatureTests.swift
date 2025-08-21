import ComposableArchitecture
import Foundation
@testable import PexelsApp
import Testing

struct PhotosFeatureTests {
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

    // MARK: - State Tests

    @Test("初期状態が正しいデフォルト値を持つ")
    func testInitialState() {
        let state = PhotosFeature.State()

        #expect(state.photos.isEmpty)
        #expect(state.isLoading == false)
        #expect(state.isLoadingMore == false)
        #expect(state.searchText.isEmpty)
        #expect(state.filterdPhotos.isEmpty)
        #expect(state.hasAppeared == false)
        #expect(state.displayMode == .singleColumn)
        #expect(state.displayRows.isEmpty)
    }

    @Test("検索テキストが空の場合、displayRowsが写真を返す")
    func displayRowsWithEmptySearch() {
        var state = PhotosFeature.State()
        let mockPhotos = [createMockPhoto(id: 1), createMockPhoto(id: 2)]
        state.photos = mockPhotos

        #expect(state.displayRows.count == 2)
        #expect(state.displayRows == mockPhotos)
    }

    @Test("検索テキストが空でない場合、displayRowsがフィルタリングされた写真を返す")
    func displayRowsWithSearch() {
        var state = PhotosFeature.State()
        let mockPhotos = [createMockPhoto(id: 1), createMockPhoto(id: 2)]
        let mockFilteredPhotos = [createMockPhoto(id: 3)]

        state.photos = mockPhotos
        state.filterdPhotos = mockFilteredPhotos
        state.searchText = "nature"

        #expect(state.displayRows.count == 1)
        #expect(state.displayRows == mockFilteredPhotos)
    }

    // MARK: - Reducer Tests

    @Test("初回表示時にOnAppearが写真を読み込む")
    func onAppearFirstTime() async {
        let mockPhotos = [createMockPhoto(id: 1), createMockPhoto(id: 2)]

        let store = await TestStore(initialState: PhotosFeature.State()) {
            PhotosFeature()
        } withDependencies: {
            $0.loadPhotos = LoadPhotosUseCase(repository: MockRepository(photos: mockPhotos))
        }

        await store.send(.onAppear) {
            $0.hasAppeared = true
            $0.isLoading = true
        }

        await store.receive(\.photosLoaded) {
            $0.isLoading = false
            $0.photos = mockPhotos
        }
    }

    @Test("既に表示済みで写真がある場合、OnAppearが写真を読み込まない")
    func onAppearAlreadyAppeared() async {
        var initialState = PhotosFeature.State()
        initialState.hasAppeared = true
        initialState.photos = [createMockPhoto(id: 1)]

        let store = await TestStore(initialState: initialState) {
            PhotosFeature()
        }

        await store.send(.onAppear)
        // No state changes expected
    }

    @Test("読み込み中にOnAppearが写真を読み込まない")
    func onAppearWhileLoading() async {
        var initialState = PhotosFeature.State()
        initialState.isLoading = true

        let store = await TestStore(initialState: initialState) {
            PhotosFeature()
        }

        await store.send(.onAppear)
        // No state changes expected
    }

    @Test("LoadPhotosが写真の取得に成功する")
    func loadPhotosSuccess() async {
        let mockPhotos = [createMockPhoto(id: 1), createMockPhoto(id: 2)]

        let store = await TestStore(initialState: PhotosFeature.State()) {
            PhotosFeature()
        } withDependencies: {
            $0.loadPhotos = LoadPhotosUseCase(repository: MockRepository(photos: mockPhotos))
        }

        await store.send(.loadPhotos) {
            $0.isLoading = true
        }

        await store.receive(\.photosLoaded) {
            $0.isLoading = false
            $0.photos = mockPhotos
        }
    }

    @Test("読み込み中にLoadPhotosが実行されない")
    func loadPhotosWhileLoading() async {
        var initialState = PhotosFeature.State()
        initialState.isLoading = true

        let store = await TestStore(initialState: initialState) {
            PhotosFeature()
        }

        await store.send(.loadPhotos)
        // No state changes expected
    }

    @Test("通常モードでLoadMorePhotosがより多くの写真を取得する")
    func loadMorePhotosNormalMode() async {
        let existingPhotos = Array(1 ... 15).map { createMockPhoto(id: $0) }
        let newPhotos = Array(16 ... 30).map { createMockPhoto(id: $0) }

        var initialState = PhotosFeature.State()
        initialState.photos = existingPhotos

        let store = await TestStore(initialState: initialState) {
            PhotosFeature()
        } withDependencies: {
            $0.loadPhotos = LoadPhotosUseCase(repository: MockRepository(photosPage: newPhotos))
        }

        await store.send(.loadMorePhotos) {
            $0.isLoadingMore = true
        }

        await store.receive(\.photosLoadedMore) {
            $0.isLoadingMore = false
            $0.photos.append(contentsOf: newPhotos)
        }
    }

    @Test("検索モードでLoadMorePhotosがより多くの検索結果を取得する")
    func loadMorePhotosSearchMode() async {
        let existingSearchResults = Array(1 ... 15).map { createMockPhoto(id: $0) }
        let newSearchResults = Array(16 ... 30).map { createMockPhoto(id: $0) }

        var initialState = PhotosFeature.State()
        initialState.searchText = "nature"
        initialState.filterdPhotos = existingSearchResults

        let store = await TestStore(initialState: initialState) {
            PhotosFeature()
        } withDependencies: {
            $0.loadPhotos = LoadPhotosUseCase(repository: MockRepository(searchResults: newSearchResults))
        }

        await store.send(.loadMorePhotos) {
            $0.isLoadingMore = true
        }

        await store.receive(\.photosSearchedMore) {
            $0.isLoadingMore = false
            $0.filterdPhotos.append(contentsOf: newSearchResults)
        }
    }

    @Test("追加読み込み中にLoadMorePhotosが実行されない")
    func loadMorePhotosWhileLoadingMore() async {
        var initialState = PhotosFeature.State()
        initialState.isLoadingMore = true

        let store = await TestStore(initialState: initialState) {
            PhotosFeature()
        }

        await store.send(.loadMorePhotos)
        // No state changes expected
    }

    @Test("クエリが空の場合、SearchPhotosがフィルタリングされた写真をクリアする")
    func searchPhotosEmptyQuery() async {
        var initialState = PhotosFeature.State()
        initialState.filterdPhotos = [createMockPhoto(id: 1)]

        let store = await TestStore(initialState: initialState) {
            PhotosFeature()
        }

        await store.send(.searchPhotos("")) {
            $0.searchText = ""
            $0.filterdPhotos = []
        }
    }

    @Test("クエリありでSearchPhotosが検索を実行する")
    func searchPhotosWithQuery() async {
        let searchResults = [createMockPhoto(id: 1), createMockPhoto(id: 2)]

        let store = await TestStore(initialState: PhotosFeature.State()) {
            PhotosFeature()
        } withDependencies: {
            $0.loadPhotos = LoadPhotosUseCase(repository: MockRepository(searchResults: searchResults))
        }

        await store.send(.searchPhotos("nature")) {
            $0.searchText = "nature"
            $0.filterdPhotos = []
            $0.isLoading = true
        }

        await store.receive(\.photosSearched) {
            $0.isLoading = false
            $0.isLoadingMore = false
            $0.filterdPhotos = searchResults
        }
    }

    @Test("ToggleDisplayModeが単列と複列を切り替える")
    func testToggleDisplayMode() async {
        let store = await TestStore(initialState: PhotosFeature.State()) {
            PhotosFeature()
        }

        await #expect(store.state.displayMode == .singleColumn)

        await store.send(.toggleDisplayMode) {
            $0.displayMode = .doubleColumn
        }

        await store.send(.toggleDisplayMode) {
            $0.displayMode = .singleColumn
        }
    }

    @Test("PhotosLoadedが状態を正しく更新する")
    func testPhotosLoaded() async {
        let mockPhotos = [createMockPhoto(id: 1), createMockPhoto(id: 2)]
        var initialState = PhotosFeature.State()
        initialState.isLoading = true

        let store = await TestStore(initialState: initialState) {
            PhotosFeature()
        }

        await store.send(.photosLoaded(mockPhotos)) {
            $0.isLoading = false
            $0.photos = mockPhotos
        }
    }

    @Test("PhotosLoadedMoreが写真を正しく追加する")
    func testPhotosLoadedMore() async {
        let existingPhotos = [createMockPhoto(id: 1)]
        let newPhotos = [createMockPhoto(id: 2), createMockPhoto(id: 3)]

        var initialState = PhotosFeature.State()
        initialState.photos = existingPhotos
        initialState.isLoadingMore = true

        let store = await TestStore(initialState: initialState) {
            PhotosFeature()
        }

        await store.send(.photosLoadedMore(newPhotos)) {
            $0.isLoadingMore = false
            $0.photos.append(contentsOf: newPhotos)
        }

        await #expect(store.state.photos.count == 3)
    }

    @Test("PhotosSearchedがフィルタリングされた写真を更新する")
    func testPhotosSearched() async {
        let searchResults = [createMockPhoto(id: 1), createMockPhoto(id: 2)]
        var initialState = PhotosFeature.State()
        initialState.isLoading = true
        initialState.isLoadingMore = true

        let store = await TestStore(initialState: initialState) {
            PhotosFeature()
        }

        await store.send(.photosSearched(searchResults)) {
            $0.isLoading = false
            $0.isLoadingMore = false
            $0.filterdPhotos = searchResults
        }
    }

    @Test("PhotosSearchedMoreがフィルタリングされた写真に追加する")
    func testPhotosSearchedMore() async {
        let existingResults = [createMockPhoto(id: 1)]
        let newResults = [createMockPhoto(id: 2), createMockPhoto(id: 3)]

        var initialState = PhotosFeature.State()
        initialState.filterdPhotos = existingResults
        initialState.isLoadingMore = true

        let store = await TestStore(initialState: initialState) {
            PhotosFeature()
        }

        await store.send(.photosSearchedMore(newResults)) {
            $0.isLoadingMore = false
            $0.filterdPhotos.append(contentsOf: newResults)
        }

        await #expect(store.state.filterdPhotos.count == 3)
    }
}

// MARK: - Mock Repository for Testing

private class MockRepository: PhotosRepositoryProtocol {
    private let photos: [Photo]
    private let photosPage: [Photo]
    private let searchResults: [Photo]

    init(photos: [Photo] = [], photosPage: [Photo] = [], searchResults: [Photo] = []) {
        self.photos = photos
        self.photosPage = photosPage
        self.searchResults = searchResults
    }

    func fetchPhotos() async throws -> [Photo] {
        return photos
    }

    func fetchPhotos(page: Int) async throws -> [Photo] {
        return photosPage
    }

    func searchPhotos(query: String, page: Int) async throws -> [Photo] {
        return searchResults
    }
}
