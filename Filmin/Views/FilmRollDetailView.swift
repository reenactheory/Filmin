import SwiftUI

struct FilmRollDetailView: View {
    let roll: FilmRoll
    let rollNumber: Int

    @Environment(\.dismiss) private var dismiss
    @State private var currentPhotoIndex: Int = 0
    @State private var showingGallery: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            titleBlock
                .padding(.horizontal, 24)
                .padding(.top, 18)

            tagChips
                .padding(.horizontal, 24)
                .padding(.top, 20)

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
