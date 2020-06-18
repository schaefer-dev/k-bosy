//
//  ModelCheckCaller.swift
//  Automata
//
//  Created by Daniel Schäfer on 18.06.20.
//

import Foundation
import LTL


public class ModelCheckCaller {

    /**
     Returns list of Tag names
     
     Adds tags to automata and modifies the guarantees to no longer contain knowledge terms
     */
    public static func generateTagsFromGuaranteesUsingMC(automata: inout Automata) -> [String] {
        
        var tags: [String] = []
        
        
        // look for knowledge terms and replace those with tags and remember the mapping from tags to LTL content of said knowledge term
        
        
        // for every Knowledge term model check the LTL content against every node in the automata
            // if implies is true then add the tag to the AutomataState structure
        
        return tags
    }

}
