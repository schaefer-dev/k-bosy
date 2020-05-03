//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 03.05.20.
//

import Foundation


public class AutomataState : Hashable {
    public var name: String
    public var propositions: [AP]
    public var transitions: [AutomataTransition]
    
    public init(name: String) {
        self.name = name
        self.propositions = []
        self.transitions = []
    }
    
    
    public func getApplicableTransitions(state: CurrentState) -> [AutomataTransition]{
        // TODO: returns the set of applicable transitions given the currentState
        var applicableTransitions: [AutomataTransition] = []
        
        // check for every transition if it can be applied
        for trans in self.transitions {
            if (trans.condition.eval(state: state)) {
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
    
    
    // Equality of states defined over their name which has to be unique
    public static func == (state1: AutomataState, state2: AutomataState) -> Bool {
        return state1.name == state2.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
