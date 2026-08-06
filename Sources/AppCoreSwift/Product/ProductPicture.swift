/// Image media types accepted by `POST /api/ai/products/from-image`.
public enum ProductImageMediaType: String, Sendable {
    case jpeg = "image/jpeg"
    case png = "image/png"
    case webP = "image/webp"
}

/// Product identification returned from an image.
/// Both values are `nil` when AppCore cannot identify exactly one product.
public struct ProductPicture: Codable, Equatable, Sendable {
    public let name: String?
    public let description: String?

    public init(name: String? = nil, description: String? = nil) {
        self.name = name
        self.description = description
    }
}
