// Exercise 17.4: a request that times out.
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

let url = URL(string: "http://localhost:8080/verdant/v1/species?delay=3000")!
var request = URLRequest(url: url)
request.timeoutInterval = 1
let start = ContinuousClock.now
do {
    _ = try await URLSession.shared.data(for: request)
    print("Unexpected success")
} catch let error as URLError {
    let seconds = (ContinuousClock.now - start).components.seconds
    print("URLError code:", error.code == .timedOut ? "timedOut" : "\(error.code.rawValue)")
    print("Gave up after about \(seconds) s")
}
