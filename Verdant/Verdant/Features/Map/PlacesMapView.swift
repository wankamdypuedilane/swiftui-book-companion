import MapKit
import SwiftUI
import VerdantKit

// <map>
/// The Map tab, with the SwiftUI MapKit API: annotations, selection, camera
/// control, the user's location and a list of the nearest places.
struct PlacesMapView: View {
    @Environment(PlacesModel.self) private var model
    @State private var location = LocationService()
    @State private var position: MapCameraPosition = .region(.kerbrume)
    @State private var usesClustering = false

    var body: some View {
        @Bindable var model = model
        NavigationStack {
            Group {
                if usesClustering {
                    ClusteredMapView(
                        places: model.visiblePlaces, selection: $model.selectedPlaceID
                    )
                    .ignoresSafeArea(edges: .bottom)
                } else {
                    map
                }
            }
            .navigationTitle("Places")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
            .sheet(
                item: Binding(
                    get: { model.selectedPlace },
                    set: { model.selectedPlaceID = $0?.id })
            ) { place in
                PlaceDetailSheet(place: place, userLocation: location.location)
                    .presentationDetents([.fraction(0.3), .medium])
            }
            .overlay(alignment: .top) {
                if let error = model.error {
                    Text(error.userMessage)
                        .font(.footnote)
                        .padding(8)
                        .background(.regularMaterial, in: .capsule)
                        .padding()
                }
            }
            .task { await model.load() }
        }
    }

    private var map: some View {
        @Bindable var model = model
        return Map(position: $position, selection: $model.selectedPlaceID) {
            ForEach(model.visiblePlaces) { place in
                Marker(
                    place.name, systemImage: place.kind.symbolName,
                    coordinate: place.coordinate
                )
                .tint(place.kind.color)
                .tag(place.id)
            }
            UserAnnotation()
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))  // only our places
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        @Bindable var model = model
        ToolbarItem(placement: .topBarLeading) {
            Menu("Show", systemImage: "line.3.horizontal.decrease.circle") {
                ForEach(Place.Kind.allCases, id: \.self) { kind in
                    Toggle(
                        kind.title, systemImage: kind.symbolName,
                        isOn: Binding(
                            get: { model.visibleKinds.contains(kind) },
                            set: { isOn in
                                if isOn {
                                    model.visibleKinds.insert(kind)
                                } else {
                                    model.visibleKinds.remove(kind)
                                }
                            }))
                }
                Divider()
                Toggle("Group nearby places (UIKit)", isOn: $usesClustering)
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button("Near me", systemImage: "location") {
                Task {
                    await location.locateOnce()
                    if let coordinate = location.location?.coordinate {
                        withAnimation {
                            position = .camera(
                                MapCamera(centerCoordinate: coordinate, distance: 4_000))
                        }
                    }
                }
            }
            .disabled(location.status == .locating)
        }
    }
}
// </map>

// <mapextensions>
extension Place {
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

extension Place.Kind {
    var color: Color {
        switch self {
        case .nursery: .green
        case .swapPoint: .orange
        case .garden: .teal
        }
    }
}

extension MKCoordinateRegion {
    /// The fictional town of Kerbrume, where the demonstration places are.
    static let kerbrume = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.395, longitude: -4.485),
        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.06))
}
// </mapextensions>
