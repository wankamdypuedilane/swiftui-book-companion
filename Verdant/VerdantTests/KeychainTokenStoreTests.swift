import Foundation
import Testing
import VerdantKit
@testable import Verdant

@Suite("Keychain", .serialized)
struct KeychainTokenStoreTests {
    let store = KeychainTokenStore(service: "verdant.tests.\(UUID().uuidString)")

    @Test func storesReplacesAndDeletesTheSession() async {
        let first = AuthSession(email: "demo@verdant.example", accessToken: "a1",
                                refreshToken: "r1", expiresAt: Date(timeIntervalSince1970: 2_000_000_000))
        await store.save(first)
        #expect(await store.load() == first)
        var second = first
        second.accessToken = "a2"
        await store.save(second)
        #expect(await store.load()?.accessToken == "a2")
        await store.save(nil)
        #expect(await store.load() == nil)
    }
}

@MainActor
@Suite("Router")
struct RouterTests {
    @Test func plantLinksOpenTheGardenTab() throws {
        let router = Router()
        let id = UUID()
        router.handle(try #require(URL(string: "verdant://plants/\(id.uuidString)")))
        #expect(router.selectedTab == .garden)
        #expect(router.gardenPath == [.plant(id)])
    }

    @Test func otherSchemesAreIgnored() throws {
        let router = Router()
        router.handle(try #require(URL(string: "https://plants/123")))
        #expect(router.selectedTab == .today)
    }
}
