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


func shell(launchPath: String, arguments: [String]) -> String {

    let process = Process()
    process.launchPath = launchPath
    process.arguments = arguments

    let pipe = Pipe()
    process.standardOutput = pipe
    process.launch()

    let output_from_command = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)!

    return output_from_command
}

let output = shell(launchPath: "/usr/bin/env", arguments: ["ls"])
print(output)

let jsonURL = URL(fileURLWithPath: CommandLine.arguments[1], relativeTo: currentDirURL)
print("loading json from path: " + jsonURL.path)


let jsonString = """
{
    "semantics": "mealy",
    "inputs": ["r_0", "r_1", "r_2"],
    "outputs": ["g_0", "g_1", "g_2"],
    "assumptions": [],
    "guarantees": [
        "G ((!g_0 || ! g_1) && (!g_0 || !g_2) && (!g_1 || !g_2))",
            "G (r_0 -> F g_0)",
            "G (r_1 -> F g_1)",
            "G (r_2 -> F g_2)",
    ]
}
"""


// if let jsonData = jsonString.data(using: .utf8)
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
