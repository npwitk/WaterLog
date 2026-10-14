import AppIntents
import CoreSpotlight
#if compiler(>=6.4)
import GeoToolbox
#endif

// --8<-- [start:entity]
#if compiler(>=6.4)
/// Xcode 27: ใช้ App Schema ของ journal ทำให้ Siri AI รู้ว่านี่คือ "บันทึก" แบบเดียวกับ app สมุดบันทึกอื่นๆ
/// schema กำหนด property ไว้ให้แล้ว (title, message, entryDate, …) เราเติม mood เองได้
@AppEntity(schema: .journal.entry)
struct EntryEntity: IndexedEntity {
    static let defaultQuery = EntryQuery()

    let id: UUID

    var title: String?
    var message: AttributedString?
    var mediaItems: [IntentFile]
    var entryDate: Date?
    var location: PlaceDescriptor?

    // ไม่ได้อยู่ใน schema แต่เพิ่มเองได้ Siri และ "Use Model" ก็มองเห็น
    @Property(title: "Mood") var mood: Mood?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title ?? "Entry")",
            subtitle: "\((entryDate ?? .now).formatted(date: .abbreviated, time: .shortened))",
            image: .init(systemName: mood?.symbol ?? "book.closed.fill")
        )
    }

    init(_ entry: Entry) {
        id = entry.id
        title = entry.headline
        message = AttributedString(entry.text)
        mediaItems = []
        entryDate = entry.date
        location = nil
        mood = entry.mood
    }
}
#else
/// Xcode 26: entity ธรรมดา ทำงานกับ Shortcuts, Spotlight และ "Use Model" ได้เหมือนกัน
struct EntryEntity: AppEntity, IndexedEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Journal Entry"
    static let defaultQuery = EntryQuery()

    let id: UUID

    // ทุก @Property คือสิ่งที่ Siri, Shortcuts และ "Use Model" มองเห็น
    @Property(title: "Title") var title: String?
    @Property(title: "Text") var text: String
    @Property(title: "Date") var entryDate: Date?
    @Property(title: "Mood") var mood: Mood?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title ?? "Entry")",
            subtitle: "\((entryDate ?? .now).formatted(date: .abbreviated, time: .shortened))",
            image: .init(systemName: mood?.symbol ?? "book.closed.fill")
        )
    }

    init(_ entry: Entry) {
        id = entry.id
        title = entry.headline
        text = entry.text
        entryDate = entry.date
        mood = entry.mood
    }
}
#endif
// --8<-- [end:entity]

// --8<-- [start:query]
struct EntryQuery: EntityStringQuery {
    /// ระบบเก็บแค่ id ไว้ แล้วขอ entity ตัวเต็มจาก app ทีหลัง
    func entities(for identifiers: [UUID]) async throws -> [EntryEntity] {
        await MainActor.run {
            let store = EntryStore.shared
            store.reload()
            return identifiers.compactMap { store.entry(id: $0) }.map(EntryEntity.init)
        }
    }

    /// รายการที่แสดงให้เลือกใน Shortcuts
    func suggestedEntities() async throws -> [EntryEntity] {
        await MainActor.run { EntryStore.shared.entries.prefix(10).map(EntryEntity.init) }
    }

    /// ค้นจากข้อความที่ผู้ใช้พิมพ์หรือพูด เช่น "bug"
    func entities(matching string: String) async throws -> [EntryEntity] {
        await MainActor.run { EntryStore.shared.search(string).map(EntryEntity.init) }
    }
}
// --8<-- [end:query]

// --8<-- [start:spotlight]
/// ส่ง entity ให้ Spotlight ทุกครั้งที่ข้อมูลเปลี่ยน ระบบจะค้นเจอทั้งใน Spotlight และ Siri
nonisolated enum SpotlightIndex {
    static func add(_ entries: [Entry]) {
        let entities = entries.map(EntryEntity.init)
        Task { try? await CSSearchableIndex.default().indexAppEntities(entities) }
    }

    static func remove(_ ids: [UUID]) {
        Task { try? await CSSearchableIndex.default().deleteAppEntities(identifiedBy: ids, ofType: EntryEntity.self) }
    }
}
// --8<-- [end:spotlight]
