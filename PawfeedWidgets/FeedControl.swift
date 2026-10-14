import AppIntents
import SwiftUI
import WidgetKit

// --8<-- [start:control]
/// ปุ่มใน Control Center (และ Lock Screen) ที่ run FeedPetIntent ตัวเดิม
struct FeedControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "FeedControl") {
            let pet = PetData.loadPets().first ?? PetData.samplePets[0]
            ControlWidgetButton(action: FeedPetIntent(pet: pet)) {
                Label("Feed \(pet.name)", systemImage: "pawprint.fill")
            }
        }
        .displayName("Feed Pet")
        .description("Feed your first pet with one tap.")
    }
}
// --8<-- [end:control]
