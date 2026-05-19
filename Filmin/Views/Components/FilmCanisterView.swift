import SwiftUI

struct FilmCanisterView: View {
    let filmStock: String
    let frameCount: Int

    var body: some View {
        ZStack {
            photoStripsBackdrop
            canister
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var photoStripsBackdrop: some View {
        ZStack {
            photoStrip
                .rotationEffect(.degrees(-8))
                .offset(x: -28, y: -6)
            photoStrip
                .rotationEffect(.degrees(6))
                .offset(x: 24, y: -10)
        }
    }

    private var photoStrip: some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.72, green: 0.82, blue: 0.88),
                        Color(red: 0.55, green: 0.65, blue: 0.72)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(Color.black.opacity(0.85), lineWidth: 6)
            )
            .frame(width: 110, height: 150)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
    }

    private var canister: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let bodyWidth = w * 0.46
            let bodyHeight = h * 0.78
            let capHeight = h * 0.08

            ZStack {
                // Top cap
                Capsule()
                    .fill(Color.black)
                    .frame(width: bodyWidth * 0.55, height: capHeight)
                    .offset(y: -bodyHeight / 2 + capHeight * 0.2)

                // Main body
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.white)
                    .frame(width: bodyWidth, height: bodyHeight)
                    .overlay(
                        VStack(spacing: 0) {
                            Rectangle()
                                .fill(Color.black)
                                .frame(height: bodyHeight * 0.18)
                            Spacer()
                            Rectangle()
                                .fill(Color.black)
                                .frame(height: bodyHeight * 0.18)
                        }
                        .frame(width: bodyWidth, height: bodyHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    )
                    .overlay(labelText(bodyWidth: bodyWidth, bodyHeight: bodyHeight))
                    .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)

                // Sprocket holes (left side)
                VStack(spacing: 3) {
                    ForEach(0..<5) { _ in
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 4, height: 6)
                    }
                }
                .offset(x: -bodyWidth / 2 + 6, y: 0)
            }
            .frame(width: w, height: h)
        }
    }

    private func labelText(bodyWidth: CGFloat, bodyHeight: CGFloat) -> some View {
        VStack(spacing: 6) {
            Text(filmStock)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.6)
                .frame(width: bodyWidth * 0.78)

            Text("35mm | \(frameCount)EXP")
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.black.opacity(0.7))
                .rotationEffect(.degrees(-90))
                .fixedSize()
                .offset(x: -bodyWidth * 0.42, y: -bodyHeight * 0.05)
        }
    }
}

#Preview {
    FilmCanisterView(filmStock: "Portra 400", frameCount: 17)
        .frame(width: 200, height: 200)
        .padding()
}
