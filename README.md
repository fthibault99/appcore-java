# AppCore Java Swift Client

A Swift 6 client package for the authenticated AppCore Spring Boot API.

The package currently supports:

- barcode product lookup and translation;
- short LEGO set description generation;
- plain-text translation;
- recipe extraction and translation;
- recipe product extraction;
- analytics event collection;
- AppCore API error decoding.

## Requirements

- Swift 6.3 or later
- iOS 15 or later
- macOS 12 or later

## Installation

In Xcode, select **File > Add Package Dependencies > Add Local**, then select the `appcore-java` directory. Add the `appcore-java` library product to your application target.

For another local Swift package, add this dependency to `Package.swift`:

```swift
dependencies: [
    .package(path: "../appcore-java")
]
```

Then add the product to the appropriate target:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "appcore-java", package: "appcore-java")
    ]
)
```

Import the generated Swift module with:

```swift
import appcore_java
```

## Client configuration

Create one client and reuse it throughout the application:

```swift
import Foundation
import appcore_java

let client = AppCoreClient(
    baseURL: URL(string: "https://api.example.com")!,
    apiKey: apiKey
)
```

The client sends the key in the `X-API-Key` header. Do not hardcode a production key in source code or commit it to the repository. Load it from the application's secure configuration.

## Barcode lookup

```swift
let product = try await client.barcode(
    "0057000613280",
    domain: .lego
)

print(product.barcode)
print(product.productName ?? "Unknown product")
print(product.brand ?? "Unknown brand")
print(product.description ?? "No description")
print(product.imageUrl ?? "No image")
```

Supported barcode domains are:

```swift
.food
.lego
.wine
```

### Translate a barcode product

```swift
guard let french = LanguageCode("fr") else {
    fatalError("Invalid language code")
}

let translatedProduct = try await client.translate(
    product,
    to: french
)
```

## LEGO set descriptions

Generate a short description from a set code and name in the requested language:

```swift
guard let french = LanguageCode("fr") else {
    fatalError("Invalid language code")
}

let description = try await client.describeBrickSet(
    code: "10307",
    name: "Eiffel Tower",
    in: french
)
```

AppCore owns the OpenAI prompt, model, output limits, and API key. The Swift client sends only the set code, set name, requested language, and its AppCore API key.

## Text translation

Translate plain text into a target language:

```swift
guard let english = LanguageCode("en") else {
    fatalError("Invalid language code")
}

let translatedText = try await client.translate(
    "Rare Sets",
    to: english,
    context: "Title of a collection of rare LEGO sets."
)

print(translatedText)
```

The request is sent to `POST /api/ai/texts/translate`. Text is limited to 20,000 characters by the AppCore server. The optional context is limited to 500 characters and helps resolve terminology, tone, or intended use. It is not translated or returned. Calls that do not need context can omit the argument.

## Recipes

### Extract a recipe from text

```swift
let recipe = try await client.extractRecipe(
    fromText: """
    Toast

    Ingredients:
    - 2 slices of bread

    Instructions:
    Toast the bread.
    """
)

print(recipe.name)
print(recipe.recipeIngredient)
print(recipe.recipeInstructions)
```

### Extract a recipe from a URL

```swift
let recipeURL = URL(string: "https://example.com/recipe")!
let recipe = try await client.extractRecipe(fromURL: recipeURL)
```

AppCore performs the remote download and recipe extraction. The URL must satisfy the server's URL security rules.

### Extract a recipe from web content

```swift
let recipe = try await client.extractRecipe(
    fromWebContent: visibleText,
    sourceURL: URL(string: "https://example.com/recipe")!,
    contentType: .text
)
```

For Schema.org JSON-LD content, use:

```swift
let recipe = try await client.extractRecipe(
    fromWebContent: jsonLD,
    sourceURL: URL(string: "https://example.com/recipe")!,
    contentType: .jsonLD
)
```

### Extract a recipe from an image

```swift
let recipe = try await client.extractRecipe(
    fromImage: imageData,
    fileName: "recipe.jpg",
    mediaType: .jpeg
)
```

Supported image media types are `.jpeg`, `.png`, and `.webP`. AppCore applies its configured image size, format, and dimension limits.

### Translate a recipe

```swift
guard let french = LanguageCode("fr") else {
    fatalError("Invalid language code")
}

let translatedRecipe = try await client.translate(
    recipe,
    to: french
)
```

`LanguageCode` accepts exactly two ASCII letters and normalizes them to lowercase. Examples include `en`, `fr`, `de`, and `it`.

### Extract grocery products from recipe ingredients

```swift
let ingredientProducts = try await client.extractRecipeProducts(
    from: recipe.recipeIngredient
)

for result in ingredientProducts {
    print(result.ingredient)
    print(result.products)
}
```

## Analytics events

AppCore derives the application client ID, API key ID, event ID, and receipt timestamp on the server. These fields cannot be supplied by the Swift client.

```swift
guard let eventType = AnalyticsEventType("recipe.imported") else {
    fatalError("Invalid analytics event type")
}

let event = AnalyticsEvent(
    eventType: eventType,
    anonymousUserId: anonymousUserId,
    sessionId: sessionId,
    platform: "IOS",
    appVersion: "1.0.0",
    language: LanguageCode("fr"),
    region: "CA",
    subscriptionStatus: "ACTIVE",
    purchased: true,
    properties: [
        "source": "URL",
        "host": "recettes.qc.ca",
        "success": true,
        "durationMs": 842
    ]
)

try await client.trackAnalyticsEvent(event)
```

Analytics event names use lowercase segments separated by `.` or `-`, for example:

```text
app.opened
recipe.imported
purchase.completed
```

Analytics properties use the type-safe `JSONValue` representation. Strings, integers, floating-point numbers, booleans, objects, arrays, and `null` are supported.

Do not send secrets or personal data in analytics properties. AppCore rejects sensitive property names such as `password`, `token`, `apiKey`, `email`, `phone`, `address`, `recipeText`, `prompt`, `message`, `content`, and `fullUrl`.

## Error handling

```swift
do {
    let product = try await client.barcode(
        "0057000613280",
        domain: .lego
    )
    print(product)
} catch let AppCoreClientError.server(statusCode, response) {
    print("AppCore error: \(statusCode)")
    print(response?.error ?? "UNKNOWN_ERROR")
    print(response?.message ?? "No error message")
    print(response?.details ?? [])
} catch let AppCoreClientError.transport(code) {
    print("Network error: \(code)")
} catch let AppCoreClientError.decoding(message) {
    print("Invalid AppCore response: \(message)")
} catch {
    print("Unexpected error: \(error)")
}
```

Non-successful AppCore responses are decoded into `AppCoreAPIErrorResponse` whenever the response body matches the server's standard error contract.

## Testing

Run the package test suite with:

```shell
swift test
```

The tests use an injected `URLSession` and do not call a live AppCore server.
