import AppIntents

// --8<-- [start:intent]
/// คืนบันทึก 7 วันล่าสุดเป็น entity เพื่อส่งต่อให้ action อื่น เช่น "Use Model" ใน Shortcuts
struct GetWeekIntent: AppIntent {
    static let title: LocalizedStringResource = "Get This Week's Entries"
    static let description = IntentDescription("Your journal entries from the last 7 days.")

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<[EntryEntity]> & ProvidesDialog {
        let store = EntryStore.shared
        store.reload()
        let week = store.thisWeek
        let counts = Mood.allCases
            .map { mood in "\(week.filter { $0.mood == mood }.count) \(mood.name.lowercased())" }
            .formatted(.list(type: .and))
        return .result(
            value: week.map(EntryEntity.init),
            dialog: "\(week.count) entries this week: \(counts)."
        )
    }
}
// --8<-- [end:intent]
