import Foundation

/// ชนิดของสัตว์เลี้ยง ใช้เลือกไอคอน
nonisolated enum Species: String, Codable, CaseIterable, Sendable {
    case cat, dog, rabbit, bird, fish

    var name: String { rawValue.capitalized }

    var symbol: String {
        switch self {
        case .cat: "cat.fill"
        case .dog: "dog.fill"
        case .rabbit: "hare.fill"
        case .bird: "bird.fill"
        case .fish: "fish.fill"
        }
    }
}

/// อาหารที่ให้ได้ มีไม่กี่แบบ จึงเป็น AppEnum ได้ในบท App entities
nonisolated enum Food: String, Codable, CaseIterable, Sendable {
    case dry, wet, treat

    var name: String {
        switch self {
        case .dry: "Dry food"
        case .wet: "Wet food"
        case .treat: "Treat"
        }
    }

    var symbol: String {
        switch self {
        case .dry: "fork.knife"
        case .wet: "drop.fill"
        case .treat: "heart.fill"
        }
    }
}

nonisolated struct Pet: Identifiable, Codable, Hashable, Sendable {
    let id: UUID
    var name: String
    var species: Species
}

/// การให้อาหาร 1 ครั้ง
nonisolated struct Feeding: Identifiable, Codable, Hashable, Sendable {
    var id = UUID()
    let petID: UUID
    let food: Food
    var date = Date.now
}
