import Foundation
import LTL

public struct InputAutomataInfo: Codable {
    public let observableAP: [String]
    public let hiddenAP: [String]
    public let outputs: [String]
    public var guarantees: [LTL]
    public let transformationRules: [LTL]?

    public init(observableAP: [String], hiddenAP: [String], outputs: [String], guarantees: [LTL], transformationRules: [LTL]) {
        self.observableAP = observableAP
        self.hiddenAP = hiddenAP
        self.outputs = outputs
        self.guarantees = guarantees
        self.transformationRules = transformationRules
    }

    public static func fromJson(string: String) -> InputAutomataInfo? {

        let decoder = JSONDecoder()
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        do {
            return try decoder.decode(InputAutomataInfo.self, from: data)
        } catch {
            return nil
        }
    }
    
    
    public mutating func applyTransformationRules() -> Bool {
        if let rules = self.transformationRules {
            let rulesMaxIndex = rules.count
            if rulesMaxIndex == 0 {
                print("Warning: no transformation Rules given.")
                return true
            }

            if (rulesMaxIndex % 2) != 0 {
                print("ERROR: transformation rules have to be given in Pairs")
                return false
            }

            var kIndex = 0
            var rIndex = 1

            while rIndex < rulesMaxIndex {

                let kLTL = rules[kIndex]
                let rLTL = rules[rIndex]

                // Replace all occurances in guarantees
                for i in 0 ..< self.guarantees.count {
                    self.guarantees[i] = self.guarantees[i].replaceKnowledgeWithLTL(knowledge_ltl: kLTL, replaced_ltl: rLTL)
                }

                // TODO: maybe add warning if replacement has not worked

                kIndex += 1
                rIndex += 1
            }

            return true
        } else {
            print("Warning: no transformation rules given, skipping 'translation-phase'.")
            return false
        }
    }

    public static func from(fileName: String) throws -> InputAutomataInfo {
        // get file contents
        let data = try Data(contentsOf: URL(fileURLWithPath: fileName))
        return try from(data: data)
    }

    public static func from(data: Data) throws -> InputAutomataInfo {
        // parse contents of `data`
        return try JSONDecoder().decode(InputAutomataInfo.self, from: data)
    }

    public func jsonString() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let jsonData = try encoder.encode(self)

            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print(error.localizedDescription)
        }

        return ""
    }

}
