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


let inputFilePrefix = "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_inputs/"



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
        if let dotGraphFilename = parguments.get(dotFile) {
            
            
            let spec = LTLSpecBuilder.prepareSynthesis(automataInfoPath: inputFilePrefix + automataInfoFilename, dotGraphPath: inputFilePrefix + dotGraphFilename, tagsAsAPs: false)
        

            let outputFilename = spec.writeJsonToDir(inputFileName: "temp_after_automata_translation", dir: getMasterSpecDirectory())
            print("Output file saved.")

            if let synt = parguments.get(synthesize), synt {
                  print("\n--------------------------------------------------")
                  print("Calling Bosy now....\n")
                  callBoSy(inputFilename: outputFilename)
              }

            exit(EXIT_SUCCESS)
        }
    }

/* Handle Argument Parser Errors */
} catch ArgumentParserError.expectedValue(let value) {
    print("Missing value for argument \(value).")
} catch ArgumentParserError.expectedArguments(let parser, let stringArray) {
    print("Parser: \(parser) Missing arguments: \(stringArray.joined()).")
} catch {
    print(error.localizedDescription)
}
