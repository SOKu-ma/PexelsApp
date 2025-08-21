import ComposableArchitecture
import SwiftUI

struct PhotosView: View {
    let store: StoreOf<PhotosFeature>

    var body: some View {
        NavigationStack {
            listContent
                .overlay { progressView }
                .navigationTitle(Text("Photos"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            store.send(.toggleDisplayMode)
                        }) {
                            Image(systemName: store.displayMode == .singleColumn ? "list.bullet" : "rectangle.grid.2x2")
                                .foregroundColor(.primary)
                        }
                    }
                }
                .onAppear {
                    store.send(.onAppear)
                }
                .navigationDestination(for: URL.self) { url in
                    FullScreenImageView(
                        store: Store(
                            initialState: FullScreenImageFeature.State(url: url))
                        {
                            FullScreenImageFeature()
                        }
                    )
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
            if store.displayMode == .singleColumn {
                // 1列表示
                LazyVStack(spacing: 0) {
                    ForEach(Array(store.displayRows.enumerated()), id: \.element.id) { index, photo in
                        NavigationLink(value: photo.urls.original) {
                            PhotoRowView(photo: photo, isGridMode: false)
                                .background(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onAppear {
                            if index >= store.displayRows.count - 5 && !store.isLoadingMore {
                                store.send(.loadMorePhotos)
                            }
                        }
                    }

                    loadingMoreView
                }
            } else {
                // 2列表示
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 1.5),
                    GridItem(.flexible(), spacing: 1.5),
                ], spacing: 1.5) {
                    ForEach(Array(store.displayRows.enumerated()), id: \.element.id) { index, photo in
                        NavigationLink(value: photo.urls.original) {
                            PhotoRowView(photo: photo, isGridMode: true)
                                .background(Color(.systemBackground))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .onAppear {
                            if index >= store.displayRows.count - 5 && !store.isLoadingMore {
                                store.send(.loadMorePhotos)
                            }
                        }
                    }

                    if store.isLoadingMore {
                        loadingMoreView
                            .gridCellColumns(2)
                    }
                }
                .padding(.horizontal, 1.5)
            }
        }
        .refreshable {
            store.send(.loadPhotos)
        }
    }

    @ViewBuilder
    private var loadingMoreView: some View {
        if store.isLoadingMore {
            HStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                Text("Loading more photos...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }

    @ViewBuilder
    private var progressView: some View {
        if store.isLoading && store.displayRows.isEmpty {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
        }
    }
}
