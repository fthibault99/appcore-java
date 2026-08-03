import Foundation
import XCTest
@testable import AppCoreSwift

final class AnalyticsEventTests: XCTestCase {
    func testEventTypeMatchesAppCoreValidationRule() {
        XCTAssertEqual(AnalyticsEventType("recipe.imported")?.rawValue, "recipe.imported")
        XCTAssertEqual(AnalyticsEventType("app-opened")?.rawValue, "app-opened")
        XCTAssertNil(AnalyticsEventType("RECIPE_IMPORTED"))
        XCTAssertNil(AnalyticsEventType("recipe_imported"))
        XCTAssertNil(AnalyticsEventType("recipe..imported"))
    }

    func testPropertiesEncodeAsJSONValues() throws {
        let properties: [String: JSONValue] = [
            "source": "URL",
            "success": true,
            "durationMs": 842,
            "tags": ["import", "recipe"]
        ]

        let data = try JSONEncoder().encode(properties)
        let object = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        XCTAssertEqual(object["source"] as? String, "URL")
        XCTAssertEqual(object["success"] as? Bool, true)
        XCTAssertEqual(object["durationMs"] as? Int, 842)
        XCTAssertEqual(object["tags"] as? [String], ["import", "recipe"])
    }
}
