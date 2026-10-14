import AppIntents

// Xcode 27 ใช้ OpenEntryIntent แบบ App Schema ใน SiriAI/JournalIntents.swift แทน
// เพราะ entity หนึ่งตัวมี OpenIntent ได้ตัวเดียว
#if !compiler(>=6.4)
// --8<-- [start:open]
/// เมื่อผู้ใช้แตะบันทึกใน Spotlight หรือใน Siri ระบบจะใช้ intent นี้เปิด app ไปที่บันทึกนั้น
struct OpenEntryIntent: OpenIntent {
    static let title: LocalizedStringResource = "Open Entry"

    @Parameter(title: "Entry")
    var target: EntryEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        Navigator.shared.openEntry = EntryStore.shared.entry(id: target.id)
        return .result()
    }
}
// --8<-- [end:open]
#endif
