import Foundation
import Testing
@testable import StreetPatchKit

// <outboxtests>
@Suite("Outbox")
struct OutboxTests {
    let service = FakeReportsService()
    let storage = InMemoryOutboxStorage()
    var outbox: ReportOutbox { ReportOutbox(storage: storage, service: service) }

    @Test func offlineReportsWaitThenLeaveInOrder() async {
        let outbox = outbox
        await service.failCreates(.offline)
        await outbox.enqueue(validDraft, photo: nil)
        var second = validDraft
        second.title = "Second problem"
        await outbox.enqueue(second, photo: nil)

        let offline = await outbox.flush()
        #expect(offline.sent.isEmpty && offline.waiting == 2)
        #expect(await storage.load().count == 2)  // saved: survives a relaunch

        let online = await outbox.flush()
        #expect(online.sent.count == 2 && online.waiting == 0)
        #expect(await service.stored.map(\.title) == [validDraft.title, "Second problem"])
        #expect(await outbox.pending.isEmpty)
    }

    @Test func aLostResponseDoesNotCreateADuplicate() async {
        let outbox = outbox
        await service.loseNextResponse()
        await outbox.enqueue(validDraft, photo: nil)
        #expect(await outbox.flush().waiting == 1)  // timed out, but the server has it
        #expect(await outbox.flush().sent.count == 1)
        #expect(await service.stored.count == 1)  // same key: the server answered a replay
        #expect(await service.createCalls == 2)
    }

    @Test func aPhotoThatFailsIsRetriedWithoutRecreatingTheReport() async throws {
        let outbox = outbox
        await service.failPhotos(.http(status: 503, message: nil))
        let jpeg = Data([0xFF, 0xD8, 0xFF])
        await outbox.enqueue(validDraft, photo: jpeg)

        #expect(await outbox.flush().waiting == 1)
        #expect(await outbox.pending.first?.serverID == "KB-0001")
        let result = await outbox.flush()
        let report = try #require(result.sent.values.first)
        #expect(report.hasPhoto)
        #expect(await service.createCalls == 1)
        #expect(await service.photos["KB-0001"] == jpeg)
    }

    @Test func aRefusedReportStaysForTheResidentToFix() async {
        let outbox = outbox
        await service.failCreates(
            .http(status: 422, message: "This place is outside Kerbrume."))
        let item = await outbox.enqueue(validDraft, photo: nil)
        var next = validDraft
        next.title = "Another one"
        await outbox.enqueue(next, photo: nil)

        let result = await outbox.flush()
        #expect(result.refused == 1 && result.sent.count == 1)  // the next one still left
        let refused = await outbox.pending
        #expect(refused.map(\.id) == [item.id])
        #expect(refused.first?.failure == "This place is outside Kerbrume.")

        await outbox.retry(item.id, with: validDraft)
        #expect(await outbox.flush().sent.count == 1)
    }

    @Test func concurrentFlushesShareOnePass() async {
        let outbox = outbox
        await outbox.enqueue(validDraft, photo: nil)
        async let first = outbox.flush()
        async let second = outbox.flush()
        let results = await [first, second]
        #expect(await service.createCalls == 1)
        #expect(results.map(\.sent.count).reduce(0, +) >= 1)
    }

    @Test func aReportQueuedDuringAPassIsKept() async {
        let outbox = outbox
        await service.slowCreates(.milliseconds(200))
        await outbox.enqueue(validDraft, photo: nil)
        let pass = Task { await outbox.flush() }
        try? await Task.sleep(for: .milliseconds(50))  // the first request is in flight
        var second = validDraft
        second.title = "Queued meanwhile"
        await outbox.enqueue(second, photo: nil)
        let result = await pass.value
        #expect(result.sent.count == 2)  // the pass picked it up too
        #expect(await service.stored.map(\.title) == [validDraft.title, "Queued meanwhile"])
        #expect(await outbox.pending.isEmpty)
    }

    @Test func theFileStorageRoundTrips() async throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("outbox-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let item = PendingReport(
            draft: validDraft, photo: Data([1, 2, 3]),
            queuedAt: Date(timeIntervalSince1970: 1_793_000_000))
        await JSONFileOutboxStorage(url: url).save([item])
        #expect(await JSONFileOutboxStorage(url: url).load() == [item])
    }
}
// </outboxtests>
