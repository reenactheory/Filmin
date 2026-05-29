import SwiftUI

/// Loads a roll photo thumbnail off the main thread, then swaps it in.
///
/// Synchronous `RollPhotoStore.thumbnail` decodes block whatever view
/// is rendering — fine once cached, but on a cold launch the My Films
/// grid decodes ~9 canister backdrops at once and the app feels slow to
/// open. Routing that first decode through a detached task lets the UI
/// appear immediately with the placeholder, and the photo fills in a
/// beat later. Subsequent appearances hit the NSCache and are instant.
struct AsyncRollImage<Placeholder: View>: View {
    let name: String
    let maxPixel: CGFloat
    var contentMode: ContentMode = .fill
    @ViewBuilder var placeholder: () -> Placeholder

    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder()
            }
        }
        .task(id: name) {
            guard image == nil, !name.isEmpty else { return }
            let loaded = await Task.detached(priority: .userInitiated) {
                RollPhotoStore.thumbnail(named: name, maxPixel: maxPixel)
            }.value
            if !Task.isCancelled {
                image = loaded
            }
        }
    }
}
