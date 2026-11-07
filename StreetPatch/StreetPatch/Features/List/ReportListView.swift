import StreetPatchKit
import SwiftUI

// <listview>
/// The same reports as the map, as a list: nearest first once the location is known,
/// filtered by status and category. The list is the accessible way to browse: every
/// report is reachable without precise gestures on a map.
struct ReportListView: View {
    @Environment(ReportsModel.self) private var model
    @Environment(LocationService.self) private var location
    @Environment(AppDependencies.self) private var dependencies

    var body: some View {
        @Bindable var model = model
        NavigationStack {
            Group {
                switch model.phase {
                case .failed(let error) where model.reports.isEmpty:
                    ContentUnavailableView {
                        Label("Cannot load the reports", systemImage: "wifi.exclamationmark")
                    } description: {
                        Text(error.userMessage)
                    } actions: {
                        Button("Try again") { Task { await model.reload() } }
                    }
                case .loaded where model.reports.isEmpty:
                    ContentUnavailableView(
                        "No reports", systemImage: "checkmark.seal",
                        description: Text("Nothing matches these filters."))
                default:
                    list
                }
            }
            .navigationTitle("Reports")
            .navigationDestination(for: Report.self) { report in
                ReportDetailView(model: dependencies.makeDetail(for: report))
            }
            .toolbar { filterMenu }
            .safeAreaInset(edge: .bottom) { ReportButton() }
            .refreshable { await model.reload() }
            .task(id: model.filter) { await model.reload() }
            .task {
                guard dependencies.usesLocation else { return }
                await location.locateOnce()
                model.userLocation = location.location.map {
                    Coordinate(
                        latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
                }
            }
        }
    }

    private var list: some View {
        List(model.sortedReports) { report in
            NavigationLink(value: report) {
                ReportRow(report: report, distance: model.distance(to: report))
            }
            .task { await model.loadMoreIfNeeded(after: report) }
        }
        .listStyle(.plain)
        .overlay {
            if model.phase == .loading && model.reports.isEmpty { ProgressView() }
        }
    }

    private var filterMenu: some ToolbarContent {
        @Bindable var model = model
        return ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Picker("Status", selection: $model.filter.statuses) {
                    Text("Open").tag(ReportFilter.open.statuses)
                    Text("Resolved").tag(Set([ReportStatus.resolved]))
                    Text("All").tag(Set<ReportStatus>())
                }
                Picker("Category", selection: $model.filter.category) {
                    Text("All categories").tag(ReportCategory?.none)
                    ForEach(ReportCategory.allCases) { category in
                        Label(category.title, systemImage: category.symbolName)
                            .tag(Optional(category))
                    }
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }
            .accessibilityIdentifier("list.filter")
        }
    }
}
// </listview>

// <row>
struct ReportRow: View {
    let report: Report
    var distance: Double?

    var body: some View {
        HStack(spacing: 12) {
            CategoryIcon(category: report.category)
            VStack(alignment: .leading, spacing: 4) {
                Text(report.title)
                    .font(.headline)
                    .lineLimit(2)
                HStack(spacing: 6) {
                    StatusPill(status: report.status)
                    if let distance { Text(distance.formattedDistance) }
                    if report.supportCount > 0 {
                        Label("\(report.supportCount)", systemImage: "hand.thumbsup")
                            .labelStyle(.titleAndIcon)
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityHint(report.category.title)
    }
}
// </row>
