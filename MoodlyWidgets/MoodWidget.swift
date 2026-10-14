import AppIntents
import SwiftUI
import WidgetKit

struct MoodEntry: TimelineEntry {
    let date: Date
    let latest: Entry?
}

struct MoodProvider: TimelineProvider {
    func placeholder(in context: Context) -> MoodEntry {
        MoodEntry(date: .now, latest: EntryData.sampleEntries.first)
    }

    func getSnapshot(in context: Context, completion: @escaping (MoodEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MoodEntry>) -> Void) {
        // อ่านข้อมูลล่าสุดจาก App Group แล้ว refresh อีกครั้งในอีก 1 ชั่วโมง
        completion(Timeline(entries: [currentEntry()], policy: .after(.now.addingTimeInterval(3600))))
    }

    private func currentEntry() -> MoodEntry {
        MoodEntry(date: .now, latest: EntryData.load().max { $0.date < $1.date })
    }
}

// --8<-- [start:view]
struct MoodWidgetView: View {
    let entry: MoodEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("How's today?").font(.headline)
            HStack(spacing: 8) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    // ปุ่มนี้ run AddEntryIntent ได้เลย โดยไม่ต้องเปิด app
                    Button(intent: AddEntryIntent(text: "\(mood.name) day", mood: mood)) {
                        Image(systemName: mood.symbol)
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                    }
                    .tint(mood.color)
                }
            }
            if let latest = entry.latest {
                Text("Last: \(latest.headline)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}
// --8<-- [end:view]

struct MoodWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "MoodWidget", provider: MoodProvider()) { entry in
            MoodWidgetView(entry: entry)
        }
        .configurationDisplayName("Mood Check-in")
        .description("Log how today feels with one tap.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    MoodWidget()
} timeline: {
    MoodEntry(date: .now, latest: EntryData.sampleEntries.first)
}
