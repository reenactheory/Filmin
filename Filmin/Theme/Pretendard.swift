import SwiftUI

enum PretendardWeight {
    case regular, medium, semiBold, bold

    var fontName: String {
        switch self {
        case .regular: return "Pretendard-Regular"
        case .medium: return "Pretendard-Medium"
        case .semiBold: return "Pretendard-SemiBold"
        case .bold: return "Pretendard-Bold"
        }
    }
}

extension Font {
    static func pretendard(_ weight: PretendardWeight, size: CGFloat) -> Font {
        .custom(weight.fontName, size: size)
    }
}
