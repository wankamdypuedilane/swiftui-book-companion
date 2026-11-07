// Exercise 3.3: a property wrapper that normalizes text input.
@propertyWrapper
struct Trimmed {
    private var text = ""
    let lowercased: Bool
    init(wrappedValue: String, lowercased: Bool = false) {
        self.lowercased = lowercased
        self.wrappedValue = wrappedValue  // goes through the setter below
    }
    var wrappedValue: String {
        get { text }
        set {
            let trimmed = newValue.split(whereSeparator: \.isWhitespace).joined(separator: " ")
            text = lowercased ? trimmed.lowercased() : trimmed
        }
    }
}

struct SignUpForm {
    @Trimmed var displayName = ""
    @Trimmed(lowercased: true) var email = ""
}

var form = SignUpForm()
form.displayName = "   Léa    Martin  "
form.email = "  Lea.Martin@Example.COM "
print("[\(form.displayName)]", "[\(form.email)]")
