import Foundation

/// อารมณ์ของวันนั้น มีไม่กี่แบบ จึงเป็น AppEnum ได้ในบท Intent แรก
nonisolated enum Mood: String, Codable, CaseIterable, Sendable {
    case great, okay, rough

    var name: String { rawValue.capitalized }

    /// ใช้สภาพอากาศแทนอารมณ์
    var symbol: String {
        switch self {
        case .great: "sun.max.fill"
        case .okay: "cloud.sun.fill"
        case .rough: "cloud.rain.fill"
        }
    }
}

/// บันทึก 1 รายการในสมุดบันทึก
nonisolated struct Entry: Identifiable, Codable, Hashable, Sendable {
    var id = UUID()
    var title: String?
    var text: String
    var date = Date.now
    var mood: Mood?

    /// ชื่อที่ใช้แสดง: ใช้ title ถ้ามี ไม่มีก็ใช้บรรทัดแรกของข้อความ
    var headline: String {
        if let title, !title.isEmpty { return title }
        return text.split(separator: "\n").first.map(String.init) ?? "Entry"
    }
}
