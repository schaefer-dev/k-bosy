//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 05.05.20.
//

import Foundation

public class FormulaParser {

    /**
    Attempts to parse a single Literal . This Literal is given as a string.
    
    - Parameter str_literal: the String that contains only the Literal (may contain negation character)
    - Parameter apList: a List of Atomic Propositions which has to contain all Atomic Propositions which occur in the given string
    
    - Returns: An optional new class of Type Literal which is the internal representation of the given Literal. This may either represent a constant or an atomic proposition. Both cases may occur in negated forms.
    */
    public static func parseLiteral(stringLiteral: String, apList: APList) -> Literal? {
        var negated = false
        // check if negated
        var literalString = stringLiteral

        if literalString.count == 0 {
            print("Tried to parse empty literal")
            return nil
        }

        if (literalString.character(at: 0) == "!") || (literalString.character(at: 0) == "¬") {
            negated = true
            // remove negation character, such that only AP remains
            literalString.remove(at: stringLiteral.startIndex)
        }

        if literalString.count == 0 {
            print("Tried to parse empty literal with only negation")
            return nil
        }

        // parse string of Literal, which can be either AP (Variable) or Constant
        if literalString == "true" {
            let constant = Constant(negated: negated, truthValue: true)
            return constant

        } else if literalString == "false" {
            let constant = Constant(negated: negated, truthValue: false)
            return constant

        } else {
            let apOpt = apList.lookupAP(apName: literalString)

            if apOpt == nil {
                return nil
            }

            let literal = Variable(negated: negated, atomicProposition: apOpt!)
            return literal
        }
    }

    /**
    Attempts to parse a supposed Formla in DNF Form. This formula is given as a string.
    
    - Parameter input_str: the String that contains only the DNF Formula
    - Parameter apList: a List of Atomic Propositions which has to contain all Atomic Propositions which occur in the given string
    
    - Returns: An optional new class of Type Formula which is the internal representation of the given DNF Formula.
    */
    public static func parseDNFFormula(inputString: String, apList: APList) -> Formula? {

        // Remove ALL whitespace from string
        var formulaString = inputString.components(separatedBy: .whitespacesAndNewlines).joined()

        // check if brackets are set correctly!!
        if !checkBracketCorrectness(inputString: formulaString) {
            print("ERROR: Invalid Brackets in formula: " + formulaString)
            return nil
        }

        // Remove all brackets
        formulaString = formulaString.replacingOccurrences(of: "(", with: "")
        formulaString = formulaString.replacingOccurrences(of: ")", with: "")

        if formulaString == "" {
            let constant = Constant(negated: false, truthValue: true)
            let conj = Conjunction(literalsContainedInConjunction: [constant])
            let trueDNFFormula = Formula(containedConjunctions: [conj], bitset_ap_mapping: apList.get_bitset_ap_index_map())
            return trueDNFFormula
        }

        // TODO: check if bracketting is correct
        let stringConjunctions = formulaString.components(separatedBy: "∨")

        var conjunctionsList: [Conjunction] = []

        for stringConjunction in stringConjunctions {
            let conj = parseConjunction(stringConjunction: stringConjunction, apList: apList)
            if conj == nil {
                return nil
            } else {
                conjunctionsList.append(conj!)
            }
        }

        let dnfFormula = Formula(containedConjunctions: conjunctionsList, bitset_ap_mapping: apList.get_bitset_ap_index_map())
        return dnfFormula
    }

    /**
     Attempts to parse a supposed conjunction, given as a string and returns the resulting Conjunction Class
     
     - Parameter str_conj: the String that contains the conjunction that is supposed to be parsed in String form
     - Parameter apList: a List of Atomic Propositions which has to contain all Atomic Propositions which occur in the given string
     
     - Returns: An optional new class of Type Conjunction which is the internal representation of the given Formula.
     */
    public static func parseConjunction(stringConjunction: String, apList: APList) -> Conjunction? {
        let stringLiterals = stringConjunction.components(separatedBy: "∧")
        var literalArray: [Literal] = []

        for stringLiteral in stringLiterals {
            let litOpt = parseLiteral(stringLiteral: stringLiteral, apList: apList)
            if litOpt == nil {
                print("ERROR: critical parsing error, literal '" + stringLiteral + "' could not be parsed!")
                return nil
            } else {
                literalArray.append(litOpt!)
            }
        }

        let conj = Conjunction(literalsContainedInConjunction: literalArray)
        return conj
    }

    /**
    Checks the correctness of the brackets in the given String. The Brackets are correct if and only if they encapsulate only Conjunctions. The only exception to this rulse is one optional set of brackets that surrounds the entire Formula. All other brackets are forbidden.
    
    - Parameter input_str: the String containing brackets which is being checked. Does NOT contain any whitespace
    
    - Returns: True if the Bracket Check was passed, false otherwise.
    */
    public static func checkBracketCorrectness(inputString: String) -> Bool {
        var counter = 0
        var parsingList: [String] = []
        var stringIndex = 0

        for character in inputString {
            if character == "(" {
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
                    if !(stringIndex == (inputString.count - 1)) || !(checkString!.contains("0")) {
                        print("DEBUG: bracketing not valid because it contained ∨")
                        return false
                    }
                }
            } else if character == "∨" {
                if parsingList.count > 0 {
                    for iter in 0...(parsingList.count - 1) {
                        parsingList[iter] += "∨"
                    }
                }
            } else if character == "∧" {
                if parsingList.count > 0 {
                    for iter in 0...(parsingList.count - 1) {
                        parsingList[iter] += "∧"
                    }
                }
            }
            // if bracket closed before opened its invalid
            if counter < 0 {
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
