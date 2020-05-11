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
    public static func _generatePossibleStateAssumptions(auto: Automata) -> [LTL] {
        let all_states = auto.get_allStates()
        var return_assumptions: [LTL] = []
        
        var current_state_index = 0
        while (current_state_index < all_states.count) {
            // build condition for state with index 'current_state_index'
            var ltl_string = "G(" + all_states[current_state_index].name + " -> ("
            
            // now build conjunction with all other states negated
            var other_state_index = 0
            while (other_state_index < all_states.count) {
                // we do not negate the same state we are currently building the condition for
                if (current_state_index == other_state_index) {
                    other_state_index += 1
                    continue
                }
                
                ltl_string += "!" + all_states[other_state_index].name
                
                // if more states missing then add conjunction afterwards
                if (other_state_index < (all_states.count - 1)) {
                    // special case only one state follows and this is the current_state_index, in this case no further conjunctions are added
                    if (other_state_index == (all_states.count - 2)) && (current_state_index > other_state_index) {
                        other_state_index += 1
                        continue
                    } else {
                        ltl_string += " && "
                    }
                }
                
                other_state_index += 1
            }
            
            ltl_string += "))"
            
            do{
                let ltl_condition = try LTL.parse(fromString: ltl_string)
                return_assumptions.append(ltl_condition)
            } catch {
                print("Error when parsing LTL condition " + ltl_string)
            }
            
            current_state_index += 1
        }
        
        
        
        // add condition that we always have to be in one of the states
        var ltl_string = "G("
        current_state_index = 0
        while (current_state_index < all_states.count) {
            ltl_string += all_states[current_state_index].name
            
            // if more states missing then add disjunction afterwards
            if (current_state_index < (all_states.count - 1)) {
                ltl_string += " || "
            }
            
            current_state_index += 1
        }
        
        ltl_string += ")"
        
        do {
            let ltl_condition = try LTL.parse(fromString: ltl_string)
            return_assumptions.append(ltl_condition)
        } catch {
            print("Error when parsing LTL condition " + ltl_string)
        }
        
        
        return return_assumptions
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
