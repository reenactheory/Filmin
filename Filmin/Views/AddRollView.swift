import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

/// "Add Roll" form. Lets the user pick film stock / format / camera /
/// date, set the exposure count, and jot a quick note before saving.
struct AddRollView: View {
    /// Called when the user taps X or after Save — host decides what
    /// to do (e.g., switch tabs back to "내 필름").
    let onClose: () -> Void
    /// Called with the new roll when the user taps Save.
    var onSave: ((FilmRoll) -> Void)? = nil
    /// Cameras the user has added (from the Cameras tab). Only these
    /// show up in the Camera dropdown; passed in from RootTabView.
    var userCameras: [String] = []

    /// UUID generated up front so any photos imported during the form
    /// session can be written under `Documents/RollPhotos/<newRollID>/`
    /// and have the saved roll reference them via `<newRollID>/<file>`.
    @State private var newRollID = UUID()

    @State private var filmStock: String = "Portra 400"
    @State private var format: String = "35mm"
    @State private var exposures: Int = 17
    @State private var camera: String = "Leica M6"
    @State private var date: Date = Date()
    @State private var notes: String = ""

    // Custom-input alert for film stock "Extra"
    @State private var isShowingCustomFilmStock = false
    @State private var customFilmStock: String = ""

    // Photo sources — both feed into `importedPhotoPaths` once the
    // bytes are read. Saving the roll writes them to disk under
    // newRollID's folder via RollPhotoStore.
    @State private var pickedPhotoItems: [PhotosPickerItem] = []
    @State private var isShowingFileImporter = false
    /// Relative paths (`<rollID>/<filename>`) of photos already saved
    /// to disk for this new roll. The Save button reads this directly.
    @State private var importedPhotoPaths: [String] = []
    @State private var isImporting = false
    @State private var importErrorMessage: String?

    private let maxNotes = 100

    private let filmStockOptions = [
        "Portra 400", "Portra 800", "Portra 160",
        "UltraMax 400", "ProImage 100", "KODACOLOR 200",
        "Ektar 100", "Tri-X 400", "HP5+", "Velvia 50"
    ]
    private let formatOptions = ["35mm", "120", "4x5", "Instant"]

    private var dateString: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: date)
    }

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(spacing: 20) {
                    canisterPreview

                    fields

                    addImageButton

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
            Text("Add Roll")
                .font(.pretendard(.bold, size: 18))
                .foregroundStyle(.primary)

            HStack {
                Button { onClose() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.black)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }

    // MARK: - Canister Preview

    private var canisterPreview: some View {
        FilmCanisterView(
            filmStock: filmStock,
            frameCount: exposures
        )
        .frame(maxWidth: .infinity)
        .padding(.top, 40) // nudged down from 30 → 40
        .padding(.bottom, 20)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.systemGray6))
        )
    }

    // MARK: - Fields

    private var fields: some View {
        VStack(spacing: 0) {
            filmStockField
            divider
            dropdownField(label: "Format", value: format, options: formatOptions) {
                format = $0
            }
            divider
            exposuresField
            divider
            cameraField
            divider
            dateField
        }
    }

    private var filmStockField: some View {
        Menu {
            ForEach(filmStockOptions, id: \.self) { option in
                Button(option) { filmStock = option }
            }
            Divider()
            Button("Extra (직접 입력)") {
                customFilmStock = ""
                isShowingCustomFilmStock = true
            }
        } label: {
            fieldLabel(label: "Film Stock", value: filmStock)
        }
        .buttonStyle(.plain)
        .alert("Film Stock 직접 입력", isPresented: $isShowingCustomFilmStock) {
            TextField("예: Cinestill 800T", text: $customFilmStock)
            Button("확인") {
                let trimmed = customFilmStock.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty { filmStock = trimmed }
            }
            Button("취소", role: .cancel) { }
        }
    }

    private var cameraField: some View {
        Group {
            if userCameras.isEmpty {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Camera")
                            .font(.pretendard(.regular, size: 14))
                            .foregroundStyle(.secondary)
                        Text("카메라를 먼저 추가하세요")
                            .font(.pretendard(.regular, size: 16))
                            .foregroundStyle(Color(.systemGray3))
                    }
                    Spacer()
                }
                .padding(.vertical, 16)
            } else {
                Menu {
                    ForEach(userCameras, id: \.self) { option in
                        Button(option) { camera = option }
                    }
                } label: {
                    fieldLabel(label: "Camera", value: camera)
                }
                .buttonStyle(.plain)
                .onAppear {
                    // Default to first user camera if current selection
                    // isn't in the list.
                    if !userCameras.contains(camera), let first = userCameras.first {
                        camera = first
                    }
                }
            }
        }
    }

    /// Shared row label used by dropdown-style fields.
    private func fieldLabel(label: String, value: String) -> some View {
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

    private var divider: some View {
        Divider().background(Color(.systemGray5))
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

    private var exposuresField: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Exposures")
                    .font(.pretendard(.regular, size: 14))
                    .foregroundStyle(.secondary)
                TextField("17", value: $exposures, format: .number)
                    .font(.pretendard(.semiBold, size: 18))
                    .foregroundStyle(.primary)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.plain)
            }
            Spacer()
        }
        .padding(.vertical, 16)
    }

    private var dateField: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Date")
                    .font(.pretendard(.regular, size: 14))
                    .foregroundStyle(.secondary)
                Text(dateString)
                    .font(.pretendard(.semiBold, size: 18))
                    .foregroundStyle(.primary)
            }
            Spacer()
            // Hidden DatePicker overlays the chevron and handles taps.
            ZStack {
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                DatePicker("", selection: $date, displayedComponents: .date)
                    .labelsHidden()
                    .blendMode(.destinationOver) // invisible but tappable
            }
            .frame(width: 40, height: 40)
        }
        .padding(.vertical, 16)
    }

    // MARK: - Add Image

    /// Two-button stack: Photos picker (gallery) + Files picker.
    /// Both append into `importedPhotoPaths` so the order users see
    /// reflects the order they imported.
    @ViewBuilder
    private var addImageButton: some View {
        VStack(spacing: 10) {
            PhotosPicker(
                selection: $pickedPhotoItems,
                maxSelectionCount: 99,
                matching: .images
            ) {
                photoSourceRow(
                    icon: "photo.badge.plus",
                    label: "갤러리에서 추가"
                )
            }
            .onChange(of: pickedPhotoItems) { _, newItems in
                guard !newItems.isEmpty else { return }
                Task { await importPhotosFromPicker(newItems) }
            }

            Button {
                isShowingFileImporter = true
            } label: {
                photoSourceRow(
                    icon: "folder.badge.plus",
                    label: "파일에서 불러오기"
                )
            }
            .buttonStyle(.plain)
            .fileImporter(
                isPresented: $isShowingFileImporter,
                allowedContentTypes: [.image, .folder],
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result)
            }

            if !importedPhotoPaths.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("\(importedPhotoPaths.count)장의 사진 추가됨")
                        .font(.pretendard(.medium, size: 14))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("초기화") {
                        clearImportedPhotos()
                    }
                    .font(.pretendard(.medium, size: 14))
                    .foregroundStyle(Color(hex: "#A1A1AA"))
                }
                .padding(.top, 2)
            }

            if isImporting {
                HStack(spacing: 8) {
                    ProgressView().scaleEffect(0.7)
                    Text("불러오는 중…")
                        .font(.pretendard(.regular, size: 14))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
        }
        .alert("불러오기 실패", isPresented: Binding(
            get: { importErrorMessage != nil },
            set: { if !$0 { importErrorMessage = nil } }
        )) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(importErrorMessage ?? "")
        }
    }

    private func photoSourceRow(icon: String, label: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
            Text(label)
                .font(.pretendard(.semiBold, size: 16))
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }

    // MARK: - Import Plumbing

    /// PhotosPicker → load each item's data → save via RollPhotoStore →
    /// append the relative path to `importedPhotoPaths`. Runs on a
    /// background task so the UI stays responsive for large batches.
    private func importPhotosFromPicker(_ items: [PhotosPickerItem]) async {
        await MainActor.run { isImporting = true }
        defer { Task { @MainActor in isImporting = false } }

        var newPaths: [String] = []
        for (idx, item) in items.enumerated() {
            guard let data = try? await item.loadTransferable(type: Data.self) else {
                continue
            }
            let ext = item.supportedContentTypes.first?.preferredFilenameExtension ?? "jpg"
            let name = "gallery-\(Int(Date().timeIntervalSince1970))-\(idx).\(ext)"
            if let path = RollPhotoStore.saveImported(
                data: data,
                originalName: name,
                rollID: newRollID
            ) {
                newPaths.append(path)
            }
        }
        await MainActor.run {
            importedPhotoPaths.append(contentsOf: newPaths)
            pickedPhotoItems = []
        }
    }

    /// fileImporter → flatten file/folder URLs into image URLs → save
    /// each to disk in document order. Folder selections enumerate
    /// their contents (one level deep) for any image-typed files.
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .failure(let error):
            importErrorMessage = error.localizedDescription
        case .success(let urls):
            Task.detached(priority: .userInitiated) {
                await processFileImport(urls: urls)
            }
        }
    }

    private func processFileImport(urls: [URL]) async {
        await MainActor.run { isImporting = true }
        defer { Task { @MainActor in isImporting = false } }

        let imageURLs = expandToImageURLs(urls)
        var newPaths: [String] = []
        for url in imageURLs {
            let didStart = url.startAccessingSecurityScopedResource()
            defer { if didStart { url.stopAccessingSecurityScopedResource() } }
            guard let data = try? Data(contentsOf: url) else { continue }
            let original = url.lastPathComponent
            if let path = RollPhotoStore.saveImported(
                data: data,
                originalName: original,
                rollID: newRollID
            ) {
                newPaths.append(path)
            }
        }
        await MainActor.run {
            importedPhotoPaths.append(contentsOf: newPaths)
        }
    }

    /// For folder URLs, enumerate one level deep for image files.
    /// For file URLs, pass through. Preserves the input ordering and
    /// sorts folder contents alphabetically (scanners typically number
    /// frames so this matches shoot order).
    private func expandToImageURLs(_ urls: [URL]) -> [URL] {
        var out: [URL] = []
        for url in urls {
            let didStart = url.startAccessingSecurityScopedResource()
            defer { if didStart { url.stopAccessingSecurityScopedResource() } }
            var isDir: ObjCBool = false
            guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir) else {
                continue
            }
            if isDir.boolValue {
                let contents = (try? FileManager.default.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: nil,
                    options: [.skipsHiddenFiles]
                )) ?? []
                let images = contents
                    .filter { isLikelyImage($0) }
                    .sorted { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending }
                out.append(contentsOf: images)
            } else if isLikelyImage(url) {
                out.append(url)
            }
        }
        return out
    }

    private func isLikelyImage(_ url: URL) -> Bool {
        let imageExtensions: Set<String> = [
            "jpg", "jpeg", "png", "heic", "heif", "tif", "tiff", "webp"
        ]
        return imageExtensions.contains(url.pathExtension.lowercased())
    }

    private func clearImportedPhotos() {
        // Wipe the on-disk folder so we don't orphan files when the
        // user changes their mind before saving.
        RollPhotoStore.deleteAll(rollID: newRollID)
        importedPhotoPaths = []
        pickedPhotoItems = []
    }

    // MARK: - Notes

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes (optional)")
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
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            // If the user actually imported photos, those drive both
            // the `photos` array contents and its count. Otherwise we
            // reserve `exposures`-many empty placeholder slots so the
            // canister still shows the right frame count.
            let photos: [String] = importedPhotoPaths.isEmpty
                ? Array(repeating: "", count: exposures)
                : importedPhotoPaths
            let roll = FilmRoll(
                id: newRollID,
                title: "새 롤",
                filmStock: filmStock,
                camera: camera,
                photos: photos,
                brand: brandPrefix(for: filmStock),
                format: format,
                location: nil,
                developedAt: date
            )
            onSave?(roll)
            onClose()
        } label: {
            Text("Save Roll")
                .font(.pretendard(.bold, size: 17))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    Capsule()
                        .fill(Color.black)
                )
        }
    }

    /// Best-guess brand prefix from the film stock name (so the saved
    /// roll renders as "Kodak Portra 400" in the detail view).
    private func brandPrefix(for stock: String) -> String? {
        let kodak = ["Portra", "UltraMax", "ProImage", "KODACOLOR", "Ektar", "Tri-X"]
        let ilford = ["HP5"]
        let fuji = ["Velvia", "Provia"]
        guard let firstWord = stock.split(separator: " ").first else { return nil }
        let word = String(firstWord)
        if kodak.contains(word) { return "Kodak" }
        if ilford.contains(where: { word.hasPrefix($0) }) { return "Ilford" }
        if fuji.contains(word) { return "Fujifilm" }
        return nil
    }
}

#Preview {
    AddRollView(onClose: { })
}
