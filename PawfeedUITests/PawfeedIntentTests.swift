import XCTest

// AppIntentsTesting มีเฉพาะ iOS 27 SDK (Xcode 27) บน Xcode 26 ไฟล์นี้จะว่างและ build ผ่าน
#if canImport(AppIntentsTesting)
import AppIntentsTesting

@available(iOS 27.0, *)
final class PawfeedIntentTests: XCTestCase {
    // Bundle ID ของ test คือ "<bundle ID ของ app>.uitests" จึงตัดท้ายออกก็ได้ bundle ID ของ app
    var definitions: IntentDefinitions {
        let testBundleID = Bundle(for: Self.self).bundleIdentifier ?? ""
        return IntentDefinitions(bundleIdentifier: testBundleID.replacingOccurrences(of: ".uitests", with: ""))
    }

    // เปิด app หนึ่งครั้งก่อน ระบบจึงรู้จัก intent ของ app
    override func setUp() async throws {
        await XCUIApplication().launch()
    }

    // --8<-- [start:test]
    func testFindPetByName() async throws {
        let pets = try await definitions.entities["PetEntity"].entities(matching: "Mochi")

        XCTAssertFalse(pets.isEmpty)
    }

    func testFeedPetReturnsPet() async throws {
        let mochi = try await definitions.entities["PetEntity"].entities(matching: "Mochi")[0]

        // run intent ผ่านระบบจริงแบบเดียวกับ Siri และ Shortcuts
        let result = try await definitions.intents["FeedPetIntent"].makeIntent(pet: mochi, food: "treat").run()

        XCTAssertEqual(try result.value.name, "Mochi")
    }
    // --8<-- [end:test]
}
#endif
