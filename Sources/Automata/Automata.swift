//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 29.04.20.
//

import Foundation


// Represents dot Graph
public class Automata {
    public var initial_states: [AutomataState]
    private var all_states: [String: AutomataState]
    public var transition_relation: [Transition]
    
    init() {
        initial_states = []
        transition_relation = []
        all_states = [String: AutomataState]()
    }
    
    // Adds state if not contained already, otherwise just skips and gives warning
    public func add_state(new_state: AutomataState) {
        if (self.all_states[new_state.name] != nil) {
            print("WARNING: tried to add State " + new_state.name + " which was already contained in Automata")
            return
        }
        self.all_states[new_state.name] = new_state
    }
    
    public func get_state(name: String) -> AutomataState? {
        return self.all_states[name]
    }
}

public class AutomataState : Hashable {
    public var name: String
    public var propositions: [AP]
    private var transitions: [Transition]
    
    public init(name: String) {
        self.name = name
        self.propositions = []
        self.transitions = []
    }
    
    public func addTransition(trans: Transition) {
        if (trans.start.name == self.name) {
            self.transitions.append(trans)
        } else {
            print("Error: Transition does not start into correct state!")
        }
    }
    
    
    public func getTransitions(state: CurrentState) -> [Transition]{
        // TODO: returns the set of applicable transitions given the currentState
        return []
    }
    
    
    // Equality of states defined over their name which has to be unique
    public static func == (state1: AutomataState, state2: AutomataState) -> Bool {
        return state1.name == state2.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}


public class Transition {
    public let start: AutomataState
    public let condition: Formula
    public let end: AutomataState
    public let action: Formula
    
    public init (start: AutomataState, condition: Formula, end: AutomataState, action: Formula) {
        self.start = start
        self.condition = condition
        self.end = end
        self.action = action
    }
}



public func readDotGraphFile(path: String) -> Automata? {
    /* Verify System requirements */
    if #available(OSX 10.11, *) {
        /* System requirements passed */
        let fileURL = URL(fileURLWithPath: path)
        print("loading dot-graph from path: " + fileURL.path)


        /* try to read input dot graph File */
        do {
            var data = try NSString(contentsOfFile: fileURL.path,
                                    encoding: String.Encoding.utf8.rawValue)

            // If a value was returned, print it.
            var content_lines = data.components(separatedBy: "\n")
            
            for i in 0...(content_lines.count - 1) {
                content_lines[i] = content_lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            // Parsing of dot graph File starts now
            var automata = Automata()
            
            // cleanup loop to remove irrelevant lines
            var index = 0
            while (index < content_lines.count - 1) {
                if (content_lines[index].contains("digraph")) {
                    content_lines.remove(at: index)
                } else {
                    index += 1
                }
            }
            
            print(content_lines[2])
            

            
            return automata
            
            
        } catch {
            /* failed to read data from given path */
            print("loading of dotGraphFile error. UTF-8 encoding expected.")
        }
    } else {
        /* failed System Requirements */
        print("ERROR: Requires at least macOS 10.11")
    }
    return nil
}
