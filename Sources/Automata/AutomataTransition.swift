import Foundation


public class AutomataTransition {
    public let start: AutomataState
    public var condition: Formula
    public let end: AutomataState
    
    // Creates Transition and adds itself to Automata and correct states
    public init (start: AutomataState, condition: Formula, end: AutomataState) {
        self.start = start
        self.condition = condition
        self.end = end
        print("DEBUG: created transition from '" + start.name + "' to '" + end.name + " with condition " + self.condition.description)
    }
    
    /**
    simplify this transition, which means that all occurances of non-output APs are replaced with their respective values according to the starting state of this transition. Only the value of output-APs is not known at this time which is why we keep those variable.
    */
    public func simplify() {
        self.condition.simplify(true_aps: self.start.propositions)
    }
}
