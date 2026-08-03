/// Error payload returned by AppCore for non-successful HTTP responses.
public struct AppCoreAPIErrorResponse: Codable, Equatable, Sendable {
    public let timestamp: String
    public let status: Int
    public let error: String
    public let message: String
    public let path: String
    public let details: [String]

    public init(
        timestamp: String,
        status: Int,
        error: String,
        message: String,
        path: String,
        details: [String]
    ) {
        self.timestamp = timestamp
        self.status = status
        self.error = error
        self.message = message
        self.path = path
        self.details = details
    }
}
