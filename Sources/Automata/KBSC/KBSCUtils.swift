//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 12.06.20.
//

import Foundation

public class KBSCUtils {

    /**
     Naive implementation that generates Formula from bitset
     
     TODO: lots of improvement potential here
     */
    public static func naiveBitsetToFormula(bs: Bitset, apList: APList) -> Formula {

        let bitsetAsFormulaString = bs.get_conjunction_string(bitsetAPMapping: apList.get_bitset_index_to_ap_string_map())

        let formula = FormulaParser.parseDNFFormula(inputString: bitsetAsFormulaString, apList: apList)

        return formula!
    }

    /**
     Devides the given set of input_states into different sets of states. Every given state will only contain in ONE of those sets.
     Every state that is contained in the same set than another state has to share all his (observable) APs with that state he is in the same set with.
     
     The minimal number of Sets is guaranteed to be returned (minimum amount of observational equivalence classes required).
     */
    public static func divideStatesByAPs(inputStates: [AutomataState]) -> [[AutomataState]] {
        var obsEqStateMapping = [[AP]: [AutomataState]]()

        // TODO: order matters so we have to make sure that list of APs contained in every state is sorted!!
        // use dictionary to track the states that share the same list of APs
        for inputState in inputStates {
            var obs_eq_states = obsEqStateMapping.removeValue(forKey: inputState.propositions)
            if obs_eq_states == nil {
                // no state list was setup here until now
                obsEqStateMapping[inputState.propositions] = [inputState]
            } else {
                // state list already existed, add this state to this list
                obs_eq_states!.append(inputState)
                obsEqStateMapping[inputState.propositions] = obs_eq_states
            }
        }

        var returnArray: [[AutomataState]] = []

        for (_, obsEqStates) in obsEqStateMapping {
            returnArray.append(obsEqStates)
        }

        return returnArray
    }

    public static func getObservableAPList(inputList: APList) -> APList {
        let newAPList = APList()

        // add all non-hidden APs
        for ap in inputList.get_allAPs() {
            if ap.obs || ap.output {
                newAPList.addAP(ap: ap)
            }
        }

        return newAPList
    }

    /**
     Returns new state resulting from the merging of n > 0 States
     Name of the new state = (s1.name + s2.name + s3.name + ....) with the names sorted (so its unique).
     
     Verifies that it makes sense to merge these states by requireing that the APs in all original states are equal
     */
    public static func mergeStatesIntoNewState(states: [AutomataState]) -> AutomataState {

        assert(states.count > 0)

        // states can only be merged if they have the same observable APs
        // (because otherwise we could distinguish them and they could never be combined into one state during KBSC)
        let requiredPropositions = states[0].propositions
        var sourceStateNames: [String] = []
        for state in states {
            assert(requiredPropositions == state.propositions, "states with different APs attempted to be merged")
            sourceStateNames.append(state.name)
        }

        let newStateName = constructStateName(sourceNames: sourceStateNames)

        let commonTags = getCommonTags(states: states)

        // create new state that represents the marged state
        let newState = AutomataState(name: newStateName, propositions: requiredPropositions)

        for commonTag in commonTags {
            newState.addAnnotation(annotationName: commonTag)
        }

        return newState
    }

    /**
     Goes through set of states and returns all tags which are included in ALL of these states
     */
    private static func getCommonTags(states: [AutomataState]) -> [String] {
        assert(states.count > 0)

        var returnArray: [String] = []

        let tags = states[0].getAnnotation()

        for tag in tags {
            var tagValidForallStates = true

            for state in states {
                if !(state.containsAnnotation(annotationName: tag)) {
                    tagValidForallStates = false
                    break
                }
            }
            // if tag valid for all states add it to the returnlist
            if tagValidForallStates {
                returnArray.append(tag)
            }
        }

        return returnArray
    }

    /**
     Helper function that constructs unique state name whenever a set of states is merged to identify that merged state
     */
    public static func constructStateName(sourceNames: [String]) -> String {
        // build new state name with sorting on contained state-names so we maintain correctness
        var newStateNameSet = Set<String>()
        var newStateNameArray: [String] = []

        for name in sourceNames {
            let containedNumbers = name.split(separator: "s")
            for number in containedNumbers {
                let numberString = String(number)
                if !newStateNameSet.contains(numberString) {
                    newStateNameSet.insert(numberString)
                    newStateNameArray.append(numberString)
                }
            }
        }
        let newStateName = "s" + newStateNameArray.sorted().joined(separator: "s")
        return newStateName
    }

}
