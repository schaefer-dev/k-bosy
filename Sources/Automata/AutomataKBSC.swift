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
        
        let new_apList = input_automata.apList
        
        let new_all_states = [String: AutomataState]()
        
        // CAREFUL: states are references here, which means that changes in states are also reflected in the original input_automata because it uses the same state references!
        var new_initial_states: [AutomataState] = []
        for old_initial_state in input_automata.initial_states {
            new_initial_states.append(old_initial_state)
        }
        
        
        let obs_automata = Automata(apList: new_apList, initial_states: new_initial_states, all_states: new_all_states, guarantees: input_automata.guarantees)
        
        return obs_automata
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
     Merging of 2 States following the KBSC algorithm.
     Name of the new state = (s1.name + s2.name) with the names sorted (so its unique).
     
     Adds resulting new state to 'target_automata' and returns list of new nodes that have to be analyzed using the algorithm
     */
    public static func mergeStates(s1: AutomataState, s2: AutomataState, target_automata: Automata) -> [AutomataState] {
        // states can only be merged if they are not the same state, but still have the same APs (because otherwise we could distinguish them)
        assert(s1.name != s2.name)
        assert(s1.propositions == s2.propositions)
        
        var todo_analyze_state_queue: [AutomataState] = []
        
        // build new state name with sorting on contained state-names so we maintain correctness
        let new_state_name_array = (s1.name.split(separator: "s") + s2.name.split(separator: "s")).sorted()
        let new_state_name = "s" + new_state_name_array.joined(separator: "s")
        
        
        let new_state = AutomataState(name: new_state_name, propositions: s1.propositions)
        
        
        // TODO: go through all transitions of s1 and for each try to merge them with all of the transitions in s2
        for trans1 in s1.transitions {
            for trans2 in s2.transitions {
                let new_state_opt = mergeTransitions(t1: trans1, t2: trans2, new_start_state: new_state)
            }
        }
        
        // TODO
        
        return todo_analyze_state_queue
    }
    
    
    public static func mergeTransitions(t1: AutomataTransition, t2: AutomataTransition, new_start_state: AutomataState) -> AutomataState? {
        
        return nil
        
        // TODO implment
    }

}
