import Foundation

struct FilmRoll: Identifiable, Hashable {
    let id: UUID
    var title: String
    var filmStock: String
    var camera: String
    /// Photos added to this roll. Placeholder strings for now;
    /// will hold real photo data once photo capture is wired up.
    var photos: [String]

    var photoCount: Int { photos.count }

    init(
        id: UUID = UUID(),
        title: String,
        filmStock: String,
        camera: String,
        photos: [String] = []
    ) {
        self.id = id
        self.title = title
        self.filmStock = filmStock
        self.camera = camera
        self.photos = photos
    }
}

extension FilmRoll {
    static let samples: [FilmRoll] = [
        .init(title: "Jeju", filmStock: "Portra 400", camera: "Leica R3",
              photos: Array(repeating: "", count: 17)),
        .init(title: "홍콩 & 삿포로", filmStock: "UltraMax 400", camera: "Leica R3",
              photos: Array(repeating: "", count: 36)),
        .init(title: "한강 테스트롤", filmStock: "ProImage 100", camera: "Leica AF-C1",
              photos: Array(repeating: "", count: 35)),
        .init(title: "홍콩 & 삿포로", filmStock: "KODACOLOR 200", camera: "Leica M6",
              photos: Array(repeating: "", count: 37)),
        .init(title: "도쿄 산책", filmStock: "Portra 800", camera: "Leica M6",
              photos: Array(repeating: "", count: 24)),
        .init(title: "교토 가을", filmStock: "Ektar 100", camera: "Leica R3",
              photos: Array(repeating: "", count: 36))
    ]
}
