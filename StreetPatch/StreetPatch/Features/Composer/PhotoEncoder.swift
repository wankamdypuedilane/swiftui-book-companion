import StreetPatchKit
import UIKit

// <encoder>
/// Turns a photo from the library or the camera into a JPEG the server accepts:
/// at most 2048 pixels on its longest side and 2 MB. Re-encoding also drops the
/// photo's metadata, including the GPS position of where it was taken.
nonisolated enum PhotoEncoder {
    /// @concurrent: runs on the global executor, not on the main actor, so the
    /// interface stays responsive while a 12-megapixel photo is redrawn.
    @concurrent
    static func jpeg(from data: Data, policy: PhotoPolicy = .standard) async -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let size = policy.targetSize(
            width: Double(image.size.width), height: Double(image.size.height))
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1  // pixels, not points
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: size.width, height: size.height), format: format)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        return policy.compress { quality in resized.jpegData(compressionQuality: quality) }
    }
}
// </encoder>
