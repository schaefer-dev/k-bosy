import Foundation


public class AutomataTransition {
    public let start: AutomataState
    public let condition: Formula
    public let end: AutomataState
    
    // Creates Transition and adds itself to Automata and correct states
    public init (start: AutomataState, condition: Formula, end: AutomataState) {
        self.start = start
        self.condition = condition
        self.end = end
        print("DEBUG: created transition from '" + start.name + "' to '" + end.name + " with condition " + self.condition.description)
    }
}
