import MapKit
import SwiftUI
import VerdantKit

// <representable>
/// An MKMapView from UIKit, wrapped for SwiftUI, to use annotation clustering,
/// which the SwiftUI Map does not offer.
struct ClusteredMapView: UIViewRepresentable {
    let places: [Place]
    @Binding var selection: Place.ID?

    func makeCoordinator() -> Coordinator { Coordinator(selection: $selection) }

    /// Called once: create and configure the UIKit view.
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = .kerbrume
        mapView.showsUserLocation = true
        mapView.pointOfInterestFilter = .excludingAll
        mapView.register(
            MKMarkerAnnotationView.self,
            forAnnotationViewWithReuseIdentifier: Coordinator.markerID)
        return mapView
    }

    /// Called whenever the SwiftUI state changes: bring the UIKit view up to date.
    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.selection = $selection
        let current = mapView.annotations.compactMap { $0 as? PlaceAnnotation }
        let wanted = Set(places.map(\.id))
        mapView.removeAnnotations(current.filter { !wanted.contains($0.place.id) })
        let shown = Set(current.map(\.place.id))
        mapView.addAnnotations(
            places.filter { !shown.contains($0.id) }.map(PlaceAnnotation.init))
    }

    /// The delegate of the map view: it receives UIKit callbacks.
    final class Coordinator: NSObject, MKMapViewDelegate {
        static let markerID = "place"
        var selection: Binding<Place.ID?>

        init(selection: Binding<Place.ID?>) { self.selection = selection }

        func mapView(
            _ mapView: MKMapView, viewFor annotation: any MKAnnotation
        ) -> MKAnnotationView? {
            // The user's location dot is not a PlaceAnnotation: keep the default view.
            guard let annotation = annotation as? PlaceAnnotation else { return nil }
            let view = mapView.dequeueReusableAnnotationView(
                withIdentifier: Self.markerID,
                for: annotation)
            guard let marker = view as? MKMarkerAnnotationView else { return view }
            marker.clusteringIdentifier = "places"  // markers close together merge
            marker.glyphImage = UIImage(systemName: annotation.place.kind.symbolName)
            marker.markerTintColor = UIColor(annotation.place.kind.color)
            return marker
        }

        func mapView(_ mapView: MKMapView, didSelect annotation: any MKAnnotation) {
            if let annotation = annotation as? PlaceAnnotation {
                selection.wrappedValue = annotation.place.id
            } else if let cluster = annotation as? MKClusterAnnotation {
                mapView.showAnnotations(cluster.memberAnnotations, animated: true)  // zoom in
            }
        }
    }
}

/// MKMapView needs annotation objects (classes), not values.
final class PlaceAnnotation: NSObject, MKAnnotation {
    let place: Place
    init(_ place: Place) { self.place = place }
    var coordinate: CLLocationCoordinate2D { place.coordinate }
    var title: String? { place.name }
    var subtitle: String? { place.kind.title }
}
// </representable>
