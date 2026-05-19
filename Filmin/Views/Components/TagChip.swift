import SwiftUI

struct TagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.pretendard(.medium, size: 14))
            .foregroundStyle(Color(hex: "#52525B"))
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
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
