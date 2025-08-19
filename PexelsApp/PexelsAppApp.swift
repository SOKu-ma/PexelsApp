import ComposableArchitecture
import SwiftUI

@main
struct PexelsAppApp: App {
    var body: some Scene {
        WindowGroup {
            PhotosView(
                store: Store(initialState: PhotosFeature.State()) {
                    PhotosFeature()
                }
            )
        }
    }
}
