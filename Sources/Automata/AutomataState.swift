//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 03.05.20.
//

import Foundation


public class AutomataState : Hashable, CustomStringConvertible {
    public var name: String
    public var propositions: [AP]
    public var transitions: [AutomataTransition]
    
    public var description: String {
        var returnString = self.name + " {"
        
        var index = 0
        while index < self.propositions.count {
            returnString += self.propositions[index].description
            
            if (index < self.propositions.count - 1) {
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
        self.transitions = []
    }
    
    
    /**
     returns the set of Transitions that may be applied starting in the current state, given the truth values contained in the given CurrentState.
     
     - Parameter state: current State which contains the truth values that currently hold for all APs.
     
     - Returns: Set of AutomataTransition which start in this state and could be applied given the CurrentTruthValues.
     */
    public func getApplicableTransitions(truthValues: CurrentTruthValues) -> [AutomataTransition]{
        var applicableTransitions: [AutomataTransition] = []
        
        // check for every transition if it can be applied
        for trans in self.transitions {
            if (trans.condition.eval(truthValues: truthValues)) {
                // condition is true -> add to returned list
                applicableTransitions.append(trans)
            }
        }
        return applicableTransitions
    }
    
    
    public func addTransition(trans: AutomataTransition) {
        // TODO: maybe check first if this exact transition is already contained
        if (trans.start.name != self.name) {
            print("Critical Error: Transition does not belong into this state")
            exit(EXIT_FAILURE)
        }
        self.transitions.append(trans)
    }
    
    public func addAPs(aps: [AP]) {
        for ap in aps {
            if (self.propositions.contains(ap)) {
                print("WARNING: tried to add AP to state, which was already contained, skipping!")
            }
            self.propositions.append(ap)
            print("DEBUG: added " + ap.description + " to state " + self.name)
        }
    }
    
    
    /**
     reduce structure in this state to only contain observable APs. This affects only  the set of APs that hold in this state
     */
    public func reduceToObservablePart() {
        
        // only keep observable APs in proposition List that hold in this state
        let obs_propositions = self.propositions.filter { $0.obs }
        self.propositions = obs_propositions
        
    }
    
    
    // Equality of states defined over their name which has to be unique
    public static func == (state1: AutomataState, state2: AutomataState) -> Bool {
        return state1.name == state2.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
