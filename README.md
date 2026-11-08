# Mastering Swift and SwiftUI: companion repository

The code of the book *Mastering Swift and SwiftUI: A Comprehensive Guide to Modern iOS
Development, Application Architecture, Networking, and App Store Deployment* by WANKAM
Dypue Dilane Junior (2026). Every listing of the book is copied from this repository,
and everything here is compiled and tested by continuous integration
(`.github/workflows/ios.yml`).

Tested with Xcode 26.6 (Swift 6.3.3, iOS 26.5 simulator) on macOS, and Swift 6.3 on
Linux. The apps use the Swift 6 language mode and target iOS 18.

## Contents

| Folder | What it is | Chapters |
|---|---|---|
| `examples/swift/` | Command-line Swift programs, each with its recorded output (`.out`) | 2, 3, 12, 13, 15, 17, 18, A |
| `examples/packages/` | Small Swift packages (access control) | 4 |
| `Projects/HelloSwiftUI`, `Projects/Sprout` | The first Xcode projects | 1, 4 |
| `Gallery/` | One app gathering the SwiftUI examples and exercise solutions | 5–9, 11–16, 22 |
| `Verdant/` | The house-plant app built through the book, and its `VerdantKit` package | 10–24 |
| `StreetPatch/` | The capstone app and its `StreetPatchKit` package | 25 |
| `book-api/` | The demonstration HTTP server used by Verdant and StreetPatch | 17–25, D |
| `tools/` | Scripts used by continuous integration | |

## Running

The Xcode projects are generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
brew install xcodegen
cd Verdant && xcodegen generate && open Verdant.xcodeproj
```

Verdant and StreetPatch talk to the demonstration server. Start it first (Node.js 20 or
later, no dependencies):

```sh
cd book-api && node server.js        # http://localhost:8080
node --test test/*.test.js           # the API's contract tests
```

Command-line examples run with `swift file.swift`; `tools/run-swift-examples.sh --check`
runs them all and compares their output with the recorded one. Packages are tested with
`swift test` in their folder; set `VERDANT_API_URL=http://localhost:8080/verdant/v1/` or
`STREETPATCH_API_URL=http://localhost:8080/streetpatch/v1/` to include the tests that use
the running server.

## Demo accounts: local only

The server accepts `demo@verdant.example`, `resident@streetpatch.example` and
`staff@streetpatch.example`, all with the password `local-only-demo-password`. They
exist only in this in-memory development server. Never deploy it, and never reuse these
values anywhere. All data (species, places, the town of Kerbrume, reports) is fictional.

## Known issues

- Verdant's accessibility audit reports one contrast failure per visible row of the
  Garden list. The audit cannot name the element, because each row combines its
  children into one accessibility element. The same rows pass on the Today screen.
  The UI test accepts this one case explicitly, and every other audit issue still fails
  it. Corrections are welcome.

## License

MIT, see `LICENSE`. Corrections are welcome as issues.
