//
//  main.swift
//  knowledge-bosy
//
//  Created by Daniel Schäfer on 19.02.20.
//  Copyright © 2020 Daniel Schäfer. All rights reserved.

import Foundation
import SPMUtility
import Utils
import Specification
import Automata

do {
    /* Create Argument Parser */
    let parser = ArgumentParser(commandName: "ap",
                                usage: "ap",
                                overview: "The command is used for argument parsing",
                                seeAlso: "getopt(1)")
    
    /* Specify arguments that can be parsed */
    let input = parser.add(option: "--spec", shortName: "-s",
                           kind: String.self,
                           usage: "A kbosy file which contains LTL spec, assumptions and set of transformation-rules",
                           completion: .filename)
    
    let automataFile = parser.add(option: "--info", shortName: "-i",
                                kind: String.self,
                                usage: "A Automata file which contains environment automata information",
                                completion: .filename)
    
    let dotFile = parser.add(option: "--dot", shortName: "-d",
                                kind: String.self,
                                usage: "A Dot Graph file which describes the behaviour of the environment",
                                completion: .filename)
    
    let synthesize = parser.add(option: "--synthesize",
                                kind: Bool.self,
                                usage: "enables following bosy call to synthesize transformed spec.",
                                completion: ShellCompletion.none)
    
    let argsv = Array(CommandLine.arguments.dropFirst())
    let parguments = try parser.parse(argsv)
    
    
    if let automataFilename = parguments.get(automataFile) {
        
        /* Verify System requirements */
        if #available(OSX 10.11, *) {
            /* System requirements passed */
            let jsonURL = URL(fileURLWithPath: automataFilename)
            print("loading json from path: " + jsonURL.path)


            /* try to read input JSON File */
            do {
                let jsonData =  try Data(contentsOf: jsonURL)
                print("File data read.")
                // jsonData can be used
                let decoder = JSONDecoder()
                do {
                    var automataInfo = try decoder.decode(AutomataInfo.self, from: jsonData)
                    print("Decoding completed.")
                    
                    // TODO: continue to work with automata info read from json
                    // TODO: read dot graph here
                    // TODO: using automataInfo and DotGraph construct automata class which contains all this information. Afterwards free the ressources used by the prior two.
                    
                    
                    
                    
                    
                    
                    
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
            exit(EXIT_FAILURE)
        }
    }
    
    
    
    /* --------------------------------------------------------------------------------------------- */
    /* Starting of reading kbosy spec file and performing translation into LTL followed by synthesis */
    
    /* Handle the passed input file */
    if let inputFilename = parguments.get(input) {
        
        /* Verify System requirements */
        if #available(OSX 10.11, *) {
            /* System requirements passed */
            let jsonURL = URL(fileURLWithPath: inputFilename)
            print("loading json from path: " + jsonURL.path)


            /* try to read input JSON File */
            do {
                let jsonData =  try Data(contentsOf: jsonURL)
                print("File data read.")
                // jsonData can be used
                let decoder = JSONDecoder()
                do {
                    var spec = try decoder.decode(SynthesisSpecification.self, from: jsonData)
                    print("Decoding completed.")
                    
                    print("Guarantees before transformation rules:")
                    for g in spec.guarantees {
                        print(g.description)
                    }

                    /* Apply transformation rules that are contained in the input file.*/
                    if !spec.applyTransformationRules(){
                        print("ERROR: Transformation Rules could not be applied.")
                        exit(EXIT_FAILURE)
                    }
                    
                    print("Guarantees after transformation rules:")
                    for g in spec.guarantees {
                        print(g.description)
                    }
                      
                    let outputFilename = spec.writeJsonToDir(inputFileName: jsonURL.lastPathComponent, dir: getMasterSpecDirectory())
                    print("Output file saved.")
                      
                    if let synt = parguments.get(synthesize), synt {
                        print("\n--------------------------------------------------")
                        print("Calling Bosy now....\n")
                        callBoSy(inputFilename: outputFilename)
                    }
                  
                    exit(EXIT_SUCCESS)
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
            exit(EXIT_FAILURE)
        }
        
        
        
        
    /* --input argument has not been specified */
    } else {
        print("No Specification file for following synthesis has been given!")
        exit(EXIT_FAILURE)
    }

/* Handle Argument Parser Errors */
} catch ArgumentParserError.expectedValue(let value) {
    print("Missing value for argument \(value).")
} catch ArgumentParserError.expectedArguments(let parser, let stringArray) {
    print("Parser: \(parser) Missing arguments: \(stringArray.joined()).")
} catch {
    print(error.localizedDescription)
}
