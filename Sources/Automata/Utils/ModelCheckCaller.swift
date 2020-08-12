//
//  ModelCheckCaller.swift
//  Automata
//
//  Created by Daniel Schäfer on 18.06.20.
//

import Foundation
import LTL
import Utils


public class ModelCheckCaller {
    
    let preexistingTags: [String]
    let tagPrefix = "k"
    var tags: [String]
    var tagMapping: [String: LTL]
    let eaHyperDir = "/Users/daniel/dev/master/eahyper/eahyper_src/eahyper.native"
    
    
    public init(preexistingTags: [String]) {
        self.preexistingTags = preexistingTags
        self.tags = []
        self.tagMapping = [String: LTL]()
    }

    /**
     Returns list of Tag names
     
     Adds tags to automata and modifies the guarantees to no longer contain knowledge terms
     */
    public func generateTagsFromGuaranteesUsingMC(automata: inout Automata) -> [String] {
        
        // look for knowledge terms and replace those with tags and remember the mapping from tags to LTL content of said knowledge term
        
        var knowledgeTermOccurances: [LTL] = []
        for guarantee in automata.guarantees {
            knowledgeTermOccurances += guarantee.getAllKnowledgeTerms()
        }
        
        let knowledgeTermSet = self.getUniqueOccurances(knowledgeTermOccurances: knowledgeTermOccurances)
        
        for knowledgeTerm in knowledgeTermSet {
            createNewTagFor(knowledgeFormula: knowledgeTerm)
        }
        
        // for every knowledgeTerm replace its occurances with the Tag in the guarantees
        for (tagName, knowledgeTerm) in self.tagMapping {
            let tagAP = LTLAtomicProposition(name: tagName)
            let tagLTL = LTL.atomicProposition(tagAP)
            
            var guaranteeIter = 0
            while guaranteeIter < automata.guarantees.count {
                automata.guarantees[guaranteeIter] = automata.guarantees[guaranteeIter].replaceKnowledgeWithLTL(knowledge_ltl: knowledgeTerm, tagLTL: tagLTL)
                guaranteeIter += 1
            }
        }
        
        let completInformationAssumptions = getEAHyperAssumptions(automata: automata)
        
        // for every knowledgeTerm test if it holds in every single state of the automata
        for (tagName, knowledgeTerm) in self.tagMapping {
            
            // remove leading K in knowledgeTerm string representation
            var knowledgeCondition = knowledgeTerm.getEAHyperFormat()
            knowledgeCondition.removeFirst()
            print("ALGO: checking knowledge condition " + knowledgeCondition)
            
            let allStates = automata.get_allStates()
            var found = false
            for state in allStates {
                let implyCondition = "forall p. G(" + state.name + "_p -> " + knowledgeCondition + ")"

                if callEAHyper(assumptions: "forall p. " + state.name + "_p &  " + completInformationAssumptions, implies: implyCondition) {
                    // if MCHyper confirms implication add candidate-tag to this state
                    print("ALGO: candidate state confirmed for " + state.name)
                    state.addAnnotation(annotationName: tagName)
                    found = true
                } else {
                    // print("DEBUG: candidate state denied for " + state.name)
                }
            }
            // if none of the states are candidates print warning
            if !found {
                print("WARNING: no states are candidates for " + knowledgeCondition)
            }
            
        }
        return self.tags
    }
    
    /**
     Call MCHyper and check if Assumptions imply 'implies'.
     Both argument are LTL formulas and have to conform to EAHyper-s input format including the  path quantifiers
     
     TODO: fix EAHyper such that we do not have to use --pltl argument (--aalta is faster)
     TODO: add initial test to ensure that EAHyper is available and working somewhere in main?
     
     NOTE: make sure that environment variable `EAHYPER_SOLVER_DIR`  is set to `/location/eahyper/LTL_SAT_solver`
     */
    public func callEAHyper(assumptions: String, implies: String) -> Bool {
        //print("DEBUG: EAHyper input assumptions: \n" + assumptions + "\n implies:\n" + implies)
        let output = shell(launchPath: self.eaHyperDir, arguments: ["-fs", assumptions, "-is", implies, "--pltl"])
        //print("DEBUG: EAHyper output: " + output)
        
        if output.contains("does imply") {
            return true
        } else {
            return false
        }
        return false
    }
    
    
    /**
     Create a new tag and save the mapping internally
     */
    private func createNewTagFor(knowledgeFormula: LTL) {
        let tagName = self.tagPrefix + String(self.tags.count + 1)
        self.tags.append(tagName)
        self.tagMapping[tagName] = knowledgeFormula
    }
    
    // return array without duplicates in fixed order (deterministic!)
    private func getUniqueOccurances(knowledgeTermOccurances: [LTL]) -> [LTL] {
        // put all occurances in a set to eliminate duplicates
        var knowledgeTermTestSet: Set<LTL> = Set<LTL>()
        var knowledgeTermSet: [LTL] = []
        
        for occurance in knowledgeTermOccurances {
            if knowledgeTermTestSet.contains(occurance) {
                // skip if already contained
                continue
            } else {
                knowledgeTermTestSet.insert(occurance)
                knowledgeTermSet.append(occurance)
            }
        }
        
        return knowledgeTermSet
    }
    
    /* Returns assumptions required for EAHyper
     NOTE: does NOT set the initial state so this can be done later!
      we have to add later: "forall p. s0_p & "*/
    public func getEAHyperAssumptions(automata: Automata) -> String {
        var completeInformationAssumptions = AssumptionsGenerator.generateAutomataAssumptions(auto: automata, tags: self.preexistingTags, tagsInAPs: true)
        
        var strings: [String] = []
        
        // Remove line which contains initial state setting
        completeInformationAssumptions.remove(at: 0)
        
        for line in completeInformationAssumptions {
            strings.append(line.getEAHyperFormat())
        }
        
        let assumptionsString =  strings.joined(separator: " & ")
        
        return assumptionsString
    }

}
