import Foundation

struct FilmRoll: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var filmStock: String
    var camera: String
    /// Photos added to this roll. Placeholder strings for now;
    /// will hold real photo data once photo capture is wired up.
    var photos: [String]

    // Detail view fields
    /// Optional brand prefix (e.g., "Kodak"). Used to render the full
    /// name on the detail view: "{brand} {filmStock}".
    var brand: String?
    /// Film format — defaults to 135 (the most common analog format).
    var format: String
    /// Where the film was developed (e.g., "엘리카메라에서").
    var location: String?
    /// When the film was developed.
    var developedAt: Date?

    var photoCount: Int { photos.count }

    /// "Kodak UltraMax 400" — brand prefix if set, otherwise raw filmStock.
    var fullName: String {
        if let brand, !brand.isEmpty {
            return "\(brand) \(filmStock)"
        }
        return filmStock
    }

    /// ISO derived from the trailing integer of filmStock (e.g., "Portra 400" → 400).
    var iso: Int? {
        guard let last = filmStock.split(separator: " ").last,
              let n = Int(last) else { return nil }
        return n
    }

    /// Three deterministic-random photos from this roll, used as the
    /// canister backdrop. The same roll always returns the same trio
    /// (within a session) since the RNG is seeded by `id`.
    var backdropPhotos: [String] {
        guard !photos.isEmpty else { return [] }
        var rng = SeededGenerator(seed: id.hashValue)
        return Array(photos.shuffled(using: &rng).prefix(3))
    }

    init(
        id: UUID = UUID(),
        title: String,
        filmStock: String,
        camera: String,
        photos: [String] = [],
        brand: String? = nil,
        format: String = "135",
        location: String? = nil,
        developedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.filmStock = filmStock
        self.camera = camera
        self.photos = photos
        self.brand = brand
        self.format = format
        self.location = location
        self.developedAt = developedAt
    }
}

/// Simple seeded RNG (xorshift64*) so that `backdropPhotos` can pick
/// a stable random trio from each roll.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: Int) {
        let unsigned = UInt64(bitPattern: Int64(seed))
        self.state = unsigned == 0 ? 0x9E3779B97F4A7C15 : unsigned
    }

    mutating func next() -> UInt64 {
        state ^= state &>> 12
        state ^= state &<< 25
        state ^= state &>> 27
        return state &* 0x2545F4914F6CDD1D
    }
}

extension FilmRoll {
    /// Default rolls shown on first launch. Intentionally empty for
    /// shipping — mock rolls (if desired) get appended here before
    /// publishing a build. The previous personal-scan samples have
    /// been removed so they don't leak into the App Store binary.
    static let samples: [FilmRoll] = []
}
