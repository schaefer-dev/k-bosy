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
    //public var transition_relation: [Transition]
    
    init() {
        initial_states = []
        //transition_relation = []
        all_states = [String: AutomataState]()
    }
    
    // Adds initial state if not contained already, otherwise just skips and gives warning
    public func add_initial_state(new_initial_state: AutomataState) {
        if (self.all_states[new_initial_state.name] != nil) {
            print("WARNING: tried to add new initial State " + new_initial_state.name + " which was already contained in Automata")
            return
        }
        self.all_states[new_initial_state.name] = new_initial_state
        self.initial_states.append(new_initial_state)
        print("DEBUG: added initial state " + new_initial_state.name + " to Automata")
    }
    
    // Adds non-initial state if not contained already, otherwise just skips and gives warning
    public func add_state(new_state: AutomataState) {
        if (self.all_states[new_state.name] != nil) {
            print("WARNING: tried to add State " + new_state.name + " which was already contained in Automata")
            return
        }
        self.all_states[new_state.name] = new_state
        print("DEBUG: added state " + new_state.name + " to Automata")
    }
    
    public func get_state(name: String) -> AutomataState? {
        return self.all_states[name]
    }
    
    
    
    
    public func addTransition(start_str: String, end_str: String, condition: String) {
        let startStateOpt = self.get_state(name: start_str)
        let endStateOpt = self.get_state(name: end_str)

        // Create startState if non existant
        if (startStateOpt == nil) {
            let startState = AutomataState(name: start_str)
            self.add_state(new_state: startState)
        }

        // Create endState if non existant
        if (endStateOpt == nil) {
           let endState = AutomataState(name: end_str)
           self.add_state(new_state: endState)
        }
        
        // after adding them we know that bost states must exist now
        let startState = self.get_state(name: start_str)!
        let endState = self.get_state(name: end_str)!


        // TODO: parse condition into Transition Class
        print("TODO: parse " + condition)
        let condition = Formula(containedConjunctions: [])
        let action = Formula(containedConjunctions: [])
        
        // Create transition and add to start state
        let new_transition = Transition(start: startState, condition: condition, end: endState, action: action)
        startState.addTransition(trans: new_transition)
    }
}



public class AutomataState : Hashable {
    public var name: String
    public var propositions: [AP]
    public var transitions: [Transition]
    
    public init(name: String) {
        self.name = name
        self.propositions = []
        self.transitions = []
    }
    
    public func getApplicableTransitions(state: CurrentState) -> [Transition]{
        // TODO: returns the set of applicable transitions given the currentState
        return []
    }
    
    public func addTransition(trans: Transition) {
        // TODO: maybe check first if this exact transition is already contained
        if (trans.start.name != self.name) {
            print("Critical Error: Transition does not belong into this state")
            exit(EXIT_FAILURE)
        }
        self.transitions.append(trans)
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
    
    // Creates Transition and adds itself to Automata and correct states
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
            var content_lines = data.components(separatedBy: ";")
            
            for i in 0...(content_lines.count - 1) {
                content_lines[i] = content_lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            // Parsing of dot graph File starts now
            var automata = Automata()
            
            // cleanup loop to remove irrelevant lines
            var index = 0
            while (index < content_lines.count - 1) {
                // Condition to find initial state marker
                if (content_lines[index].contains("_init -> ")){
                    let substrings = content_lines[index].components(separatedBy: " -> ")
                    let right_substrings = substrings[1].split(separator: "[")
                    let initial_state_name = right_substrings[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    var new_initial_state = AutomataState(name: initial_state_name)
                    automata.add_initial_state(new_initial_state: new_initial_state)
                } else {
                    // Condition to find transition description line
                    if (wildcard(content_lines[index], pattern: "?* -> ?*")) {
                        print("DEBUG: Transition found in Statement " + String(index + 1))
                        let substrings = content_lines[index].components(separatedBy: " -> ")
                        let start_state = substrings[0].trimmingCharacters(in: .whitespacesAndNewlines)
                        let right_substrings = substrings[1].components(separatedBy: "[")
                        let goal_state = right_substrings[0].trimmingCharacters(in: .whitespacesAndNewlines)
                        let right_sub_substrings = right_substrings[1].components(separatedBy: "\"")
                        let equation = right_sub_substrings[1].trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        automata.addTransition(start_str: start_state, end_str: goal_state, condition: equation)
                    }
                }
                index += 1
            }
            

            
            return automata
            
            
        } catch {
            /* failed to read data from given path */
            print("loading of dotGraphFile error. UTF-8 encoding expected.")
            exit(EXIT_FAILURE)
        }
    } else {
        /* failed System Requirements */
        print("ERROR: Requires at least macOS 10.11")
        exit(EXIT_FAILURE)
    }
    return nil
}


func wildcard(_ string: String, pattern: String) -> Bool {
    let pred = NSPredicate(format: "self LIKE %@", pattern)
    return !NSArray(object: string).filtered(using: pred).isEmpty
}
