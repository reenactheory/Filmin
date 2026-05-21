import Foundation

/// Persists the user's camera list (including any photo data they
/// attached) to a JSON file in the app's Documents directory so the
/// list survives across app launches.
///
/// First launch behavior: if no file exists yet, callers fall back to
/// `Camera.samples` and the first mutation writes the file.
enum CameraStore {
    private static let filename = "cameras.json"

    private static var fileURL: URL {
        let docs = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        return docs.appendingPathComponent(filename)
    }

    /// Load the saved cameras. Returns nil if no file exists (first
    /// launch) or the file can't be read — caller decides the fallback.
    static func load() -> [Camera]? {
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode([Camera].self, from: data)
    }

    /// Write the cameras to disk. Best-effort — silently ignores errors
    /// so a transient write failure doesn't crash the UI.
    static func save(_ cameras: [Camera]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(cameras) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }
}
