import SwiftUI

/// สีประจำอารมณ์ ใช้ทั้งใน app และ widget
extension Mood {
    var color: Color {
        switch self {
        case .great: .orange
        case .okay: .teal
        case .rough: .indigo
        }
    }
}

/// วงกลมไอคอนอารมณ์ ถ้ายังไม่ได้เลือกอารมณ์จะเป็นรูปสมุด
struct MoodIcon: View {
    let mood: Mood?
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: mood?.symbol ?? "book.closed.fill")
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background((mood?.color ?? .gray).gradient, in: .circle)
    }
}
