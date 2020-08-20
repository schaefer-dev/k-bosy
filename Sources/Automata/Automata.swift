import Foundation
import LTL

// Represents dot Graph
public class Automata {
    public var apList: APList
    public var initialStates: [AutomataState]
    private var allStates: [String: AutomataState]
    public var guarantees: [LTL]

    /**
     This constructor may only be called in the `parseDotGraphFile` method.
    
     - Parameter info: InputAutomataInfo which provides additional information that is required to construct Automata structure.
    */
    init(info: InputAutomataInfo) {
        self.apList = APList()

        // fill APList with elements from InputAutomataInfo
        for ap in info.hiddenAP {
            _ = AP(name: ap, observable: false, list: self.apList)
        }
        for ap in info.observableAP {
            _ = AP(name: ap, observable: true, list: self.apList)
        }
        for ap in info.outputs {
            _ = AP(name: ap, observable: true, list: self.apList, output: true)
        }
        self.guarantees = info.guarantees

        self.initialStates = []
        self.allStates = [String: AutomataState]()
    }

    /**
     This constructor may only be called in the `getObservableAutomata` method.
    */
    init(apList: APList, initialStates: [AutomataState], allStates: [String: AutomataState], guarantees: [LTL]) {
        self.apList = apList
        self.initialStates = initialStates
        self.allStates = allStates
        self.guarantees = guarantees
    }

    /**
     Adds an initial state to the automata strucure. The addition is skipped whenever the state is already contained, however a warning is printed whenever this case happens.
     The Addition of the state is also skipped if it was previously contained as a non-initial state and is afterwards attempted to be added as an initial state. The same warning is output in this special-case.
    
     - Parameter new_state: State which should be added to the Automata Structure
    */
    public func add_initial_state(newInitialState: AutomataState) {
        if self.allStates[newInitialState.name] != nil {
            print("WARNING: tried to add new initial State " + newInitialState.name + " which was already contained in Automata")
            return
        }
        self.allStates[newInitialState.name] = newInitialState
        self.initialStates.append(newInitialState)
        // print("DEBUG: added initial state " + newInitialState.description + " to Automata")
    }

    /**
     Adds a non-initial state to the automata strucure. The addition is skipped whenever the state is already contained, however a warning is printed whenever this case happens.
     
     - Parameter new_state: State which should be added to the Automata Structure
     */
    public func add_state(newState: AutomataState) {
        if self.allStates[newState.name] != nil {
            print("WARNING: tried to add State " + newState.name + " which was already contained in Automata")
            return
        }
        self.allStates[newState.name] = newState
        newState.setParentAutomata(parent: self)
        // print("DEBUG: added state " + newState.description + " to Automata")
    }

    public func get_state(name: String) -> AutomataState? {
        return self.allStates[name]
    }

    /**
     returns all States that are part of this Automata structure sorted by state name
     */
    public func get_allStates() -> [AutomataState] {
        var stateList: [AutomataState] = []

        for state in self.allStates {
            stateList.append(state.value)
        }

        // sorting happens to guarantee deterministic behaviour of Assumptions-generation which improves ability to test in these cases
        let stateListSorted = stateList.sorted { $0.name < $1.name }

        return stateListSorted
    }

    /**
     Used to parse transition from a string representation that occurs in the dot  graph file and add it to the Automata strucutre this method is called with. Sideffects from this addition may be the creation of states that are part of the transtion but not yet part of the Automata structure.
     
     - Parameter start_str: string which represents the starting state of this transition
     - Parameter end_str: string which represents the ending state of this transition
     - Parameter condition: string which represents the condition under which this transition is taken. May also contain actions that are preformed by the environment whenever this transition is taken, these actions are listed after the character '/' terminates the conditon.
     */
    public func parseAndAddTransition(startString: String, endString: String, condition: String) {
        let startStateOpt = self.get_state(name: startString)
        let endStateOpt = self.get_state(name: endString)

        // Create startState if non existant
        if startStateOpt == nil {
            let startState = AutomataState(name: startString, propositions: [])
            self.add_state(newState: startState)
        }

        // Create endState if non existant
        if endStateOpt == nil {
           let endState = AutomataState(name: endString, propositions: [])
           self.add_state(newState: endState)
        }

        // after adding them we know that bost states must exist now
        let startState = self.get_state(name: startString)!
        let endState = self.get_state(name: endString)!

        let conditionTrimmed = condition.trimmingCharacters(in: .whitespacesAndNewlines)
        let firstSplit = conditionTrimmed.components(separatedBy: "/")

        if firstSplit.count == 2 {
            print("WARNING: detected '/', which is not expected in kripke representation")
        } else if firstSplit.count > 2 {
            print("ERROR: two '/' encounted in one transition, parsing error!")
        }

        // parse condition
        let conditionString = firstSplit[0].trimmingCharacters(in: .whitespacesAndNewlines)

        let condition = FormulaParser.parseDNFFormula(inputString: conditionString, apList: self.apList)

        if condition==nil {
            print("ERROR: can not create transition for invalid DNF formula, exiting")
            exit(EXIT_FAILURE)
        }

        let newTransition = AutomataTransition(start: startState, condition: condition!, end: endState)

        startState.addTransition(trans: newTransition)
    }
    
    
    /**
     For all  given tags, look through state-structure and then replace this tag in guarantees with the disjunction of all states that are annotated with this tag.
     */
    public func getGuaranteesWithCandidateStateNames(tags: [String], tag_knowledge_mapping : [String: LTL]? = nil) -> [LTL]{
        let allStates = self.get_allStates()
        var newGuarantees: [LTL] = self.guarantees
        for tag in tags {
            var tagStates: [AutomataState] = []
            
            // check for every state if it was annotated with this parcitular tag
            for state in allStates {
                if state.getAnnotation().contains(tag) {
                    tagStates.append(state)
                }
            }
            
            var tagStateNames: [String] = []
            for tagState in tagStates {
                tagStateNames.append(tagState.name)
            }
            
            var tagStateFormula = ""
            
            if tagStateNames.count == 0 {
                // if no candidate state replace it with formula 'false'
                tagStateFormula = "false"
            } else {
                tagStateFormula = "("
                tagStateFormula += tagStateNames.joined(separator: " || ")
                tagStateFormula += ")"
                
                if tag_knowledge_mapping == nil {
                    print("DEBUG: replacing tag " + tag + " with formula " + tagStateFormula)
                } else {
                    print("DEBUG: replacing " + tag_knowledge_mapping![tag]!.description + " with formula " + tagStateFormula)
                }
            }
            
            // replace all all occurances of this tag with this formula
            var guaranteeIndex = 0
            while (guaranteeIndex < newGuarantees.count) {
                newGuarantees[guaranteeIndex] = newGuarantees[guaranteeIndex].stringReplaceLTL(oldLTLSubString: tag, newLTLSubString: tagStateFormula)
                guaranteeIndex += 1
            }
        }
        
        return newGuarantees
    }

    /**
     performs simplifications in this automata.
     This includes optimizations that are performed on Transition-Conditions and also the building of BitsetRepresentations for all transitions.
     */
    public func finalize(optimizationUsingReduce: Bool = false) {
        for state in self.get_allStates() {
            state.finalize(optimizationUsingReduce: optimizationUsingReduce)
        }
    }

    /**
     Reduces the entire automata structure to only contain observable stuff. This removed all non-observable and non-output APs from the apList. It also removes all non-observable APs from the state structure.
     - IMPORTANT: it does not remove any occurances of non-observable APs from the formulas that specify transition-conditions!
     */
    public func reduceToObservablePart() {
        // Transform apList to only contain observable stuff
        self.apList = KBSCUtils.getObservableAPList(inputList: self.apList)

        // Transform states to only contain observable propositions
        for state in self.get_allStates() {
            state.reduceToObservablePart()
        }
    }
    
    
    public func addTagsToCandidateStates(tags: [String], candidateStateNames: [[String]]){
        // Translate String stateNames into AutomataState Array to work with it easier
        assert(tags.count == candidateStateNames.count)
        var candidateStates: [[AutomataState]] = []
        for candidateStateNameSet in candidateStateNames {
            var candidateStateSet: [AutomataState] = []
            for candidateStateName in candidateStateNameSet {
                let candidateState = self.get_state(name: candidateStateName)
                if candidateState == nil {
                    print("State " + candidateStateName + " was given as candidate state but does not exist in automata")
                    exit(EXIT_FAILURE)
                }
                candidateStateSet.append(candidateState!)
            }
            candidateStates.append(candidateStateSet)
        }
        
        // annotate all candidate tags with their respective tag
        var tagIndex = 0
        while tagIndex < tags.count {
            let currentTag = tags[tagIndex]
            for candidateState in candidateStates[tagIndex] {
                candidateState.addAnnotation(annotationName: currentTag)
            }
            tagIndex += 1
        }
    }
}

func wildcard(_ string: String, pattern: String) -> Bool {
    let range = NSRange(location: 0, length: string.utf16.count)
    let regex = try! NSRegularExpression(pattern: pattern)
    
    if regex.firstMatch(in: string, options: [], range: range) != nil {
        return true
    }
    return false
}
