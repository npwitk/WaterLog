import AppIntents
import SwiftUI

struct ContentView: View {
    @State private var store = EntryStore.shared
    @State private var navigator = Navigator.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    CheckInCard()
                    WeekSummary(entries: store.thisWeek)

                    GlassEffectContainer(spacing: 16) {
                        // iPad แสดงหลายคอลัมน์ iPhone แสดงคอลัมน์เดียว
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 340), spacing: 16)], spacing: 16) {
                            ForEach(visibleEntries) { entry in
                                EntryCard(entry: entry)
                                    .onTapGesture { navigator.openEntry = entry }
                                    // --8<-- [start:annotate]
                                    // บอกระบบว่าการ์ดนี้คือบันทึกไหน Siri จึงเข้าใจ "open the second one"
                                    .appEntityIdentifier(EntityIdentifier(for: EntryEntity.self, identifier: entry.id))
                                    // --8<-- [end:annotate]
                            }
                        }
                    }
                }
                .padding()
            }
            .background(Backdrop())
            .navigationTitle("Moodly")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("New Entry", systemImage: "square.and.pencil") { navigator.isComposing = true }
                }
            }
            // ช่องค้นหาเดียวกับที่ SearchEntriesIntent ใส่คำค้นให้เมื่อสั่ง Siri
            .searchable(text: $navigator.searchText, prompt: "Search your journal")
            .sheet(item: $navigator.openEntry) { entry in
                EntryDetail(entryID: entry.id)
            }
            .sheet(isPresented: $navigator.isComposing) {
                ComposeView()
            }
        }
        .onChange(of: scenePhase) { _, phase in
            // widget อาจบันทึกข้อมูลไว้ตอนที่ app อยู่เบื้องหลัง
            if phase == .active { store.reload() }
        }
    }

    private var visibleEntries: [Entry] {
        navigator.searchText.isEmpty ? store.entries : store.search(navigator.searchText)
    }
}

/// พื้นหลังสีอ่อนๆ ให้กระจก (Liquid Glass) มีสีให้หักเห
struct Backdrop: View {
    var body: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [[0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.55, 0.5], [1, 0.5], [0, 1], [0.5, 1], [1, 1]],
            colors: [.orange.opacity(0.45), .pink.opacity(0.3), .indigo.opacity(0.35),
                     .yellow.opacity(0.25), .white.opacity(0.2), .teal.opacity(0.3),
                     .purple.opacity(0.3), .teal.opacity(0.25), .orange.opacity(0.3)]
        )
        .ignoresSafeArea()
    }
}

/// "How's today?" กดครั้งเดียวบันทึกอารมณ์ของวันนี้
struct CheckInCard: View {
    @State private var store = EntryStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How's today?").font(.title3.bold())
            GlassEffectContainer(spacing: 10) {
                HStack(spacing: 10) {
                    // --8<-- [start:app-button]
                    // ปุ่มใน app ก็เรียก intent ตัวเดียวกับ Siri และ widget ได้
                    Button(intent: AddEntryIntent(text: "Great day", mood: .great)) {
                        MoodChoice(mood: .great)
                    }
                    // --8<-- [end:app-button]
                    .buttonStyle(.glass)
                    Button(intent: AddEntryIntent(text: "Okay day", mood: .okay)) {
                        MoodChoice(mood: .okay)
                    }
                    .buttonStyle(.glass)
                    Button(intent: AddEntryIntent(text: "Rough day", mood: .rough)) {
                        MoodChoice(mood: .rough)
                    }
                    .buttonStyle(.glass)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
    }
}

struct MoodChoice: View {
    let mood: Mood

    var body: some View {
        VStack(spacing: 6) {
            MoodIcon(mood: mood, size: 44)
            Text(mood.name).font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }
}

struct WeekSummary: View {
    let entries: [Entry]

    var body: some View {
        HStack(spacing: 16) {
            Text("This week").font(.headline)
            Spacer()
            ForEach(Mood.allCases, id: \.self) { mood in
                Label("\(entries.filter { $0.mood == mood }.count)", systemImage: mood.symbol)
                    .foregroundStyle(mood.color)
                    .font(.headline)
                    .contentTransition(.numericText())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .glassEffect(.regular, in: .capsule)
        .animation(.default, value: entries.count)
    }
}

struct EntryCard: View {
    let entry: Entry

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            MoodIcon(mood: entry.mood, size: 48)
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.headline).font(.headline)
                Text(entry.text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(entry.date, format: .relative(presentation: .named))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            Spacer(minLength: 0)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 26))
        .contentShape(.rect(cornerRadius: 26))
    }
}

struct EntryDetail: View {
    let entryID: UUID
    @State private var store = EntryStore.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        if let entry = store.entry(id: entryID) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 14) {
                        MoodIcon(mood: entry.mood, size: 64)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.headline).font(.title.bold())
                            Text(entry.date.formatted(date: .complete, time: .shortened))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Text(entry.text).font(.body)
                    GlassEffectContainer(spacing: 10) {
                        HStack(spacing: 10) {
                            ForEach(Mood.allCases, id: \.self) { mood in
                                Button { store.update(entry.id, mood: mood) } label: {
                                    MoodChoice(mood: mood)
                                }
                                .buttonStyle(.glass)
                                .opacity(entry.mood == mood ? 1 : 0.6)
                            }
                        }
                    }
                    Button("Delete Entry", systemImage: "trash", role: .destructive) {
                        store.delete([entry.id])
                        dismiss()
                    }
                    .buttonStyle(.glass)
                }
                .padding(24)
            }
            .presentationDetents([.medium, .large])
            // --8<-- [start:detail]
            // หน้านี้แสดงบันทึกเดียวเป็นหลัก: บอกระบบผ่าน user activity
            // Siri จึงรู้ว่า "this entry" หมายถึงบันทึกนี้
            .userActivity("th.yidh26.moodly.view-entry") { activity in
                activity.title = entry.headline
                activity.appEntityIdentifier = EntityIdentifier(for: EntryEntity.self, identifier: entry.id)
            }
            // --8<-- [end:detail]
        } else {
            ContentUnavailableView("Entry deleted", systemImage: "trash")
        }
    }
}

struct ComposeView: View {
    @State private var title = ""
    @State private var text = ""
    @State private var mood: Mood?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Title (optional)", text: $title)
                    .font(.title3.bold())
                    .padding(16)
                    .glassEffect(.regular, in: .rect(cornerRadius: 20))
                TextEditor(text: $text)
                    .scrollContentBackground(.hidden)
                    .padding(12)
                    .frame(minHeight: 160)
                    .glassEffect(.regular, in: .rect(cornerRadius: 20))
                GlassEffectContainer(spacing: 10) {
                    HStack(spacing: 10) {
                        ForEach(Mood.allCases, id: \.self) { choice in
                            Button { mood = choice } label: { MoodChoice(mood: choice) }
                                .buttonStyle(.glass)
                                .opacity(mood == choice ? 1 : 0.55)
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", systemImage: "xmark") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", systemImage: "checkmark") {
                        EntryStore.shared.add(text, title: title.isEmpty ? nil : title, mood: mood)
                        dismiss()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
