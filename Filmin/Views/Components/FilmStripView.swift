import SwiftUI

/// Horizontal film strip viewer: a fixed canister leader on the left
/// and a horizontally scrollable strip on the right. The strip's three
/// frame interiors get photo placeholders.
struct FilmStripView: View {
    @Binding var currentPhotoIndex: Int
    let photos: [String]

    /// Optional mirror used by `.scrollPosition(id:)`. Synced two-way
    /// with `currentPhotoIndex` so swipes update the counter and
    /// programmatic index changes scroll the strip.
    @State private var scrolledIndex: Int? = 0

    private let leaderWidth: CGFloat = 190
    private let leaderHeight: CGFloat = 380
    // Strip width derived from the single-frame asset aspect
    // (1451×1179). Each tile shows ONE photo now.
    private let stripHeight: CGFloat = 300
    private var stripWidth: CGFloat { stripHeight * (1451.0 / 1179.0) } // ≈ 381
    // Photo placeholder size that sits inside each strip frame.
    // +1 right (347 → 348); height kept 224.
    private let photoSize = CGSize(width: 348, height: 224)
    /// Center-position adjustment so each side-growth lands on the
    /// intended side. x: previous -0.5, +0.5 for right-side growth → 0.
    /// y kept at +1 for bottom growth.
    private let photoCenterOffset = CGSize(width: 0, height: 1)
    /// Horizontal nudge for where the strip starts.
    private let stripLeadingOffset: CGFloat = 30
    /// Reference screen width that the leader's base offset was tuned
    /// for (iPhone Pro family: 16 Pro, 17 Pro — all ~393pt).
    private let referenceScreenWidth: CGFloat = 393
    /// Base leader offset that produced the centered look on the
    /// reference device. Wider devices shift further right (see
    /// `leaderOffset(for:)`) to keep the gap to the centered photo
    /// visually identical.
    private let leaderBaseOffset: CGFloat = -17

    var body: some View {
        // Strip sits BEHIND the leader (z-axis). The strip starts at the
        // left edge of the container, so its first frames slide under the
        // leader — giving the impression of film unspooling from the
        // canister. The leader is laid on top last.
        //
        // Wrapped in a GeometryReader so the leader's horizontal offset
        // can scale with the actual screen width — `scrollPosition`
        // already centers the current photo at screenWidth/2 on any
        // device, but the leader is anchored to leading and wouldn't
        // otherwise move. Shifting the leader by half the device-width
        // delta keeps the visual gap between leader and photo identical
        // across iPhone Pro / Pro Max / Plus sizes.
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                ScrollView(.horizontal, showsIndicators: false) {
                    stripContent
                        .padding(.leading, stripLeadingOffset)
                }
                .frame(height: stripHeight)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrolledIndex, anchor: .center)
                .onAppear { scrolledIndex = currentPhotoIndex }
                .onChange(of: scrolledIndex) { _, newValue in
                    if let newValue, newValue != currentPhotoIndex {
                        currentPhotoIndex = newValue
                    }
                }
                .onChange(of: currentPhotoIndex) { _, newValue in
                    if scrolledIndex != newValue {
                        scrolledIndex = newValue
                    }
                }

                Image("FilmLeader")
                    .resizable()
                    .scaledToFit()
                    .frame(width: leaderWidth, height: leaderHeight, alignment: .leading)
                    .offset(x: leaderOffset(for: geo.size.width))
                    .allowsHitTesting(false)
            }
        }
        .frame(height: leaderHeight)
    }

    /// Shift the leader rightward by half of any extra device width
    /// beyond the reference (iPhone Pro). This preserves the same
    /// visual distance between the leader's right edge and the
    /// screen-centered photo across all iPhone sizes.
    private func leaderOffset(for screenWidth: CGFloat) -> CGFloat {
        let delta = screenWidth - referenceScreenWidth
        return leaderBaseOffset + delta / 2
    }

    private var stripContent: some View {
        // Each FilmStrip tile = ONE photo frame. The very LAST tile
        // swaps in FilmStripEnd (wider, with an extended dark tail) so
        // the strip reads as the actual end of the roll.
        let tileCount = max(1, photos.count)
        let endTileWidth = stripHeight * (1699.0 / 1179.0) // FilmStripEnd aspect

        return HStack(spacing: 0) {
            ForEach(0..<tileCount, id: \.self) { tileIdx in
                let isLast = tileIdx == tileCount - 1
                let tileWidth = isLast ? endTileWidth : stripWidth
                let imageName = isLast ? "FilmStripEnd" : "FilmStrip"

                ZStack(alignment: .topLeading) {
                    // Photo placeholder sits BEHIND the strip image; the
                    // strip's frame window is transparent so the photo
                    // shows through, with the black sprocket border
                    // framing it.
                    // For the end tile the photo stays at the SAME
                    // absolute X as a regular tile (i.e., centered on
                    // the frame portion of the strip, not the wider
                    // tile center) — so it lines up with the asset's
                    // frame window.
                    photoPlaceholder(for: tileIdx)
                        .frame(width: photoSize.width, height: photoSize.height)
                        .clipped()
                        .position(
                            x: stripWidth / 2 + photoCenterOffset.width,
                            y: stripHeight / 2 + photoCenterOffset.height
                        )

                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: tileWidth, height: stripHeight)
                }
                .frame(width: tileWidth, height: stripHeight)
                .id(tileIdx)
            }
        }
        .scrollTargetLayout()
    }

    @ViewBuilder
    private func photoPlaceholder(for index: Int) -> some View {
        if index < photos.count, !photos[index].isEmpty,
           let uiImage = RollPhotoStore.image(named: photos[index]) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else if index < photos.count {
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
    FilmStripView(currentPhotoIndex: .constant(0), photos: Array(repeating: "", count: 17))
        .background(Color.white)
}
