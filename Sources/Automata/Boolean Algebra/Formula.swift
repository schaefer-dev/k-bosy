//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 28.04.20.
//

import Foundation



/* Formula represented as Distjunctive Normal Form (DNF) */
public struct Formula : Equatable {
    var dnf: [Conjunction]
    
    public func eval(state: CurrentState) -> Bool {
        // empty formula is true
        if (self.dnf.count == 0) {
            return true
        }
        
        
        for conj in dnf {
            // whenever one conjunction is true, then DNF-Formula must be true
            if (conj.eval(state: state)){
                return true
            }
        }
        return false
    }
    
    public static func == (f1: Formula, f2: Formula) -> Bool {
        // if not same length of dnf can not be equal
        if f1.dnf.count != f2.dnf.count {
            return false
        }
        
        for i in 0...(f1.dnf.count - 1) {
            // if any pair in dnf not equal return false
            if (f1.dnf[i] != f2.dnf[i]) {
                return false
            }
        }
        
        return true
    }
    
    public init(containedConjunctions: [Conjunction]) {
        dnf = containedConjunctions
    }
    
    
    
    public func toString() -> String {
        if dnf.count == 0 {
            return ""
        }
        
        var output_string = ""
        
        var conj_index = 0
        while (true) {
            output_string += self.dnf[conj_index].toString()
            conj_index += 1
            if (conj_index > (self.dnf.count - 1)) {
                break
            }
            output_string += " ∨ "
        }
        
        return output_string
    }
}


public struct Conjunction : Equatable {
    var literals : [Literal]
    
    public func eval(state: CurrentState) -> Bool {
        if (self.literals.count == 0) {
            print("WARNING: empty Conjunction evaluated, this should never happen!")
            return true
        }
        
        for literal in literals {
            // whenever one literal not true, conjunction can no longer be true
            if !(literal.eval(state: state)){
                return false
            }
        }
        return true
    }
    
    public static func == (c1: Conjunction, c2: Conjunction) -> Bool {
        // if not same length of dnf can not be equal
        if c1.literals.count != c2.literals.count {
            return false
        }
        
        for i in 0...(c1.literals.count - 1) {
            // if any pair in dnf not equal return false
            if (c1.literals[i].toString() != c2.literals[i].toString()) {
                return false
            }
        }
        
        return true
    }
    
    public init(literalsContainedInConjunction: [Literal]) {
        literals = literalsContainedInConjunction
    }
    
    
    public func toString() -> String {
        if literals.count == 0 {
            return ""
        }
        
        var output_string = "("
        var lit_index = 0
        while (true) {
            output_string += self.literals[lit_index].toString()
            lit_index += 1
            if (lit_index > (self.literals.count - 1)) {
                break
            }
            output_string += " ∧ "
        }
        
        
        output_string += ")"
        
        return output_string
    }
}

public func checkBracketCorrectness(input_str: String) -> Bool {
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


public func parseDNFFormula(input_str: String, apList: APList) -> Formula? {
    
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


public func parseConjunction(str_conj: String, apList: APList) -> Conjunction? {
    print("DEBUG: parsing conjunction " + str_conj)
    
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
