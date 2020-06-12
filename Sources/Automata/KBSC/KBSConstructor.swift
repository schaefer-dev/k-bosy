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
                
                // determine the successor states of each of those old states for this particular bitset conditon
                var old_states_successors: [AutomataState] = []
                for old_state in old_states {
                    for old_trans in old_state.transitions {
                        // TODO check if current_bitset_condition assumption satisfies condition for this transition.
                        if old_trans.condition.bitset_representation.holdsUnderAssumption(assumption_bs: current_bitset_condition) {
                            old_states_successors.append(old_trans.end)
                        }
                    }
                }
                print("DEBUG: Successors " + old_states_successors.description + " possible according to original automata using condition " + current_bitset_condition.description)
                
                // divide possible successor states into sets that each contain environment-states which can not be distinguished by their APs
                let obs_eq_state_classes = KBSCUtils._divideStatesByAPs(input_states: old_states_successors)
                
                for obs_eq_state_set in obs_eq_state_classes {
                    // TODO: minor optimization: check before creating new state if it already exists
                    var obs_successor_state = KBSCUtils.mergeStatesIntoNewState(states: obs_eq_state_set)
                    if self.obs_automata.get_state(name: obs_successor_state.name) == nil {
                        // obs_successor_state is in fact new and thus has to be added to the obs automata structures
                        self.new_to_old_states_mapping[obs_successor_state] = obs_eq_state_set
                        print("DEBUG: newly discovered state " + obs_successor_state.name + " added to observational automata.")
                        self.obs_automata.add_state(new_state: obs_successor_state)
                        
                        // also we have to put in in the queue to observe its possible successors later
                        state_analyze_queue.append(obs_successor_state)
                    } else {
                        // new_successor_state is not new -> abort newly created state and move reference to the already existing one such that the transition links to the correct state
                        print("DEBUG: skipping state " + obs_successor_state.name + " because it was already created.")
                        
                        obs_successor_state = self.obs_automata.get_state(name: obs_successor_state.name)!
                    }
                    
                    // create the transition from 'analyzed_state' to 'obs_successor_state' with condition 'current_bitset_condition' and add it to the state 'analyzed_state'
                    
                    let transition_formula = KBSCUtils._naiveBitsetToFormula(bs: current_bitset_condition, apList: self.obs_automata.apList)
                    let new_found_transition = AutomataTransition(start: analyzed_state, condition: transition_formula, end: obs_successor_state)
                    analyzed_state.addTransition(trans: new_found_transition)
                }
                
            } while (current_bitset_condition.increment())
            
        }
        return self.obs_automata
    }

}
