import SwiftUI

struct FilmCanisterView: View {
    let filmStock: String
    let frameCount: Int

    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            ZStack {
                photoBackdrop(side: side)
                canister(side: side)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func labelText(w: CGFloat, h: CGFloat) -> some View {
        // Force two-line layout by replacing the first space with a newline,
        // so "KODACOLOR 200" lays out as "KODACOLOR" / "200" instead of being
        // broken mid-word at the frame edge.
        let display = filmStock.replacingOccurrences(of: " ", with: "\n", options: [], range: filmStock.range(of: " "))
        return Text(display)
            .font(.system(size: w * 0.18, weight: .bold))
            .foregroundStyle(.black)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .lineSpacing(-w * 0.03)
            .minimumScaleFactor(0.45)
            .allowsTightening(true)
            .frame(width: w * 0.48)
            .position(x: w * 0.66, y: h * 0.5)
    }

    private func canister(side: CGFloat) -> some View {
        Image("FilmCanister")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: side * 0.78)
            .overlay(
                GeometryReader { imgGeo in
                    let w = imgGeo.size.width
                    let h = imgGeo.size.height

                    ZStack {
                        labelText(w: w, h: h)

                        // Vertical "35mm | XXEXP" — placed near the left edge
                        // of the white label, inside the label area
                        Text("35mm | \(frameCount)EXP")
                            .font(.system(size: w * 0.072, weight: .semibold))
                            .foregroundStyle(.black)
                            .fixedSize()
                            .rotationEffect(.degrees(-90))
                            .position(x: w * 0.475, y: h * 0.5)
                    }
                }
            )
            .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 4)
    }

    private func photoBackdrop(side: CGFloat) -> some View {
        ZStack {
            photoPrint(width: side * 0.52, height: side * 0.68, palette: .sky)
                .rotationEffect(.degrees(-14))
                .offset(x: -side * 0.16, y: -side * 0.08)

            photoPrint(width: side * 0.48, height: side * 0.62, palette: .shadow)
                .rotationEffect(.degrees(9))
                .offset(x: side * 0.18, y: -side * 0.12)
        }
    }

    private enum Palette { case sky, shadow }

    private func photoPrint(width: CGFloat, height: CGFloat, palette: Palette) -> some View {
        let colors: [Color] = {
            switch palette {
            case .sky:
                return [
                    Color(red: 0.62, green: 0.74, blue: 0.84),
                    Color(red: 0.40, green: 0.52, blue: 0.62)
                ]
            case .shadow:
                return [
                    Color(red: 0.28, green: 0.30, blue: 0.34),
                    Color(red: 0.12, green: 0.14, blue: 0.18)
                ]
            }
        }()

        return RoundedRectangle(cornerRadius: 5, style: .continuous)
            .fill(LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom))
            .frame(width: width, height: height)
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(Color.black.opacity(0.9), lineWidth: 2.5)
            )
            .shadow(color: .black.opacity(0.18), radius: 4, x: 0, y: 3)
    }
}

#Preview {
    VStack {
        HStack(spacing: 16) {
            FilmCanisterView(filmStock: "Portra 400", frameCount: 17)
                .frame(width: 160, height: 160)
            FilmCanisterView(filmStock: "UltraMax 400", frameCount: 36)
                .frame(width: 160, height: 160)
        }
        HStack(spacing: 16) {
            FilmCanisterView(filmStock: "ProImage 100", frameCount: 35)
                .frame(width: 160, height: 160)
            FilmCanisterView(filmStock: "KODACOLOR 200", frameCount: 37)
                .frame(width: 160, height: 160)
        }
    }
    .padding()
    .background(Color.white)
}
