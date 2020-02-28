//  LTL implementation by Leander Tentrupp (github @ltentrup)
//
//  Sourced by Daniel Schäfer on 28.02.20.

extension LTL: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let representation = try container.decode(String.self)
        self = try LTL.parse(fromString: representation)
    }

    public func encode(to encoder: Encoder) throws {
        try self.description.encode(to: encoder)
    }


}

