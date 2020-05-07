import Foundation


// Represents dot Graph
public class Automata {
    public var apList: APList
    public var initial_states: [AutomataState]
    private var all_states: [String: AutomataState]
    // Transition contained in states currently: public var transition_relation: [Transition]
    
    
    /**
     This constructor may only be called in the `parseDotGraphFile` method.
    
     - Parameter info: InputAutomataInfo which provides additional information that is required to construct Automata structure.
    */
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
    
    /**
     Adds an initial state to the automata strucure. The addition is skipped whenever the state is already contained, however a warning is printed whenever this case happens.
     The Addition of the state is also skipped if it was previously contained as a non-initial state and is afterwards attempted to be added as an initial state. The same warning is output in this special-case.
    
     - Parameter new_state: State which should be added to the Automata Structure
    */
    public func add_initial_state(new_initial_state: AutomataState) {
        if (self.all_states[new_initial_state.name] != nil) {
            print("WARNING: tried to add new initial State " + new_initial_state.name + " which was already contained in Automata")
            return
        }
        self.all_states[new_initial_state.name] = new_initial_state
        self.initial_states.append(new_initial_state)
        print("DEBUG: added initial state " + new_initial_state.description + " to Automata")
    }
    

    /**
     Adds a non-initial state to the automata strucure. The addition is skipped whenever the state is already contained, however a warning is printed whenever this case happens.
     
     - Parameter new_state: State which should be added to the Automata Structure
     */
    public func add_state(new_state: AutomataState) {
        if (self.all_states[new_state.name] != nil) {
            print("WARNING: tried to add State " + new_state.name + " which was already contained in Automata")
            return
        }
        self.all_states[new_state.name] = new_state
        print("DEBUG: added state " + new_state.description + " to Automata")
    }
    
    
    public func get_state(name: String) -> AutomataState? {
        return self.all_states[name]
    }
    
    
    /**
     Used to parse transition from a string representation that occurs in the dot  graph file and add it to the Automata strucutre this method is called with. Sideffects from this addition may be the creation of states that are part of the transtion but not yet part of the Automata structure.
     
     - Parameter start_str: string which represents the starting state of this transition
     - Parameter end_str: string which represents the ending state of this transition
     - Parameter condition: string which represents the condition under which this transition is taken. May also contain actions that are preformed by the environment whenever this transition is taken, these actions are listed after the character '/' terminates the conditon.
     */
    public func parseAndAddTransition(start_str: String, end_str: String, condition: String) {
        let startStateOpt = self.get_state(name: start_str)
        let endStateOpt = self.get_state(name: end_str)

        // Create startState if non existant
        if (startStateOpt == nil) {
            let startState = AutomataState(name: start_str, propositions: [])
            self.add_state(new_state: startState)
        }

        // Create endState if non existant
        if (endStateOpt == nil) {
           let endState = AutomataState(name: end_str, propositions: [])
           self.add_state(new_state: endState)
        }
        
        // after adding them we know that bost states must exist now
        let startState = self.get_state(name: start_str)!
        let endState = self.get_state(name: end_str)!

        let cond_trimmed = condition.trimmingCharacters(in: .whitespacesAndNewlines)
        let first_split = cond_trimmed.components(separatedBy: "/")
        
        if (first_split.count == 2) {
            print("WARNING: detected '/', which is not expected in kripke representation")
        } else if (first_split.count > 2) {
            print("ERROR: two '/' encounted in one transition, parsing error!")
        }
        
        // parse condition
        let condition_string = first_split[0].trimmingCharacters(in: .whitespacesAndNewlines)
        
        let condition = FormulaParser.parseDNFFormula(input_str: condition_string, apList: self.apList)
        
        if (condition==nil) {
            print("ERROR: can not create transition for invalid DNF formula, exiting")
            exit(EXIT_FAILURE)
        }
        
        let new_transition = AutomataTransition(start: startState, condition: condition!, end: endState)
        startState.addTransition(trans: new_transition)
    }
}


func wildcard(_ string: String, pattern: String) -> Bool {
    let pred = NSPredicate(format: "self LIKE %@", pattern)
    return !NSArray(object: string).filtered(using: pred).isEmpty
}
