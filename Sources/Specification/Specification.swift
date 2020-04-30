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
import LTL


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
    public var assumptions: [LTL]
    public var guarantees: [LTL]
    public let transformation_rules: [LTL]?
    
    public init(semantics: TransitionSystemType, inputs: [String], outputs: [String], assumptions: [LTL], guarantees: [LTL], transformation_rules: [LTL]) {
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
        if let rules = self.transformation_rules {
            print("transformation rules: ", rules)
        }
        print("----------------------------------------")
    }
    
    
    public mutating func applyTransformationRules() -> Bool {
        if let rules = self.transformation_rules {
            let rules_max_index = rules.count
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
                 
                let k_ltl = rules[k_index]
                let r_ltl = rules[r_index]
                 
                // Replace all occurances in assumptions
                for i in 0 ..< self.assumptions.count {
                    self.assumptions[i] = self.assumptions[i].replaceKnowledgeWithLTL(knowledge_ltl: k_ltl, replaced_ltl: r_ltl)
                }
                
                // Replace all occurances in guarantees
                for i in 0 ..< self.guarantees.count {
                    self.guarantees[i] = self.guarantees[i].replaceKnowledgeWithLTL(knowledge_ltl: k_ltl, replaced_ltl: r_ltl)
                }
                
                // TODO: maybe add warning if replacement has not worked
                
                k_index += 1
                r_index += 1
            }
            
            return true
        } else {
            print("Warning: no transformation rules given, skipping 'translation-phase'.")
            return true
        }
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
    
    /* returns output filename */
    public func writeJsonToDir(inputFileName: String, dir: URL) -> String {
        let jsonString = self.jsonString()
        
        // use input filename without the file-suffix (without .kbosy)
        let output_filename = inputFileName.split(separator: ".")[0].description + "_transformed.bosy"
        
        let output_file = dir.appendingPathComponent(output_filename)
        
        do {
            try jsonString.write(to: output_file, atomically: true, encoding: String.Encoding.utf8)
            return output_filename
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            print("ERROR: writing json file to Directory failed!")
            
        }
        return ""
    }

}

public func readSpecificationFile(path: String) -> SynthesisSpecification? {
    /* Verify System requirements */
    if #available(OSX 10.11, *) {
        /* System requirements passed */
        let jsonURL = URL(fileURLWithPath: path)
        //print("loading json from path: " + jsonURL.path)


        /* try to read input JSON File */
        do {
            let jsonData =  try Data(contentsOf: jsonURL)
            // jsonData can be used
            let decoder = JSONDecoder()
            do {
                let spec = try decoder.decode(SynthesisSpecification.self, from: jsonData)
                return spec
                
                
            } catch {
                /* failed to decode content of jsonData */
                print("ERROR during Decoding: " + error.localizedDescription)
            }
        } catch {
            /* failed to read data from jsonURL */
            print("loading of jsonData error...")
        }
    } else {
        /* failed System Requirements */
        print("ERROR: Requires at least macOS 10.11")
    }
    return nil
}
