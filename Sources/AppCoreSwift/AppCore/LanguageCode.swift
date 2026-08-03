/// A normalized two-letter language code such as `fr`, `en`, `de` or `it`.
public struct LanguageCode: RawRepresentable, Codable, Equatable, Hashable, Sendable {
    public let rawValue: String

    public init?(rawValue: String) {
        let normalized = rawValue.lowercased()
        guard normalized.utf8.count == 2,
              normalized.utf8.allSatisfy({ byte in
                  byte >= Character("a").asciiValue! && byte <= Character("z").asciiValue!
              }) else {
            return nil
        }
        self.rawValue = normalized
    }

    public init?(_ value: String) {
        self.init(rawValue: value)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        guard let code = Self(value) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Expected a two-letter language code"
            )
        }
        self = code
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
