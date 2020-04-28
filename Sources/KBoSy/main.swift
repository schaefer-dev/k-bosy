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
    let input = parser.add(option: "--input", shortName: "-i",
                           kind: String.self,
                           usage: "A kbosy file which contains LTL spec, assumptions and set of transformation-rules",
                           completion: .filename)
    
    let synthesize = parser.add(option: "--synthesize",
                                shortName: "-s",
                                kind: Bool.self,
                                usage: "enables following bosy call to synthesize transformed spec.",
                                completion: ShellCompletion.none)
    
    let argsv = Array(CommandLine.arguments.dropFirst())
    let parguments = try parser.parse(argsv)
    
    // TODO: generate this APList from input that specifies observable and non-observable APs
    let globalAPList = APList()
    
    // Create Sample APs
    let test_ap1 = AP(name: "test1", observable: true, list: globalAPList)
    let test_ap2 = AP(name: "test2", observable: true, list: globalAPList)
    let test_ap3 = AP(name: "test3", observable: false, list: globalAPList)
    
    
    // Create Sample Variables that may occur in a formula, they are linked to APs
    var lit1: Literal = Variable(negated: true, atomicProposition: test_ap1)
    var lit2: Literal = Variable(negated: true, atomicProposition: globalAPList.lookupAP(apName: "test2")!)
    var lit3: Literal = Variable(negated: false, atomicProposition: globalAPList.lookupAP(apName: "test3")!)
    // Create Sample Constats that may occur in a formula
    var lit4: Literal = Constant(negated: true, truthValue: true)
    var lit5: Literal = Constant(negated: false, truthValue: false)
    print(lit1.toString())
    print(lit2.toString())
    print(lit3.toString())
    print(lit4.toString())
    print(lit5.toString())
    
    
    var currentState = CurrentState()
    currentState.update_value(ap: test_ap1, value: true)
    currentState.update_value(ap: test_ap2, value: false)
    currentState.update_value(ap: test_ap3, value: true)
    print("written with values: true, false, true")
    
    
    print("resulted in eval result:")
    print(lit1.eval(state: currentState))
    print(lit2.eval(state: currentState))
    print(lit3.eval(state: currentState))
    print(lit4.eval(state: currentState))
    print(lit5.eval(state: currentState))
    
    
    
    
    
    print("Early Termination during testing")
    exit(EXIT_SUCCESS)
    
    
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
        print("ERROR: Input file has to be specified!")
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
