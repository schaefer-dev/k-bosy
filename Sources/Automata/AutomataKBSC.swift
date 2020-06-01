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
        input_automata.reduceToObservablePart()
        
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
     perform Knowledge based subset construction with the given initial states to output automata structure that contains only the observable part
     */
    public static func knowledgeBasedSubsetConstruction(old_initial_states: [AutomataState], old_states: [String: AutomataState]) -> ([AutomataState], [String: AutomataState]) {
        
        // TODO: make sure to fix transitions that contain non-observable APs - make sure that all cases are covered because these values may be either true or false at any point in time!
        
        return (old_initial_states, old_states)
    }

}
