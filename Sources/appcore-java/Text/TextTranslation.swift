/// Body accepted by `POST /api/ai/texts/translate`.
public struct TranslateTextRequest: Codable, Equatable, Sendable {
    public let text: String
    public let targetLanguage: LanguageCode

    public init(text: String, targetLanguage: LanguageCode) {
        self.text = text
        self.targetLanguage = targetLanguage
    }
}

/// Response returned by `POST /api/ai/texts/translate`.
public struct TranslateTextResponse: Codable, Equatable, Sendable {
    public let text: String

    public init(text: String) {
        self.text = text
    }
}
