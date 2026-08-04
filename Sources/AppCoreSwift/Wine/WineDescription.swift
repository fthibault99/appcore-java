/// Body accepted by `POST /api/ai/wines/describe`.
public struct DescribeWineRequest: Codable, Equatable, Sendable {
    public let name: String
    public let language: LanguageCode

    public init(name: String, language: LanguageCode) {
        self.name = name
        self.language = language
    }
}

/// Image media types accepted by `POST /api/ai/wines/from-image`.
public enum WineImageMediaType: String, Sendable {
    case jpeg = "image/jpeg"
    case png = "image/png"
    case webP = "image/webp"
}

/// Localized wine or spirits information returned by AppCore.
public struct WineProduct: Codable, Equatable, Sendable {
    public let name: String?
    public let description: String?
    public let country: String?
    public let region: String?
    public let paysDOc: String?
    public let regulatedDesignation: String?
    public let alcoholContent: String?
    public let sugarContent: String?
    public let color: String?
    public let format: String?
    public let producer: String?
    public let error: String?
    public let type: String?

    public init(
        name: String? = nil,
        description: String? = nil,
        country: String? = nil,
        region: String? = nil,
        paysDOc: String? = nil,
        regulatedDesignation: String? = nil,
        alcoholContent: String? = nil,
        sugarContent: String? = nil,
        color: String? = nil,
        format: String? = nil,
        producer: String? = nil,
        error: String? = nil,
        type: String? = nil
    ) {
        self.name = name
        self.description = description
        self.country = country
        self.region = region
        self.paysDOc = paysDOc
        self.regulatedDesignation = regulatedDesignation
        self.alcoholContent = alcoholContent
        self.sugarContent = sugarContent
        self.color = color
        self.format = format
        self.producer = producer
        self.error = error
        self.type = type
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case description
        case country
        case region
        case paysDOc = "pays_d'Oc"
        case regulatedDesignation = "regulated_designation"
        case alcoholContent = "alcohol_content"
        case sugarContent = "sugar_content"
        case color
        case format
        case producer
        case error
        case type
    }
}
