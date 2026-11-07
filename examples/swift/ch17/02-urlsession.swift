// Talking to the demonstration API (start it first: node book-api/server.js).
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

let base = URL(string: "http://localhost:8080/verdant/v1/")!

struct Page<Item: Decodable>: Decodable {
    let items: [Item]
    let page: Int
    let totalPages: Int
    let total: Int
}
struct Species: Decodable { let id: String; let commonName: String; let wateringDays: Int }
struct ServerError: Decodable { let error: String }

// <get>
// 1. A GET request with query items.
var components = URLComponents(
    url: base.appendingPathComponent("species"), resolvingAgainstBaseURL: false)!
components.queryItems = [
    URLQueryItem(name: "perPage", value: "3"),
    URLQueryItem(name: "light", value: "low"),
]
let (data, response) = try await URLSession.shared.data(from: components.url!)
let http = response as! HTTPURLResponse
print("GET", components.url!.absoluteString)
print(
    "Status:", http.statusCode, "| Content-Type:",
    http.value(forHTTPHeaderField: "Content-Type")!)
let page = try JSONDecoder().decode(Page<Species>.self, from: data)
print("Page \(page.page) of \(page.totalPages), \(page.total) species with low light:")
for species in page.items {
    print(" -", species.commonName, "every", species.wateringDays, "days")
}
// </get>

// <post>
// 2. A POST request with a JSON body.
struct Credentials: Encodable { let email: String; let password: String }
struct Token: Decodable { let accessToken: String; let expiresIn: Int }

var request = URLRequest(url: base.appendingPathComponent("auth/token"))
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
request.httpBody = try JSONEncoder().encode(
    Credentials(email: "demo@verdant.example", password: "local-only-demo-password"))
let (tokenData, tokenResponse) = try await URLSession.shared.data(for: request)
let token = try JSONDecoder().decode(Token.self, from: tokenData)
print(
    "POST auth/token ->", (tokenResponse as! HTTPURLResponse).statusCode,
    "| token of \(token.accessToken.count) characters, valid \(token.expiresIn) s")
// </post>

// <status>
// 3. URLSession does not throw for HTTP errors: check the status code yourself.
for path in ["species/aloe-vera", "species/unicorn-plant", "me/garden"] {
    let (body, reply) = try await URLSession.shared.data(
        from: base.appendingPathComponent(path))
    let status = (reply as! HTTPURLResponse).statusCode
    if (200..<300).contains(status) {
        print(path, "->", status, "OK")
    } else {
        let message = (try? JSONDecoder().decode(ServerError.self, from: body))?.error ?? "?"
        print(path, "->", status, message)
    }
}
// </status>
