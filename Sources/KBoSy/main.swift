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

                    /* Apply transformation rules that are contained in the input file.*/
                    if !spec.applyTransformationRules(){
                        print("ERROR: Transformation Rules could not be applied.")
                        exit(EXIT_FAILURE)
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
