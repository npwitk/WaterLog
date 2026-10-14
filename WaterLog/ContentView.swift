import AppIntents
import SwiftUI

struct ContentView: View {
    @State private var store = WaterStore.shared
    @State private var navigator = Navigator.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            List {
                if !navigator.searchText.isEmpty {
                    Section("Results") {
                        ForEach(searchResults) { drink in
                            Button { navigator.openDrink = drink } label: { DrinkRow(drink: drink) }
                                .foregroundStyle(.primary)
                        }
                    }
                }
                Section {
                    TodayHeader(total: store.todayTotal, goal: WaterData.dailyGoal)
                    QuickAddRow()
                }
                Section("Today") {
                    if store.todayDrinks.isEmpty {
                        Text("No drinks yet. Tap a button above, or try Shortcuts, Spotlight or Siri.")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(store.todayDrinks) { drink in
                        Button { navigator.openDrink = drink } label: { DrinkRow(drink: drink) }
                            .foregroundStyle(.primary)
                            // --8<-- [start:annotate]
                            // บอกระบบว่าแถวนี้คือ drink ตัวไหน Siri จึงเข้าใจคำว่า "this drink"
                            .appEntityIdentifier(EntityIdentifier(for: DrinkEntity.self, identifier: drink.id))
                            // --8<-- [end:annotate]
                    }
                    .onDelete { offsets in
                        offsets.map { store.todayDrinks[$0] }.forEach(store.delete)
                    }
                }
            }
            .navigationTitle("Water Log")
            // ช่องค้นหาเดียวกับที่ SearchDrinksIntent ใส่คำค้นให้เมื่อสั่ง Siri
            .searchable(text: $navigator.searchText, prompt: "Search drinks")
            .sheet(item: $navigator.openDrink) { drink in
                DrinkDetail(drink: drink)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            // widget อาจบันทึกข้อมูลไว้ตอนที่ app อยู่เบื้องหลัง
            if phase == .active { store.reload() }
        }
    }

    private var searchResults: [Drink] {
        store.drinks
            .filter { $0.beverage.name.localizedStandardContains(navigator.searchText) }
            .sorted { $0.date > $1.date }
    }
}

struct TodayHeader: View {
    let total: Int
    let goal: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(total) / \(goal) ml")
                .font(.largeTitle.bold())
                .contentTransition(.numericText())
            ProgressView(value: Double(min(total, goal)), total: Double(goal))
                .tint(.blue)
        }
        .padding(.vertical, 8)
        .animation(.default, value: total)
    }
}

struct QuickAddRow: View {
    var body: some View {
        HStack {
            // --8<-- [start:app-button]
            // ปุ่มใน app ก็เรียก intent ตัวเดียวกับ Siri และ widget ได้
            Button(intent: LogWaterIntent(milliliters: 250)) {
                Label("250 ml", systemImage: "drop.fill")
            }
            // --8<-- [end:app-button]
            Button(intent: LogWaterIntent(milliliters: 500)) {
                Label("500 ml", systemImage: "drop.fill")
            }
            Button(intent: LogWaterIntent(milliliters: 200, beverage: .coffee)) {
                Label("Coffee", systemImage: "cup.and.saucer.fill")
            }
        }
        .buttonStyle(.bordered)
    }
}

struct DrinkRow: View {
    let drink: Drink

    var body: some View {
        HStack {
            Image(systemName: drink.beverage.symbol)
                .foregroundStyle(.blue)
                .frame(width: 28)
            Text(drink.beverage.name)
            Spacer()
            Text("\(drink.milliliters) ml").monospacedDigit()
            Text(drink.date, style: .time).foregroundStyle(.secondary)
        }
    }
}

struct DrinkDetail: View {
    let drink: Drink

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: drink.beverage.symbol)
                .font(.system(size: 64))
                .foregroundStyle(.blue)
            Text("\(drink.beverage.name) \(drink.milliliters) ml").font(.title.bold())
            Text(drink.date.formatted(date: .complete, time: .shortened))
                .foregroundStyle(.secondary)
        }
        .padding()
        .presentationDetents([.medium])
        // --8<-- [start:detail]
        // หน้านี้แสดง drink ตัวเดียวเป็นหลัก: บอกระบบผ่าน user activity
        // Siri จึงรู้ว่า "this" หมายถึงแก้วนี้
        .userActivity("th.yidh26.waterlog.view-drink") { activity in
            activity.title = "\(drink.beverage.name) \(drink.milliliters) ml"
            activity.appEntityIdentifier = EntityIdentifier(for: DrinkEntity.self, identifier: drink.id)
        }
        // --8<-- [end:detail]
    }
}

#Preview {
    ContentView()
}
