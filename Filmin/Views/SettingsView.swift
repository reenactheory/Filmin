import SwiftUI
import UniformTypeIdentifiers

/// Settings tab — minimal: backup export, restore, storage info,
/// feedback, version.
struct SettingsView: View {
    @Binding var rolls: [FilmRoll]
    @Binding var cameras: [Camera]

    @State private var backupURL: URL?
    @State private var showingShareSheet = false

    // Restore flow state
    @State private var showingImporter = false
    @State private var pendingBackup: FilminBackup?
    @State private var showingRestoreConfirmation = false
    @State private var importErrorMessage: String?
    @State private var showingImportError = false

    private var appVersion: String {
        let v = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(v) (\(build))"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                title

                section(title: "데이터") {
                    actionRow(label: "백업 (내보내기)", trailing: .chevron) {
                        prepareAndShareBackup()
                    }
                    divider
                    actionRow(label: "복원 (가져오기)", trailing: .chevron) {
                        showingImporter = true
                    }
                    divider
                    infoRow(label: "저장 위치", value: "이 기기")
                }

                section(title: "정보") {
                    infoRow(label: "버전", value: appVersion)
                }

                disclaimerNote
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
        .background(Color.white)
        .sheet(isPresented: $showingShareSheet) {
            if let url = backupURL {
                ShareSheet(activityItems: [url])
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.json]
        ) { result in
            handleImport(result)
        }
        .alert("복원하시겠어요?", isPresented: $showingRestoreConfirmation) {
            Button("취소", role: .cancel) {
                pendingBackup = nil
            }
            Button("복원", role: .destructive) {
                applyRestore()
            }
        } message: {
            if let backup = pendingBackup {
                Text("롤 \(backup.rolls.count)개, 카메라 \(backup.cameras.count)개를 발견했어요. 현재 데이터가 이 백업으로 교체됩니다.")
            }
        }
        .alert("불러오기 실패", isPresented: $showingImportError) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(importErrorMessage ?? "")
        }
    }

    // MARK: - Header

    private var title: some View {
        Text("Settings")
            .font(.pretendard(.bold, size: 34))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Sections

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.pretendard(.semiBold, size: 13))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.systemGray6))
            )
        }
    }

    private var divider: some View {
        Divider().background(Color(.systemGray4))
    }

    // MARK: - Rows

    private enum RowTrailing {
        case chevron
        case value(String)
        case none
    }

    private func actionRow(
        label: String,
        trailing: RowTrailing,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(label)
                    .font(.pretendard(.regular, size: 16))
                    .foregroundStyle(.primary)
                Spacer()
                trailingView(trailing)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.pretendard(.regular, size: 16))
                .foregroundStyle(.primary)
            Spacer()
            Text(value)
                .font(.pretendard(.regular, size: 15))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private func trailingView(_ trailing: RowTrailing) -> some View {
        switch trailing {
        case .chevron:
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color(.systemGray3))
        case .value(let v):
            Text(v)
                .font(.pretendard(.regular, size: 15))
                .foregroundStyle(.secondary)
        case .none:
            EmptyView()
        }
    }

    // MARK: - Disclaimer

    private var disclaimerNote: some View {
        Text("필름인의 모든 데이터는 이 기기에만 저장됩니다.\n앱을 삭제하면 데이터가 사라지니 가끔 백업해 두세요.")
            .font(.pretendard(.regular, size: 13))
            .foregroundStyle(.secondary)
            .lineSpacing(4)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 4)
    }

    // MARK: - Actions

    private func prepareAndShareBackup() {
        let backup = FilminBackup(exportedAt: Date(), rolls: rolls, cameras: cameras)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(backup) else { return }

        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd-HHmmss"
        let filename = "filmin-backup-\(f.string(from: Date())).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: url, options: .atomic)
            backupURL = url
            showingShareSheet = true
        } catch {
            // Silent fail for now; could surface an alert later.
        }
    }

    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .failure(let error):
            importErrorMessage = error.localizedDescription
            showingImportError = true
        case .success(let url):
            // Document picker returns a security-scoped URL.
            let didStart = url.startAccessingSecurityScopedResource()
            defer {
                if didStart { url.stopAccessingSecurityScopedResource() }
            }
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let backup = try decoder.decode(FilminBackup.self, from: data)
                pendingBackup = backup
                showingRestoreConfirmation = true
            } catch {
                importErrorMessage = "백업 파일을 읽을 수 없어요.\n\(error.localizedDescription)"
                showingImportError = true
            }
        }
    }

    private func applyRestore() {
        guard let backup = pendingBackup else { return }
        rolls = backup.rolls
        cameras = backup.cameras
        pendingBackup = nil
    }

}

// MARK: - Backup payload

struct FilminBackup: Codable {
    let exportedAt: Date
    let rolls: [FilmRoll]
    let cameras: [Camera]
}

// MARK: - Share sheet wrapper

private struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

#Preview {
    SettingsView(
        rolls: .constant(FilmRoll.samples),
        cameras: .constant(Camera.samples)
    )
}
