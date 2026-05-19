import SwiftUI

/// Horizontal film strip viewer: shows the canister leader on the left
/// and the film strip extending right. Each frame of the strip can hold
/// a photo placeholder. Scrollable horizontally so the user can swipe
/// between frames.
struct FilmStripView: View {
    let photos: [String]

    private let stripHeight: CGFloat = 280
    /// Aspect ratio (W:H) of the FilmStrip asset.
    private let stripAspect: CGFloat = 4556.0 / 1220.0
    /// Aspect ratio (W:H) of the FilmLeader asset.
    private let leaderAspect: CGFloat = 786.0 / 1694.0

    var body: some View {
        let leaderWidth = stripHeight * leaderAspect
        let stripWidth = stripHeight * stripAspect

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                Image("FilmLeader")
                    .resizable()
                    .scaledToFit()
                    .frame(width: leaderWidth, height: stripHeight)

                Image("FilmStrip")
                    .resizable()
                    .scaledToFit()
                    .frame(width: stripWidth, height: stripHeight)
                    .overlay(photoOverlays(stripWidth: stripWidth))
            }
        }
        .frame(height: stripHeight)
    }

    /// Position photo placeholders inside the three frames of the
    /// FilmStrip asset. Frame interiors (the white windows) sit at
    /// roughly y = 18%..82% (vertical) and at three horizontal slots
    /// across the strip.
    private func photoOverlays(stripWidth: CGFloat) -> some View {
        let frameTop: CGFloat = 0.18
        let frameBottom: CGFloat = 0.82
        let frameHeightPct = frameBottom - frameTop

        // Each frame's horizontal interior, expressed as (start, end)
        // fraction of the strip width.
        let slots: [(CGFloat, CGFloat)] = [
            (0.040, 0.310),
            (0.365, 0.635),
            (0.690, 0.960)
        ]

        return ZStack(alignment: .topLeading) {
            ForEach(Array(slots.enumerated()), id: \.offset) { idx, slot in
                let x = stripWidth * slot.0
                let w = stripWidth * (slot.1 - slot.0)
                let y = stripHeight * frameTop
                let h = stripHeight * frameHeightPct

                photoPlaceholder(for: idx)
                    .frame(width: w, height: h)
                    .offset(x: x, y: y)
            }
        }
        .frame(width: stripWidth, height: stripHeight, alignment: .topLeading)
    }

    @ViewBuilder
    private func photoPlaceholder(for index: Int) -> some View {
        if index < photos.count {
            // Real photo data would render here. For now, use a
            // soft gradient placeholder so the frame doesn't read empty.
            LinearGradient(
                colors: [
                    Color(red: 0.68, green: 0.80, blue: 0.88),
                    Color(red: 0.42, green: 0.55, blue: 0.45)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            Color.white
        }
    }
}

#Preview {
    FilmStripView(photos: Array(repeating: "", count: 17))
        .background(Color.white)
}
