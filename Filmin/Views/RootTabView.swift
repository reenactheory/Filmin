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
