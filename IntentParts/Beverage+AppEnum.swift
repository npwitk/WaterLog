import AppIntents

// --8<-- [start:enum]
extension Beverage: AppEnum {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Drink"

    static let caseDisplayRepresentations: [Beverage: DisplayRepresentation] = [
        .water: DisplayRepresentation(title: "Water", image: .init(systemName: "drop.fill")),
        .tea: DisplayRepresentation(title: "Tea", image: .init(systemName: "leaf.fill")),
        .coffee: DisplayRepresentation(title: "Coffee", image: .init(systemName: "cup.and.saucer.fill")),
        .milk: DisplayRepresentation(title: "Milk", image: .init(systemName: "carton.fill")),
        .juice: DisplayRepresentation(title: "Juice", image: .init(systemName: "wineglass.fill")),
    ]
}
// --8<-- [end:enum]
