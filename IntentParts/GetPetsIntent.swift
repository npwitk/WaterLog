import AppIntents

// --8<-- [start:intent]
/// คืนสัตว์เลี้ยงทุกตัวเป็น entity เพื่อส่งต่อให้ action อื่น เช่น "Use Model" ใน Shortcuts
struct GetPetsIntent: AppIntent {
    static let title: LocalizedStringResource = "Get My Pets"
    static let description = IntentDescription("Every pet with when it last ate.")

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<[PetEntity]> & ProvidesDialog {
        let store = PetStore.shared
        store.reload()
        let hungry = store.pets.filter { store.mealsToday(of: $0) == 0 }.map(\.name)
        let summary = hungry.isEmpty
            ? "Everyone has eaten today."
            : "Not fed yet today: \(hungry.formatted(.list(type: .and)))."
        return .result(value: store.pets.map { PetEntity($0) }, dialog: "\(summary)")
    }
}
// --8<-- [end:intent]
