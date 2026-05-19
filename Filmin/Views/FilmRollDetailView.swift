import SwiftUI

struct FilmRollDetailView: View {
    let roll: FilmRoll
    let rollNumber: Int

    @Environment(\.dismiss) private var dismiss
    @State private var currentPhotoIndex: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleBlock
                .padding(.horizontal, 24)
                .padding(.top, 8)

            tagChips
                .padding(.horizontal, 24)
                .padding(.top, 20)

            filmStripPlaceholder
                .padding(.top, 28)

            counterText
                .padding(.top, 12)

            viewAllButton
                .padding(.top, 28)

            Spacer(minLength: 0)
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
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("나의 \(rollNumber)번째 롤")
                .font(.pretendard(.regular, size: 18))
                .foregroundStyle(.secondary)
            Text(roll.fullName)
                .font(.pretendard(.bold, size: 28))
                .foregroundStyle(.primary)
        }
    }

    private var tagChips: some View {
        FlowLayout(horizontalSpacing: 8, verticalSpacing: 8) {
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
        // Placeholder for the film-strip photo viewer.
        // Real implementation will use the roll's photos array.
        ZStack {
            Rectangle()
                .fill(Color.black)
            VStack(spacing: 8) {
                Image(systemName: "photo")
                    .font(.system(size: 36))
                    .foregroundStyle(.white.opacity(0.6))
                Text("필름 사진")
                    .font(.pretendard(.medium, size: 14))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .frame(height: 320)
    }

    private var counterText: some View {
        HStack {
            Spacer()
            Text("\(currentPhotoIndex + 1) / \(roll.photoCount)")
                .font(.pretendard(.medium, size: 14))
                .foregroundStyle(.primary)
            Spacer()
        }
    }

    private var viewAllButton: some View {
        HStack {
            Spacer()
            Button {
                // TODO: show all photos grid
            } label: {
                Text("전체 필름 한 눈에 보기")
                    .font(.pretendard(.semiBold, size: 16))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.black))
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
