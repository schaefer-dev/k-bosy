//
//  ModelCheckCaller.swift
//  Automata
//
//  Created by Daniel Schäfer on 18.06.20.
//

import Foundation
import LTL


public class ModelCheckCaller {
    
    let tagPrefix = "kmc"
    var tags: [String]
    var tagMapping: [String: LTL]
    
    
    public init() {
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
            
            var guarantee_iter = 0
            while guarantee_iter < automata.guarantees.count {
                automata.guarantees[guarantee_iter] = automata.guarantees[guarantee_iter].replaceKnowledgeWithLTL(knowledge_ltl: knowledgeTerm, replaced_ltl: tagLTL)
                guarantee_iter += 1
            }
        }
        
        let complete_information_assumptions = getCompleteInformationAssumptions(automata: automata)
        
        return self.tags
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
    
    
    public func getCompleteInformationAssumptions(automata: Automata) -> String {
        let completeInformationAssumptions = AssumptionsGenerator.generateAutomataAssumptions(auto: automata, tags: [])
        
        var strings: [String] = []
        for line in completeInformationAssumptions {
            strings.append(line.description)
        }
        
        var assumptionsString = strings.joined(separator: " & ")
        
        // TODO: maybe post processing of string required here because EAHyper is pretty picky!
        
        return assumptionsString
    }

}
