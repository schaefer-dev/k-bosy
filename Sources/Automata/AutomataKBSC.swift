//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 01.06.20.
//

import Foundation


public class AutomataKBSC {

    public static func getObservableAutomata(input_automata: Automata) -> Automata? {
        
        
        let new_apList = getObservableAPList(input_list: input_automata.apList)
        
        return nil
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

}
