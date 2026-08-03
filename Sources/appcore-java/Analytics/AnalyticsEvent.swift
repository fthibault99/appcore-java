import Foundation

/// Validated AppCore analytics event name, such as `recipe.imported`.
public struct AnalyticsEventType: RawRepresentable, Codable, Equatable, Hashable, Sendable {
    public let rawValue: String

    public init?(rawValue: String) {
        guard rawValue.count <= 100,
              rawValue.range(
                  of: #"^[a-z][a-z0-9]*(?:[.-][a-z0-9]+)*$"#,
                  options: .regularExpression
              ) != nil else {
            return nil
        }
        self.rawValue = rawValue
    }

    public init?(_ value: String) {
        self.init(rawValue: value)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        guard let eventType = Self(value) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid analytics event type"
            )
        }
        self = eventType
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

/// Body accepted by `POST /api/v1/analytics/events`.
public struct AnalyticsEvent: Codable, Equatable, Sendable {
    public let eventType: AnalyticsEventType
    public let occurredAt: Date
    public let anonymousUserId: String?
    public let sessionId: String?
    public let platform: String?
    public let appVersion: String?
    public let language: LanguageCode?
    public let region: String?
    public let subscriptionStatus: String?
    public let purchased: Bool?
    public let properties: [String: JSONValue]

    public init(
        eventType: AnalyticsEventType,
        occurredAt: Date = Date(),
        anonymousUserId: String? = nil,
        sessionId: String? = nil,
        platform: String? = nil,
        appVersion: String? = nil,
        language: LanguageCode? = nil,
        region: String? = nil,
        subscriptionStatus: String? = nil,
        purchased: Bool? = nil,
        properties: [String: JSONValue] = [:]
    ) {
        self.eventType = eventType
        self.occurredAt = occurredAt
        self.anonymousUserId = anonymousUserId
        self.sessionId = sessionId
        self.platform = platform
        self.appVersion = appVersion
        self.language = language
        self.region = region
        self.subscriptionStatus = subscriptionStatus
        self.purchased = purchased
        self.properties = properties
    }
}
