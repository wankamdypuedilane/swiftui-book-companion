// Integer and floating-point arithmetic.
let seeds = 17
let packets = 5
print("Integer division:", seeds / packets, "remainder:", seeds % packets)
print("Floating-point division:", Double(seeds) / Double(packets))

print("Int range:", Int.min, "...", Int.max)
let small: UInt8 = 250
print("Wrapping addition 250 &+ 10 =", small &+ 10)
let (sum, overflow) = small.addingReportingOverflow(10)
print("addingReportingOverflow:", sum, overflow)

// Doubles are binary approximations: 0.1 + 0.2 is not exactly 0.3.
let a = 0.1 + 0.2
print(a == 0.3, a)
print(abs(a - 0.3) < 1e-9)

// Rounding and conversions
print(Int(9.99), Int((9.99).rounded()), (2.0).squareRoot(), Double.pi)
print(Int("42") as Any, Int("forty-two") as Any)
