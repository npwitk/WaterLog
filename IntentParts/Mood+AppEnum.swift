import AppIntents

// --8<-- [start:enum]
extension Mood: AppEnum {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Mood"

    static let caseDisplayRepresentations: [Mood: DisplayRepresentation] = [
        .great: DisplayRepresentation(title: "Great", image: .init(systemName: "sun.max.fill")),
        .okay: DisplayRepresentation(title: "Okay", image: .init(systemName: "cloud.sun.fill")),
        .rough: DisplayRepresentation(title: "Rough", image: .init(systemName: "cloud.rain.fill")),
    ]
}
// --8<-- [end:enum]
