import Foundation

/// Format size category used in film photography.
enum CameraFormatCategory: String, Codable {
    case small = "소형"     // 35mm, half-frame
    case medium = "중형"    // 120 / 220
    case large = "대형"     // 4x5, 8x10
    case instant = "인스턴트"
    case other = "기타"
}

struct Camera: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var brand: String?
    /// Specific format string: "35mm", "120", "4x5", "Instant", etc.
    var format: String
    /// When the user acquired the camera (optional).
    var purchaseDate: Date?
    /// When the user retired / sold the camera (optional). Set when
    /// the user taps "사용 종료" on the detail view.
    var retiredDate: Date?
    var notes: String?
    /// Currently in active rotation vs. retired / sold.
    var isActive: Bool
    /// JPEG/PNG data of a user-uploaded photo of the camera.
    var photoData: Data?

    init(
        id: UUID = UUID(),
        name: String,
        brand: String? = nil,
        format: String = "35mm",
        purchaseDate: Date? = nil,
        retiredDate: Date? = nil,
        notes: String? = nil,
        isActive: Bool = true,
        photoData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.brand = brand
        self.format = format
        self.purchaseDate = purchaseDate
        self.retiredDate = retiredDate
        self.notes = notes
        self.isActive = isActive
        self.photoData = photoData
    }
}

// MARK: - Derived metadata

extension Camera {
    /// 소형 / 중형 / 대형 / 인스턴트 / 기타 — derived from `format`.
    var formatCategory: CameraFormatCategory {
        switch format {
        case "35mm", "Half-frame": return .small
        case "120", "220": return .medium
        case "4x5", "8x10", "Large Format": return .large
        case "Instant": return .instant
        default: return .other
        }
    }

    /// e.g., "2020년 5월 14일" — formatted Korean date.
    var purchaseDateDescription: String? {
        Self.formatKoreanDate(purchaseDate)
    }

    /// e.g., "2024년 11월 3일" — when the camera was retired/sold.
    var retiredDateDescription: String? {
        Self.formatKoreanDate(retiredDate)
    }

    private static func formatKoreanDate(_ date: Date?) -> String? {
        guard let date else { return nil }
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일"
        return f.string(from: date)
    }

    /// e.g., "3년 7개월" — usage period. If retired, runs purchase→retired;
    /// otherwise purchase→now.
    var usageDurationDescription: String? {
        guard let purchaseDate else { return nil }
        let endDate = retiredDate ?? Date()
        let comps = Calendar.current.dateComponents(
            [.year, .month],
            from: purchaseDate,
            to: endDate
        )
        let years = max(0, comps.year ?? 0)
        let months = max(0, comps.month ?? 0)

        if years > 0 && months > 0 {
            return "\(years)년 \(months)개월"
        } else if years > 0 {
            return "\(years)년"
        } else if months > 0 {
            return "\(months)개월"
        } else {
            return "1개월 미만"
        }
    }
}

// MARK: - Samples

extension Camera {
    /// Default cameras shown on first launch. Empty for shipping —
    /// users add their own via the Cameras tab. The previous samples
    /// embedded personal purchase dates and notes, so they were
    /// removed before App Store submission.
    static let samples: [Camera] = []
}
