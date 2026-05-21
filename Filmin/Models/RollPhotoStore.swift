import UIKit

/// Stores photos that the user imports from the Files app (or Photos
/// picker) so they survive app restarts. Photos are written under
/// `Documents/RollPhotos/<rollID>/<filename>` and referenced from
/// `FilmRoll.photos` by their relative path (`"<rollID>/<filename>"`).
///
/// Loading is transparent across both storage worlds: `image(named:)`
/// first tries the asset catalog (bundled sample photos) and falls back
/// to the Documents directory (user-imported photos).
enum RollPhotoStore {
    private static let folderName = "RollPhotos"

    private static var rootURL: URL {
        let docs = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        let url = docs.appendingPathComponent(folderName, isDirectory: true)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(
                at: url,
                withIntermediateDirectories: true
            )
        }
        return url
    }

    /// Resolve a photo name from `FilmRoll.photos` to a UIImage.
    /// Tries the bundle asset catalog first (sample rolls), then falls
    /// back to the imported photo at `Documents/RollPhotos/<name>`.
    static func image(named name: String) -> UIImage? {
        guard !name.isEmpty else { return nil }
        if let img = UIImage(named: name) { return img }
        let fileURL = rootURL.appendingPathComponent(name)
        return UIImage(contentsOfFile: fileURL.path)
    }

    /// Save image data for the given roll. Returns the relative path
    /// (`"<rollID>/<filename>"`) suitable for `FilmRoll.photos`, or nil
    /// on failure. Filenames are made unique within the roll's folder
    /// by appending a numeric suffix if a name collision happens.
    @discardableResult
    static func saveImported(
        data: Data,
        originalName: String,
        rollID: UUID
    ) -> String? {
        let rollDir = rootURL.appendingPathComponent(rollID.uuidString, isDirectory: true)
        if !FileManager.default.fileExists(atPath: rollDir.path) {
            do {
                try FileManager.default.createDirectory(
                    at: rollDir,
                    withIntermediateDirectories: true
                )
            } catch {
                return nil
            }
        }

        let filename = uniqueFilename(in: rollDir, base: sanitize(originalName))
        let dest = rollDir.appendingPathComponent(filename)
        do {
            try data.write(to: dest, options: [.atomic])
        } catch {
            return nil
        }
        return "\(rollID.uuidString)/\(filename)"
    }

    /// Delete every photo owned by this roll. Call when the user
    /// deletes the roll so we don't accumulate orphaned files.
    static func deleteAll(rollID: UUID) {
        let rollDir = rootURL.appendingPathComponent(rollID.uuidString, isDirectory: true)
        try? FileManager.default.removeItem(at: rollDir)
    }

    // MARK: - Helpers

    /// Replace path separators and anything weird in user-supplied
    /// filenames with `_` so we never escape the roll's folder.
    private static func sanitize(_ name: String) -> String {
        let allowed = CharacterSet.alphanumerics
            .union(.init(charactersIn: "._- "))
        let cleaned = name.unicodeScalars.map {
            allowed.contains($0) ? Character($0) : "_"
        }
        let result = String(cleaned).trimmingCharacters(in: .whitespaces)
        return result.isEmpty ? "image.jpg" : result
    }

    /// Append `-1`, `-2`, … before the extension if needed to avoid
    /// overwriting an existing file in `dir`.
    private static func uniqueFilename(in dir: URL, base: String) -> String {
        var candidate = base
        var counter = 1
        let baseURL = dir.appendingPathComponent(base)
        if !FileManager.default.fileExists(atPath: baseURL.path) {
            return candidate
        }
        let ext = (base as NSString).pathExtension
        let stem = (base as NSString).deletingPathExtension
        while true {
            candidate = ext.isEmpty ? "\(stem)-\(counter)" : "\(stem)-\(counter).\(ext)"
            let url = dir.appendingPathComponent(candidate)
            if !FileManager.default.fileExists(atPath: url.path) {
                return candidate
            }
            counter += 1
        }
    }
}
