//
//  main.swift
//  knowledge-bosy
//
//  Created by Daniel Schäfer on 19.02.20.
//  Copyright © 2020 Daniel Schäfer. All rights reserved.
//

import Foundation




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


if let jsonData = jsonString.data(using: .utf8)
{
    // jsonData can be used
    let decoder = JSONDecoder()
    do {
        let spec = try decoder.decode(SynthesisSpecification.self, from: jsonData)
        print(spec.outputs)
    } catch {
        print(error.localizedDescription)
    }
} else {
    print("loading of jsonData error...")
}
