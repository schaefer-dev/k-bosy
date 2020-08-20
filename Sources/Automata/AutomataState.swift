//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 03.05.20.
//

import Foundation

public class AutomataState: Hashable, CustomStringConvertible {
    public var name: String
    // proposition list is kept sorted
    public var propositions: [AP]
    public var transitions: [AutomataTransition]
    private var parentAutomata: Automata?

    private var tagAnnotation: Set<String>

    public var description: String {
        var returnString = self.name + " {"

        var index = 0
        while index < self.propositions.count {
            returnString += self.propositions[index].description

            if index < self.propositions.count - 1 {
                // more elements follow, thus add commata
                returnString += ", "
            }
            index += 1
        }
        returnString += "}"
        return returnString
     }

    public init(name: String, propositions: [AP]) {
        self.name = name
        self.propositions = propositions
        self.propositions = self.propositions.sorted()
        self.transitions = []
        self.parentAutomata = nil
        self.tagAnnotation = Set.init()
    }

    /**
     returns the set of Transitions that may be applied starting in the current state, given the truth values contained in the given CurrentState.
     
     - Parameter state: current State which contains the truth values that currently hold for all APs.
     
     - Returns: Set of AutomataTransition which start in this state and could be applied given the CurrentTruthValues.
     */
    public func getApplicableTransitions(truthValues: CurrentTruthValues) -> [AutomataTransition] {
        var applicableTransitions: [AutomataTransition] = []

        // check for every transition if it can be applied
        for trans in self.transitions {
            if trans.condition.eval(truthValues: truthValues) {
                // condition is true -> add to returned list
                applicableTransitions.append(trans)
            }
        }
        return applicableTransitions
    }

    public func addTransition(trans: AutomataTransition) {
        // TODO: maybe check first if this exact transition is already contained
        if trans.start.name != self.name {
            print("Critical Error: Transition does not belong into this state")
            exit(EXIT_FAILURE)
        }
        self.transitions.append(trans)
    }

    public func addAPs(aps: [AP]) {
        for ap in aps {
            if self.propositions.contains(ap) {
                print("WARNING: tried to add AP to state, which was already contained, skipping!")
            }
            self.propositions.append(ap)
            //print("DEBUG: added " + ap.description + " to state " + self.name)
        }

        // Keep proposition list sorted
        self.propositions = self.propositions.sorted()
    }

    public func setParentAutomata(parent: Automata) {
        // make sure that parent was not set yet (is only allowed to happen once!)
        assert(self.parentAutomata == nil)

        self.parentAutomata = parent
    }

    /**
     reduce structure in this state to only contain observable APs. This affects only  the set of APs that hold in this state
     */
    public func reduceToObservablePart() {

        // only keep observable APs in proposition List that hold in this state
        let obsPropositions = self.propositions.filter { $0.obs }
        self.propositions = obsPropositions

    }

    public func containsAnnotation(annotationName: String) -> Bool {
        return self.tagAnnotation.contains(annotationName)
    }

    public func addAnnotation(annotationName: String) {
        // if tag already contained it is skipped because tag_annotation is a set
        self.tagAnnotation.insert(annotationName)
    }

    public func getAnnotation() -> [String] {
        return Array(self.tagAnnotation)
    }

    /**
     performs simplifications in this state.
     This means that conditions of all transitions starting in this state are simplified
        all occurances of non-output APs are replaced with their respective values according to the state we are currently in. Only the value of output-APs is not known at this time which is why we keep those variable.
        Tautologies are also removed in the formulas
     Also the Bitset representations of these simplified transitions are built.
     */
    public func finalize() {
        print("DEBUG: starting finalize")
        for trans in self.transitions {
            trans.simplify()
            trans.buildBitsetRepresentation()
        }
        print("DEBUG: finalize: completed initial simplifications")
        
        /* merge transitions whenever possible */
        // divide transitions by their outgoing state
        var endStateToTransitionMap: [AutomataState: [AutomataTransition]] = [:]
        for trans in self.transitions {
            if (endStateToTransitionMap[trans.end] == nil) {
                endStateToTransitionMap[trans.end] = [trans]
            } else {
                endStateToTransitionMap[trans.end]!.append(trans)
            }
        }
        
        print(endStateToTransitionMap)
        
        var newTransitions: [AutomataTransition] = []
        for (_, transitionSet) in endStateToTransitionMap {
            print("DEBUG: merge call performed")
            newTransitions += AutomataState.tryTransitionMerge(transitionSet: transitionSet)
        }
        
        print(newTransitions)
        
        // overwrite old transitions
        self.transitions = newTransitions
        print("DEBUG: finalize: completed")
    }
    
    
    /**
     Tries to merge the given transitions into as few transitions as possible. Assumes that bitmapsrepresentation has been built. All endStates of given transitions have to be equal.
     */
    public static func tryTransitionMerge(transitionSet: [AutomataTransition]) -> [AutomataTransition] {
        // check that all transitions share the same goalstate, otherwise this is not valid
        for inputTransition in transitionSet {
            assert(inputTransition.end.name == transitionSet[0].end.name, "Only transition with same endstate can be attempted to be merged")
        }
        var newMinimalTransitionSet: [AutomataTransition] = []
        
        var iter = 0
        var newConjunctions: [Bitset] = []
        
        while (iter < transitionSet.count) {
            let currentTransition = transitionSet[iter]
            /* TODO: add subsumes check maybe here already? */
            newConjunctions += currentTransition.condition.bitsetRepresentation.conjunctions!
            
            iter += 1
        }
        
        let bitsetDNFFormula: BitsetDNFFormula = BitsetDNFFormula(ap_index_map: transitionSet[0].condition.bitsetRepresentation.get_mapping())
        
        for cond in newConjunctions {
            bitsetDNFFormula.add_formula(bitset: cond)
        }
        
        bitsetDNFFormula.reduce()
        
        let newAutomataTransition = AutomataTransition(start: transitionSet[0].start, bitsetRepresentation: bitsetDNFFormula, end: transitionSet[0].end)
        newMinimalTransitionSet.append(newAutomataTransition)
        
        return newMinimalTransitionSet
    }
    

    // Equality of states defined over their name which has to be unique
    public static func == (state1: AutomataState, state2: AutomataState) -> Bool {
        return state1.name == state2.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
