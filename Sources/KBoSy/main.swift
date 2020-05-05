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
    
    let automataInfoFile = parser.add(option: "--info", shortName: "-i",
                                kind: String.self,
                                usage: "A Automata file which contains environment automata information",
                                completion: .filename)
    
    let dotFile = parser.add(option: "--dot", shortName: "-d",
                                kind: String.self,
                                usage: "A Dot Graph file which describes the behaviour of the environment. Requires automataInfo to be also given.",
                                completion: .filename)
    
    let synthesize = parser.add(option: "--synthesize",
                                kind: Bool.self,
                                usage: "enables following bosy call to synthesize transformed spec.",
                                completion: ShellCompletion.none)
    
    let argsv = Array(CommandLine.arguments.dropFirst())
    let parguments = try parser.parse(argsv)
    
    
    
    
    
    /* --------------------------------------------------------------------------------------------- */
    /* Starting of reading Automata file(s) */
    if let automataInfoFilename = parguments.get(automataInfoFile) {
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: automataInfoFilename)
        if (automataInfoOpt == nil) {
            print("ERROR: something went wrong while reading AutomataInfo File")
            exit(EXIT_FAILURE)
        }
        let automataInfo = automataInfoOpt!
        
        if let dotGraphFilename = parguments.get(dotFile) {
            let automataOpt = FileParser.readDotGraphFile(path: dotGraphFilename, info: automataInfo)
            if (automataOpt == nil) {
                print("ERROR: something went wrong while reading AutomataInfo File")
                exit(EXIT_FAILURE)
            }
            let automata = automataOpt!
        }
    }
    
    
    
    
    
    /* performing minimization of automata with following Generation of transformation rules */
    
    // TODO: implement
    
    
    
    
    /* --------------------------------------------------------------------------------------------- */
    /* Starting of reading kbosy spec file and performing translation into LTL followed by synthesis */
    
    /* Handle the passed input file */
    if let inputFilename = parguments.get(input) {
        
        let specOpt = readSpecificationFile(path: inputFilename)
        if (specOpt == nil) {
            print("ERROR: something went wrong while reading specifictaion File")
            exit(EXIT_FAILURE)
        }
        var spec = specOpt!
        
                    
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
        
        let inputFilePath = inputFilename.split(separator: "/")
        let inputFilePathLastComponent = String(inputFilePath[inputFilePath.count - 1])
        
        let outputFilename = spec.writeJsonToDir(inputFileName: inputFilePathLastComponent, dir: getMasterSpecDirectory())
        print("Output file saved.")
          
        if let synt = parguments.get(synthesize), synt {
            print("\n--------------------------------------------------")
            print("Calling Bosy now....\n")
            callBoSy(inputFilename: outputFilename)
        }
      
        exit(EXIT_SUCCESS)
        
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
