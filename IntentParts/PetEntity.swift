import AppIntents
import CoreSpotlight

// --8<-- [start:entity]
struct PetEntity: AppEntity, IndexedEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Pet"
    static let defaultQuery = PetQuery()

    let id: UUID

    // ทุก @Property คือสิ่งที่ Siri, Shortcuts และ "Use Model" มองเห็น
    @Property(title: "Name") var name: String
    @Property(title: "Species") var species: String
    @Property(title: "Last fed") var lastFed: Date?
    @Property(title: "Last food") var lastFood: Food?
    @Property(title: "Meals today") var mealsToday: Int

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: "\(mealsToday) meals today",
            image: .init(systemName: Species(rawValue: species.lowercased())?.symbol ?? "pawprint.fill")
        )
    }

    init(_ pet: Pet, feedings: [Feeding]) {
        let last = PetData.lastFeeding(of: pet.id, in: feedings)
        id = pet.id
        name = pet.name
        species = pet.species.name
        lastFed = last?.date
        lastFood = last?.food
        mealsToday = PetData.mealsToday(of: pet.id, in: feedings)
    }
}

extension PetEntity {
    /// สร้างจากข้อมูลล่าสุดใน PetStore
    @MainActor init(_ pet: Pet) {
        self.init(pet, feedings: PetStore.shared.feedings)
    }
}
// --8<-- [end:entity]

// --8<-- [start:query]
struct PetQuery: EntityStringQuery {
    /// ระบบเก็บแค่ id ไว้ แล้วขอ entity ตัวเต็มจาก app ทีหลัง
    func entities(for identifiers: [UUID]) async throws -> [PetEntity] {
        await MainActor.run {
            let store = PetStore.shared
            store.reload()
            return identifiers.compactMap { store.pet(id: $0) }.map { PetEntity($0) }
        }
    }

    /// รายการที่แสดงให้เลือกใน Shortcuts และใช้กับ phrase "Feed Mochi"
    func suggestedEntities() async throws -> [PetEntity] {
        await MainActor.run {
            PetStore.shared.reload()
            return PetStore.shared.pets.map { PetEntity($0) }
        }
    }

    /// ค้นจากชื่อที่ผู้ใช้พิมพ์หรือพูด เช่น "Mochi"
    func entities(matching string: String) async throws -> [PetEntity] {
        await MainActor.run {
            PetStore.shared.pets
                .filter { $0.name.localizedStandardContains(string) }
                .map { PetEntity($0) }
        }
    }
}
// --8<-- [end:query]

// --8<-- [start:spotlight]
/// ส่ง entity ให้ Spotlight ทุกครั้งที่ข้อมูลเปลี่ยน ระบบจะค้นเจอทั้งใน Spotlight และ Siri
nonisolated enum SpotlightIndex {
    static func update(_ pets: [Pet], feedings: [Feeding]) {
        let entities = pets.map { PetEntity($0, feedings: feedings) }
        Task { try? await CSSearchableIndex.default().indexAppEntities(entities) }
    }
}
// --8<-- [end:spotlight]
