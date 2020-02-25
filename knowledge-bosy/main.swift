//
//  main.swift
//  knowledge-bosy
//
//  Created by Daniel Schäfer on 19.02.20.
//  Copyright © 2020 Daniel Schäfer. All rights reserved.
//

import Foundation

let currentDirURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
print("currently in dir: " + currentDirURL.path)

// let jsonURL = URL(fileURLWithPath: CommandLine.arguments[1], relativeTo: currentDirURL)

if let specPath = Bundle.main.url(forResource: "simple_arbiter", withExtension: "bosy") {
    
    let jsonURL = URL(fileURLWithPath: specPath.path)
    print("loading json from path: " + jsonURL.path)
    
    do {
        let jsonData =  try Data(contentsOf: jsonURL)
        // jsonData can be used
        let decoder = JSONDecoder()
        do {
            let spec = try decoder.decode(SynthesisSpecification.self, from: jsonData)
        } catch {
            print(error.localizedDescription)
        }
    } catch {
        print("loading of jsonData error...")
    }
    
} else {
    print("file was not found in Bundle")
}

print(shell(launchPath: "/usr/bin/env", arguments: ["ls", "knowledge-bosy"]))
