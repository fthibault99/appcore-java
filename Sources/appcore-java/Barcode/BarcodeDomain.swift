/// Product families supported by AppCore's barcode lookup endpoint.
public enum BarcodeDomain: String, CaseIterable, Codable, Sendable {
    case food = "FOOD"
    case lego = "LEGO"
    case wine = "WINE"

    /// Value expected by AppCore in `/api/{domain}/barcodes/{barcode}`.
    public var pathComponent: String { rawValue }
}
