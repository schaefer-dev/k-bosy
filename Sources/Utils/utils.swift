//
//  utils.swift
//  knowledge-bosy
//
//  Created by Daniel Schäfer on 25.02.20.
//  Copyright © 2020 Daniel Schäfer. All rights reserved.
//

import Foundation

public func shell(launchPath: String, arguments: [String]) -> String {

    let process = Process()
    process.launchPath = launchPath
    process.arguments = arguments

    let pipe = Pipe()
    process.standardOutput = pipe
    process.launch()

    let output_from_command = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)!

    return output_from_command
}


public func listAllFiles(dir: URL) {
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

public func getDesktopDirectory() -> URL {
    let paths = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)
    return paths[0]
}

public func getMasterSpecDirectory() -> URL {
    let pathUrl = URL(fileURLWithPath: "/Users/daniel/uni_repos/repo_masterThesisSpecifications/kbosy_outputs/")
    return pathUrl
}

public func callBoSy(inputFilename: String) {
    //let command = "cd /Users/daniel/dev/master/bosy; swift run -c release BoSy --synthesize /Users/daniel/dev/master/bosy/Specs/kbosy_outputs/" + inputFilename
    print(shell(launchPath: "/usr/bin/env", arguments: ["Samples/bosy_call.sh", inputFilename]))
}
