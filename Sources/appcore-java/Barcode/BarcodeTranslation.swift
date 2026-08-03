/// Body accepted by `POST /api/ai/products/translate`.
public struct TranslateBarcodeProductRequest: Codable, Equatable, Sendable {
    public let targetLanguage: LanguageCode
    public let product: BarcodeProduct

    public init(targetLanguage: LanguageCode, product: BarcodeProduct) {
        self.targetLanguage = targetLanguage
        self.product = product
    }
}

/// Response returned by `POST /api/ai/products/translate`.
public struct TranslateBarcodeProductResponse: Codable, Equatable, Sendable {
    public let product: BarcodeProduct

    public init(product: BarcodeProduct) {
        self.product = product
    }
}
