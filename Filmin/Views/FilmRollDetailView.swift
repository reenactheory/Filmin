import SwiftUI

struct FilmRollDetailView: View {
    let roll: FilmRoll
    let rollNumber: Int

    @Environment(\.dismiss) private var dismiss
    @State private var currentPhotoIndex: Int = 0
    @State private var scrolledMediumIndex: Int? = 0
    @State private var showingGallery: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            titleBlock
                .padding(.horizontal, 24)
                .padding(.top, 18)

            tagChips
                .padding(.horizontal, 24)
                .padding(.top, 20)

            if roll.format == "120" {
                // 중형 (120) — strip이 검정 박스라 35mm처럼 strip
                // 내부로 overlap 시키지 않고 20pt 아래로 내려서 표시.
                Spacer(minLength: 30)
                mediumPhotoStrip
                counterText
                    .padding(.top, 16)
                    .offset(y: -10)
                viewAllButton
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                    .offset(y: -13)
            } else {
                // 35mm — 기존 가로 스크롤 필름 스트립 + 카운터 + 버튼.
                Spacer(minLength: 40)
                filmStripPlaceholder
                // counter and button shifted up together; offset -41 keeps the
                // 24pt gap between them intact while moving the pair higher.
                counterText
                    .padding(.top, 16)
                    .offset(y: -41)
                viewAllButton
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                    .offset(y: -41)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.black)
                }
            }
        }
        .fullScreenCover(isPresented: $showingGallery) {
            FilmRollGalleryView(roll: roll, rollNumber: rollNumber)
        }
    }

    private var titleBlock: some View {
        VStack(spacing: 4) {
            (
                Text("나의 ").foregroundStyle(.secondary)
                + Text("\(rollNumber)번째").foregroundStyle(.primary)
                + Text(" 롤").foregroundStyle(.secondary)
            )
            .font(.pretendard(.bold, size: 28))
            .multilineTextAlignment(.center)

            Text(roll.fullName)
                .font(.pretendard(.bold, size: 28))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.65)
        }
        .frame(maxWidth: .infinity)
    }

    private var tagChips: some View {
        FlowLayout(horizontalSpacing: 8, verticalSpacing: 8, alignment: .center) {
            TagChip(text: "#\(roll.format)")
            TagChip(text: "#\(roll.camera)")
            if let iso = roll.iso {
                TagChip(text: "#ISO\(iso)")
            }
            if let location = roll.location {
                TagChip(text: "#\(location)")
            }
            if let developedAt = roll.developedAt {
                TagChip(text: "#\(formatDate(developedAt))에 현상")
            }
        }
    }

    private var filmStripPlaceholder: some View {
        FilmStripView(currentPhotoIndex: $currentPhotoIndex, photos: roll.photos)
    }

    /// 120 photos laid out side-by-side inside one shared black strip,
    /// scrollable horizontally with snap-to-center paging.
    ///
    /// Each photo gets a fixed 280×280 frame so `scrollTargetBehavior`
    /// has consistent snap targets — variable widths from `aspectRatio(.fit)`
    /// would make the center snap wobble between frames.
    private var mediumPhotoStrip: some View {
        GeometryReader { geo in
            let sidePadding = max(0, (geo.size.width - Self.mediumPhotoSize) / 2 - 10)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(0..<roll.photoCount, id: \.self) { idx in
                        mediumPhoto(for: idx)
                            .frame(
                                width: Self.mediumPhotoSize,
                                height: Self.mediumPhotoSize
                            )
                            .id(idx)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, sidePadding + 10)
                .background(Color.black)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrolledMediumIndex, anchor: .center)
            .onAppear { scrolledMediumIndex = currentPhotoIndex }
            .onChange(of: scrolledMediumIndex) { _, newValue in
                if let newValue, newValue != currentPhotoIndex {
                    currentPhotoIndex = newValue
                }
            }
            .onChange(of: currentPhotoIndex) { _, newValue in
                if scrolledMediumIndex != newValue {
                    scrolledMediumIndex = newValue
                }
            }
        }
        .frame(height: Self.mediumPhotoSize + 20)
    }

    private static let mediumPhotoSize: CGFloat = 280

    @ViewBuilder
    private func mediumPhoto(for index: Int) -> some View {
        let name = index < roll.photos.count ? roll.photos[index] : ""
        Group {
            if !name.isEmpty, let uiImage = RollPhotoStore.image(named: name) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Rectangle()
                    .fill(Color(.systemGray3))
            }
        }
    }

    private var counterText: some View {
        HStack {
            Spacer()
            Group {
                if currentPhotoIndex == 0 {
                    Text("스크롤 해보세요 →")
                } else {
                    Text("\(currentPhotoIndex + 1) / \(roll.photoCount)")
                }
            }
            .font(.pretendard(.medium, size: 14))
            .foregroundStyle(Color(hex: "#A1A1AA"))
            Spacer()
        }
    }

    private var viewAllButton: some View {
        HStack {
            Spacer()
            Button {
                showingGallery = true
            } label: {
                Text("전체 필름 한 눈에 보기")
                    .font(.pretendard(.semiBold, size: 16))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.black)
                    )
            }
            Spacer()
        }
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        return f.string(from: date)
    }
}

#Preview {
    NavigationStack {
        FilmRollDetailView(roll: FilmRoll.samples[1], rollNumber: 3)
    }
}
