//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 11.05.20.
//

import Foundation
import LTL

public class AssumptionsGenerator {

    /**
     Assumes that bitset representation has been built whenever this function is called
     */
    public static func generateAutomataAssumptions(auto: Automata, tags: [String], tagsInAPs: Bool) -> [LTL] {
        var returnAssumptions: [LTL] = []

        // create set of tags that has to be used
        var tagSet: Set<String> = Set.init()
        for tag in tags {
            tagSet.insert(tag)
        }

        // create APs belonging to those tags
        for tag in tagSet {
            _ = AP(name: tag, observable: true, list: auto.apList)
        }

        returnAssumptions += self.internal_generatePossibleStateAssumptions(auto: auto)
        returnAssumptions.append(self.internal_generateInitialStateAssumptions(auto: auto))
        returnAssumptions +=  self.internal_generateStateAPsAssumptions(auto: auto, tagsInAPs: tagsInAPs)
        returnAssumptions += self.internal_generateTransitionAssumptions(auto: auto)

        return returnAssumptions
    }

    /**
     adds all state-names as input APs and also all APs which are specified to be observable
     
     Returns all inputAPs of the Synthesis Task
     */
    public static func getAutomataInputAPs(auto: Automata, tags: [String]) -> [String] {
        var returnArray: [String] = []

        // add all states as input APs
        let allStates = auto.get_allStates()
        for state in allStates {
            returnArray.append(state.name)
        }

        // add all observable, non-output APs as input APs
        let allAPs = auto.apList.get_allAPs()
        for ap in allAPs {
            if !ap.output {
                returnArray.append(ap.name)
            }
        }
        
        // add tags as additional input APs
        for tag in tags {
            returnArray.append(tag)
        }

        return returnArray.sorted()
    }

    /**
     returns all output APs of the Synthesis Task
     */
    public static func getAutomataOutputAPs(auto: Automata) -> [String] {
        // return all
        var returnArray: [String] = []

        // add all output APs
        let allAPs = auto.apList.get_allAPs()
        for ap in allAPs {
            if ap.output {
                returnArray.append(ap.name)
            }
        }

        return returnArray.sorted()
    }

    /**
     generates all Assumptions that are caused by transitions from state to state, make sure that non-observable APs are not contained here
     */
    public static func internal_generateTransitionAssumptions(auto: Automata) -> [LTL] {
        let allStates = auto.get_allStates()
        var returnAssumptions: [LTL] = []

        var currentStateIndex = 0
        while currentStateIndex < allStates.count {
            // handle transitions contained in state at index 'current_state_index'
            var ltlString = "G(!" + allStates[currentStateIndex].name + " || ("

            var transitionIndex = 0
            let relevantTransition = allStates[currentStateIndex].transitions

            // special case if no outgoing transitions in state
            if relevantTransition.count == 0 {
                print("WARNING: State " + allStates[currentStateIndex].name + " has no outgoing transitions. This is not allowed")
                ltlString += "false"
            }

            // for all condition build string "(trans1_cond && trans1_end)" and disjunct these for all conditions in that state
            while transitionIndex < relevantTransition.count {

                // add condition that is being in the correct state and the transition condition holding
                let relevantTransitionCondition = relevantTransition[transitionIndex].condition
                
                // check if working with bitset or if we have to use dnf
                if (relevantTransitionCondition.dnf == nil) {
                    ltlString += "((" + relevantTransitionCondition.getStringFromBitsetRepresentation(index_to_ap_map: auto.apList.get_bitset_index_to_ap_string_map()) + ")"
                } else {
                    // TODO: think about if we should require the bitset structure to be built here
                    ltlString += "((" + relevantTransition[transitionIndex].condition.description + ")"
                }
                ltlString += " && X(" + relevantTransition[transitionIndex].end.name + "))"

                // if more transitions following add disjunction
                if transitionIndex < (relevantTransition.count - 1) {
                    ltlString += " || "
                }

                transitionIndex += 1

            }
            ltlString += "))"

            do {
                let ltlCondition = try LTL.parse(fromString: ltlString)
                returnAssumptions.append(ltlCondition)
            } catch {
                assertionFailure("Error in generatingTransitionAssumptions when parsing LTL condition " + ltlString)
            }

            currentStateIndex += 1
        }

        return returnAssumptions
    }

    /**
     generates assumptions which assign each state their respective APs, make sure that non-observable APs are not contained here
     */
    public static func internal_generateStateAPsAssumptions(auto: Automata, tagsInAPs: Bool) -> [LTL] {
        let allStates = auto.get_allStates()
        let allObservableAPs = auto.apList.get_allObservableAPs()
        var returnAssumptions: [LTL] = []

        var currentStateIndex = 0
        while currentStateIndex < allStates.count {
            // get all observable APs that hold in this state
            var obsStateAPs: [AP] = []
            for ap in allStates[currentStateIndex].propositions {
                obsStateAPs.append(ap)
            }

            if tagsInAPs {
                // add all the tags that have been set in this state
                for tag in allStates[currentStateIndex].getAnnotation() {
                    let tagAPOpt = auto.apList.lookupAP(apName: tag)
                    assert(tagAPOpt != nil, "tag AP was not created properly")
                    obsStateAPs.append(tagAPOpt!)
                }
            }

            // generate string version of this array with all APs that hold in this state
            var obsStateAPsStrings: [String] = []
            for ap in obsStateAPs {
                obsStateAPsStrings.append(ap.name)
            }

            // get all observable AP names that do not hold in this state
            var obsNotStateAPsStrings: [String] = []
            for ap in allObservableAPs {
                if obsStateAPs.contains(ap) || ap.output {
                    // output APs of the synthesis task can not hold in environment states, so they are skipped
                    continue
                } else {
                    // if AP is not contained it does not hold in this state
                    obsNotStateAPsStrings.append(ap.name)
                }
            }

            var ltlString = "G(" + allStates[currentStateIndex].name + " -> ("

            // build positive condition section for this string which contains all observable APs that hold in this state
            if obsStateAPsStrings.count != 0 {
                ltlString += obsStateAPsStrings.joined(separator: " && ")
            } else {
                ltlString += "true"
            }

            // connect positive condition section with negative condition section
            ltlString += " && "

            // build negative condition section for this string which contains all observable APs that do not hold in this state
            if obsNotStateAPsStrings.count != 0 {
                // negation of first element has to be added manually
                ltlString += "!"

                ltlString += obsNotStateAPsStrings.joined(separator: " && !")
            } else {
                ltlString += "true"
            }

            ltlString += "))"

            do {
                let ltlCondition = try LTL.parse(fromString: ltlString)
                returnAssumptions.append(ltlCondition)
            } catch {
                print("Error when parsing LTL condition " + ltlString)
            }

            currentStateIndex += 1
        }

        return returnAssumptions
    }

    /**
     generate Assumptions which specifiy the fact that we have to be in one (and only one!)  of the environment states at any point in time
     */
    public static func internal_generatePossibleStateAssumptions(auto: Automata) -> [LTL] {
        let allStates = auto.get_allStates()
        var returnAssumptions: [LTL] = []

        var currentStateIndex = 0
        while currentStateIndex < allStates.count {
            // build condition for state with index 'current_state_index'
            var ltlString = "G(" + allStates[currentStateIndex].name + " -> ("

            // now build conjunction with all other states negated
            var otherStateIndex = 0
            while otherStateIndex < allStates.count {
                // we do not negate the same state we are currently building the condition for
                if currentStateIndex == otherStateIndex {
                    otherStateIndex += 1
                    continue
                }

                ltlString += "!" + allStates[otherStateIndex].name

                // if more states missing then add conjunction afterwards
                if otherStateIndex < (allStates.count - 1) {
                    // special case only one state follows and this is the current_state_index, in this case no further conjunctions are added
                    if (otherStateIndex == (allStates.count - 2)) && (currentStateIndex > otherStateIndex) {
                        otherStateIndex += 1
                        continue
                    } else {
                        ltlString += " && "
                    }
                }

                otherStateIndex += 1
            }

            ltlString += "))"

            do {
                let ltlCondition = try LTL.parse(fromString: ltlString)
                returnAssumptions.append(ltlCondition)
            } catch {
                print("Error when parsing LTL condition " + ltlString)
            }

            currentStateIndex += 1
        }

        // add condition that we always have to be in one of the states
        var ltlString = "G("
        currentStateIndex = 0
        while currentStateIndex < allStates.count {
            ltlString += allStates[currentStateIndex].name

            // if more states missing then add disjunction afterwards
            if currentStateIndex < (allStates.count - 1) {
                ltlString += " || "
            }

            currentStateIndex += 1
        }

        ltlString += ")"

        do {
            let ltlCondition = try LTL.parse(fromString: ltlString)
            returnAssumptions.append(ltlCondition)
        } catch {
            print("Error when parsing LTL condition " + ltlString)
        }

        return returnAssumptions
    }

    /**
     generate Assumptions which specifiy the starting behaviour of the automaton
     */
    public static func internal_generateInitialStateAssumptions(auto: Automata) -> LTL {
        let initialStates = auto.initialStates

        var ltlString = "("

        var stateIndex = 0
        while stateIndex < initialStates.count {
            ltlString += initialStates[stateIndex].name

            // if more states coming add disjunction
            if stateIndex < (initialStates.count - 1) {
                ltlString += " || "
            }
            stateIndex += 1
        }

        ltlString += ")"

        do {
            let returnLTL = try LTL.parse(fromString: ltlString)
            return returnLTL
        } catch {
            print("ERROR: could not generate initial StateAssumptions")
            exit(EXIT_FAILURE)
        }
    }

}
