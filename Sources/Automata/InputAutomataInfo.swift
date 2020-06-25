import Foundation
import LTL

public struct InputAutomataInfo: Codable {
    public let observableAP: [String]
    public let hiddenAP: [String]
    public let outputs: [String]
    public var guarantees: [LTL]
    private let knowledgeTerms: [LTL]?
    private let candidateStates: [[String]]?
    private var tags: [String]?

    public init(observableAP: [String], hiddenAP: [String], outputs: [String], guarantees: [LTL], knowledgeTerms: [LTL], candidateStates: [[String]]) {
        self.observableAP = observableAP
        self.hiddenAP = hiddenAP
        self.outputs = outputs
        self.guarantees = guarantees
        self.knowledgeTerms = knowledgeTerms
        self.candidateStates = candidateStates
        self.tags = nil
    }
    
    private mutating func generateAndApplyTags() -> Bool {
        // handle invalid cases
        if self.knowledgeTerms == nil || self.knowledgeTerms!.count == 0 {
            return false
        }
        if self.knowledgeTerms!.count != self.candidateStates!.count {
            print("ERROR: not the same number of knowledge terms and candidateStateSets given!")
            return false
        }
        
        // handle regular cases
        for knowledgeTerm in self.knowledgeTerms! {
            // Replace all occurances in guarantees
            let newTag = self.getNewTag()
            do {
                let tagLTL = try LTL.parse(fromString: newTag)
                for i in 0 ..< self.guarantees.count {
                    self.guarantees[i] = self.guarantees[i].replaceKnowledgeWithLTL(knowledge_ltl: knowledgeTerm, tagLTL: tagLTL)
                }
            } catch {
                print("ERROR: could not generate LTL for Tag")
                exit(EXIT_FAILURE)
            }
        }
        
        return true
    }
    
    
    public mutating func getTagToCandidateStatesMapping() -> ([String], [[String]])? {
        let candidate_states_given_by_user_bool = self.generateAndApplyTags()
        if !candidate_states_given_by_user_bool {
            return nil
        }
        return (self.tags!, self.candidateStates!)
    }
    
    
    private mutating func getNewTag() -> String {
        if self.tags == nil {
            let i = 0
            let tagName = "k" + String(i)
            self.tags = [tagName]
            return tagName
        } else {
            let i = self.tags!.count
            let tagName = "k" + String(i)
            self.tags!.append(tagName)
            return tagName
        }
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
