import AppIntents
import SwiftUI

struct ContentView: View {
    @State private var store = PetStore.shared
    @State private var navigator = Navigator.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TodaySummary(pets: store.pets.count, meals: store.todayFeedings.count)

                    GlassEffectContainer(spacing: 16) {
                        // iPad แสดงหลายคอลัมน์ iPhone แสดงคอลัมน์เดียว
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 340), spacing: 16)], spacing: 16) {
                            ForEach(visiblePets) { pet in
                                PetCard(pet: pet)
                                    .onTapGesture { navigator.openPet = pet }
                                    // --8<-- [start:annotate]
                                    // บอกระบบว่าการ์ดนี้คือสัตว์เลี้ยงตัวไหน Siri จึงเข้าใจ "the second one"
                                    .appEntityIdentifier(EntityIdentifier(for: PetEntity.self, identifier: pet.id))
                                    // --8<-- [end:annotate]
                            }
                        }
                    }

                    if !store.todayFeedings.isEmpty {
                        TodayLog(feedings: store.todayFeedings)
                    }
                }
                .padding()
            }
            .background(Backdrop())
            .navigationTitle("Pawfeed")
            // ช่องค้นหาเดียวกับที่ SearchPetsIntent ใส่คำค้นให้เมื่อสั่ง Siri
            .searchable(text: $navigator.searchText, prompt: "Search pets")
            .sheet(item: $navigator.openPet) { pet in
                PetDetail(pet: pet)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            // widget อาจบันทึกข้อมูลไว้ตอนที่ app อยู่เบื้องหลัง
            if phase == .active { store.reload() }
        }
    }

    private var visiblePets: [Pet] {
        navigator.searchText.isEmpty
            ? store.pets
            : store.pets.filter { $0.name.localizedStandardContains(navigator.searchText) }
    }
}

/// พื้นหลังสีอุ่นๆ ให้กระจก (Liquid Glass) มีสีให้หักเห
struct Backdrop: View {
    var body: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [[0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.6, 0.45], [1, 0.5], [0, 1], [0.5, 1], [1, 1]],
            colors: [.orange.opacity(0.55), .pink.opacity(0.35), .yellow.opacity(0.35),
                     .pink.opacity(0.25), .white.opacity(0.2), .orange.opacity(0.25),
                     .purple.opacity(0.3), .orange.opacity(0.2), .pink.opacity(0.35)]
        )
        .ignoresSafeArea()
    }
}

struct TodaySummary: View {
    let pets: Int
    let meals: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "pawprint.fill")
                .font(.title2)
                .foregroundStyle(.orange)
            Text("\(pets) pets · \(meals) meals today")
                .font(.headline)
                .contentTransition(.numericText())
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .glassEffect(.regular, in: .capsule)
        .animation(.default, value: meals)
    }
}

struct PetCard: View {
    let pet: Pet
    @State private var store = PetStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                PetAvatar(species: pet.species, size: 56)
                VStack(alignment: .leading, spacing: 2) {
                    Text(pet.name).font(.title2.bold())
                    LastFedLabel(date: store.lastFeeding(of: pet)?.date)
                        .font(.subheadline)
                }
                Spacer()
                MealsBadge(count: store.mealsToday(of: pet))
            }
            HStack(spacing: 10) {
                // --8<-- [start:app-button]
                // ปุ่มใน app ก็เรียก intent ตัวเดียวกับ Siri และ widget ได้
                Button(intent: FeedPetIntent(pet: pet)) {
                    Label("Feed", systemImage: "fork.knife").frame(maxWidth: .infinity)
                }
                // --8<-- [end:app-button]
                .buttonStyle(.glassProminent)
                .tint(.orange)
                Button(intent: FeedPetIntent(pet: pet, food: .treat)) {
                    Label("Treat", systemImage: "heart.fill").frame(maxWidth: .infinity)
                }
                .buttonStyle(.glass)
            }
            .controlSize(.large)
        }
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
        .contentShape(.rect(cornerRadius: 28))
    }
}

struct PetAvatar: View {
    let species: Species
    let size: CGFloat

    var body: some View {
        Image(systemName: species.symbol)
            .font(.system(size: size * 0.45, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(species.color.gradient, in: .circle)
    }
}

struct MealsBadge: View {
    let count: Int

    var body: some View {
        VStack(spacing: 0) {
            Text("\(count)")
                .font(.title2.bold())
                .contentTransition(.numericText())
            Text(count == 1 ? "meal" : "meals")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 64, height: 56)
        .glassEffect(.regular, in: .rect(cornerRadius: 18))
        .animation(.default, value: count)
    }
}

struct TodayLog: View {
    let feedings: [Feeding]
    @State private var store = PetStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today").font(.headline)
            ForEach(feedings.prefix(6)) { feeding in
                HStack(spacing: 12) {
                    Image(systemName: feeding.food.symbol)
                        .foregroundStyle(.orange)
                        .frame(width: 24)
                    Text(store.pet(id: feeding.petID)?.name ?? "Pet").bold()
                    Text(feeding.food.name).foregroundStyle(.secondary)
                    Spacer()
                    Text(feeding.date, style: .time).foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassEffect(.regular, in: .rect(cornerRadius: 28))
    }
}

struct PetDetail: View {
    let pet: Pet
    @State private var store = PetStore.shared

    var body: some View {
        VStack(spacing: 20) {
            PetAvatar(species: pet.species, size: 96)
            VStack(spacing: 4) {
                Text(pet.name).font(.largeTitle.bold())
                Text(pet.species.name).foregroundStyle(.secondary)
            }
            HStack(spacing: 12) {
                Stat(title: "Meals today", value: "\(store.mealsToday(of: pet))")
                Stat(title: "Last food", value: store.lastFeeding(of: pet)?.food.name ?? "–")
            }
            LastFedLabel(date: store.lastFeeding(of: pet)?.date)
            GlassEffectContainer {
                HStack(spacing: 10) {
                    Button(intent: FeedPetIntent(pet: pet)) {
                        Label("Feed", systemImage: "fork.knife").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.orange)
                    Button(intent: FeedPetIntent(pet: pet, food: .treat)) {
                        Label("Treat", systemImage: "heart.fill").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glass)
                }
                .controlSize(.large)
            }
        }
        .padding(24)
        .presentationDetents([.medium])
        // --8<-- [start:detail]
        // หน้านี้แสดงสัตว์เลี้ยงตัวเดียวเป็นหลัก: บอกระบบผ่าน user activity
        // Siri จึงรู้ว่า "her" หรือ "this pet" หมายถึงตัวนี้
        .userActivity("th.yidh26.pawfeed.view-pet") { activity in
            activity.title = pet.name
            activity.appEntityIdentifier = EntityIdentifier(for: PetEntity.self, identifier: pet.id)
        }
        // --8<-- [end:detail]
    }
}

struct Stat: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value).font(.title3.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }
}

#Preview {
    ContentView()
}
