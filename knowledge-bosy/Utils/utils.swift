//
//  utils.swift
//  knowledge-bosy
//
//  Created by Daniel Schäfer on 25.02.20.
//  Copyright © 2020 Daniel Schäfer. All rights reserved.
//

import Foundation

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


func listAllFiles(dir: URL) {
    /* try to list all files in directory */
    let fileManager = FileManager.default
    print("currently in dir: " + dir.path)

    do {
        let fileURLs = try fileManager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
        print(fileURLs)
    } catch {
        print("Error while enumerating files \(dir.path): \(error.localizedDescription)")
    }
    
}
