import AppIntents
import SwiftUI

@main
struct PawfeedApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // บอกระบบว่ามีสัตว์เลี้ยงตัวไหนบ้าง phrase "Feed Mochi in Pawfeed" จึงใช้ได้
                    PawShortcuts.updateAppShortcutParameters()
                }
        }
    }
}
