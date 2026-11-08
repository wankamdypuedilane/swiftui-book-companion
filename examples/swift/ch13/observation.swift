// How the Observation framework tracks the properties a piece of code reads.
import Observation

// <model>
@Observable
final class WateringCan {
    var millilitres = 1_000
    var colour = "green"
    @ObservationIgnored var fillCount = 0  // never triggers updates
}
// </model>

// <tracking>
let can = WateringCan()

// Run `render` once, record what it reads, and call `onChange` at the first change
// of any of those properties. SwiftUI does exactly this with a view's body.
func observe(_ label: String, render: @escaping () -> String) {
    let output = withObservationTracking {
        render()
    } onChange: {
        print("  -> \(label) must be redrawn")
    }
    print("\(label) shows: \(output)")
}

observe("LevelView") { "\(can.millilitres) ml" }  // reads millilitres only
observe("ColourView") { can.colour }  // reads colour only

print("Changing the colour:")
can.colour = "orange"  // only ColourView is notified
print("Changing an ignored property:")
can.fillCount += 1  // nobody is notified
print("Changing the level:")
can.millilitres -= 250  // only LevelView is notified
print("Changing the level again:")
can.millilitres -= 250  // nobody: tracking is one-shot, SwiftUI re-registers on redraw
// </tracking>
