import Foundation
import Security
import VerdantKit

// <keychain>
/// Saves the session in the Keychain, the encrypted store iOS provides for
/// secrets. Never store tokens in UserDefaults or in files.
struct KeychainTokenStore: TokenStore {
    let service: String
    private let account = "session"

    func load() async -> AuthSession? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
            let data = result as? Data
        else { return nil }
        return try? APIClient.makeDecoder().decode(AuthSession.self, from: data)
    }

    func save(_ session: AuthSession?) async {
        let identity: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(identity as CFDictionary)  // replace any previous value
        guard let session, let data = try? APIClient.makeEncoder().encode(session) else {
            return
        }
        var attributes = identity
        attributes[kSecValueData as String] = data
        // Readable after the first unlock, never synced or restored to another device.
        attributes[kSecAttrAccessible as String] =
            kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        let status = SecItemAdd(attributes as CFDictionary, nil)
        if status != errSecSuccess {
            Log.data.error("Keychain write failed: \(status)")
        }
    }
}
// </keychain>
