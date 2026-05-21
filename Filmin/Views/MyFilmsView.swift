import SwiftUI

enum RollSortOrder: String, CaseIterable, Identifiable {
    case recent = "최신 순"
    case oldest = "오래된 순"

    var id: Self { self }
}

struct MyFilmsView: View {
    @Binding var rolls: [FilmRoll]
    /// Cameras the user has added — handed through so the edit sheet
    /// on the detail view can populate its Camera dropdown.
    var userCameras: [String] = []
    @State private var searchText: String = ""
    @State private var sortOrder: RollSortOrder = .recent

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    private var filteredRolls: [FilmRoll] {
        let sorted: [FilmRoll]
        switch sortOrder {
        case .recent: sorted = rolls
        case .oldest: sorted = rolls.reversed()
        }

        guard !searchText.isEmpty else { return sorted }
        return sorted.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.filmStock.localizedCaseInsensitiveContains(searchText)
                || $0.camera.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    searchBar
                    grid
                        .padding(.top, 20)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
            .background(Color.white)
            .ignoresSafeArea(.keyboard)
            .navigationDestination(for: FilmRoll.self) { roll in
                // Re-find by ID and bind into the array so edits in
                // the detail sheet propagate back to the shared store.
                if let idx = rolls.firstIndex(where: { $0.id == roll.id }) {
                    FilmRollDetailView(
                        roll: $rolls[idx],
                        rollNumber: rollNumber(for: roll),
                        userCameras: userCameras
                    )
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("My Films")
                .font(.pretendard(.bold, size: 34))
                .foregroundStyle(.primary)
            Text("총 \(rolls.count)롤")
                .font(.pretendard(.regular, size: 16))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search", text: $searchText)
                    .font(.pretendard(.regular, size: 16))
                    .textFieldStyle(.plain)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color(.systemGray6))
            )

            Menu {
                Picker("정렬", selection: $sortOrder) {
                    ForEach(RollSortOrder.allCases) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
        }
    }

    private var grid: some View {
        LazyVGrid(columns: columns, spacing: 40) {
            ForEach(filteredRolls) { roll in
                NavigationLink(value: roll) {
                    FilmRollCard(roll: roll)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func rollNumber(for roll: FilmRoll) -> Int {
        (rolls.firstIndex(of: roll) ?? 0) + 1
    }

}

#Preview {
    MyFilmsView(rolls: .constant(FilmRoll.samples))
}
