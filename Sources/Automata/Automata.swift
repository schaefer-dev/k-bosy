import Foundation


// Represents dot Graph
public class Automata {
    public var apList: APList
    public var initial_states: [AutomataState]
    private var all_states: [String: AutomataState]
    // Transition contained in states currently: public var transition_relation: [Transition]
    
    
    // Constructor only called via readDotgraphFile!!
    init(info: InputAutomataInfo) {
        self.apList = APList()
        
        // fill APList with elements from InputAutomataInfo
        for ap in info.hiddenAP {
            let _ = AP(name: ap, observable: false, list: self.apList)
        }
        for ap in info.observableAP {
            let _ = AP(name: ap, observable: true, list: self.apList)
        }
        for ap in info.outputs {
            let _ = AP(name: ap, observable: true, list: self.apList, output: true)
        }
        
        initial_states = []
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
    
    
    
    /* main function that is used to parse transition from string to the automata structure which
        adds it to the initial state this transtion starts at. */
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

        let cond_trimmed = condition.trimmingCharacters(in: .whitespacesAndNewlines)
        let first_split = cond_trimmed.components(separatedBy: "/")
        
        var action: Formula? = nil
        if (first_split.count == 2) {
            // parse action
            let action_string = first_split[1].trimmingCharacters(in: .whitespacesAndNewlines)
            if (action_string != "") {
                // TODO: add handling for cases in which more than one actions happens
                let apOpt = self.apList.lookupAP(apName: action_string)
                if (apOpt == nil) {
                } else {
                    let variable = Variable(negated: false, atomicProposition: apOpt!)
                    let conj = Conjunction(literalsContainedInConjunction: [variable])
                    action = Formula(containedConjunctions: [conj])
                }
            }
        } else if (first_split.count > 2) {
            print("ERROR: two '/' encounted in one transition, parsing error!")
        }
        
        
        // parse condition
        let condition_string = first_split[0].trimmingCharacters(in: .whitespacesAndNewlines)
        print("DEBUG: condition of transition is " + condition_string)
        
        
        let condition = parseDNFFormula(input_str: condition_string, apList: self.apList)
        
        if (condition==nil) {
            print("ERROR: can not create transition for invalid DNF formula, exiting")
            exit(EXIT_FAILURE)
        }
        
        let new_transition = AutomataTransition(start: startState, condition: condition!, end: endState, action: action)
        startState.addTransition(trans: new_transition)
    }
}


public func readDotGraphFile(path: String, info: InputAutomataInfo) -> Automata? {
    /* Verify System requirements */
    if #available(OSX 10.11, *) {
        /* System requirements passed */
        let fileURL = URL(fileURLWithPath: path)
        print("loading dot-graph from path: " + fileURL.path)


        /* try to read input dot graph File */
        do {
            let data = try NSString(contentsOfFile: fileURL.path,
                                    encoding: String.Encoding.utf8.rawValue)

            // If a value was returned, print it.
            var content_lines = data.components(separatedBy: ";")
            
            for i in 0...(content_lines.count - 1) {
                content_lines[i] = content_lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            // Parsing of dot graph File starts now
            let automata = Automata(info: info)
            
            // cleanup loop to remove irrelevant lines
            var index = 0
            while (index < content_lines.count - 1) {
                // Condition to find initial state marker
                if (content_lines[index].contains("_init -> ")){
                    let substrings = content_lines[index].components(separatedBy: " -> ")
                    let right_substrings = substrings[1].split(separator: "[")
                    let initial_state_name = right_substrings[0].trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    let new_initial_state = AutomataState(name: initial_state_name)
                    automata.add_initial_state(new_initial_state: new_initial_state)
                } else {
                    // Condition to find transition description line
                    if (wildcard(content_lines[index], pattern: "?* -> ?*")) {
                        //print("DEBUG: Transition found in Statement " + String(index + 1))
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
