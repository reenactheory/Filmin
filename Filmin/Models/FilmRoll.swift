import Foundation

struct FilmRoll: Identifiable, Hashable {
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

extension FilmRoll {
    static let samples: [FilmRoll] = [
        .init(title: "Jeju", filmStock: "Portra 400", camera: "Leica R3",
              photos: Array(repeating: "", count: 17),
              brand: "Kodak"),
        .init(title: "홍콩 & 삿포로", filmStock: "UltraMax 400", camera: "Leica R3",
              photos: Array(repeating: "", count: 36),
              brand: "Kodak",
              location: "엘리카메라에서",
              developedAt: dateFromString("2025-04-12")),
        .init(title: "한강 테스트롤", filmStock: "ProImage 100", camera: "Leica AF-C1",
              photos: Array(repeating: "", count: 35),
              brand: "Kodak"),
        .init(title: "홍콩 & 삿포로", filmStock: "KODACOLOR 200", camera: "Leica M6",
              photos: Array(repeating: "", count: 37),
              brand: "Kodak"),
        .init(title: "도쿄 산책", filmStock: "Portra 800", camera: "Leica M6",
              photos: Array(repeating: "", count: 24),
              brand: "Kodak"),
        .init(title: "교토 가을", filmStock: "Ektar 100", camera: "Leica R3",
              photos: Array(repeating: "", count: 36),
              brand: "Kodak")
    ]

    private static func dateFromString(_ s: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: s)
    }
}
