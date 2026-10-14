import AppIntents

// App Schemas เป็น API ของ iOS 27: build ได้เฉพาะ Xcode 27
// บน Xcode 26 จะใช้ OpenPetIntent แบบธรรมดาใน OpenPetIntent.swift แทน
#if compiler(>=6.4)
// --8<-- [start:schema]
/// ใช้ schema .system.open ทำให้ Siri รู้ว่า intent นี้คือ "เปิดสิ่งนี้"
/// schema กำหนด title และ parameter ให้แล้ว เราเขียนแค่ target กับ perform()
@available(iOS 27.0, *)
@AppIntent(schema: .system.open)
struct OpenPetIntent {
    var target: PetEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        Navigator.shared.openPet = PetStore.shared.pet(id: target.id)
        return .result()
    }
}
// --8<-- [end:schema]
#endif
