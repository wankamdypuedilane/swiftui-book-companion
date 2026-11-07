import SwiftUI
import MapKit
import Observation

@Observable final class Tally { var count = 0 }

@main struct SmokeApp: App {
    var body: some Scene { WindowGroup { ContentView() } }
}

struct ContentView: View {
    @State private var tally = Tally()
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Taps: \(tally.count)").font(.title).accessibilityIdentifier("taps")
                Button("Tap") { tally.count += 1 }.buttonStyle(.borderedProminent)
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 48.39, longitude: -4.49),
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))) {
                    Marker("Demo", coordinate: CLLocationCoordinate2D(latitude: 48.39, longitude: -4.49))
                }.frame(height: 200)
            }
            .padding()
            .navigationTitle("Smoke")
        }
    }
}
