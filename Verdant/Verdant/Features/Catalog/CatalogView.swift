import SwiftUI
import VerdantKit

// <catalog>
/// The Catalogue tab: species from the API in an adaptive grid, with search,
/// filtering, pagination, pull to refresh, and loading, error, empty and
/// offline states.
struct CatalogView: View {
    @Environment(CatalogModel.self) private var model
    @Environment(NetworkMonitor.self) private var network
    @Environment(Router.self) private var router

    private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

    var body: some View {
        @Bindable var model = model
        @Bindable var router = router
        NavigationStack(path: $router.catalogPath) {
            content
                .navigationTitle("Catalogue")
                .navigationDestination(for: Species.self) { SpeciesDetailView(species: $0) }
                .searchable(text: $model.query, prompt: "Search species")
                .toolbar {
                    Menu("Light", systemImage: "sun.max") {
                        Picker("Light", selection: $model.lightFilter) {
                            Text("Any light").tag(LightLevel?.none)
                            ForEach(LightLevel.allCases) {
                                Text($0.title).tag(LightLevel?.some($0))
                            }
                        }
                    }
                }
                .safeAreaInset(edge: .top) {
                    if !network.isConnected || model.isShowingCachedData {
                        OfflineBanner(isOffline: !network.isConnected)
                    }
                }
                // Runs on appear and again whenever the search or the filter changes.
                // A change cancels the previous task, so typing quickly sends one request.
                .task(id: SearchKey(query: model.query, light: model.lightFilter)) {
                    if model.phase != .idle {
                        try? await Task.sleep(for: .milliseconds(300))  // debounce typing
                        guard !Task.isCancelled else { return }
                    }
                    await model.reload()
                }
        }
    }

    private struct SearchKey: Equatable { let query: String; let light: LightLevel? }

    @ViewBuilder
    private var content: some View {
        switch model.phase {
        case .idle,
            .loading where model.species.isEmpty:
            ProgressView("Loading the catalogue…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let error) where model.species.isEmpty:
            ContentUnavailableView {
                Label("Catalogue unavailable", systemImage: "wifi.exclamationmark")
            } description: {
                Text(error.userMessage)
            } actions: {
                Button("Try again") { Task { await model.reload() } }
                    .buttonStyle(.borderedProminent)
            }
        default:
            if model.isEmpty {
                ContentUnavailableView.search(text: model.query)
            } else {
                grid
            }
        }
    }

    private var grid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(model.species) { species in
                    NavigationLink(value: species) {
                        SpeciesCard(species: species)
                    }
                    .buttonStyle(.plain)
                    .task { await model.loadMoreIfNeeded(after: species) }
                }
            }
            .padding()
            if model.isLoadingMore {
                ProgressView().padding()
            }
        }
        .refreshable { await model.reload() }
    }
}
// </catalog>

// <banner>
struct OfflineBanner: View {
    let isOffline: Bool

    var body: some View {
        Label(
            isOffline
                ? "You are offline. Showing saved results."
                : "Showing saved results: the server could not be reached.",
            systemImage: "icloud.slash"
        )
        .font(.footnote.weight(.medium))
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(.yellow.opacity(0.25))
    }
}
// </banner>
