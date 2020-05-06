//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 05.05.20.
//

import Foundation


public class FormulaParser {
    
    public static func parseLiteral(str_literal: String, apList: APList) -> Literal? {
        var negated = false
        // check if negated
        var literal_str = str_literal
        
        if (literal_str.count == 0) {
            print("Tried to parse empty literal")
            return nil
        }
        
        if (literal_str.character(at: 0) == "!") || (literal_str.character(at: 0) == "¬") {
            negated = true
            // remove negation character, such that only AP remains
            literal_str.remove(at: str_literal.startIndex)
        }
        
        if (literal_str.count == 0) {
            print("Tried to parse empty literal with only negation")
            return nil
        }
        
        
        // parse string of Literal, which can be either AP (Variable) or Constant
        if literal_str == "true" {
            let constant = Constant(negated: negated, truthValue: true)
            return constant
            
        } else if literal_str == "false" {
            let constant = Constant(negated: negated, truthValue: false)
            return constant
            
        } else {
            let apOpt = apList.lookupAP(apName: literal_str)
            
            if (apOpt == nil) {
                return nil
            }
            
            let literal = Variable(negated: negated, atomicProposition: apOpt!)
            return literal
        }
    }

    
    public static func parseDNFFormula(input_str: String, apList: APList) -> Formula? {
        
        // Remove ALL whitespace from string
        var formula_string = input_str.components(separatedBy: .whitespacesAndNewlines).joined()
        
        // check if brackets are set correctly!!
        if !checkBracketCorrectness(input_str: formula_string) {
            print("ERROR: Invalid Brackets in formula: " + formula_string)
            return nil
        }
        
        // Remove all brackets
        formula_string = formula_string.replacingOccurrences(of: "(", with: "")
        formula_string = formula_string.replacingOccurrences(of: ")", with: "")
        
        if (formula_string == "") {
            let constant = Constant(negated: false, truthValue: true)
            let conj = Conjunction(literalsContainedInConjunction: [constant])
            let true_dnf_formula = Formula(containedConjunctions: [conj])
            return true_dnf_formula
        }
        
        
        // TODO: check if bracketting is correct
        let str_conjunctions = formula_string.components(separatedBy: "∨")
        
        var conj_list: [Conjunction] = []
        
        for str_conj in str_conjunctions {
            let conj = parseConjunction(str_conj: str_conj, apList: apList)
            if (conj == nil) {
                return nil
            } else {
                conj_list.append(conj!)
            }
        }
        
        let dnf_formula = Formula(containedConjunctions: conj_list)
        return dnf_formula
    }


    public static func parseConjunction(str_conj: String, apList: APList) -> Conjunction? {        
        let str_literals = str_conj.components(separatedBy: "∧")
        var literal_array: [Literal] = []
        
        for str_literal in str_literals {
            let litOpt = parseLiteral(str_literal: str_literal, apList: apList)
            if (litOpt == nil) {
                print("ERROR: critical parsing error, literal '" + str_literal + "' could not be parsed!")
                return nil
            } else {
                literal_array.append(litOpt!)
            }
        }
        
        let conj = Conjunction(literalsContainedInConjunction: literal_array)
        return conj
    }
    
    
    public static func checkBracketCorrectness(input_str: String) -> Bool {
        var counter = 0
        var parsingList: [String] = []
        var stringIndex = 0
        
        for character in input_str {
            if (character == "(") {
                counter += 1
                if stringIndex == 0 {
                    parsingList.append("0")
                } else {
                    parsingList.append("")
                }
            } else if (character == ")") {
                counter -= 1
                // check if enclosed formula is fine
                let checkString = parsingList.popLast()
                // check if enclosed formula in brackets contained ∨, if yet it may be invalid
                if checkString != nil && (checkString!.contains("∨")) {
                    // check if it is not a surrounding bracket (start at index 0 end at last index), which allows for ∨ being contained
                    if !(stringIndex == (input_str.count - 1)) || !(checkString!.contains("0")) {
                        print("DEBUG: bracketing not valid because it contained ∨")
                        return false
                    }
                }
            } else if (character == "∨") {
                if parsingList.count > 0 {
                    for i in 0...(parsingList.count - 1) {
                        parsingList[i] += "∨"
                    }
                }
            } else if (character == "∧") {
                if parsingList.count > 0 {
                    for i in 0...(parsingList.count - 1) {
                        parsingList[i] += "∧"
                    }
                }
            }
            // if bracket closed before opened its invalid
            if (counter < 0) {
                return false
            }
            stringIndex += 1
        }
        
        // if not all brackets closed its invalid
        if counter != 0 {
            return false
        }
        
        return true
    }



}
