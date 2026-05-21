import SwiftUI

enum AppTab: Hashable {
    case myFilms, cameras, settings, addRoll
}

struct RootTabView: View {
    @State private var selection: AppTab = .myFilms
    /// Shared stores. Both tabs (films and cameras) and the settings
    /// view read/write through these so a single source of truth.
    /// Both arrays persist to JSON in Documents on every change so the
    /// user's data survives app restarts. First launch falls back to
    /// the bundled samples when no file exists yet.
    @State private var rolls: [FilmRoll] = RollStore.load() ?? FilmRoll.samples
    @State private var cameras: [Camera] = CameraStore.load() ?? Camera.samples

    var body: some View {
        TabView(selection: $selection) {
            Tab("내 필름", systemImage: "film.stack", value: AppTab.myFilms) {
                MyFilmsView(rolls: $rolls)
            }

            Tab("카메라", systemImage: "camera", value: AppTab.cameras) {
                CameraView(cameras: $cameras)
            }

            Tab("설정", systemImage: "gearshape", value: AppTab.settings) {
                SettingsView(rolls: $rolls, cameras: $cameras)
            }

            // role: .search makes this render as a separate circular
            // glass button on the right of the tab pill (iOS 26 pattern,
            // same as Apple Music's search button).
            Tab("새 롤", systemImage: "plus", value: AppTab.addRoll, role: .search) {
                AddRollView(
                    onClose: { selection = .myFilms },
                    onSave: { roll in rolls.append(roll) },
                    userCameras: cameras.filter(\.isActive).map(\.name)
                )
            }
        }
        .tint(.black)
        // Write to disk on every mutation. Cheap because both files
        // are small JSON (cameras include uploaded photoData, rolls
        // currently only hold filename references to bundled photos).
        .onChange(of: cameras) { _, newValue in
            CameraStore.save(newValue)
        }
        .onChange(of: rolls) { _, newValue in
            RollStore.save(newValue)
        }
    }
}

#Preview {
    RootTabView()
}
