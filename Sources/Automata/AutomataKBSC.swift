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
        
        let (obs_automata, new_to_old_states_mapping) = _createObservableAutomataWithInitialStateSetup(input_automata: input_automata)
        
        
        // only initial states exist currently, we have to analyze all those states
        var state_analyze_queue: [AutomataState] = obs_automata.initial_states
        
        // repeat until all states have been analyzed
        while (state_analyze_queue.count > 0) {
            let analyzed_state = state_analyze_queue.removeFirst()
            
            // Builds the Transitions in `new_state` according to the behaviour in the old corresponding states given in `old_states`.
            
            let bitset_ap_index_map = obs_automata.apList.get_bitset_ap_index_map()
            var current_bitset_condition = Bitset(size: bitset_ap_index_map.count, truth_value: false)
            
        }
        
        return obs_automata
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
