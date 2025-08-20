import ComposableArchitecture
import SwiftUI

struct FullScreenImageView: View {
    let store: StoreOf<FullScreenImageFeature>

    var body: some View {
        ZStack {
            GeometryReader { proxy in
                AsyncImage(url: store.url) { image in
                    image.resizable()
                        .resizable()
                        .scaledToFill()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                } placeholder: {
                    ProgressView()
                }
            }.ignoresSafeArea()
        }
    }
}
