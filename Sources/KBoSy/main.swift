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


let inputFilePrefix = "/home/daniel/benchmarks/kltl_inputs/"



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

    let arg_automataInfoFile = parser.add(option: "--info", shortName: "-i",
                                kind: String.self,
                                usage: "A Automata file which contains environment automata information",
                                completion: .filename)

    let arg_dotFile = parser.add(option: "--dot", shortName: "-d",
                                kind: String.self,
                                usage: "A Dot Graph file which describes the behaviour of the environment. Requires automataInfo to be also given.",
                                completion: .filename)

    let arg_synthesize = parser.add(option: "--synthesize",
                                kind: Bool.self,
                                usage: "enables following bosy call to synthesize transformed spec.",
                                completion: ShellCompletion.none)
    
    let arg_tags = parser.add(option: "--tags", shortName: "-t",
                                kind: Bool.self,
                                usage: "enables following bosy call to synthesize transformed spec.",
                                completion: ShellCompletion.none)

    let argsv = Array(CommandLine.arguments.dropFirst())
    let parguments = try parser.parse(argsv)

    
    /* -------------------------------------------------------------*/
    /* Starting of reading Automata file(s) */
    if let automataInfoFilename = parguments.get(arg_automataInfoFile) {
        if let dotGraphFilename = parguments.get(arg_dotFile) {
            
            /**
             check if user wishes to keep tags as new inputAPs and add them to the assumptions.
             Otherwise the determined states would have been added to guarantees directly
                as a disjunciton of statenames.
             */
            var tagsAsAPs = false
            if let tagsArg = parguments.get(arg_tags), tagsArg {
                tagsAsAPs = true
            }
            
            let spec = LTLSpecBuilder.prepareSynthesis(automataInfoPath: inputFilePrefix + automataInfoFilename, dotGraphPath: inputFilePrefix + dotGraphFilename, tagsAsAPs: tagsAsAPs)
        

            let outputFilename = spec.writeJsonToDir(inputFileName: "temp_after_automata_translation", dir: getMasterSpecDirectory())
            print("Output file saved.")

            if let synt = parguments.get(arg_synthesize), synt {
                  print("\n--------------------------------------------------")
                  print("Calling Bosy now....\n")
                  callBoSy(inputFilename: outputFilename)
            }

            exit(EXIT_SUCCESS)
        }
    }
    
    
    /* Alternative input of just LTL assumptions and rewriting in spec directly using given rules */
    if let inputFilename = parguments.get(input) {
        
        let specOpt = readSpecificationFile(path: inputFilename)
        if (specOpt == nil) {
            print("ERROR: something went wrong while reading specifictaion File")
            exit(EXIT_FAILURE)
        }
        var spec = specOpt!
        
        /* Apply transformation rules that are contained in the input file.*/
        if !spec.applyTransformationRules(){
            print("ERROR: Transformation Rules could not be applied.")
            exit(EXIT_FAILURE)
        }
        
        
        let outputFilename = spec.writeJsonToDir(inputFileName: "temp_after_guarantees_transformation", dir: getMasterSpecDirectory())
        print("Output file saved.")
        
        
        
        if let synt = parguments.get(arg_synthesize), synt {
              print("\n--------------------------------------------------")
              print("Calling Bosy now....\n")
              callBoSy(inputFilename: outputFilename)
          }
        
          exit(EXIT_SUCCESS)
    }
    

/* Handle Argument Parser Errors */
} catch ArgumentParserError.expectedValue(let value) {
    print("Missing value for argument \(value).")
} catch ArgumentParserError.expectedArguments(let parser, let stringArray) {
    print("Parser: \(parser) Missing arguments: \(stringArray.joined()).")
} catch {
    print(error.localizedDescription)
}
