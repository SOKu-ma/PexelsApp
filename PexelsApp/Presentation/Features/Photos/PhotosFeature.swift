import ComposableArchitecture

@Reducer
struct PhotosFeature {
    @Dependency(\.loadPhotos) private var loadPhotosUseCase

    @ObservableState
    struct State: Equatable {
        var photos: [Photo] = []
        var isLoading: Bool = false
        var searchText: String = ""
    }

    enum Action {
        case onAppear
        case loadPhotos
        case photosLoaded([Photo])
        case searchPhotos(String)
        case photosSearched([Photo])
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
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

            case .loadPhotos:
                return .none

            case let .photosLoaded(list):
                state.isLoading = false
                state.photos = list
                return .none

            case let .searchPhotos(query):
                return .none

            case let .photosSearched(result):
                return .none
            }
        }
    }
}
