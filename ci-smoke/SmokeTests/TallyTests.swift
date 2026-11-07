import Testing
@testable import Smoke
@MainActor @Test func tallyIncrements() { let t = Tally(); t.count += 1; #expect(t.count == 1) }
