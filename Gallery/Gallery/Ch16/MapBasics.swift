import MapKit
import SwiftUI

// <basics>
struct MapBasicsView: View {
    struct Stop: Identifiable {
        let id: Int
        let name: String
        let coordinate: CLLocationCoordinate2D
    }

    let stops = [
        Stop(
            id: 1, name: "Glasshouse", coordinate: .init(latitude: 48.3905, longitude: -4.4860)),
        Stop(id: 2, name: "Swap box", coordinate: .init(latitude: 48.4011, longitude: -4.4826)),
        Stop(id: 3, name: "Orchard", coordinate: .init(latitude: 48.3992, longitude: -4.5096)),
    ]

    @State private var position = MapCameraPosition.automatic  // fit all the content
    @State private var style = 0

    var body: some View {
        Map(position: $position) {
            Marker("Glasshouse", systemImage: "leaf", coordinate: stops[0].coordinate)
                .tint(.green)
            Annotation(stops[1].name, coordinate: stops[1].coordinate, anchor: .bottom) {
                Image(systemName: "arrow.left.arrow.right.circle.fill")  // any SwiftUI view
                    .font(.title)
                    .foregroundStyle(.white, .orange)
            }
            Marker(stops[2].name, monogram: Text("O"), coordinate: stops[2].coordinate)
            MapCircle(center: stops[2].coordinate, radius: 300)
                .foregroundStyle(.teal.opacity(0.25))
            MapPolyline(coordinates: stops.map(\.coordinate))
                .stroke(.blue, lineWidth: 3)
        }
        .mapStyle(style == 0 ? .standard : .imagery(elevation: .realistic))
        .safeAreaInset(edge: .bottom) {
            HStack {
                Picker("Style", selection: $style) {
                    Text("Standard").tag(0)
                    Text("Satellite").tag(1)
                }
                .pickerStyle(.segmented)
                Button("Fit") { withAnimation { position = .automatic } }
            }
            .padding()
            .background(.regularMaterial)
        }
    }
}
// </basics>

#Preview { MapBasicsView() }
