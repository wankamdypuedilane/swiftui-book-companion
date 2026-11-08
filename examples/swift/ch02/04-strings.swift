// Strings and characters.
let species = "Monstera deliciosa"
print(species.count, species.uppercased(), species.hasPrefix("Mon"))

let words = species.split(separator: " ")
print(words.first!, "|", words.last!)

var note = "Water"
note += " every 7 days"
note.append("!")
print(note)

// A Character is what a reader perceives as one character.
let flower = "🌸"
let cafe = "café"
print(flower.count, flower.utf8.count, cafe.count, cafe.unicodeScalars.count)

// Multiline string literal
let label = """
    Plant: \(species)
    Light: bright, indirect
    """
print(label)

// Raw strings keep backslashes and quotes as typed.
print(#"Path: C:\plants\"fern".txt"#)
