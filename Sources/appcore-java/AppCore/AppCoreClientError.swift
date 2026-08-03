import Foundation

public enum AppCoreClientError: Error, Equatable, Sendable {
    /// The server did not return an HTTP response.
    case invalidResponse

    /// The request could not be completed by URLSession.
    case transport(URLError.Code)

    /// AppCore returned a non-2xx status. The body is present when it matched
    /// AppCore's standard `ApiErrorResponse` contract.
    case server(statusCode: Int, response: AppCoreAPIErrorResponse?)

    /// A successful response did not match the expected AppCore JSON contract.
    case decoding(String)

    /// A request body could not be encoded.
    case encoding(String)
}
