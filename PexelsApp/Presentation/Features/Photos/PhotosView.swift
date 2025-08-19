import ComposableArchitecture
import SwiftUI

struct PhotosView: View {
    let store: StoreOf<PhotosFeature>

    var body: some View {
        NavigationStack {
            listContent
                .overlay {
                    if store.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .navigationTitle(Text("Photos"))
                .padding(.top, 8)
                .padding(.bottom, 8)
                .task {
                    store.send(.onAppear)
                }
                .searchable(
                    text: Binding(
                        get: { store.searchText },
                        set: { store.send(.searchPhotos($0)) }
                    ),
                    prompt: "Search photos"
                )
        }
    }

    @ViewBuilder
    private var listContent: some View {
        ScrollView {
//            LazyVStack {
//                ForEach(store.photos) { photo in
//                    PhotoRowView(photo: photo)
//                        .background(Color.white)
//                        .cornerRadius(8)
//                }
//            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 2), spacing: 4) {
                ForEach(store.photos) { photo in
                    GridRow {
                        PhotoRowView(photo: photo)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
}
