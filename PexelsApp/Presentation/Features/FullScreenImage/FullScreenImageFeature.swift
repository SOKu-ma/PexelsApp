import ComposableArchitecture
import Foundation

@Reducer
struct FullScreenImageFeature {
    @ObservableState
    struct State: Equatable {
        var url: URL
        var isLoading: Bool = false
    }

    enum Action {
        case onAppear
        case photoLoaded
        case onDisappear
        case close
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .none

            case .photoLoaded:
                state.isLoading = false
                state.url = state.url
                return .none

            case .onDisappear:
                // Logic to handle when the view disappears
                state.isLoading = false
                return .none

            case .close:
                // Logic to close the full-screen image view
                return .none
            }
        }
    }
}
