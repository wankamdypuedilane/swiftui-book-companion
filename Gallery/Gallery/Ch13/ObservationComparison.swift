import Combine
import SwiftUI

// <legacy>
/// The pre-iOS 17 way: ObservableObject, @Published, @StateObject, @ObservedObject.
final class LegacyCounter: ObservableObject {
    @Published var count = 0  // every @Published change notifies every observer
    @Published var label = "Mistings"
}

struct LegacyOwnerView: View {
    @StateObject private var counter = LegacyCounter()  // owns the object

    var body: some View {
        VStack {
            LegacyChildView(counter: counter)
            Button("Mist") { counter.count += 1 }
        }
    }
}

struct LegacyChildView: View {
    @ObservedObject var counter: LegacyCounter  // observes an object owned elsewhere

    var body: some View {
        TextField("Label", text: $counter.label)  // $ gives bindings
        Text("\(counter.label): \(counter.count)")
    }
}
// </legacy>

// <modern>
/// The iOS 17+ way: @Observable, @State to own, plain properties or @Bindable to use.
@Observable
final class ModernCounter {
    var count = 0  // only views that read `count` update
    var label = "Mistings"
}

struct ModernOwnerView: View {
    @State private var counter = ModernCounter()  // owns the object

    var body: some View {
        VStack {
            ModernChildView(counter: counter)
            Button("Mist") { counter.count += 1 }
        }
    }
}

struct ModernChildView: View {
    @Bindable var counter: ModernCounter  // only needed for $ bindings

    var body: some View {
        TextField("Label", text: $counter.label)
        Text("\(counter.label): \(counter.count)")
    }
}
// </modern>

struct ObservationComparisonView: View {
    var body: some View {
        Form {
            Section("ObservableObject (legacy)") { LegacyOwnerView() }
            Section("@Observable (modern)") { ModernOwnerView() }
        }
    }
}

#Preview { ObservationComparisonView() }
