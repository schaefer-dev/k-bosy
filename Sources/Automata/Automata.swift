//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 29.04.20.
//

import Foundation


// Represents dot Graph
public class Automata {
    
}

public struct AutomataState {
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
}



public func readDotGraphFile(path: String) -> Automata? {
    /* Verify System requirements */
    if #available(OSX 10.11, *) {
        /* System requirements passed */
        let fileURL = URL(fileURLWithPath: path)
        print("loading json from path: " + fileURL.path)


        /* try to read input JSON File */
        do {
            let fileData =  try Data(contentsOf: fileURL)
            print("File data read.")
            
            
            // TODO: create Automata structure here from dot graph content inside fileData
            print("TODO: Dot Graph reading not yet implemented.")
            var automata = Automata()
            return automata
            
            
        } catch {
            /* failed to read data from jsonURL */
            print("loading of dotGraphFile error...")
        }
    } else {
        /* failed System Requirements */
        print("ERROR: Requires at least macOS 10.11")
    }
    return nil
}
