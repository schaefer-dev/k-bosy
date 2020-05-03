import Foundation


public class AutomataTransition {
    public let start: AutomataState
    public let condition: Formula
    public let end: AutomataState
    public let action: Formula?
    
    // Creates Transition and adds itself to Automata and correct states
    public init (start: AutomataState, condition: Formula, end: AutomataState, action: Formula?) {
        self.start = start
        self.condition = condition
        self.end = end
        self.action = action
        if (action != nil) {
            let action_str = action!.dnf[0].literals[0].toString()
            print("DEBUG: created transition from '" + start.name + "' to '" + end.name + "' with action contained being " + action_str)
        } else {
            print("DEBUG: created transition from '" + start.name + "' to '" + end.name + " with no action contained")
        }
    }
}
