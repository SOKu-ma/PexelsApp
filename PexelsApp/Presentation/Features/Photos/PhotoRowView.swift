import Kingfisher
import SwiftUI

struct PhotoRowView: View {
    let photo: Photo

    var body: some View {
        KFImage(photo.urls.original)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .clipped()
    }
}

// #Preview {
//    PhotoRowView(photo: Photo(id: 1, width: 200, height: 200, aspectRatio: <#T##CGFloat#>, photographerName: <#T##String#>, photographerURL: <#T##URL#>, avgColorHex: <#T##String?#>, urls: <#T##Photo.URLs#>, alt: <#T##String#>, liked: <#T##Bool#>))
// }
