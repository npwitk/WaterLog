import FoundationModels

/// ใช้ model บนเครื่อง (Foundation Models, Workshop 2) เดาอารมณ์จากข้อความที่ Siri เขียนให้
/// ถ้าเครื่องไม่รองรับ Apple Intelligence จะคืน nil และบันทึกจะไม่มีอารมณ์
enum MoodGuesser {
    @Generable
    enum Guess {
        case great, okay, rough
    }

    static func guess(for text: String) async -> Mood? {
        guard SystemLanguageModel.default.isAvailable else { return nil }
        let session = LanguageModelSession(
            instructions: "You read one journal entry and decide how the writer feels: great, okay or rough."
        )
        guard let response = try? await session.respond(to: text, generating: Guess.self) else { return nil }
        switch response.content {
        case .great: return .great
        case .okay: return .okay
        case .rough: return .rough
        }
    }
}
