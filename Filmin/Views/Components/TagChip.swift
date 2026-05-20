import SwiftUI

struct TagChip: View {
    let text: String
    var fontSize: CGFloat = 16

    var body: some View {
        // Padding scales with font size so the chip stays proportional
        // when smaller variants are used (e.g., on the gallery view).
        let hPadding = fontSize * (18.0 / 16.0)
        let vPadding = fontSize * (7.0 / 16.0)

        Text(text)
            .font(.pretendard(.bold, size: fontSize))
            .foregroundStyle(Color(hex: "#27272A"))
            .padding(.horizontal, hPadding)
            .padding(.vertical, vPadding)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(.systemGray6))
            )
    }
}

#Preview {
    VStack(spacing: 8) {
        TagChip(text: "#135")
        TagChip(text: "#Leica R3")
        TagChip(text: "#ISO400")
        TagChip(text: "#엘리카메라에서")
        TagChip(text: "#20250412에 현상")
    }
    .padding()
}
