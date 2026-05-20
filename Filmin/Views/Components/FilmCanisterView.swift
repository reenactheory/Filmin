import SwiftUI

struct FilmCanisterView: View {
    let filmStock: String
    let frameCount: Int
    /// Up to 3 photos to render in the backdrop behind the canister.
    /// Pass image asset/bundle names (empty string → gradient fallback).
    var backdropPhotos: [String] = []

    private let labelColor = Color(hex: "#27272A")
    private let stripTextColor = Color(hex: "#FAFAFA")

    var body: some View {
        ZStack {
            photoBackdrop
            canister
        }
        .frame(width: 160, height: 180)
    }

    private static let canisterWidth: CGFloat = 120
    private static let canisterHeight: CGFloat = 175

    private var canister: some View {
        Image("FilmCanister")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: Self.canisterWidth, height: Self.canisterHeight)
            .overlay(canisterTextOverlay)
            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 3)
    }

    private var canisterTextOverlay: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Film name on white label area.
                // Box top-left anchored at (57, 48.85), width 46 (right edge 103),
                // height 107. Position places the frame center, so
                //   center = (57 + 46/2, 48.85 + 107/2) = (80, 102.35).
                labelText
                    .position(x: 80, y: 102.35)

                // 35mm | XXEXP — design spec spacing scaled to 120x175:
                //   top 72.02, left 37.5, bottom 44.95 (from 65.85/35/41.09 @ 112x160)
                //   x = 37.5 + halfRotatedWidth(~7) - 2 (user nudge) = 42.5
                //   y = (72.02 + (175 - 44.95)) / 2 = 101.04
                Text("35mm | \(frameCount)EXP")
                    .font(.pretendard(.medium, size: 11))
                    .foregroundStyle(stripTextColor)
                    .fixedSize()
                    .rotationEffect(.degrees(-90))
                    .position(x: 42.5, y: 101.04)
            }
        }
    }

    private var labelText: some View {
        let layout = labelLayout
        let longestBrand = layout.brand.map(\.count).max() ?? 0
        let suffixSize: CGFloat = {
            switch longestBrand {
            case ...5: return 15
            case 6...7: return 14
            default: return 13
            }
        }()
        let isSplit = layout.brand.count > 1
        // Split brand parts ride a touch smaller so they read as one
        // compound word broken across lines instead of separate words.
        let brandSize: CGFloat = isSplit ? max(11, suffixSize - 2) : suffixSize

        return VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: isSplit ? -2 : 0) {
                ForEach(layout.brand.indices, id: \.self) { idx in
                    Text(layout.brand[idx])
                        .font(.pretendard(.bold, size: brandSize))
                }
            }

            if let suffix = layout.suffix {
                Text(suffix)
                    .font(.pretendard(.bold, size: suffixSize))
            }
        }
        .lineLimit(1)
        .minimumScaleFactor(0.5)
        .foregroundStyle(labelColor)
        .frame(width: 46, alignment: .leading)
        .padding(.top, 6)
        .frame(width: 46, height: 107, alignment: .topLeading)
    }

    private struct LabelLayout {
        let brand: [String]
        let suffix: String?
    }

    /// Split the film stock into brand parts + suffix (the ISO number).
    /// Examples:
    ///   "Portra 400"      → brand: ["Portra"],       suffix: "400"
    ///   "UltraMax 400"    → brand: ["Ultra", "Max"], suffix: "400"
    ///   "KODACOLOR 200"   → brand: ["KODA", "COLOR"],suffix: "200"
    private var labelLayout: LabelLayout {
        let words = filmStock.split(separator: " ").map(String.init)
        let brand = words.first ?? filmStock
        let suffix = words.count > 1 ? words[1] : nil

        let brandParts = Self.knownWordSplits[brand] ?? Self.splitCamelCase(brand)
        return LabelLayout(brand: brandParts, suffix: suffix)
    }

    /// All-caps brand words that don't have a camelCase boundary;
    /// add entries as more film stocks are introduced.
    private static let knownWordSplits: [String: [String]] = [
        "KODACOLOR": ["KODA", "COLOR"]
    ]

    private static func splitCamelCase(_ s: String) -> [String] {
        var result: [String] = []
        var current = ""
        for (i, ch) in s.enumerated() {
            if i > 0, ch.isUppercase {
                let prevIdx = s.index(s.startIndex, offsetBy: i - 1)
                if s[prevIdx].isLowercase {
                    result.append(current)
                    current = ""
                }
            }
            current.append(ch)
        }
        if !current.isEmpty { result.append(current) }
        return result
    }

    private var photoBackdrop: some View {
        ZStack {
            backdropPrint(photoIndex: 0, palette: .sky)
                .rotationEffect(.degrees(-14))
                .offset(x: -28, y: -34)

            backdropPrint(photoIndex: 1, palette: .dusk)
                .rotationEffect(.degrees(-2))
                .offset(x: 0, y: -42)

            backdropPrint(photoIndex: 2, palette: .shadow)
                .rotationEffect(.degrees(12))
                .offset(x: 30, y: -34)
        }
    }

    private enum Palette { case sky, dusk, shadow }

    /// One backdrop print: if a photo name is provided for this slot,
    /// render the image cropped to fill; otherwise fall back to a
    /// gradient. Either way, clip to the print's rounded rect + shadow.
    @ViewBuilder
    private func backdropPrint(photoIndex: Int, palette: Palette) -> some View {
        Group {
            if photoIndex < backdropPhotos.count,
               !backdropPhotos[photoIndex].isEmpty,
               let uiImage = UIImage(named: backdropPhotos[photoIndex]) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                LinearGradient(
                    colors: paletteColors(palette),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .frame(width: 72, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
        .shadow(color: .black.opacity(0.22), radius: 8, x: 0, y: 4)
    }

    private func paletteColors(_ palette: Palette) -> [Color] {
        switch palette {
        case .sky:
            return [
                Color(red: 0.66, green: 0.78, blue: 0.86),
                Color(red: 0.42, green: 0.54, blue: 0.64)
            ]
        case .dusk:
            return [
                Color(red: 0.45, green: 0.50, blue: 0.58),
                Color(red: 0.25, green: 0.30, blue: 0.36)
            ]
        case .shadow:
            return [
                Color(red: 0.28, green: 0.30, blue: 0.34),
                Color(red: 0.12, green: 0.14, blue: 0.18)
            ]
        }
    }
}

#Preview {
    VStack(spacing: 24) {
        HStack(spacing: 16) {
            FilmCanisterView(filmStock: "Portra 400", frameCount: 17)
            FilmCanisterView(filmStock: "UltraMax 400", frameCount: 36)
        }
        HStack(spacing: 16) {
            FilmCanisterView(filmStock: "ProImage 100", frameCount: 35)
            FilmCanisterView(filmStock: "KODACOLOR 200", frameCount: 37)
        }
    }
    .padding()
    .background(Color.white)
}
