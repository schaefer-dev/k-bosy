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
                var contentLines = data.components(separatedBy: ";")

                for i in 0...(contentLines.count - 1) {
                    contentLines[i] = contentLines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                }

                // Parsing of dot graph File starts now
                let automata = Automata(info: info)

                // cleanup loop to remove irrelevant lines
                var index = 0
                while index < contentLines.count - 1 {
                    // Condition to find initial state marker
                    if contentLines[index].contains("_init -> ") {
                        let substrings = contentLines[index].components(separatedBy: " -> ")
                        let rightSubstrings = substrings[1].split(separator: "[")
                        let initialStateName = rightSubstrings[0].trimmingCharacters(in: .whitespacesAndNewlines)

                        let newInitialState = AutomataState(name: initialStateName, propositions: [])
                        automata.add_initial_state(newInitialState: newInitialState)
                    } else {
                        // Condition to find transition description line
                        if wildcard(contentLines[index], pattern: "??*->??*") {
                            print("PARSING: Transition found in Statement " + String(index + 1))
                            let substrings = contentLines[index].components(separatedBy: "->")
                            let startState = substrings[0].trimmingCharacters(in: .whitespacesAndNewlines)
                            let rightSubstring = substrings[1].components(separatedBy: "[")
                            let goalState = rightSubstring[0].trimmingCharacters(in: .whitespacesAndNewlines)
                            let rightSubSubstring = rightSubstring[1].components(separatedBy: "\"")
                            let equation = rightSubSubstring[1].trimmingCharacters(in: .whitespacesAndNewlines)

                            automata.parseAndAddTransition(startString: startState, endString: goalState, condition: equation)
                        } else {
                            // if wildcard does not match we may be looking at a state description
                            if (wildcard(contentLines[index], pattern: "*[*label=\"{*}\"*]*")) {
                                // matches state description line according to wildcard
                                let substrings = contentLines[index].components(separatedBy: "\"")
                                var formulaSubstring = substrings[1].trimmingCharacters(in: .whitespacesAndNewlines)
                                let leftSubstring = substrings[0].components(separatedBy: "[")
                                let statenameSubstring = leftSubstring[0].trimmingCharacters(in: .whitespacesAndNewlines)

                                // print("DEBUG: Parser found APs " + formula_substring + " in state " + statename_substring)

                                // Remove brackets
                                formulaSubstring.removeLast()
                                formulaSubstring.removeFirst()
                                formulaSubstring = formulaSubstring.trimmingCharacters(in: .whitespacesAndNewlines)

                                let formulaElementList = formulaSubstring.components(separatedBy: ",")

                                var apList: [AP] = []
                                for apString in formulaElementList {
                                    // do not handle empty string
                                    if apString == "" {
                                        continue
                                    }
                                    let apOpt = automata.apList.lookupAP(apName: apString.trimmingCharacters(in: .whitespacesAndNewlines))
                                    if apOpt == nil {
                                        print("Parsing Error: State contained AP '" + apString + "' which was not previously defined.")
                                    } else {
                                        apList.append(apOpt!)
                                    }
                                }

                                // If state already created (e.g. is initial state, add the missing APs to it
                                let stateAlreadyThereOpt = automata.get_state(name: statenameSubstring)
                                if stateAlreadyThereOpt == nil {
                                    // create state because does not exist yet
                                    let newState = AutomataState(name: statenameSubstring, propositions: apList)
                                    automata.add_state(newState: newState)
                                } else {
                                    // State already exists in automata, so we only add the APs to it
                                    let state = stateAlreadyThereOpt!
                                    state.addAPs(aps: apList)
                                }

                            }
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
