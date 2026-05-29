import UIKit
import ImageIO

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

    /// Decoded thumbnails keyed by "<name>@<maxPixel>". Lab scans are
    /// often 20MP+, so re-decoding the full JPEG on every SwiftUI render
    /// (and during a swipe) hitches badly — caching the downsampled
    /// result keeps strip scrolling smooth.
    private static let thumbnailCache = NSCache<NSString, UIImage>()

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

    /// Resolve a photo name from `FilmRoll.photos` to a full-resolution
    /// UIImage. Tries the bundle (sample rolls) first, then the
    /// Documents directory (user-imported photos). Use this only where
    /// full resolution matters (e.g. the 1080×1920 export render) —
    /// for on-screen strips/grids prefer `thumbnail(named:maxPixel:)`.
    static func image(named name: String) -> UIImage? {
        guard !name.isEmpty else { return nil }
        if let img = UIImage(named: name) { return img }
        let fileURL = rootURL.appendingPathComponent(name)
        return UIImage(contentsOfFile: fileURL.path)
    }

    /// Resolve a photo to a downsampled UIImage whose longest side is
    /// roughly `maxPixel`, decoded straight to that size via ImageIO so
    /// the full-resolution bitmap never touches memory. Cached by
    /// name+size. This is what the film strip and contact-sheet grids
    /// should use for smooth scrolling.
    static func thumbnail(named name: String, maxPixel: CGFloat) -> UIImage? {
        guard !name.isEmpty else { return nil }
        let key = "\(name)@\(Int(maxPixel))" as NSString
        if let cached = thumbnailCache.object(forKey: key) {
            return cached
        }
        guard let url = fileURL(for: name) else {
            // Couldn't resolve a file URL (shouldn't happen) — fall back
            // to the full-resolution loader so the photo still shows.
            return image(named: name)
        }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ]
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let cgImage = CGImageSourceCreateThumbnailAtIndex(
                source, 0, options as CFDictionary
              ) else {
            return UIImage(contentsOfFile: url.path)
        }
        let thumb = UIImage(cgImage: cgImage)
        thumbnailCache.setObject(thumb, forKey: key)
        return thumb
    }

    /// Map a photo name to its on-disk file URL — Documents for imported
    /// photos ("<rollID>/<file>"), or the flattened bundle resource for
    /// the bundled sample rolls ("0003_36.jpg").
    private static func fileURL(for name: String) -> URL? {
        let docURL = rootURL.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: docURL.path) {
            return docURL
        }
        let base = (name as NSString).deletingPathExtension
        let ext = (name as NSString).pathExtension
        return Bundle.main.url(forResource: base, withExtension: ext)
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
