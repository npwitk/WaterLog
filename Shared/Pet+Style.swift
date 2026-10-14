import SwiftUI

/// สีประจำสัตว์แต่ละชนิด ใช้ทั้งใน app และ widget
extension Species {
    var color: Color {
        switch self {
        case .cat: .orange
        case .dog: .brown
        case .rabbit: .pink
        case .bird: .teal
        case .fish: .blue
        }
    }
}

/// "Fed 2 hours ago" หรือ "Not fed yet" อัปเดตเองตามเวลา
struct LastFedLabel: View {
    let date: Date?

    var body: some View {
        if let date {
            Text("Fed \(Text(date, style: .relative)) ago")
                .foregroundStyle(.secondary)
        } else {
            Text("Not fed yet")
                .foregroundStyle(.orange)
        }
    }
}
