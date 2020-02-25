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
