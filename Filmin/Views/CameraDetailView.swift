import SwiftUI

/// Detail view for a single camera. Reached by tapping a card on the
/// Cameras tab. Edits flow back through the binding so the cameras
/// store stays in sync.
struct CameraDetailView: View {
    @Binding var camera: Camera

    @State private var showingRetireSheet = false
    @State private var showingEditSheet = false
    @State private var retireDate = Date()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heroImage

                titleBlock
                    .padding(.horizontal, 24)

                infoList
                    .padding(.horizontal, 24)

                if let notes = camera.notes, !notes.isEmpty {
                    notesBlock(notes: notes)
                        .padding(.horizontal, 24)
                }

                if camera.isActive {
                    retireButton
                        .padding(.horizontal, 24)
                        .padding(.top, 12)
                }
            }
            .padding(.top, 12)
            .padding(.bottom, 60)
        }
        .background(Color.white)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingEditSheet = true
                } label: {
                    Text("Edit")
                        .font(.pretendard(.semiBold, size: 16))
                        .foregroundStyle(.primary)
                }
            }
        }
        .sheet(isPresented: $showingRetireSheet) {
            retireSheet
        }
        .sheet(isPresented: $showingEditSheet) {
            AddCameraView(existingCamera: camera) { updated in
                camera = updated
            }
        }
    }

    // MARK: - Hero

    private var heroImage: some View {
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
                                .font(.system(size: 72, weight: .regular))
                                .foregroundStyle(Color(.systemGray3))
                        )
                }
            }
        }
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(alignment: .topTrailing) {
                if !camera.isActive {
                    Text("retired")
                        .font(.pretendard(.medium, size: 12))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(Color(.systemGray5))
                        )
                        .padding(16)
                }
            }
            .padding(.horizontal, 24)
    }

    // MARK: - Title

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(camera.name)
                .font(.pretendard(.bold, size: 28))
                .foregroundStyle(.primary)

            if let brand = camera.brand, !brand.isEmpty {
                Text(brand)
                    .font(.pretendard(.regular, size: 16))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Info List

    private var infoList: some View {
        VStack(spacing: 0) {
            infoRow(label: "포맷", value: "\(camera.format) · \(camera.formatCategory.rawValue)")
            divider
            if let brand = camera.brand, !brand.isEmpty {
                infoRow(label: "브랜드", value: brand)
                divider
            }
            if let date = camera.purchaseDateDescription {
                infoRow(label: "구입일", value: date)
                divider
            }
            if let retired = camera.retiredDateDescription {
                infoRow(label: "사용 종료일", value: retired)
                divider
            }
            if let duration = camera.usageDurationDescription {
                infoRow(label: "사용 기간", value: duration)
                divider
            }
            infoRow(label: "상태", value: camera.isActive ? "사용 중" : "보관 / 미사용")
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.pretendard(.regular, size: 15))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.pretendard(.semiBold, size: 16))
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 14)
    }

    private var divider: some View {
        Divider().background(Color(.systemGray5))
    }

    // MARK: - Notes

    private func notesBlock(notes: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("메모")
                .font(.pretendard(.regular, size: 14))
                .foregroundStyle(.secondary)

            Text(notes)
                .font(.pretendard(.regular, size: 16))
                .foregroundStyle(.primary)
                .lineSpacing(5)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                )
        }
    }

    // MARK: - Retire Button + Sheet

    private var retireButton: some View {
        Button {
            retireDate = Date()
            showingRetireSheet = true
        } label: {
            Text("사용 종료")
                .font(.pretendard(.semiBold, size: 16))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .stroke(Color(.systemGray3), lineWidth: 1)
                )
        }
    }

    private var retireSheet: some View {
        NavigationStack {
            VStack(spacing: 0) {
                DatePicker(
                    "",
                    selection: $retireDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding(.horizontal, 16)
                .padding(.top, 16)

                Spacer()
            }
            .navigationTitle("사용 종료일")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        showingRetireSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("확인") {
                        camera.retiredDate = retireDate
                        camera.isActive = false
                        showingRetireSheet = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    NavigationStack {
        CameraDetailView(camera: .constant(Camera.samples[0]))
    }
}
