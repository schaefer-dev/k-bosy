//
//  main.swift
//  knowledge-bosy
//
//  Created by Daniel Schäfer on 19.02.20.
//  Copyright © 2020 Daniel Schäfer. All rights reserved.
//

import Foundation
import SPMUtility



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
      /* Input filename has been specified, Figure out URL of cwd and then path of input json file */
      var currentDirURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
      let jsonURL = URL(fileURLWithPath: inputFilename, relativeTo: currentDirURL)
      print("loading json from path: " + jsonURL.path)

      
      /* try to read input JSON File */
      do {
          let jsonData =  try Data(contentsOf: jsonURL)
          // jsonData can be used
          let decoder = JSONDecoder()
          do {
              var spec = try decoder.decode(SynthesisSpecification.self, from: jsonData)
              
              /* Apply transformation rules that are contained in the input file.*/
              if !spec.applyTransformationRules(){
                  print("ERROR: Transformation Rules could not be applied.")
                  exit(EXIT_FAILURE)
              }
              
              spec.writeJsonToDesktop(inputFileName: jsonURL.lastPathComponent)
              
              if let synt = parguments.get(synthesize), synt {
                  print("Calling Bosy now....")
                  // TODO: call Bosy here with the newly written json file
              }
              
              exit(EXIT_SUCCESS)
          } catch {
              print(error.localizedDescription)
          }
      } catch {
          print("loading of jsonData error...")
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
