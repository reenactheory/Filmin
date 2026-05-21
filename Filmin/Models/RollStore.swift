import Foundation

/// Persists the user's film rolls to a JSON file in the app's Documents
/// directory so the list survives across app launches.
///
/// First launch behavior: if no file exists yet, callers fall back to
/// `FilmRoll.samples` and the first mutation writes the file.
enum RollStore {
    private static let filename = "rolls.json"

    private static var fileURL: URL {
        let docs = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        return docs.appendingPathComponent(filename)
    }

    /// Load the saved rolls. Returns nil if no file exists (first launch)
    /// or the file can't be read — caller decides the fallback.
    static func load() -> [FilmRoll]? {
        guard FileManager.default.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode([FilmRoll].self, from: data)
    }

    /// Write the rolls to disk. Best-effort — silently ignores errors so
    /// a transient write failure doesn't crash the UI.
    static func save(_ rolls: [FilmRoll]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(rolls) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }
}
