//
//  specification.swift
//  knowledge-bosy
//
//  SOURCE: BOSY Codebase
//
//  Created by Daniel Schäfer on 19.02.20.
//  Copyright © 2020 Daniel Schäfer. All rights reserved.
//

import Foundation


public enum TransitionSystemType: String, Codable {
    case mealy = "mealy"
    case moore = "moore"
    
    public var swapped: TransitionSystemType {
        switch self {
            case .mealy: return .moore
            case .moore: return .mealy
        }
    }
    
    public static let allValues: [TransitionSystemType] = [.mealy, .moore]
}


public struct SynthesisSpecification: Codable {
    public var semantics: TransitionSystemType
    public let inputs: [String]
    public let outputs: [String]
    public var assumptions: [String]
    public var guarantees: [String]
    public let transformation_rules: [String]
    
    public init(semantics: TransitionSystemType, inputs: [String], outputs: [String], assumptions: [String], guarantees: [String], transformation_rules: [String]) {
        self.semantics = semantics
        self.inputs = inputs
        self.outputs = outputs
        self.assumptions = assumptions
        self.guarantees = guarantees
        self.transformation_rules = transformation_rules
    }
    
    
    public static func fromJson(string: String) -> SynthesisSpecification? {

        let decoder = JSONDecoder()
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        do {
            return try decoder.decode(SynthesisSpecification.self, from: data)
        } catch {
            return nil
        }
    }
    

    public static func from(fileName: String) throws -> SynthesisSpecification {
        // get file contents
        let data = try Data(contentsOf: URL(fileURLWithPath: fileName))
        return try from(data: data)
    }

    public static func from(data: Data) throws -> SynthesisSpecification {
        // parse contents of `data`
        return try JSONDecoder().decode(SynthesisSpecification.self, from: data)
    }
    
    public func writeToShell() {
        print("----------------------------------------")
        print("------------Synthesis spec:-------------")
        print("semantics: ", self.semantics)
        print("inputs: ", self.inputs)
        print("outputs: ", self.outputs)
        print("assumptions: ", self.assumptions)
        print("guarantees: ", self.guarantees)
        print("transformation rules: ", self.transformation_rules)
        print("----------------------------------------")
    }
    
    public mutating func applyTransformationRules() -> Bool {
        let rules_max_index = self.transformation_rules.count
        if (rules_max_index == 0) {
            print("Warning: no transformation Rules given.")
            return true
        }
        
        if (rules_max_index % 2) != 0 {
            print("ERROR: transformation rules have to be given in Pairs")
            return false
        }
        
        var k_index = 0
        var r_index = 1
        
        while r_index < rules_max_index {
            let k_string = self.transformation_rules[k_index]
            let r_string = "(" + self.transformation_rules[r_index] + ")"
            
            // Replace all occurances in assumptions
            for i in 0 ..< self.assumptions.count {
                self.assumptions[i] = self.assumptions[i].replacingOccurrences(of: k_string, with: r_string)
            }
            
            // Replace all occurances in guarantees
            for i in 0 ..< self.guarantees.count {
                self.guarantees[i] = self.guarantees[i].replacingOccurrences(of: k_string, with: r_string)
            }
            
            k_index += 1
            r_index += 1
        }
        
        return true
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
    
    public func writeJsonToDesktop() {
        let jsonString = self.jsonString()
        let filename = getDesktopDirectory().appendingPathComponent("output.bosy")
        
        do {
            try jsonString.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            print("ERROR: writing json file to Desktop failed!")
        }
    }

}
