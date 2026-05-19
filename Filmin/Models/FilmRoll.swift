import Foundation

struct FilmRoll: Identifiable, Hashable {
    let id: UUID
    var title: String
    var frameCount: Int
    var filmStock: String
    var camera: String

    init(id: UUID = UUID(), title: String, frameCount: Int, filmStock: String, camera: String) {
        self.id = id
        self.title = title
        self.frameCount = frameCount
        self.filmStock = filmStock
        self.camera = camera
    }
}

extension FilmRoll {
    static let samples: [FilmRoll] = [
        .init(title: "Jeju", frameCount: 17, filmStock: "Portra 400", camera: "Leica R3"),
        .init(title: "홍콩 & 삿포로", frameCount: 36, filmStock: "UltraMax 400", camera: "Leica R3"),
        .init(title: "한강 테스트롤", frameCount: 35, filmStock: "ProImage 100", camera: "Leica AF-C1"),
        .init(title: "홍콩 & 삿포로", frameCount: 37, filmStock: "KODACOLOR 200", camera: "Leica M6"),
        .init(title: "도쿄 산책", frameCount: 24, filmStock: "Portra 800", camera: "Leica M6"),
        .init(title: "교토 가을", frameCount: 36, filmStock: "Ektar 100", camera: "Leica R3")
    ]
}
