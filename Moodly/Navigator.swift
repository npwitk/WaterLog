import Observation

/// เก็บว่าตอนนี้ต้องเปิดหน้าไหน OpenEntryIntent ใช้พาผู้ใช้ไปที่บันทึกที่แตะจาก Spotlight หรือ Siri
@MainActor @Observable
final class Navigator {
    static let shared = Navigator()
    var openEntry: Entry?
    var isComposing = false
    /// คำค้นจาก SearchEntriesIntent (Siri) หรือช่องค้นหาใน app
    var searchText = ""
}
