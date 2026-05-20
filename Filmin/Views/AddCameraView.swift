import SwiftUI
import PhotosUI

/// Sheet-presented form for adding OR editing a camera. Pass an
/// existing camera to pre-fill and switch into edit mode.
struct AddCameraView: View {
    @Environment(\.dismiss) private var dismiss
    /// If non-nil, the form is in edit mode and saving updates this
    /// camera (preserving its id and retiredDate).
    var existingCamera: Camera?
    var onSave: (Camera) -> Void

    @State private var name: String
    @State private var brand: String
    @State private var format: String
    @State private var hasPurchaseDate: Bool
    @State private var purchaseDate: Date
    @State private var notes: String
    @State private var isActive: Bool
    @State private var photoData: Data?
    @State private var pickedPhotoItem: PhotosPickerItem?

    private let formatOptions = ["35mm", "120", "4x5", "Instant"]
    private let maxNotes = 100

    init(existingCamera: Camera? = nil, onSave: @escaping (Camera) -> Void) {
        self.existingCamera = existingCamera
        self.onSave = onSave
        _name = State(initialValue: existingCamera?.name ?? "")
        _brand = State(initialValue: existingCamera?.brand ?? "")
        _format = State(initialValue: existingCamera?.format ?? "35mm")
        _hasPurchaseDate = State(initialValue: existingCamera?.purchaseDate != nil)
        _purchaseDate = State(initialValue: existingCamera?.purchaseDate ?? Date())
        _notes = State(initialValue: existingCamera?.notes ?? "")
        _isActive = State(initialValue: existingCamera?.isActive ?? true)
        _photoData = State(initialValue: existingCamera?.photoData)
    }

    private var isEditing: Bool { existingCamera != nil }
    private var headerTitle: String { isEditing ? "Edit Camera" : "Add Camera" }
    private var saveButtonTitle: String { isEditing ? "Update" : "Save Camera" }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 0) {
                    photoSection
                        .padding(.bottom, 16)

                    textField(label: "이름", placeholder: "Leica M6", text: $name)
                    divider
                    textField(label: "브랜드", placeholder: "Leica", text: $brand)
                    divider
                    dropdownField(label: "포맷", value: format, options: formatOptions) {
                        format = $0
                    }
                    divider
                    purchaseDateField
                    divider
                    toggleField
                    divider
                    notesSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }

            saveButton
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
        }
        .background(Color.white)
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text(headerTitle)
                .font(.pretendard(.bold, size: 18))
                .foregroundStyle(.primary)

            HStack {
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.black)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 32) // +20 to clear the sheet grabber
        .padding(.bottom, 4)
    }

    // MARK: - Photo

    private var photoSection: some View {
        PhotosPicker(selection: $pickedPhotoItem, matching: .images) {
            ZStack {
                if let data = photoData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.systemGray6))
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 32, weight: .regular))
                                    .foregroundStyle(Color(.systemGray3))
                                Text("카메라 사진 추가")
                                    .font(.pretendard(.medium, size: 14))
                                    .foregroundStyle(.secondary)
                            }
                        )
                }
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(alignment: .topTrailing) {
                if photoData != nil {
                    Button {
                        photoData = nil
                        pickedPhotoItem = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(.white, .black.opacity(0.6))
                    }
                    .padding(8)
                }
            }
        }
        .onChange(of: pickedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
    }

    // MARK: - Fields

    private var divider: some View {
        Divider().background(Color(.systemGray5))
    }

    private func textField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.pretendard(.regular, size: 14))
                .foregroundStyle(.secondary)
            TextField(placeholder, text: text)
                .font(.pretendard(.semiBold, size: 18))
                .foregroundStyle(.primary)
                .textFieldStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
    }

    private func numberField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.pretendard(.regular, size: 14))
                .foregroundStyle(.secondary)
            TextField(placeholder, text: text)
                .font(.pretendard(.semiBold, size: 18))
                .foregroundStyle(.primary)
                .keyboardType(.numberPad)
                .textFieldStyle(.plain)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
    }

    private func dropdownField(
        label: String,
        value: String,
        options: [String],
        onSelect: @escaping (String) -> Void
    ) -> some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) { onSelect(option) }
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(label)
                        .font(.pretendard(.regular, size: 14))
                        .foregroundStyle(.secondary)
                    Text(value)
                        .font(.pretendard(.semiBold, size: 18))
                        .foregroundStyle(.primary)
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }

    private var purchaseDateField: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("구입일 (선택)")
                    .font(.pretendard(.regular, size: 14))
                    .foregroundStyle(.secondary)
                if hasPurchaseDate {
                    Text(formatDate(purchaseDate))
                        .font(.pretendard(.semiBold, size: 18))
                        .foregroundStyle(.primary)
                } else {
                    Text("미지정")
                        .font(.pretendard(.regular, size: 16))
                        .foregroundStyle(Color(.systemGray3))
                }
            }
            Spacer()
            HStack(spacing: 8) {
                if hasPurchaseDate {
                    Button {
                        hasPurchaseDate = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color(.systemGray3))
                    }
                }
                ZStack {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                    DatePicker("", selection: $purchaseDate, displayedComponents: .date)
                        .labelsHidden()
                        .blendMode(.destinationOver)
                        .onChange(of: purchaseDate) { _, _ in
                            hasPurchaseDate = true
                        }
                }
                .frame(width: 40, height: 40)
            }
        }
        .padding(.vertical, 16)
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy년 M월 d일"
        return f.string(from: date)
    }

    private var toggleField: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("상태")
                    .font(.pretendard(.regular, size: 14))
                    .foregroundStyle(.secondary)
                Text(isActive ? "사용 중" : "보관 / 미사용")
                    .font(.pretendard(.semiBold, size: 18))
                    .foregroundStyle(.primary)
            }
            Spacer()
            Toggle("", isOn: $isActive)
                .labelsHidden()
        }
        .padding(.vertical, 16)
    }

    // MARK: - Notes

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("메모 (선택)")
                .font(.pretendard(.regular, size: 14))
                .foregroundStyle(.secondary)

            ZStack(alignment: .topLeading) {
                if notes.isEmpty {
                    Text("Start typing...")
                        .font(.pretendard(.regular, size: 16))
                        .foregroundStyle(Color(.systemGray3))
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $notes)
                    .font(.pretendard(.regular, size: 16))
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(minHeight: 96)
                    .onChange(of: notes) { _, newValue in
                        if newValue.count > maxNotes {
                            notes = String(newValue.prefix(maxNotes))
                        }
                    }

                HStack {
                    Spacer()
                    Text("\(notes.count)/\(maxNotes)")
                        .font(.pretendard(.regular, size: 12))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .padding(.vertical, 16)
    }

    // MARK: - Save

    private var saveButton: some View {
        Button {
            let trimmedName = name.trimmingCharacters(in: .whitespaces)
            let trimmedBrand = brand.trimmingCharacters(in: .whitespaces)
            let camera = Camera(
                id: existingCamera?.id ?? UUID(),
                name: trimmedName,
                brand: trimmedBrand.isEmpty ? nil : trimmedBrand,
                format: format,
                purchaseDate: hasPurchaseDate ? purchaseDate : nil,
                // Preserve retiredDate from the existing camera so
                // editing doesn't undo a previous "사용 종료" action.
                retiredDate: existingCamera?.retiredDate,
                notes: notes.isEmpty ? nil : notes,
                isActive: isActive,
                photoData: photoData
            )
            onSave(camera)
            dismiss()
        } label: {
            Text(saveButtonTitle)
                .font(.pretendard(.bold, size: 17))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    Capsule()
                        .fill(canSave ? Color.black : Color(.systemGray3))
                )
        }
        .disabled(!canSave)
    }
}

#Preview {
    AddCameraView { _ in }
}
