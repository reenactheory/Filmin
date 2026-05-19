import SwiftUI

struct FilmCanisterView: View {
    let filmStock: String
    let frameCount: Int

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                Image("FilmCanister")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: w, height: h)

                // "Portra 400" — centered on white label
                Text(filmStock)
                    .font(.system(size: max(8, w * 0.13), weight: .semibold))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .frame(width: w * 0.42)
                    .offset(x: w * 0.13, y: 0)

                // "35mm | XXEXP" — vertical, left side of label
                Text("35mm | \(frameCount)EXP")
                    .font(.system(size: max(6, w * 0.05), weight: .medium))
                    .foregroundStyle(.black.opacity(0.75))
                    .rotationEffect(.degrees(-90))
                    .fixedSize()
                    .offset(x: -w * 0.05, y: 0)
            }
        }
        .aspectRatio(510.0 / 730.0, contentMode: .fit)
    }
}

#Preview {
    HStack(spacing: 16) {
        FilmCanisterView(filmStock: "Portra 400", frameCount: 17)
            .frame(width: 160)
        FilmCanisterView(filmStock: "UltraMax 400", frameCount: 36)
            .frame(width: 160)
    }
    .padding()
}
