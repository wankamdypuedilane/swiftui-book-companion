import Foundation
import Testing
@testable import Gallery

// <tests>
@Suite("Deep links")
struct DeepLinkTests {
    let specimens = Specimen.samples

    @Test func roomThenPlant() throws {
        let url = try #require(URL(string: "verdant://rooms/Kitchen/plants/3"))
        #expect(DeepLink.routes(from: url, specimens: specimens)
                == [.room("Kitchen"), .specimen(specimens[2])])
    }

    @Test func settings() throws {
        let url = try #require(URL(string: "verdant://settings"))
        #expect(DeepLink.routes(from: url, specimens: specimens) == [.settings])
    }

    @Test(arguments: ["https://rooms/Kitchen", "verdant://plants/99", "verdant://unknown/1"])
    func invalidLinksOpenNothing(link: String) throws {
        let url = try #require(URL(string: link))
        #expect(DeepLink.routes(from: url, specimens: specimens).isEmpty)
    }

    @Test func validPrefixIsKept() throws {
        let url = try #require(URL(string: "verdant://rooms/Bedroom/plants/42"))
        #expect(DeepLink.routes(from: url, specimens: specimens) == [.room("Bedroom")])
    }
}
// </tests>
