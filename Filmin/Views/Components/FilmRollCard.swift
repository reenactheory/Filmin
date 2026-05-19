import SwiftUI

struct FilmRollCard: View {
    let roll: FilmRoll

    var body: some View {
        VStack(spacing: 6) {
            FilmCanisterView(filmStock: roll.filmStock, frameCount: roll.photoCount)
                .frame(maxWidth: .infinity)

            HStack(spacing: 6) {
                Text(roll.title)
                    .font(.pretendard(.bold, size: 17))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("\(roll.photoCount)")
                    .font(.pretendard(.semiBold, size: 12))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray6))
                    )
            }

            VStack(spacing: 2) {
                Text(roll.filmStock)
                    .font(.pretendard(.semiBold, size: 14))
                    .foregroundStyle(.secondary)
                Text(roll.camera)
                    .font(.pretendard(.semiBold, size: 14))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FilmRollCard(roll: FilmRoll.samples[0])
        .frame(width: 180)
        .padding()
}
