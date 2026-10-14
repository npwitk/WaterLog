import Foundation
import Observation
import WidgetKit

/// อ่าน/เขียนข้อมูลใน App Group ที่ app และ widget extension ใช้ร่วมกัน
/// ไม่ผูกกับ MainActor จึงเรียกจาก widget timeline ได้
nonisolated enum EntryData {
    private static let key = "entries"

    /// App Group ID มาจาก build setting MOODLY_APP_GROUP ผ่าน Info.plist
    /// ถ้าหาไม่เจอ (ยังไม่ได้ตั้ง App Group) จะใช้ UserDefaults ปกติ: app ทำงานได้ แต่ widget จะไม่เห็นข้อมูล
    static var defaults: UserDefaults {
        let group = Bundle.main.object(forInfoDictionaryKey: "MoodlyAppGroup") as? String
        return group.flatMap { UserDefaults(suiteName: $0) } ?? .standard
    }

    /// บันทึกตัวอย่าง (ข้อมูลสมมติ) ใส่ให้ตอนเปิด app ครั้งแรก
    static var sampleEntries: [Entry] {
        let day: TimeInterval = 86_400
        return [
            Entry(title: "Demo day prep", text: "Practiced our pitch twice. The demo finally works end to end!", date: .now.addingTimeInterval(-2 * 3600), mood: .great),
            Entry(title: "Long lecture", text: "Three hours of calculus. Tired, but I understand limits now.", date: .now.addingTimeInterval(-day), mood: .okay),
            Entry(title: "Missed the bus", text: "Rain, missed the bus, and forgot my charger. Rough morning.", date: .now.addingTimeInterval(-3 * day), mood: .rough),
        ]
    }

    static func load() -> [Entry] {
        if let data = defaults.data(forKey: key),
           let entries = try? JSONDecoder().decode([Entry].self, from: data) {
            return entries
        }
        let samples = sampleEntries
        save(samples)
        return samples
    }

    static func save(_ entries: [Entry]) {
        defaults.set(try? JSONEncoder().encode(entries), forKey: key)
    }
}

/// ข้อมูลที่หน้าจอของ app ใช้ ทุก action ทั้งจากปุ่มใน app, Siri, Shortcuts และ widget มาจบที่นี่
@MainActor @Observable
final class EntryStore {
    static let shared = EntryStore()

    private(set) var entries: [Entry] = []

    init() {
        reload()
        SpotlightIndex.add(entries)
    }

    /// อ่านใหม่จาก App Group เพราะ widget อาจเขียนข้อมูลไว้ตอนที่ app ไม่ได้เปิดอยู่
    func reload() {
        entries = EntryData.load().sorted { $0.date > $1.date }
    }

    @discardableResult
    func add(_ text: String, title: String? = nil, mood: Mood? = nil, date: Date = .now) -> Entry {
        reload()
        let entry = Entry(title: title, text: text, date: date, mood: mood)
        entries.insert(entry, at: 0)
        save()
        SpotlightIndex.add([entry])
        return entry
    }

    @discardableResult
    func update(_ id: UUID, title: String? = nil, text: String? = nil, mood: Mood? = nil, date: Date? = nil) -> Entry? {
        reload()
        guard let index = entries.firstIndex(where: { $0.id == id }) else { return nil }
        if let title { entries[index].title = title }
        if let text { entries[index].text = text }
        if let mood { entries[index].mood = mood }
        if let date { entries[index].date = date }
        save()
        SpotlightIndex.add([entries[index]])
        return entries[index]
    }

    func delete(_ ids: [UUID]) {
        reload()
        entries.removeAll { ids.contains($0.id) }
        save()
        SpotlightIndex.remove(ids)
    }

    func entry(id: UUID) -> Entry? {
        entries.first { $0.id == id }
    }

    func search(_ term: String) -> [Entry] {
        entries.filter {
            $0.text.localizedStandardContains(term) || ($0.title?.localizedStandardContains(term) ?? false)
        }
    }

    /// บันทึก 7 วันล่าสุด
    var thisWeek: [Entry] {
        let start = Date.now.addingTimeInterval(-7 * 86_400)
        return entries.filter { $0.date >= start }
    }

    private func save() {
        EntryData.save(entries)
        // บอก widget และ control ให้วาดใหม่ทันที
        WidgetCenter.shared.reloadAllTimelines()
        ControlCenter.shared.reloadAllControls()
    }
}
