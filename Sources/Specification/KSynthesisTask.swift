import Automata

// TODO: possibly this class is no longer required
public class KSynthesisTask {
    public var automata: Automata
    public var observableAP: [AP]
    public var hiddenAP: [AP]
    public var outputs: [AP]

    // parse passed information into KSynthesisTask structure, transforms strings into AP structure and adds those to apList that is passed
    public init(automata: Automata, observableAP: [String], hiddenAP: [String], outputs: [String], apList: APList) {
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
    }
}
