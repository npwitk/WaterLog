import AppIntents

// --8<-- [start:enum]
extension Food: AppEnum {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Food"

    static let caseDisplayRepresentations: [Food: DisplayRepresentation] = [
        .dry: DisplayRepresentation(title: "Dry food", image: .init(systemName: "fork.knife")),
        .wet: DisplayRepresentation(title: "Wet food", image: .init(systemName: "drop.fill")),
        .treat: DisplayRepresentation(title: "Treat", image: .init(systemName: "heart.fill")),
    ]
}
// --8<-- [end:enum]
