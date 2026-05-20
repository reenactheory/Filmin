import SwiftUI

/// Archive — film rolls grouped by year. Each year row shows a roll
/// count and a chevron; tap to expand and reveal that year's rolls
/// in a horizontally-scrolling carousel.
struct ArchiveView: View {
    let rolls: [FilmRoll]

    @State private var searchText: String = ""
    @State private var expandedYear: Int? = nil

    private var groupedByYear: [Int: [FilmRoll]] {
        Dictionary(grouping: rolls) { roll in
            let date = roll.developedAt ?? Date()
            return Calendar.current.component(.year, from: date)
        }
    }

    private var sortedYears: [Int] {
        groupedByYear.keys.sorted(by: >)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                title
                searchBar
                yearList
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 120)
        }
        .background(Color.white)
        .ignoresSafeArea(.keyboard)
        .onAppear {
            // Expand the most recent year by default
            if expandedYear == nil {
                expandedYear = sortedYears.first
            }
        }
    }

    // MARK: - Header

    private var title: some View {
        Text("Archive")
            .font(.pretendard(.bold, size: 22))
            .foregroundStyle(.primary)
            .frame(maxWidth: .infinity)
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

            Button {
                // Filter action
            } label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 24, height: 24)
            }
        }
    }

    // MARK: - Year List

    private var yearList: some View {
        VStack(spacing: 0) {
            ForEach(sortedYears, id: \.self) { year in
                yearSection(year: year, rolls: groupedByYear[year] ?? [])
                Divider()
            }
        }
    }

    private func yearSection(year: Int, rolls: [FilmRoll]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedYear = (expandedYear == year) ? nil : year
                }
            } label: {
                HStack {
                    Text("\(String(year))")
                        .font(.pretendard(.bold, size: 32))
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(rolls.count) rolls")
                        .font(.pretendard(.regular, size: 14))
                        .foregroundStyle(.secondary)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(expandedYear == year ? 90 : 0))
                }
                .padding(.vertical, 20)
            }
            .buttonStyle(.plain)

            if expandedYear == year && !rolls.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 20) {
                        ForEach(rolls) { roll in
                            FilmRollCard(roll: roll)
                                .frame(width: 160)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, -24) // bleed past the parent padding
                .safeAreaPadding(.horizontal, 24)
            }
        }
    }
}

#Preview {
    ArchiveView(rolls: FilmRoll.samples)
}
