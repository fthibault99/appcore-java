/// Body accepted by `POST /api/ai/brick-sets/describe`.
public struct DescribeBrickSetRequest: Codable, Equatable, Sendable {
    public let setCode: String
    public let setName: String
    public let language: LanguageCode

    public init(setCode: String, setName: String, language: LanguageCode) {
        self.setCode = setCode
        self.setName = setName
        self.language = language
    }
}

/// Response returned by `POST /api/ai/brick-sets/describe`.
public struct DescribeBrickSetResponse: Codable, Equatable, Sendable {
    public let description: String
    public let language: LanguageCode

    public init(description: String, language: LanguageCode) {
        self.description = description
        self.language = language
    }
}
