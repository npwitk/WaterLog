import Observation

/// เก็บว่าตอนนี้ต้องเปิดหน้าไหน OpenPetIntent ใช้พาผู้ใช้ไปที่สัตว์เลี้ยงที่แตะจาก Spotlight หรือ Siri
@MainActor @Observable
final class Navigator {
    static let shared = Navigator()
    var openPet: Pet?
    /// คำค้นจาก SearchPetsIntent (Siri) หรือช่องค้นหาใน app
    var searchText = ""
}
