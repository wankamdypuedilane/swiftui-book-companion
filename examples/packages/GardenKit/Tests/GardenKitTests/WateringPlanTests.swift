import Testing
@testable import GardenKit   // @testable also exposes internal members to tests

@Test func intervalIsClampedToSixtyDays() {
    let plan = WateringPlan(plantName: "Cactus", intervalDays: 90, today: 0)
    #expect(plan.intervalDays == 60)
}

@Test func nextWateringFollowsTheLastOne() {
    var plan = WateringPlan(plantName: "Fern", intervalDays: 3, today: 1)
    plan.recordWatering(onDay: 4)
    #expect(plan.history == [4])
    #expect(plan.nextWatering(today: 5) == 7)
}
