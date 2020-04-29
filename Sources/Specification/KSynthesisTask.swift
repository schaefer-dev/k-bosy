import Automata

public class KSynthesisTask {
    public var automata : Automata
    public var observableAP: [AP]
    public var hiddenAP: [AP]
    public var outputs: [AP]
    public var initialStates: [AutomataState]
    
    
    // parse passed information into KSynthesisTask structure, transforms strings into AP structure and adds those to apList that is passed
    public init(automata: Automata, observableAP: [String], hiddenAP: [String], outputs: [String], initialStates: [String], apList: APList) {
        self.automata = automata
        
        self.observableAP = []
        for str in observableAP {
            let newAP = AP(name: str, observable: true, list: apList)
            self.observableAP.append(newAP)
        }
        
        self.hiddenAP = []
        for str in hiddenAP {
            let newAP = AP(name: str, observable: false, list: apList)
            self.hiddenAP.append(newAP)
        }
        
        self.outputs = []
        for str in outputs {
            let newAP = AP(name: str, observable: true, list: apList, output: true)
            self.outputs.append(newAP)
        }
        
        // TODO: implement transformation from String to AutomataState
        self.initialStates = []
        for str in initialStates {
            let newState = AutomataState(name: str)
            self.initialStates.append(newState)
        }
    }
}
