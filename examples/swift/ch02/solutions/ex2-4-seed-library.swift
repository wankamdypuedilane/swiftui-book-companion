// Exercise 2.4 (synthesis): the ledger of a community seed library.
import Foundation

enum Status: Equatable { case onLoan(dueDay: Int), returned(day: Int), lost }

struct Loan {
    let id: Int
    let member: String
    let variety: String
    let borrowedDay: Int
    var status: Status

    func isOverdue(today: Int) -> Bool {
        if case .onLoan(let due) = status { return today > due }
        return false
    }
    func daysLate(today: Int) -> Int? {
        guard case .onLoan(let due) = status, today > due else { return nil }
        return today - due
    }
}

enum LedgerError: Error { case unknownLoan(Int), alreadyClosed(Int) }

struct Ledger {
    private(set) var loans: [Loan] = []
    private var nextID = 1
    let loanPeriod = 30

    mutating func lend(_ variety: String, to member: String, on day: Int) -> Int {
        let loan = Loan(id: nextID, member: member, variety: variety, borrowedDay: day,
                        status: .onLoan(dueDay: day + loanPeriod))
        loans.append(loan)
        nextID += 1
        return loan.id
    }

    mutating func markReturned(_ id: Int, on day: Int) throws(LedgerError) {
        guard let index = loans.firstIndex(where: { $0.id == id }) else { throw .unknownLoan(id) }
        guard case .onLoan = loans[index].status else { throw .alreadyClosed(id) }
        loans[index].status = .returned(day: day)
    }

    func overdue(today: Int) -> [Loan] {
        loans.filter { $0.isOverdue(today: today) }
            .sorted { ($0.daysLate(today: today) ?? 0) > ($1.daysLate(today: today) ?? 0) }
    }

    func countBy<Key: Hashable>(_ key: (Loan) -> Key) -> [Key: Int] {
        loans.reduce(into: [:]) { counts, loan in counts[key(loan), default: 0] += 1 }
    }
}

var ledger = Ledger()
let a = ledger.lend("Cherokee tomato", to: "Inès", on: 1)
let b = ledger.lend("Lemon basil", to: "Tom", on: 3)
_ = ledger.lend("Purple carrot", to: "Inès", on: 10)
let d = ledger.lend("Sunflower", to: "Malo", on: 12)
_ = ledger.lend("Runner bean", to: "Tom", on: 20)

do {
    try ledger.markReturned(b, on: 25)
    try ledger.markReturned(d, on: 40)
    try ledger.markReturned(b, on: 41)          // fails: already returned
} catch {
    print("Error:", error)
}
_ = a

let today = 45
for loan in ledger.overdue(today: today) {
    print("Overdue: #\(loan.id) \(loan.variety) (\(loan.member)), \(loan.daysLate(today: today)!) days late")
}
let perMember = ledger.countBy(\.member)
for member in perMember.keys.sorted() { let n = perMember[member]!; print("\(member): \(n) loan\(n == 1 ? "" : "s")") }
let onLoan = ledger.loans.filter { if case .onLoan = $0.status { true } else { false } }.count
print("Still on loan: \(onLoan) of \(ledger.loans.count)")
