import MapKit
import StreetPatchKit
import SwiftUI

// <mapview>
/// Every open report of the town on a map. Tapping a marker opens the report in a
/// sheet that leaves the map visible above it.
struct ReportsMapView: View {
    @Environment(ReportsModel.self) private var model
    @Environment(AppDependencies.self) private var dependencies
    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: ServiceArea.kerbrume.centre.clCoordinate,
            latitudinalMeters: 2500, longitudinalMeters: 2500))
    @State private var selectedID: String?

    var body: some View {
        NavigationStack {
            Map(position: $position, selection: $selectedID) {
                // Showing the user's position asks for location access: not in UI tests.
                if dependencies.usesLocation { UserAnnotation() }
                ForEach(model.reports) { report in
                    Annotation(report.title, coordinate: report.coordinate.clCoordinate) {
                        CategoryIcon(category: report.category)
                    }
                    .tag(report.id)
                }
            }
            .mapControls {
                if dependencies.usesLocation { MapUserLocationButton() }
                MapCompass()
                MapScaleView()
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) { ReportButton() }
            }
            .navigationTitle("Kerbrume")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: selectedReport) { report in
                ReportDetailView(model: dependencies.makeDetail(for: report))
                    .presentationDetents([.medium, .large])
            }
            .task {
                if model.phase == .idle { await model.reload() }
            }
        }
    }

    /// The selection is an id (what Map tags carry); the sheet wants the report.
    private var selectedReport: Binding<Report?> {
        Binding(
            get: { model.reports.first { $0.id == selectedID } },
            set: { selectedID = $0?.id })
    }
}
// </mapview>

extension Coordinate {
    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
