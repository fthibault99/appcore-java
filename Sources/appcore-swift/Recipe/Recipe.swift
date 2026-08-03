/// Recipe contract returned and accepted by AppCore.
public struct Recipe: Codable, Equatable, Sendable {
    public let url: String?
    public let name: String
    public let image: [String]?
    public let author: String?
    public let datePublished: String?
    public let description: String?
    public let prepTime: String?
    public let cookTime: String?
    public let totalTime: String?
    public let keywords: String?
    public let recipeIngredient: [String]
    public let recipeInstructions: [String]
    public let recipeYield: String?

    public init(
        url: String? = nil,
        name: String,
        image: [String]? = nil,
        author: String? = nil,
        datePublished: String? = nil,
        description: String? = nil,
        prepTime: String? = nil,
        cookTime: String? = nil,
        totalTime: String? = nil,
        keywords: String? = nil,
        recipeIngredient: [String],
        recipeInstructions: [String],
        recipeYield: String? = nil
    ) {
        self.url = url
        self.name = name
        self.image = image
        self.author = author
        self.datePublished = datePublished
        self.description = description
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.totalTime = totalTime
        self.keywords = keywords
        self.recipeIngredient = recipeIngredient
        self.recipeInstructions = recipeInstructions
        self.recipeYield = recipeYield
    }
}
