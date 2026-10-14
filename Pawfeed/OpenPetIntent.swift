import AppIntents

// Xcode 27 ใช้ OpenPetIntent แบบ App Schema ใน SiriAI/OpenPetIntent+Schema.swift แทน
// เพราะ entity หนึ่งตัวมี OpenIntent ได้ตัวเดียว
#if !compiler(>=6.4)
// --8<-- [start:open]
/// เมื่อผู้ใช้แตะสัตว์เลี้ยงใน Spotlight หรือใน Siri ระบบจะใช้ intent นี้เปิด app ไปที่ตัวนั้น
struct OpenPetIntent: OpenIntent {
    static let title: LocalizedStringResource = "Open Pet"

    @Parameter(title: "Pet")
    var target: PetEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        Navigator.shared.openPet = PetStore.shared.pet(id: target.id)
        return .result()
    }
}
// --8<-- [end:open]
#endif
