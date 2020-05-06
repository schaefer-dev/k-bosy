//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 05.05.20.
//

import Foundation


public class FileParser {

    
    /**
    Attempts to parse a AutomataInfo File which corresponds to the structure specified in the 'InputAutomataInfo' class. This file adheres to the JSON standart.
    
    - Parameter path: the String that describes the path to the AutomataInfo File given in json form.
    
    - Returns: Optional Representation of InfoAutomataInfo file.
    */
    public static func readAutomataInfoFile(path: String) -> InputAutomataInfo? {
        /* Verify System requirements */
        if #available(OSX 10.11, *) {
            /* System requirements passed */
            let jsonURL = URL(fileURLWithPath: path)
            //print("loading json from path: " + jsonURL.path)


            /* try to read input JSON File */
            do {
                let jsonData =  try Data(contentsOf: jsonURL)
                //print("File data read.")
                // jsonData can be used
                let decoder = JSONDecoder()
                do {
                    let automataInfo = try decoder.decode(InputAutomataInfo.self, from: jsonData)
                    //print("AutomataInfoDecoding completed.")
                    return automataInfo
                    
                    
                } catch {
                    /* failed to decode content of jsonData */
                    print("ERROR during Decoding: " + error.localizedDescription)
                }
            } catch {
                /* failed to read data from jsonURL */
                print("loading of jsonData error...")
            }
        } else {
            /* failed System Requirements */
            print("ERROR: Requires at least macOS 10.11")
        }
        return nil
    }
    
    
    /**
     Attempts to parse a Text file describing a dot graph. This dot graph describes the Automata which describes the possible behaviour of the environment.
   
     - Parameter path: the String that describes the path to the AutomataInfo File given in json form.
     - Parameter info: the InputAutomataInfo which was previously read using the 'readAutomataInfoFile' method. This Structure contains additional information that is required to generate the returned Automata structure.
     
     - Returns: Optional Automata class, which contains all relevant information, rendering the InputAutomataInfo now redundant.
    */
    public static func readDotGraphFile(path: String, info: InputAutomataInfo) -> Automata? {
        /* Verify System requirements */
        if #available(OSX 10.11, *) {
            /* System requirements passed */
            let fileURL = URL(fileURLWithPath: path)
            print("loading dot-graph from path: " + fileURL.path)


            /* try to read input dot graph File */
            do {
                let data = try NSString(contentsOfFile: fileURL.path,
                                        encoding: String.Encoding.utf8.rawValue)

                // If a value was returned, print it.
                var content_lines = data.components(separatedBy: ";")
                
                for i in 0...(content_lines.count - 1) {
                    content_lines[i] = content_lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                // Parsing of dot graph File starts now
                let automata = Automata(info: info)
                
                // cleanup loop to remove irrelevant lines
                var index = 0
                while (index < content_lines.count - 1) {
                    // Condition to find initial state marker
                    if (content_lines[index].contains("_init -> ")){
                        let substrings = content_lines[index].components(separatedBy: " -> ")
                        let right_substrings = substrings[1].split(separator: "[")
                        let initial_state_name = right_substrings[0].trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        let new_initial_state = AutomataState(name: initial_state_name)
                        automata.add_initial_state(new_initial_state: new_initial_state)
                    } else {
                        // Condition to find transition description line
                        if (wildcard(content_lines[index], pattern: "?* -> ?*")) {
                            //print("DEBUG: Transition found in Statement " + String(index + 1))
                            let substrings = content_lines[index].components(separatedBy: " -> ")
                            let start_state = substrings[0].trimmingCharacters(in: .whitespacesAndNewlines)
                            let right_substrings = substrings[1].components(separatedBy: "[")
                            let goal_state = right_substrings[0].trimmingCharacters(in: .whitespacesAndNewlines)
                            let right_sub_substrings = right_substrings[1].components(separatedBy: "\"")
                            let equation = right_sub_substrings[1].trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            automata.parseAndAddTransition(start_str: start_state, end_str: goal_state, condition: equation)
                        }
                    }
                    index += 1
                }
                return automata
            
            } catch {
                /* failed to read data from given path */
                print("loading of dotGraphFile error. UTF-8 encoding expected.")
                exit(EXIT_FAILURE)
            }
        } else {
            /* failed System Requirements */
            print("ERROR: Requires at least macOS 10.11")
            exit(EXIT_FAILURE)
        }
        return nil
    }
    
    
}
