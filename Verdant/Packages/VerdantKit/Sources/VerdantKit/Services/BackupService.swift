import Foundation

// <backup>
/// Copies the garden to the user's account and back. Requires a signed-in user.
public protocol BackupService: Sendable {
    func upload(_ plants: [Plant]) async throws(APIError) -> BackupReceipt
    func download() async throws(APIError) -> [Plant]
}

public struct BackupReceipt: Codable, Equatable, Sendable {
    public var plantCount: Int
    public var savedAt: Date
}

public struct RemoteBackupService: BackupService {
    private let client: APIClient
    public init(client: APIClient) { self.client = client }

    public func upload(_ plants: [Plant]) async throws(APIError) -> BackupReceipt {
        let body: Data
        do { body = try APIClient.makeEncoder().encode(plants) } catch {
            throw .invalidRequest("Could not encode the garden")
        }
        return try await client.send(
            Endpoint<BackupReceipt>(
                .put, "me/garden", body: body,
                requiresAuthentication: true))
    }

    public func download() async throws(APIError) -> [Plant] {
        try await client.send(
            Endpoint<[Plant]>(.get, "me/garden", requiresAuthentication: true))
    }
}
// </backup>
