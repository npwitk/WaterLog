import AppIntents

// --8<-- [start:intent]
struct AddEntryIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Entry"
    static let description = IntentDescription("Write a journal entry in Moodly.")

    @Parameter(title: "Text")
    var text: String

    @Parameter(title: "Mood")
    var mood: Mood?

    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$text) with mood \(\.$mood)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<EntryEntity> & ProvidesDialog {
        let entry = EntryStore.shared.add(text, mood: mood)
        return .result(
            value: EntryEntity(entry),
            dialog: "Saved to your journal. \(EntryStore.shared.thisWeek.count) entries this week."
        )
    }
}
// --8<-- [end:intent]

// --8<-- [start:init]
extension AddEntryIntent {
    /// ใช้ตอนสร้าง intent เองในโค้ด เช่น ปุ่มใน app, widget และ control
    init(text: String, mood: Mood?) {
        self.text = text
        self.mood = mood
    }
}
// --8<-- [end:init]
