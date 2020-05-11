//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 11.05.20.
//

import Foundation
import LTL


public class AssumptionsGenerator {
    
    
    public static func getAutomataAssumptions(auto: Automata) -> [LTL] {
        var return_assumptions: [LTL] = []
        
        let initial_state_assumptions = self._generateInitialStateAssumptions(auto: auto)
        
        return_assumptions.append(initial_state_assumptions)
        
        // TODO implement
        
        return return_assumptions
    }
    
    /**
     adds all state-names as input APs and also all APs which are specified to be observable
     */
    public static func getAutomataInputAPs(auto: Automata) -> [String] {
        // add all states as input APs + observable APs
        var return_array: [String] = []
        
        return return_array
    }
    
    /**
     returns all output APs of the Automata
     */
    public static func getAutomataOutputAPs(auto: Automata) -> [String] {
        // return all
        var return_array: [String] = []
        
        return return_array
    }
    
    /**
     generate Assumptions which specifiy the starting behaviour of the automaton
     */
    public static func _generateInitialStateAssumptions(auto: Automata) -> LTL {
        let initial_states = auto.initial_states
        
        var ltl_string = "("
        
        var state_index = 0
        while state_index < initial_states.count {
            ltl_string += initial_states[state_index].name
            
            // if more states coming add disjunction
            if (state_index < (initial_states.count - 1)) {
                ltl_string += " || "
            }
            state_index += 1
        }
        
        ltl_string += ")"
        
        do {
            let return_ltl = try LTL.parse(fromString: ltl_string)
            return return_ltl
        } catch {
            print("ERROR: could not generate initial StateAssumptions")
            exit(EXIT_FAILURE)
        }
    }
    
}
