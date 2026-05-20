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
    static let samples: [FilmRoll] = [
        .init(title: "Jeju", filmStock: "Portra 400", camera: "Leica R3",
              photos: Array(repeating: "", count: 17),
              brand: "Kodak",
              location: "엘리카메라에서",
              developedAt: dateFromString("2025-03-15")),
        .init(title: "김재연 #2", filmStock: "UltraMax 400", camera: "Leica R3",
              photos: ultraMax400Roll2Photos,
              brand: "Kodak",
              location: "엘리카메라에서",
              developedAt: dateFromString("2025-04-12")),
        .init(title: "한강 테스트롤", filmStock: "ProImage 100", camera: "Leica AF-C1",
              photos: Array(repeating: "", count: 35),
              brand: "Kodak",
              location: "엘리카메라에서",
              developedAt: dateFromString("2025-02-20")),
        .init(title: "홍콩 & 삿포로", filmStock: "KODACOLOR 200", camera: "Leica M6",
              photos: Array(repeating: "", count: 37),
              brand: "Kodak",
              location: "엘리카메라에서",
              developedAt: dateFromString("2025-04-15")),
        .init(title: "도쿄 산책", filmStock: "Portra 800", camera: "Leica M6",
              photos: Array(repeating: "", count: 24),
              brand: "Kodak",
              location: "엘리카메라에서",
              developedAt: dateFromString("2025-01-20")),
        .init(title: "교토 가을", filmStock: "Ektar 100", camera: "Leica R3",
              photos: Array(repeating: "", count: 36),
              brand: "Kodak",
              location: "엘리카메라에서",
              developedAt: dateFromString("2024-12-05"))
    ]

    private static func dateFromString(_ s: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: s)
    }

    /// Bundled photos for the "김재연 울트라맥스400 2" sample roll.
    /// Ordered frame 1 → frame 36 (oldest to newest exposure).
    /// Files live in `Filmin/Resources/SampleRollPhotos/`.
    /// All 38 developed scans from the "김재연 울트라맥스400 2" roll,
    /// in the order they came out of the scanner (file order).
    /// `photoCount` therefore reflects how many photos were
    /// actually developed, not the film's frame capacity.
    private static let ultraMax400Roll2Photos: [String] = [
        "0001_###.jpg", "0002_E.jpg",
        "0003_36.jpg", "0004_35.jpg", "0005_34.jpg",
        "0006_33.jpg", "0007_32.jpg", "0008_31.jpg", "0009_30.jpg", "0010_29.jpg",
        "0011_28.jpg", "0012_27.jpg", "0013_26.jpg", "0014_25.jpg", "0015_24.jpg",
        "0016_23.jpg", "0017_22.jpg", "0018_21.jpg", "0019_20.jpg", "0020_19.jpg",
        "0021_18.jpg", "0022_17.jpg", "0023_16.jpg", "0024_15.jpg", "0025_14.jpg",
        "0026_13.jpg", "0027_12.jpg", "0028_11.jpg", "0029_10.jpg", "0030_9.jpg",
        "0031_8.jpg", "0032_7.jpg", "0033_6.jpg", "0034_5.jpg", "0035_4.jpg",
        "0036_3.jpg", "0037_2.jpg", "0038_1.jpg"
    ]
}
