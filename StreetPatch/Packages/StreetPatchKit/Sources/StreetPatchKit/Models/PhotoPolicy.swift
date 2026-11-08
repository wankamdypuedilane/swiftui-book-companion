import Foundation

// <photopolicy>
/// How large a photo may be. The app resizes and compresses with UIKit; the
/// arithmetic lives here so that it is tested on every platform.
public struct PhotoPolicy: Sendable {
    public var maxBytes = 2_000_000  // the server refuses anything larger
    public var maxPixelSize = 2048.0  // longest side
    public var qualities: [Double] = [0.8, 0.6, 0.4, 0.25]

    public init() {}

    public static let standard = PhotoPolicy()

    /// The size to draw the image at: unchanged if it fits, otherwise scaled so its
    /// longest side is maxPixelSize, keeping the aspect ratio.
    public func targetSize(width: Double, height: Double) -> (width: Double, height: Double) {
        let longest = max(width, height)
        guard longest > maxPixelSize, longest > 0 else { return (width, height) }
        let scale = maxPixelSize / longest
        return ((width * scale).rounded(), (height * scale).rounded())
    }

    /// Tries each quality in turn and returns the first encoding small enough.
    public func compress(using encode: (Double) -> Data?) -> Data? {
        for quality in qualities {
            if let data = encode(quality), data.count <= maxBytes { return data }
        }
        return nil
    }
}
// </photopolicy>
