//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 01.06.20.
//

import Foundation


public class AutomataKBSC {

    public static func constructObservableAutomataKBSC(input_automata: Automata) -> Automata {
        
        // states and aplist now only contain observable or output propositions.
        input_automata._reduceToObservablePart()
        input_automata.finalize()
        
        var (obs_automata, new_to_old_states_mapping) = _createObservableAutomataWithInitialStateSetup(input_automata: input_automata)
        
        
        // only initial states exist currently, we have to analyze all those states
        var state_analyze_queue: [AutomataState] = obs_automata.initial_states
        
        // repeat until all states have been analyzed
        while (state_analyze_queue.count > 0) {
            let analyzed_state = state_analyze_queue.removeFirst()
            print("DEBUG: analyzing state '" + analyzed_state.description + "' in obs Automata now.")
            
            // Builds the Transitions in `new_state` according to the behaviour in the old corresponding states given in `old_states`.
            
            let bitset_ap_index_map = obs_automata.apList.get_bitset_ap_index_map()
            let current_bitset_condition = Bitset(size: bitset_ap_index_map.count, truth_value: false)
            
            // check behaviour for current_bitset_condition until all possible combination of truth values have been checked. This is the case whenever the bitset can no longer be incremented.
            repeat {
                // lookup old states that were merged into the currently analyzed state
                let old_states: [AutomataState] = new_to_old_states_mapping[analyzed_state]!
                
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
                let obs_eq_state_classes = _divideStatesByAPs(input_states: old_states_successors)
                
                for obs_eq_state_set in obs_eq_state_classes {
                    // TODO: minor optimization: check before creating new state if it already exists
                    var obs_successor_state = mergeStates(states: obs_eq_state_set)
                    if obs_automata.get_state(name: obs_successor_state.name) == nil {
                        // obs_successor_state is in fact new and thus has to be added to the obs automata structures
                        new_to_old_states_mapping[obs_successor_state] = obs_eq_state_set
                        print("DEBUG: newly discovered state " + obs_successor_state.name + " added to observational automata.")
                        obs_automata.add_state(new_state: obs_successor_state)
                        
                        // also we have to put in in the queue to observe its possible successors later
                        state_analyze_queue.append(obs_successor_state)
                    } else {
                        // new_successor_state is not new -> abort newly created state and move reference to the already existing one such that the transition links to the correct state
                        print("DEBUG: skipping state " + obs_successor_state.name + " because it was already created.")
                        
                        obs_successor_state = obs_automata.get_state(name: obs_successor_state.name)!
                    }
                    
                    // create the transition from 'analyzed_state' to 'obs_successor_state' with condition 'current_bitset_condition' and add it to the state 'analyzed_state'
                    
                    let transition_formula = _naiveBitsetToFormula(bs: current_bitset_condition, apList: obs_automata.apList)
                    let new_found_transition = AutomataTransition(start: analyzed_state, condition: transition_formula, end: obs_successor_state)
                    analyzed_state.addTransition(trans: new_found_transition)
                }
                
            } while (current_bitset_condition.increment())
            
        }
        return obs_automata
    }
    
    /**
     Naive implementation that generates Formula from bitset
     
     TODO: lots of improvement potential here
     */
    public static func _naiveBitsetToFormula(bs: Bitset, apList: APList) -> Formula {
        // build array that contains all APs in the order of their indices in the bitmap
        // TODO store this array in APList and update it whenever an AP gets added!
        
        let ap_index_map = apList.get_bitset_ap_index_map()
        var bitset_ap_mapping = [String](repeating: "", count: ap_index_map.count)
       
        for (ap_str, ap_bitmap_index) in ap_index_map {
            bitset_ap_mapping[ap_bitmap_index] = ap_str
        }
        
        let bitset_as_formula_string = bs.get_conjunction_string(bitset_ap_mapping: bitset_ap_mapping)
        
        let formula = FormulaParser.parseDNFFormula(input_str: bitset_as_formula_string, apList: apList)
        
        return formula!
    }
    
    
    /**
     Devides the given set of input_states into different sets of states. Every given state will only contain in ONE of those sets. Every state that is contained in the same set than another state has to share all his (observable) APs with that state he is in the same set with.
     
     The minimal number of Sets is guaranteed to be returned (minimum amount of observational equivalence classes required).
     */
    public static func _divideStatesByAPs(input_states: [AutomataState]) -> [[AutomataState]] {
        var obs_eq_state_mapping = [[AP] : [AutomataState]]()
        
        // TODO: order matters so we have to make sure that list of APs contained in every state is sorted!!
        // use dictionary to track the states that share the same list of APs
        for input_state in input_states {
            var obs_eq_states = obs_eq_state_mapping.removeValue(forKey: input_state.propositions)
            if (obs_eq_states == nil) {
                // no state list was setup here until now
                obs_eq_state_mapping[input_state.propositions] = [input_state]
            } else {
                // state list already existed, add this state to this list
                obs_eq_states!.append(input_state)
                obs_eq_state_mapping[input_state.propositions] = obs_eq_states
            }
        }
        
        var return_array: [[AutomataState]] = []
        
        for (_, obs_eq_states) in obs_eq_state_mapping {
            return_array.append(obs_eq_states)
        }
        
        return return_array
    }
    
    
    public static func _createObservableAutomataWithInitialStateSetup(input_automata: Automata) -> (Automata, [AutomataState: [AutomataState]]) {
        let new_apList = input_automata.apList
        
        var new_all_states = [String: AutomataState]()
        
        // Merge previous initial states into one state
        // TODO: think later about this 'limitation' is reasonable. Not sure if different observable APs in different initial states can already be used to distinguish in which state the environment currently is
        let new_initial_state = mergeStates(states: input_automata.initial_states)
        let new_initial_states: [AutomataState] = [new_initial_state]
        new_all_states[new_initial_state.name] = new_initial_state
        
        var new_to_old_states_mapping = [AutomataState: [AutomataState]]()
        new_to_old_states_mapping[new_initial_state] = input_automata.initial_states
        
        let obs_automata = Automata(apList: new_apList, initial_states: new_initial_states, all_states: new_all_states, guarantees: input_automata.guarantees)
        
        
        return (obs_automata, new_to_old_states_mapping)
    }
    
    
    public static func getObservableAPList(input_list: APList) -> APList {
        let new_apList = APList()
        
        // add all non-hidden APs
        for ap in input_list.get_allAPs() {
            if ap.obs || ap.output {
                new_apList.addAP(ap: ap)
            }
        }
        
        return new_apList
    }
    
    
    /**
     Returns new state resulting from the merging of n > 0 States
     Name of the new state = (s1.name + s2.name + s3.name + ....) with the names sorted (so its unique).
     
     Verifies that it makes sense to merge these states by requireing that the APs in all original states are equal
     */
    public static func mergeStates(states: [AutomataState]) -> AutomataState {
        
        assert(states.count > 0)
        
        // states can only be merged if they have the same observable APs (because otherwise we could distinguish them and they could never be combined into one state during KBSC)
        let required_propositions = states[0].propositions
        var source_state_names: [String] = []
        for state in states {
            assert(required_propositions == state.propositions, "states with different APs attempted to be merged")
            source_state_names.append(state.name)
        }
        
        let new_state_name = constructStateName(source_names: source_state_names)
        
        
        // create new state that represents the marged state
        let new_state = AutomataState(name: new_state_name, propositions: required_propositions)
        
        return new_state
    }
    
    /**
     Helper function that constructs unique state name whenever a set of states is merged to identify that merged state
     */
    private static func constructStateName(source_names: [String]) -> String {
        // build new state name with sorting on contained state-names so we maintain correctness
        var new_state_name_set = Set<String>()
        var new_state_name_array : [String] = []
        
        for name in source_names {
            let contained_numbers = name.split(separator: "s")
            for number in contained_numbers {
                let number_string = String(number)
                if !new_state_name_set.contains(number_string) {
                    new_state_name_set.insert(number_string)
                    new_state_name_array.append(number_string)
                }
            }
        }
        let new_state_name = "s" + new_state_name_array.sorted().joined(separator: "s")
        return new_state_name
    }

}
