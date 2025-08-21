import Kingfisher
import SwiftUI

struct PhotoRowView: View {
    let photo: Photo

    private var imageWidth: CGFloat {
        UIScreen.main.bounds.width
    }

    private var imageHeight: CGFloat {
        imageWidth / photo.aspectRatio
    }

    private var optimizedImageURL: URL {
        let screenScale = UIScreen.main.scale
        let requiredWidth = imageWidth * screenScale

        // 必要な幅に応じて適切なサイズを選択
        if requiredWidth <= 350 {
            return photo.urls.small
        } else if requiredWidth <= 640 {
            return photo.urls.medium
        } else if requiredWidth <= 940 {
            return photo.urls.large
        } else {
            return photo.urls.large2x
        }
    }

    var body: some View {
        KFImage(optimizedImageURL)
            .placeholder {
                Rectangle()
                    .fill(Color(photo.avgColorHex!))
                    .frame(width: imageWidth, height: imageHeight)
                    .overlay {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
            }
            .loadDiskFileSynchronously()
            .cacheMemoryOnly(false)
            .fade(duration: 0.25)
            .resizable()
            .aspectRatio(photo.aspectRatio, contentMode: .fit)
            .frame(width: imageWidth, height: imageHeight)
            .clipped()
    }
}

#Preview {
    PhotoRowView(photo: Photo(id: 1, width: 200, height: 200, aspectRatio: 1.0, photographerName: "Test", photographerURL: URL(string: "https://example.com")!, avgColorHex: "#FF0000", urls: Photo.URLs(original: URL(string: "https://example.com")!, large: URL(string: "https://example.com")!, large2x: URL(string: "https://example.com")!, medium: URL(string: "https://example.com")!, small: URL(string: "https://example.com")!, portrait: URL(string: "https://example.com")!, landscape: URL(string: "https://example.com")!, tiny: URL(string: "https://example.com")!), alt: "Test", liked: false))
}
