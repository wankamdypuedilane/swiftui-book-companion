import GardenKit

var fern = WateringPlan(plantName: "Fern", intervalDays: 3, today: 1)
var cactus = WateringPlan(plantName: "Cactus", intervalDays: 90, today: 1)
fern.recordWatering(onDay: 4)
cactus.adjust(toDays: 21)
print(report(for: [cactus, fern], today: 5))
print("Cactus interval:", cactus.intervalDays)
// fern.intervalDays = 10     // error: setter is private
// fern.history               // error: 'history' is inaccessible (internal)
