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
    
    
    public func getApplicableTransitions(state: CurrentState) -> [AutomataTransition]{
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
    
    public func addAPs(aps: [AP]) {
        for ap in aps {
            if (self.propositions.contains(ap)) {
                print("WARNING: tried to add AP to state, which was already contained, skipping!")
            }
            self.propositions.append(ap)
            print("DEBUG: added " + ap.description + " to state " + self.name)
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
