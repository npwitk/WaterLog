import AppIntents
import SwiftUI
import WidgetKit

struct PetsEntry: TimelineEntry {
    let date: Date
    let pets: [Pet]
    let feedings: [Feeding]
}

struct PetsProvider: TimelineProvider {
    func placeholder(in context: Context) -> PetsEntry {
        PetsEntry(date: .now, pets: PetData.samplePets, feedings: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (PetsEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PetsEntry>) -> Void) {
        // อ่านข้อมูลล่าสุดจาก App Group แล้ว refresh อีกครั้งในอีก 1 ชั่วโมง
        completion(Timeline(entries: [currentEntry()], policy: .after(.now.addingTimeInterval(3600))))
    }

    private func currentEntry() -> PetsEntry {
        PetsEntry(date: .now, pets: PetData.loadPets(), feedings: PetData.loadFeedings())
    }
}

// --8<-- [start:view]
struct PetsWidgetView: View {
    let entry: PetsEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(entry.pets.prefix(3)) { pet in
                HStack(spacing: 10) {
                    Image(systemName: pet.species.symbol)
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(pet.species.color.gradient, in: .circle)
                    VStack(alignment: .leading, spacing: 0) {
                        Text(pet.name).font(.subheadline.bold())
                        LastFedLabel(date: PetData.lastFeeding(of: pet.id, in: entry.feedings)?.date)
                            .font(.caption2)
                    }
                    Spacer()
                    // ปุ่มนี้ run FeedPetIntent ได้เลย โดยไม่ต้องเปิด app
                    Button(intent: FeedPetIntent(pet: pet)) {
                        Image(systemName: "fork.knife")
                    }
                    .tint(.orange)
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}
// --8<-- [end:view]

struct PetsWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "PetsWidget", provider: PetsProvider()) { entry in
            PetsWidgetView(entry: entry)
        }
        .configurationDisplayName("My Pets")
        .description("See who ate last and feed them with one tap.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    PetsWidget()
} timeline: {
    PetsEntry(date: .now, pets: PetData.samplePets, feedings: [])
}
