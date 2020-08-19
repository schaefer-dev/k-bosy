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

    let outputFromCommand = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: String.Encoding.utf8)!

    return outputFromCommand
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
    if let output_dir = ProcessInfo.processInfo.environment["KBOSY_OUTPUT_DIR"] {
        let pathUrl = URL(fileURLWithPath: output_dir)
        return pathUrl
    } else {
        print("Environment Variable 'KBOSY_OUTPUT_DIR' not set!")
        exit(EXIT_FAILURE)
    }
}

public func callBoSy(inputFilename: String, benchmarkEnabled: Bool = false) {
    //let command = "cd /Users/daniel/dev/master/bosy; swift run -c release BoSy --synthesize /Users/daniel/dev/master/bosy/Specs/kbosy_outputs/" + inputFilename
    if let output_dir = ProcessInfo.processInfo.environment["KBOSY_ROOT_DIR"] {
        print("Calling Bosy using:")
        print(output_dir + "/bosy_run.sh " + inputFilename + " --synthesize\n")
        if benchmarkEnabled {
            let bosyBenchmark = Benchmark(name: "BoSy()")
            bosyBenchmark.start()
            print(shell(launchPath: "/usr/bin/env", arguments: [output_dir + "/bosy_run.sh", inputFilename, "--synthesize"]))
            bosyBenchmark.stop()
            bosyBenchmark.report()
        } else {
            print(shell(launchPath: "/usr/bin/env", arguments: [output_dir + "/bosy_run.sh", inputFilename, "--synthesize"]))
        }
    } else {
        print("Environment Variable 'KBOSY_ROOT_DIR' not set!")
        exit(EXIT_FAILURE)
    }
    
}
