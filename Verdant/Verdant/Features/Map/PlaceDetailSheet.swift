import CoreLocation
import SwiftUI
import VerdantKit

// <placesheet>
struct PlaceDetailSheet: View {
    let place: Place
    let userLocation: CLLocation?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(place.kind.title, systemImage: place.kind.symbolName)
                .font(.subheadline)
                .foregroundStyle(place.kind.color)
            Text(place.name).font(.title2.bold())
            Text(place.address).foregroundStyle(.secondary)
            Label(place.openingHours, systemImage: "clock")
            if let userLocation {
                let metres = userLocation.distance(
                    from: CLLocation(
                        latitude: place.latitude,
                        longitude: place.longitude))
                Label(
                    Measurement(value: metres, unit: UnitLength.meters)
                        .formatted(.measurement(width: .abbreviated, usage: .road)),
                    systemImage: "figure.walk")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}
// </placesheet>
