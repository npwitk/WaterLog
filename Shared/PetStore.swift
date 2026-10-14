import Foundation
import Observation
import WidgetKit

/// อ่าน/เขียนข้อมูลใน App Group ที่ app และ widget extension ใช้ร่วมกัน
/// ไม่ผูกกับ MainActor จึงเรียกจาก widget timeline ได้
nonisolated enum PetData {
    private static let petsKey = "pets"
    private static let feedingsKey = "feedings"

    /// App Group ID มาจาก build setting PAWFEED_APP_GROUP ผ่าน Info.plist
    /// ถ้าหาไม่เจอ (ยังไม่ได้ตั้ง App Group) จะใช้ UserDefaults ปกติ: app ทำงานได้ แต่ widget จะไม่เห็นข้อมูล
    static var defaults: UserDefaults {
        let group = Bundle.main.object(forInfoDictionaryKey: "PawfeedAppGroup") as? String
        return group.flatMap { UserDefaults(suiteName: $0) } ?? .standard
    }

    /// สัตว์เลี้ยงตัวอย่าง (ข้อมูลสมมติ) ใส่ให้ตอนเปิด app ครั้งแรก
    /// id ตายตัว app และ widget จึงเห็นเป็นตัวเดียวกันเสมอ
    static let samplePets = [
        Pet(id: UUID(uuidString: "A1B2C3D4-0001-4000-8000-000000000001")!, name: "Mochi", species: .cat),
        Pet(id: UUID(uuidString: "A1B2C3D4-0002-4000-8000-000000000002")!, name: "Taro", species: .dog),
        Pet(id: UUID(uuidString: "A1B2C3D4-0003-4000-8000-000000000003")!, name: "Nori", species: .rabbit),
    ]

    static func loadPets() -> [Pet] {
        if let data = defaults.data(forKey: petsKey),
           let pets = try? JSONDecoder().decode([Pet].self, from: data) {
            return pets
        }
        save(pets: samplePets)
        return samplePets
    }

    static func loadFeedings() -> [Feeding] {
        guard let data = defaults.data(forKey: feedingsKey) else { return [] }
        return (try? JSONDecoder().decode([Feeding].self, from: data)) ?? []
    }

    static func save(pets: [Pet]) {
        defaults.set(try? JSONEncoder().encode(pets), forKey: petsKey)
    }

    static func save(feedings: [Feeding]) {
        defaults.set(try? JSONEncoder().encode(feedings), forKey: feedingsKey)
    }

    static func lastFeeding(of petID: UUID, in feedings: [Feeding]) -> Feeding? {
        feedings.filter { $0.petID == petID }.max { $0.date < $1.date }
    }

    static func mealsToday(of petID: UUID, in feedings: [Feeding]) -> Int {
        feedings.filter { $0.petID == petID && Calendar.current.isDateInToday($0.date) }.count
    }
}

/// ข้อมูลที่หน้าจอของ app ใช้ ทุก action ทั้งจากปุ่มใน app, Siri, Shortcuts และ widget มาจบที่นี่
@MainActor @Observable
final class PetStore {
    static let shared = PetStore()

    private(set) var pets: [Pet] = []
    private(set) var feedings: [Feeding] = []

    init() {
        reload()
        SpotlightIndex.update(pets, feedings: feedings)
    }

    /// อ่านใหม่จาก App Group เพราะ widget อาจเขียนข้อมูลไว้ตอนที่ app ไม่ได้เปิดอยู่
    func reload() {
        pets = PetData.loadPets()
        feedings = PetData.loadFeedings()
    }

    @discardableResult
    func feed(_ pet: Pet, food: Food = .dry) -> Feeding {
        reload()
        let feeding = Feeding(petID: pet.id, food: food)
        feedings.append(feeding)
        PetData.save(feedings: feedings)
        SpotlightIndex.update([pet], feedings: feedings)
        // บอก widget และ control ให้วาดใหม่ทันที
        WidgetCenter.shared.reloadAllTimelines()
        ControlCenter.shared.reloadAllControls()
        return feeding
    }

    func pet(id: UUID) -> Pet? {
        pets.first { $0.id == id }
    }

    func pet(named name: String) -> Pet? {
        pets.first { $0.name.localizedCaseInsensitiveCompare(name) == .orderedSame }
    }

    func lastFeeding(of pet: Pet) -> Feeding? {
        PetData.lastFeeding(of: pet.id, in: feedings)
    }

    func mealsToday(of pet: Pet) -> Int {
        PetData.mealsToday(of: pet.id, in: feedings)
    }

    /// การให้อาหารวันนี้ทั้งหมด ใหม่สุดก่อน
    var todayFeedings: [Feeding] {
        feedings.filter { Calendar.current.isDateInToday($0.date) }.sorted { $0.date > $1.date }
    }
}
