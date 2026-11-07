// expect: compile-error
// Mixing types without an explicit conversion is rejected by the compiler.
let trays = 4
let pricePerTray = 7.25
let total = trays * pricePerTray
var name = "Fern"
name = 42
print(total, name)
