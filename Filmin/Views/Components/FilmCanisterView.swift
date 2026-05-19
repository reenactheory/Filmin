import SwiftUI

struct FilmCanisterView: View {
    let filmStock: String
    let frameCount: Int

    private let labelColor = Color(hex: "#27272A")
    private let stripTextColor = Color(hex: "#FAFAFA")

    var body: some View {
        ZStack {
            photoBackdrop
            canister
        }
        .frame(width: 160, height: 180)
    }

    private static let canisterWidth: CGFloat = 112
    private static let canisterHeight: CGFloat = 160

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
                // Film name — 2 lines, dynamic size, on white label
                labelText
                    .frame(width: w * 0.46)
                    .position(x: w * 0.66, y: h * 0.5)

                // 35mm | XXEXP — centered on the LEFT BLACK canister edge.
                // y is offset to ~0.53 because the canister has a black cap
                // at the top, so the body's true vertical center sits below
                // the image's geometric center.
                Text("35mm | \(frameCount)EXP")
                    .font(.pretendard(.medium, size: 10))
                    .foregroundStyle(stripTextColor)
                    .fixedSize()
                    .rotationEffect(.degrees(-90))
                    .position(x: w * 0.305, y: h * 0.53)
            }
        }
    }

    private var labelText: some View {
        let parts = filmStock.split(separator: " ", maxSplits: 1).map(String.init)
        let firstLine = parts.first ?? filmStock
        let secondLine = parts.count > 1 ? parts[1] : ""

        return VStack(spacing: 0) {
            Text(firstLine)
            Text(secondLine)
        }
        .font(.pretendard(.bold, size: dynamicLabelSize))
        .foregroundStyle(labelColor)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }

    private var dynamicLabelSize: CGFloat {
        // Size 12-14 based on longest word in the film stock name
        let longestWord = filmStock
            .split(separator: " ")
            .map(\.count)
            .max() ?? filmStock.count
        switch longestWord {
        case ...5: return 14
        case 6...7: return 13
        default: return 12
        }
    }

    private var photoBackdrop: some View {
        let photoSize = CGSize(width: 72, height: 100)
        return ZStack {
            photoPrint(palette: .sky)
                .frame(width: photoSize.width, height: photoSize.height)
                .rotationEffect(.degrees(-14))
                .offset(x: -28, y: -34)

            photoPrint(palette: .dusk)
                .frame(width: photoSize.width, height: photoSize.height)
                .rotationEffect(.degrees(-2))
                .offset(x: 0, y: -42)

            photoPrint(palette: .shadow)
                .frame(width: photoSize.width, height: photoSize.height)
                .rotationEffect(.degrees(12))
                .offset(x: 30, y: -34)
        }
    }

    private enum Palette { case sky, dusk, shadow }

    private func photoPrint(palette: Palette) -> some View {
        let colors: [Color] = {
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
        }()

        return RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(Color.black.opacity(0.9), lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
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
