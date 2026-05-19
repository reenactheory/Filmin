import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            Tab("내 필름", systemImage: "film.stack") {
                MyFilmsView()
            }

            Tab("카메라", systemImage: "camera") {
                PlaceholderView(title: "카메라", icon: "camera")
            }

            Tab("설정", systemImage: "gearshape") {
                PlaceholderView(title: "설정", icon: "gearshape")
            }

            // role: .search makes this render as a separate circular
            // glass button on the right of the tab pill (iOS 26 pattern,
            // same as Apple Music's search button).
            Tab("새 롤", systemImage: "plus", role: .search) {
                PlaceholderView(title: "새 롤 추가", icon: "plus.circle")
            }
        }
    }
}

private struct PlaceholderView: View {
    let title: String
    let icon: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.pretendard(.bold, size: 24))
                .foregroundStyle(.primary)
            Text("준비 중")
                .font(.pretendard(.regular, size: 14))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    RootTabView()
}
