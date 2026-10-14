import AppIntents

// --8<-- [start:shortcuts]
/// App Shortcuts ใช้ได้ทันทีหลังติดตั้ง ไม่ต้องให้ผู้ใช้สร้าง shortcut เอง
/// ทุก phrase ต้องมี \(.applicationName)
struct PawShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: FeedPetIntent(),
            phrases: [
                "Feed \(\.$pet) in \(.applicationName)",
                "Feed my pet in \(.applicationName)",
            ],
            shortTitle: "Feed Pet",
            systemImageName: "pawprint.fill"
        )
        AppShortcut(
            intent: GetPetsIntent(),
            phrases: ["How are my pets in \(.applicationName)"],
            shortTitle: "My Pets",
            systemImageName: "list.bullet"
        )
    }

    static let shortcutTileColor: ShortcutTileColor = .orange
}
// --8<-- [end:shortcuts]
