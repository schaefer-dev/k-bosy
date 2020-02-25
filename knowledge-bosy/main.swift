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

do {
    let jsonData =  try Data(contentsOf: jsonURL)
    // jsonData can be used
    let decoder = JSONDecoder()
    do {
        let spec = try decoder.decode(SynthesisSpecification.self, from: jsonData)
        
        /* handle spec here */
        spec.writeToShell()
        
    } catch {
        print(error.localizedDescription)
    }
} catch {
    print("loading of jsonData error...")
}
