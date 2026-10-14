import XCTest

// AppIntentsTesting มีเฉพาะ iOS 27 SDK (Xcode 27) บน Xcode 26 ไฟล์นี้จะว่างและ build ผ่าน
#if canImport(AppIntentsTesting)
import AppIntentsTesting

@available(iOS 27.0, *)
final class MoodlyIntentTests: XCTestCase {
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
    func testAddEntryThenFindIt() async throws {
        // run intent ผ่านระบบจริงแบบเดียวกับ Siri และ Shortcuts
        _ = try await definitions.intents["AddEntryIntent"]
            .makeIntent(text: "Shipped the workshop app", mood: "great").run()

        let found = try await definitions.entities["EntryEntity"].entities(matching: "workshop")

        XCTAssertFalse(found.isEmpty)
    }
    // --8<-- [end:test]
}
#endif
