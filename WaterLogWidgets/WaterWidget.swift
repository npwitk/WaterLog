import AppIntents
import SwiftUI
import WidgetKit

struct WaterEntry: TimelineEntry {
    let date: Date
    let total: Int
}

struct WaterProvider: TimelineProvider {
    func placeholder(in context: Context) -> WaterEntry {
        WaterEntry(date: .now, total: 750)
    }

    func getSnapshot(in context: Context, completion: @escaping (WaterEntry) -> Void) {
        completion(WaterEntry(date: .now, total: WaterData.todayTotal()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WaterEntry>) -> Void) {
        // อ่านยอดล่าสุดจาก App Group แล้ว refresh อีกครั้งตอนเที่ยงคืนเพื่อเริ่มนับวันใหม่
        let entry = WaterEntry(date: .now, total: WaterData.todayTotal())
        let midnight = Calendar.current.startOfDay(for: .now.addingTimeInterval(86_400))
        completion(Timeline(entries: [entry], policy: .after(midnight)))
    }
}

// --8<-- [start:view]
struct WaterWidgetView: View {
    let entry: WaterEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Today", systemImage: "drop.fill")
                .font(.caption.bold())
                .foregroundStyle(.blue)
            Text("\(entry.total) ml")
                .font(.title2.bold())
                .contentTransition(.numericText())
            ProgressView(value: Double(min(entry.total, WaterData.dailyGoal)),
                         total: Double(WaterData.dailyGoal))
            // ปุ่มนี้ run LogWaterIntent ได้เลย โดยไม่ต้องเปิด app
            Button(intent: LogWaterIntent(milliliters: 250)) {
                Label("250 ml", systemImage: "plus")
                    .frame(maxWidth: .infinity)
            }
            .tint(.blue)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}
// --8<-- [end:view]

struct WaterWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WaterWidget", provider: WaterProvider()) { entry in
            WaterWidgetView(entry: entry)
        }
        .configurationDisplayName("Water Today")
        .description("See today's total and log a glass.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    WaterWidget()
} timeline: {
    WaterEntry(date: .now, total: 750)
}
