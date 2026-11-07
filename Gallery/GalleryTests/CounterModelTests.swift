import Testing
@testable import Gallery

// <countertests>
@Test func counterStopsAtTheUpperBound() {
    let model = CounterModel(range: 1...2)
    model.increment()
    model.increment()
    #expect(model.value == 2)
    #expect(!model.canIncrement)
}

@Test func counterStartsAtTheLowerBound() {
    #expect(CounterModel(range: 3...5).value == 3)
}
// </countertests>
