import AppIntents

// --8<-- [start:intent]
struct FeedPetIntent: AppIntent {
    static let title: LocalizedStringResource = "Feed Pet"
    static let description = IntentDescription("Record a meal in Pawfeed.")

    @Parameter(title: "Pet")
    var pet: PetEntity

    @Parameter(title: "Food", default: .dry)
    var food: Food

    static var parameterSummary: some ParameterSummary {
        Summary("Feed \(\.$pet) \(\.$food)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<PetEntity> & ProvidesDialog {
        let store = PetStore.shared
        guard let model = store.pet(id: pet.id) else {
            throw PetNotFound()
        }
        store.feed(model, food: food)
        return .result(
            value: PetEntity(model),
            dialog: "Fed \(model.name) \(food.name.lowercased()). Meals today: \(store.mealsToday(of: model))."
        )
    }
}
// --8<-- [end:intent]

// --8<-- [start:init]
extension FeedPetIntent {
    /// ใช้ตอนสร้าง intent เองในโค้ด เช่น ปุ่มใน app, widget และ control
    init(pet: Pet, food: Food = .dry) {
        self.pet = PetEntity(pet, feedings: PetData.loadFeedings())
        self.food = food
    }
}

/// error ที่ Siri อ่านให้ผู้ใช้ฟังได้
struct PetNotFound: Error, CustomLocalizedStringResourceConvertible {
    var localizedStringResource: LocalizedStringResource { "That pet isn't in Pawfeed anymore." }
}
// --8<-- [end:init]
