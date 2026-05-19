import SwiftUI

struct TagChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.pretendard(.bold, size: 16))
            .foregroundStyle(Color(hex: "#27272A"))
            .padding(.horizontal, 18)
            .padding(.vertical, 7)
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
