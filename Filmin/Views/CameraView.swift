import SwiftUI

/// Cameras tab — list of cameras the user owns/uses. Tap + to add a
/// new one. Only cameras here appear in AddRollView's camera dropdown.
struct CameraView: View {
    @Binding var cameras: [Camera]

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    if cameras.isEmpty {
                        emptyState
                    } else {
                        grid
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .background(Color.white)
            .navigationDestination(for: Camera.self) { camera in
                if let idx = cameras.firstIndex(where: { $0.id == camera.id }) {
                    CameraDetailView(camera: $cameras[idx])
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Cameras")
                .font(.pretendard(.bold, size: 34))
                .foregroundStyle(.primary)
            Text("총 \(cameras.count)대")
                .font(.pretendard(.regular, size: 16))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Grid

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(cameras) { camera in
                NavigationLink(value: camera) {
                    CameraCard(camera: camera)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(.secondary)
            Text("아직 카메라가 없어요")
                .font(.pretendard(.semiBold, size: 16))
                .foregroundStyle(.primary)
            Text("+ 버튼을 눌러 카메라를 추가하세요")
                .font(.pretendard(.regular, size: 14))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
}

private struct CameraCard: View {
    let camera: Camera

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            GeometryReader { geo in
                ZStack {
                    if let data = camera.photoData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .clipped()
                    } else {
                        Color(.systemGray6)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 42, weight: .regular))
                                    .foregroundStyle(Color(.systemGray3))
                            )
                    }
                }
            }
            .aspectRatio(1.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(alignment: .topTrailing) {
                    if !camera.isActive {
                        Text("retired")
                            .font(.pretendard(.medium, size: 10))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                Capsule().fill(Color(.systemGray5))
                            )
                            .padding(8)
                    }
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(camera.name)
                    .font(.pretendard(.bold, size: 16))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(subtitle)
                    .font(.pretendard(.regular, size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 2)
        }
    }

    private var subtitle: String {
        var parts: [String] = []
        if let brand = camera.brand, !brand.isEmpty { parts.append(brand) }
        parts.append("\(camera.format) · \(camera.formatCategory.rawValue)")
        return parts.joined(separator: " · ")
    }
}

#Preview {
    CameraView(cameras: .constant(Camera.samples))
}
