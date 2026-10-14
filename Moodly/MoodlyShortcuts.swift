import AppIntents

// --8<-- [start:shortcuts]
/// App Shortcuts ใช้ได้ทันทีหลังติดตั้ง ไม่ต้องให้ผู้ใช้สร้าง shortcut เอง
/// ทุก phrase ต้องมี \(.applicationName)
struct MoodlyShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddEntryIntent(),
            phrases: [
                "Add an entry in \(.applicationName)",
                "Log a \(\.$mood) day in \(.applicationName)",
            ],
            shortTitle: "Add Entry",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: GetWeekIntent(),
            phrases: ["How was my week in \(.applicationName)"],
            shortTitle: "My Week",
            systemImageName: "calendar"
        )
    }

    static let shortcutTileColor: ShortcutTileColor = .orange
}
// --8<-- [end:shortcuts]
