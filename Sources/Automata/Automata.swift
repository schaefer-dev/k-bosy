import Foundation

public struct AutomataInput: Codable {
    public let observableAP: [String]
    public let hiddenAP: [String]
    public let outputs: [String]
    public let initialStates: [String]
    public let dotGraph: String

    public init(observableAP: [String], hiddenAP: [String], outputs: [String], initialStates: [String], dotGraph: String) {
        self.observableAP = observableAP
        self.hiddenAP = hiddenAP
        self.outputs = outputs
        self.initialStates = initialStates
        self.dotGraph = dotGraph
    }
    
    
    
    public static func fromJson(string: String) -> AutomataInput? {

        let decoder = JSONDecoder()
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        do {
            return try decoder.decode(AutomataInput.self, from: data)
        } catch {
            return nil
        }
    }
    

    public static func from(fileName: String) throws -> AutomataInput {
        // get file contents
        let data = try Data(contentsOf: URL(fileURLWithPath: fileName))
        return try from(data: data)
    }

    
    public static func from(data: Data) throws -> AutomataInput {
        // parse contents of `data`
        return try JSONDecoder().decode(AutomataInput.self, from: data)
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
