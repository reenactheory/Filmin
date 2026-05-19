import SwiftUI

struct FilmRollCard: View {
    let roll: FilmRoll

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            FilmCanisterView(filmStock: roll.filmStock, frameCount: roll.frameCount)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 4)

            HStack(spacing: 6) {
                Text(roll.title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text("\(roll.frameCount)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray6))
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(roll.filmStock)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Text(roll.camera)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    FilmRollCard(roll: FilmRoll.samples[0])
        .frame(width: 180)
        .padding()
}
