import ComposableArchitecture

@Reducer
struct PhotosFeature {
    @Dependency(\.loadPhotos) private var loadPhotosUseCase

    enum DisplayMode: Equatable {
        case singleColumn
        case doubleColumn
    }

    @ObservableState
    struct State: Equatable {
        var photos: [Photo] = []
        var isLoading: Bool = false
        var isLoadingMore: Bool = false
        var searchText: String = ""
        var filterdPhotos: [Photo] = []
        var hasAppeared: Bool = false
        var displayMode: DisplayMode = .singleColumn

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
        case photosSearchedMore([Photo])
        case toggleDisplayMode
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
                guard !state.isLoading else { return .none }

                state.isLoading = true
                return .run { send in
                    do {
                        let list = try await loadPhotosUseCase()
                        await send(.photosLoaded(list))
                    } catch {
                        print("Error loading Photos: \(error)")
                    }
                }

            case .loadMorePhotos:
                guard !state.isLoadingMore && !state.isLoading else { return .none }

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
                            await send(.photosSearchedMore(list))
                        } catch {
                            print("Failed to load more search results: \(error)")
                        }
                    }
                }

            case let .photosLoadedMore(list):
                state.isLoadingMore = false
                state.photos.append(contentsOf: list)
                return .none

            case let .photosLoaded(list):
                state.isLoading = false
                state.photos = list
                return .none

            case let .searchPhotos(query):
                state.searchText = query

                if query.isEmpty {
                    // 検索テキストが空の場合は通常のリストに戻る
                    state.filterdPhotos = []
                    return .none
                }

                // 検索時は既存の結果をクリアしてからローディング開始
                state.filterdPhotos = []
                state.isLoading = true

                return .run { send in
                    do {
                        let list = try await loadPhotosUseCase.search(query: query, page: 1)
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

            case let .photosSearchedMore(result):
                state.isLoadingMore = false
                state.filterdPhotos.append(contentsOf: result)
                return .none

            case .toggleDisplayMode:
                state.displayMode = state.displayMode == .singleColumn ? .doubleColumn : .singleColumn
                return .none
            }
        }
    }
}
