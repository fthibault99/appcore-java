import Foundation

/// Client for AppCore's authenticated public API.
public final class AppCoreClient: Sendable {
    public static let apiKeyHeader = "X-API-Key"

    private let baseURL: URL
    private let apiKey: String
    private let session: URLSession

    /// Creates a client without persisting or logging the supplied API key.
    ///
    /// - Parameters:
    ///   - baseURL: AppCore server URL, for example `https://api.example.com`.
    ///   - apiKey: AppCore client key sent in the `X-API-Key` header.
    ///   - session: Injectable URL session, primarily useful for tests.
    public init(
        baseURL: URL,
        apiKey: String,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.session = session
    }

    /// Calls `GET /api/{domain}/barcodes/{barcode}`.
    public func barcode(
        _ barcode: String,
        domain: BarcodeDomain
    ) async throws -> BarcodeProduct {
        let url = baseURL
            .appendingPathComponent("api")
            .appendingPathComponent(domain.pathComponent)
            .appendingPathComponent("barcodes")
            .appendingPathComponent(barcode)

        return try await send(URLRequest(url: url))
    }

    /// Calls `POST /api/ai/products/translate`.
    public func translate(
        _ product: BarcodeProduct,
        to targetLanguage: LanguageCode
    ) async throws -> BarcodeProduct {
        let url = baseURL
            .appendingPathComponent("api")
            .appendingPathComponent("ai")
            .appendingPathComponent("products")
            .appendingPathComponent("translate")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(
                TranslateBarcodeProductRequest(
                    targetLanguage: targetLanguage,
                    product: product
                )
            )
        } catch {
            throw AppCoreClientError.encoding(String(describing: error))
        }

        let response: TranslateBarcodeProductResponse = try await send(request)
        return response.product
    }

    /// Calls `POST /api/ai/recipes/translate`.
    public func translate(
        _ recipe: Recipe,
        to targetLanguage: LanguageCode
    ) async throws -> Recipe {
        let response: TranslateRecipeResponse = try await postJSON(
            path: ["api", "ai", "recipes", "translate"],
            body: TranslateRecipeRequest(
                targetLanguage: targetLanguage,
                recipe: recipe
            )
        )
        return response.recipe
    }

    /// Calls `POST /api/ai/recipes/extract`.
    public func extractRecipe(fromText text: String) async throws -> Recipe {
        try await postJSON(
            path: ["api", "ai", "recipes", "extract"],
            body: ExtractRecipeFromTextRequest(text: text)
        )
    }

    /// Calls `POST /api/ai/recipes/extract-from-url`.
    public func extractRecipe(fromURL url: URL) async throws -> Recipe {
        try await postJSON(
            path: ["api", "ai", "recipes", "extract-from-url"],
            body: ExtractRecipeFromURLRequest(url: url.absoluteString)
        )
    }

    /// Calls `POST /api/ai/recipes/from-web-content`.
    public func extractRecipe(
        fromWebContent content: String,
        sourceURL: URL,
        contentType: WebRecipeContentType
    ) async throws -> Recipe {
        try await postJSON(
            path: ["api", "ai", "recipes", "from-web-content"],
            body: WebRecipeContentRequest(
                url: sourceURL.absoluteString,
                contentType: contentType,
                content: content
            )
        )
    }

    /// Calls `POST /api/ai/recipes/products/extract`.
    public func extractRecipeProducts(
        from ingredients: [String]
    ) async throws -> [IngredientProducts] {
        let response: ExtractRecipeProductsResponse = try await postJSON(
            path: ["api", "ai", "recipes", "products", "extract"],
            body: ExtractRecipeProductsRequest(ingredients: ingredients)
        )
        return response.ingredients
    }

    /// Calls `POST /api/ai/recipes/from-image` with multipart form data.
    public func extractRecipe(
        fromImage data: Data,
        fileName: String,
        mediaType: RecipeImageMediaType
    ) async throws -> Recipe {
        let boundary = "AppCoreBoundary-\(UUID().uuidString)"
        var request = URLRequest(url: url(path: ["api", "ai", "recipes", "from-image"]))
        request.httpMethod = "POST"
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody = multipartImageBody(
            data: data,
            fileName: fileName,
            mediaType: mediaType,
            boundary: boundary
        )
        return try await send(request)
    }

    /// Calls `POST /api/v1/analytics/events` and expects `202 Accepted`.
    public func trackAnalyticsEvent(_ event: AnalyticsEvent) async throws {
        var request = URLRequest(url: url(path: ["api", "v1", "analytics", "events"]))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            request.httpBody = try encoder.encode(event)
        } catch {
            throw AppCoreClientError.encoding(String(describing: error))
        }

        _ = try await perform(request)
    }

    private func postJSON<Body: Encodable, Response: Decodable>(
        path: [String],
        body: Body
    ) async throws -> Response {
        var request = URLRequest(url: url(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw AppCoreClientError.encoding(String(describing: error))
        }

        return try await send(request)
    }

    private func url(path: [String]) -> URL {
        path.reduce(baseURL) { url, component in
            url.appendingPathComponent(component)
        }
    }

    private func multipartImageBody(
        data: Data,
        fileName: String,
        mediaType: RecipeImageMediaType,
        boundary: String
    ) -> Data {
        var body = Data()
        body.append(Data("--\(boundary)\r\n".utf8))
        body.append(Data("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n".utf8))
        body.append(Data("Content-Type: \(mediaType.rawValue)\r\n\r\n".utf8))
        body.append(data)
        body.append(Data("\r\n--\(boundary)--\r\n".utf8))
        return body
    }

    private func send<Response: Decodable>(
        _ request: URLRequest
    ) async throws -> Response {
        let data = try await perform(request)

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw AppCoreClientError.decoding(String(describing: error))
        }
    }

    private func perform(_ request: URLRequest) async throws -> Data {
        var authenticatedRequest = request
        authenticatedRequest.setValue(apiKey, forHTTPHeaderField: Self.apiKeyHeader)
        authenticatedRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: authenticatedRequest)
        } catch let error as URLError {
            throw AppCoreClientError.transport(error.code)
        } catch {
            throw AppCoreClientError.transport(.unknown)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppCoreClientError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(AppCoreAPIErrorResponse.self, from: data)
            throw AppCoreClientError.server(
                statusCode: httpResponse.statusCode,
                response: apiError
            )
        }

        return data
    }
}
