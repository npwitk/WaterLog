import AppIntents
import SwiftUI
import WidgetKit

// --8<-- [start:control]
/// ปุ่มใน Control Center (และ Lock Screen) ที่ run AddEntryIntent ตัวเดิม
struct GreatDayControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "GreatDayControl") {
            ControlWidgetButton(action: AddEntryIntent(text: "Great moment", mood: .great)) {
                Label("Great moment", systemImage: "sun.max.fill")
            }
        }
        .displayName("Log a Great Moment")
        .description("Save a great moment to your journal.")
    }
}
// --8<-- [end:control]
