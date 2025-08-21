import ComposableArchitecture

@Reducer
struct PhotosFeature {
    @Dependency(\.loadPhotos) private var loadPhotosUseCase

    @ObservableState
    struct State: Equatable {
        var photos: [Photo] = []
        var isLoading: Bool = false
        var isLoadingMore: Bool = false
        var searchText: String = ""
        var filterdPhotos: [Photo] = []
        var hasAppeared: Bool = false

        // 検索結果 or 通常のリストを表示するためのプロパティ
        var displayRows: [Photo] {
            searchText.isEmpty ? photos : filterdPhotos
        }
    }

    enum Action {
        case onAppear
        case loadPhotos
        case loadMorePhotos
        case photosLoaded([Photo])
        case photosLoadedMore([Photo])
        case searchPhotos(String)
        case photosSearched([Photo])
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard !state.isLoading else { return .none }

                // 初回のみ実行される条件をstore側で管理
                guard !state.hasAppeared && state.photos.isEmpty else { return .none }

                state.hasAppeared = true
                state.isLoading = true
                return .run { send in
                    do {
                        let list = try await loadPhotosUseCase()
                        await send(.photosLoaded(list))

                    } catch {
                        print("Error loading Photos: \(error)")
                    }
                }

            case .loadPhotos:
                return .none

            case .loadMorePhotos:
                guard !state.isLoadingMore else { return .none }

                state.isLoading = true
                state.isLoadingMore = true

                // 通常モード
                if state.searchText.isEmpty {
                    let nextPage = state.photos.count / 15 + 1
                    return .run { send in
                        do {
                            let list = try await loadPhotosUseCase(page: nextPage)
                            await send(.photosLoadedMore(list))
                        } catch {
                            print("Error loading more recruits: \(error)")
                        }
                    }
                } else {
                    // 検索モード
                    let nextPage = state.filterdPhotos.count / 15 + 1

                    let searchQuery = state.searchText
                    return .run { send in
                        do {
                            let list = try await loadPhotosUseCase.search(query: searchQuery, page: nextPage)
                            await send(.photosSearched(list))
                        } catch {
                            print("Failed to load more search results: \(error)")
                        }
                    }
                }

            case let .photosLoadedMore(list):
                state.isLoading = false
                state.isLoadingMore = false
                state.photos.append(contentsOf: list)
                return .none

            case let .photosLoaded(list):
                state.isLoading = false
                state.photos = list
                return .none

            case let .searchPhotos(query):
                if query.isEmpty {
                    // 検索テキストが空の場合は通常のリストに戻る
                    state.filterdPhotos = []
                    return .none
                }

                state.searchText = query
                state.isLoading = true

                let page = state.filterdPhotos.count / 15 + 1
                return .run { send in
                    do {
                        let list = try await loadPhotosUseCase.search(query: query, page: page)
                        await send(.photosSearched(list))
                    } catch {
                        print("Failed to search photos list: \(error)")
                    }
                }

            case let .photosSearched(result):
                state.isLoading = false
                state.isLoadingMore = false
                state.filterdPhotos = result
                return .none
            }
        }
    }
}
