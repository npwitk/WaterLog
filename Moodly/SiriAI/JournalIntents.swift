import AppIntents

// App Schemas ของ journal: Siri AI เข้าใจคำพูดแบบธรรมดาเอง เราไม่ต้องเขียน phrase
// เป็น API ของ iOS 27 build ได้เฉพาะ Xcode 27 บน Xcode 26 ใช้ OpenEntryIntent ธรรมดาใน OpenEntryIntent.swift
#if compiler(>=6.4)
import GeoToolbox

// --8<-- [start:create]
/// "Write in Moodly that I finally fixed the login bug"
@AppIntent(schema: .journal.createEntry)
struct CreateEntryIntent {
    var message: AttributedString
    var title: String?
    var location: PlaceDescriptor?
    var mediaItems: [IntentFile]
    var entryDate: Date?

    @MainActor
    func perform() async throws -> some ReturnsValue<EntryEntity> {
        let text = String(message.characters)
        // AI บนเครื่อง (Foundation Models) เดาอารมณ์จากข้อความให้
        let mood = await MoodGuesser.guess(for: text)
        let entry = EntryStore.shared.add(text, title: title, mood: mood, date: entryDate ?? .now)
        return .result(value: EntryEntity(entry))
    }
}
// --8<-- [end:create]

// --8<-- [start:update]
/// "Change the title of this entry to Demo day"
@AppIntent(schema: .journal.updateEntry)
struct UpdateEntryIntent {
    var target: EntryEntity
    var title: String?
    var message: AttributedString?
    var mediaItems: [IntentFile]?
    var entryDate: Date?
    var location: PlaceDescriptor?

    @MainActor
    func perform() async throws -> some IntentResult {
        EntryStore.shared.update(
            target.id,
            title: title,
            text: message.map { String($0.characters) },
            date: entryDate
        )
        return .result()
    }
}
// --8<-- [end:update]

// --8<-- [start:delete]
/// "Delete this entry" Siri ถามยืนยันให้เองก่อนลบ
@AppIntent(schema: .journal.deleteEntry)
struct DeleteEntryIntent: DeleteIntent {
    var entities: [EntryEntity]

    @MainActor
    func perform() async throws -> some IntentResult {
        EntryStore.shared.delete(entities.map(\.id))
        return .result()
    }
}
// --8<-- [end:delete]

// --8<-- [start:search]
/// "Search Moodly for bug" เปิด app พร้อมผลค้นหา
@AppIntent(schema: .journal.search)
struct SearchEntriesIntent: ShowInAppSearchResultsIntent {
    static var searchScopes: [StringSearchScope] = [.general]

    var criteria: StringSearchCriteria

    @MainActor
    func perform() async throws -> some IntentResult {
        Navigator.shared.searchText = criteria.term
        return .result()
    }
}
// --8<-- [end:search]

// --8<-- [start:open]
/// เปิด app ไปที่บันทึกที่แตะจาก Spotlight หรือที่บอก Siri ว่า "Open my last entry"
@available(iOS 27.0, *)
@AppIntent(schema: .system.open)
struct OpenEntryIntent {
    var target: EntryEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        Navigator.shared.openEntry = EntryStore.shared.entry(id: target.id)
        return .result()
    }
}
// --8<-- [end:open]
#endif
