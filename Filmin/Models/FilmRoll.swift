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
    /// Curated mock rolls bundled into the App Store binary so new
    /// users see how a filled-out roll looks. The scans live under
    /// `Filmin/Resources/SampleRolls/<title>/` — Xcode flattens them
    /// to the bundle root so `UIImage(named:)` resolves by filename.
    static let samples: [FilmRoll] = [
        .init(
            title: "기타큐슈",
            filmStock: "Portra 400",
            camera: "Leica M6",
            photos: kitakyushuPhotos,
            brand: "Kodak",
            developedAt: dateFromString("2024-09-15")
        ),
        .init(
            title: "홍콩 & 삿포로",
            filmStock: "UltraMax 400",
            camera: "Leica M6",
            photos: hkSapporoPhotos,
            brand: "Kodak",
            developedAt: dateFromString("2024-12-10")
        ),
        .init(
            title: "중형 테스트",
            filmStock: "Ektar 100",
            camera: "Hasselblad 500CM",
            photos: mediumTestPhotos,
            brand: "Kodak",
            format: "120",
            developedAt: dateFromString("2024-10-05")
        )
    ]

    /// 23 scans, listed in scanner (file) order — the same sequence the
    /// lab returned them in, frame 36 down to frame 1.
    private static let kitakyushuPhotos: [String] = [
        "0003_36.jpg", "0004_35.jpg", "0005_34.jpg", "0006_33.jpg",
        "0009_30.jpg", "0015_24.jpg", "0017_22.jpg", "0018_21.jpg",
        "0019_20.jpg", "0020_19.jpg", "0021_18.jpg", "0022_17.jpg",
        "0023_16.jpg", "0024_15.jpg", "0025_14.jpg", "0027_12.jpg",
        "0028_11.jpg", "0029_10.jpg", "0030_9.jpg", "0031_8.jpg",
        "0033_6.jpg", "0035_4.jpg", "0038_1.jpg"
    ]

    /// 14 scans from "홍콩 & 삿포로", scanner order.
    private static let hkSapporoPhotos: [String] = [
        "0003_0.jpg", "0004_1.jpg", "0005_2.jpg", "0006_3.jpg",
        "0011_8.jpg", "0013_10.jpg", "0015_12.jpg", "0022_19.jpg",
        "0026_23.jpg", "0027_24.jpg", "0028_25.jpg", "0029_26.jpg",
        "0030_27.jpg", "0036_33.jpg"
    ]

    /// 8 medium-format scans (some intermediate frames skipped).
    private static let mediumTestPhotos: [String] = [
        "30360001.JPG", "30360002.JPG", "30360003.JPG", "30360004.JPG",
        "30360005.JPG", "30360010.JPG", "30360011.JPG", "30360013.JPG"
    ]

    private static func dateFromString(_ s: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: s)
    }
}
