import Foundation


public class AutomataTransition {
    public let start: AutomataState
    public let condition: Formula
    public let end: AutomataState
    public let action: [AP]
    
    // Creates Transition and adds itself to Automata and correct states
    public init (start: AutomataState, condition: Formula, end: AutomataState, action: [AP]) {
        self.start = start
        self.condition = condition
        self.end = end
        self.action = action
        if (action.count > 0) {
            let action_str = action[0].id
            print("DEBUG: created transition from '" + start.name + "' to '" + end.name + "' with action contained being " + action_str)
        } else {
            print("DEBUG: created transition from '" + start.name + "' to '" + end.name + " with no action contained")
        }
    }
}
