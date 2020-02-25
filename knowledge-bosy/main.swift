//
//  main.swift
//  knowledge-bosy
//
//  Created by Daniel Schäfer on 19.02.20.
//  Copyright © 2020 Daniel Schäfer. All rights reserved.
//

import Foundation


var currentDirURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

let jsonURL = URL(fileURLWithPath: CommandLine.arguments[1], relativeTo: currentDirURL)

print("loading json from path: " + jsonURL.path)

let inputFileName = jsonURL.lastPathComponent
print("input file: " + inputFileName)

do {
    let jsonData =  try Data(contentsOf: jsonURL)
    // jsonData can be used
    let decoder = JSONDecoder()
    do {
        var spec = try decoder.decode(SynthesisSpecification.self, from: jsonData)
        
        if !spec.applyTransformationRules(){
            print("ERROR: Transformation Rules could not be applied.")
            exit(EXIT_FAILURE)
        }
        
        /* handle spec here */
        spec.writeToShell()
        
        spec.writeJsonToDesktop(inputFileName: inputFileName)
        exit(EXIT_SUCCESS)
    } catch {
        print(error.localizedDescription)
    }
} catch {
    print("loading of jsonData error...")
}
