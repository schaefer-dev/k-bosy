//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 01.06.20.
//

import Foundation


public class KBSConstructor {
    
    private let input_automata: Automata
    private var obs_automata: Automata
    
    private var new_to_old_states_mapping: [AutomataState: [AutomataState]]
    
    
    /**
     Assumes that finalize has not been called yet on given input automata
     */
    public init(input_automata: Automata) {
        input_automata._reduceToObservablePart()
        input_automata.finalize()
        self.input_automata = input_automata
        
        let new_apList = input_automata.apList
        
        var new_all_states = [String: AutomataState]()
        
        // Merge previous initial states into one state
        // TODO: think later about this 'limitation' is reasonable. Not sure if different observable APs in different initial states can already be used to distinguish in which state the environment currently is
        let new_initial_state = KBSCUtils.mergeStatesIntoNewState(states: input_automata.initial_states)
        let new_initial_states: [AutomataState] = [new_initial_state]
        new_all_states[new_initial_state.name] = new_initial_state
        
        self.new_to_old_states_mapping = [AutomataState: [AutomataState]]()
        self.new_to_old_states_mapping[new_initial_state] = input_automata.initial_states
        
        self.obs_automata = Automata(apList: new_apList, initial_states: new_initial_states, all_states: new_all_states, guarantees: input_automata.guarantees)
    }
    
    
    /**
     Perform Knowledge Based Subset Construction and return the observational Automata
     */
    public func run() -> Automata {
        // only initial states exist currently, we have to analyze all those states
        var state_analyze_queue: [AutomataState] = self.obs_automata.initial_states
        
        // repeat until all states have been analyzed
        while (state_analyze_queue.count > 0) {
            let analyzed_state = state_analyze_queue.removeFirst()
            print("DEBUG: analyzing state '" + analyzed_state.description + "' in obs Automata now.")
            
            // Builds the Transitions in `new_state` according to the behaviour in the old corresponding states given in `old_states`.
            
            let bitset_ap_index_map = self.obs_automata.apList.get_bitset_ap_index_map()
            let current_bitset_condition = Bitset(size: bitset_ap_index_map.count, truth_value: false)
            
            // check behaviour for current_bitset_condition until all possible combination of truth values have been checked. This is the case whenever the bitset can no longer be incremented.
            repeat {
                // lookup old states that were merged into the currently analyzed state
                let old_states: [AutomataState] = self.new_to_old_states_mapping[analyzed_state]!
                
                let old_states_successors = getPossibleSuccessorsUnderCondition(condition: current_bitset_condition, start_states: old_states)
                
                // divide possible successor states into sets that each contain environment-states which can not be distinguished by their APs
                let obs_eq_state_classes = KBSCUtils.divideStatesByAPs(input_states: old_states_successors)
                
                for obs_eq_state_set in obs_eq_state_classes {
                    
                    let (obs_successor_state, is_new_state) = getObsEqState(obs_eq_state_set: obs_eq_state_set)
                    
                    if (is_new_state) {
                        // if new state was created we put it in the queue to observe its possible successors later
                        state_analyze_queue.append(obs_successor_state)
                    }
                    
                    // create the transition from 'analyzed_state' to 'obs_successor_state' with condition 'current_bitset_condition' and add it to the state 'analyzed_state'
                    createTransitionFromBitset(bs: current_bitset_condition, start: analyzed_state, end: obs_successor_state)
                }
                
            } while (current_bitset_condition.increment())
            
        }
        return self.obs_automata
    }
    
    
    
    /**
     Returns the set of possible successors of all states given as `start_states` with the condition `condition` holding for all taken transitions.
     */
    private func getPossibleSuccessorsUnderCondition(condition: Bitset, start_states: [AutomataState]) -> [AutomataState] {
        // determine the successor states of each of those old states for this particular bitset conditon
        var old_states_successors: [AutomataState] = []
        for state in start_states {
            for transition in state.transitions {
                // check if current_bitset_condition assumption satisfies condition for this transition.
                if transition.condition.bitset_representation.holdsUnderAssumption(assumption_bs: condition) {
                    old_states_successors.append(transition.end)
                }
            }
        }
        
        print("DEBUG: Successors " + old_states_successors.description + " possible according to original automata using condition " + current_bitset_condition.description)
        return old_states_successors
    }
    
    
    /**
     Check if a state that contains all the states given as argument already exists.
     If yes, return a reference to this existing state and also return false.
     If no, create a new state that corresponds to this set of states and add it to the automata structure and then return a reference to this new state. Also return true.
     */
    private func getObsEqState(obs_eq_state_set: [AutomataState]) -> (AutomataState, Bool) {
        // check before creating adding new state if it already exists
        var obs_successor_state = KBSCUtils.mergeStatesIntoNewState(states: obs_eq_state_set)
        if self.obs_automata.get_state(name: obs_successor_state.name) == nil {
            // obs_successor_state is in fact new and thus has to be added to the obs automata structures
            self.new_to_old_states_mapping[obs_successor_state] = obs_eq_state_set
            print("DEBUG: newly discovered state " + obs_successor_state.name + " added to observational automata.")
            self.obs_automata.add_state(new_state: obs_successor_state)
            
            
            return (obs_successor_state, true)
        } else {
            // new_successor_state is not new -> abort newly created state and move reference to the already existing one such that the following transition creation links to the already existing state in the structure
            obs_successor_state = self.obs_automata.get_state(name: obs_successor_state.name)!
            return (obs_successor_state, false)
        }
    }
    
    
    /**
     Create a AutomataTransition in `start` that goes from state `start` to state `end` with the condition `bs`.
     */
    private func createTransitionFromBitset(bs: Bitset, start: AutomataState, end: AutomataState) {
        let transition_formula = KBSCUtils.naiveBitsetToFormula(bs: bs, apList: self.obs_automata.apList)
        let new_found_transition = AutomataTransition(start: start, condition: transition_formula, end: end)
        start.addTransition(trans: new_found_transition)
    }

}
