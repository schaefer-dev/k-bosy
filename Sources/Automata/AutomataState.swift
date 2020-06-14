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
    private var parent_automata: Automata?

    private var tag_annotation: Set<String>

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
        // TODO sort propositions list!
        self.transitions = []
        self.parent_automata = nil
        self.tag_annotation = Set.init()
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
            print("DEBUG: added " + ap.description + " to state " + self.name)
        }

        // Keep proposition list sorted
        self.propositions = self.propositions.sorted()
    }

    public func setParentAutomata(parent: Automata) {
        // make sure that parent was not set yet (is only allowed to happen once!)
        assert(self.parent_automata == nil)

        self.parent_automata = parent
    }

    /**
     reduce structure in this state to only contain observable APs. This affects only  the set of APs that hold in this state
     */
    public func reduceToObservablePart() {

        // only keep observable APs in proposition List that hold in this state
        let obs_propositions = self.propositions.filter { $0.obs }
        self.propositions = obs_propositions

    }

    public func containsAnnotation(annotation_name: String) -> Bool {
        return self.tag_annotation.contains(annotation_name)
    }

    public func addAnnotation(annotation_name: String) {
        // if tag already contained it is skipped because tag_annotation is a set
        self.tag_annotation.insert(annotation_name)
    }

    public func getAnnotation() -> [String] {
        return Array(self.tag_annotation)
    }

    /**
     performs simplifications in this state.
     This means that conditions of all transitions starting in this state are simplified
        all occurances of non-output APs are replaced with their respective values according to the state we are currently in. Only the value of output-APs is not known at this time which is why we keep those variable.
        Tautologies are also removed in the formulas
     Also the Bitset representations of these simplified transitions are built.
     */
    public func finalize() {
        for trans in self.transitions {
            trans._simplify()
            trans._buildBitsetRepresentation()
        }
    }

    // Equality of states defined over their name which has to be unique
    public static func == (state1: AutomataState, state2: AutomataState) -> Bool {
        return state1.name == state2.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
