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
    public static func generateAutomataAssumptions(auto: Automata, tags: [String]) -> [LTL] {
        var return_assumptions: [LTL] = []

        // create set of tags that has to be used
        var tag_set: Set<String> = Set.init()
        for tag in tags {
            tag_set.insert(tag)
        }

        // create APs belonging to those tags
        for tag in tag_set {
            let new_ap = AP(name: tag, observable: true, list: auto.apList)
        }

        return_assumptions = return_assumptions + self._generatePossibleStateAssumptions(auto: auto)
        return_assumptions.append(self._generateInitialStateAssumptions(auto: auto))
        return_assumptions = return_assumptions + self._generateStateAPsAssumptions(auto: auto)
        return_assumptions = return_assumptions + self._generateTransitionAssumptions(auto: auto)

        return return_assumptions
    }

    /**
     adds all state-names as input APs and also all APs which are specified to be observable
     
     Returns all inputAPs of the Synthesis Task
     */
    public static func getAutomataInputAPs(auto: Automata) -> [String] {
        var return_array: [String] = []

        // add all states as input APs
        let all_states = auto.get_allStates()
        for state in all_states {
            return_array.append(state.name)
        }

        // add all observable, non-output APs as input APs
        let all_aps = auto.apList.get_allAPs()
        for ap in all_aps {
            if ap.obs && !ap.output {
                return_array.append(ap.id)
            }
        }

        return return_array.sorted()
    }

    /**
     returns all output APs of the Synthesis Task
     */
    public static func getAutomataOutputAPs(auto: Automata) -> [String] {
        // return all
        var return_array: [String] = []

        // add all output APs
        let all_aps = auto.apList.get_allAPs()
        for ap in all_aps {
            if ap.output {
                return_array.append(ap.id)
            }
        }

        return return_array.sorted()
    }

    /**
     generates all Assumptions that are caused by transitions from state to state, make sure that non-observable APs are not contained here
     */
    public static func _generateTransitionAssumptions(auto: Automata) -> [LTL] {
        let all_states = auto.get_allStates()
        var return_assumptions: [LTL] = []

        var current_state_index = 0
        while current_state_index < all_states.count {
            // handle transitions contained in state at index 'current_state_index'
            var ltl_string = "G(!" + all_states[current_state_index].name + " || ("

            var transition_index = 0
            let relevant_transitions = all_states[current_state_index].transitions

            // special case if no outgoing transitions in state
            if relevant_transitions.count == 0 {
                print("WARNING: State " + all_states[current_state_index].name + " has no outgoing transitions. This is not allowed")
                ltl_string += "false"
            }

            // for all condition build string "(trans1_cond && trans1_end)" and disjunct these for all conditions in that state
            while transition_index < relevant_transitions.count {

                // add condition that is being in the correct state and the transition condition holding
                let relevant_transition_condition = relevant_transitions[transition_index].condition
                // TODO: think about if we should require the following line or not
                assert(relevant_transition_condition.dnf == nil, "dnf structure has to be aborted at this point and worked only with bitset. This can be achieved by using automata.finalize() which builds this structure.")
                ltl_string += "((" + relevant_transition_condition.getStringFromBitsetRepresentation(index_to_ap_map: auto.apList.get_bitset_index_to_ap_string_map()) + ")"
                ltl_string += " && X(" + relevant_transitions[transition_index].end.name + "))"

                // if more transitions following add disjunction
                if transition_index < (relevant_transitions.count - 1) {
                    ltl_string += " || "
                }

                transition_index += 1

            }
            ltl_string += "))"

            do {
                let ltl_condition = try LTL.parse(fromString: ltl_string)
                return_assumptions.append(ltl_condition)
            } catch {
                assertionFailure("Error in generatingTransitionAssumptions when parsing LTL condition " + ltl_string)
            }

            current_state_index += 1
        }

        return return_assumptions
    }

    /**
     generates assumptions which assign each state their respective APs, make sure that non-observable APs are not contained here
     */
    public static func _generateStateAPsAssumptions(auto: Automata) -> [LTL] {
        let all_states = auto.get_allStates()
        let all_observable_aps = auto.apList.get_allObservableAPs()
        var return_assumptions: [LTL] = []

        var current_state_index = 0
        while current_state_index < all_states.count {
            // get all observable APs that hold in this state
            var obs_state_aps: [AP] = []
            for ap in all_states[current_state_index].propositions {
                if ap.obs {
                    obs_state_aps.append(ap)
                }
            }

            // add all the tags that have been set in this state
            for tag in all_states[current_state_index].getAnnotation() {
                let tag_ap_opt = auto.apList.lookupAP(apName: tag)
                assert(tag_ap_opt != nil, "tag AP was not created properly")
                obs_state_aps.append(tag_ap_opt!)
            }

            // generate string version of this array with all APs that hold in this state
            var obs_state_aps_strings: [String] = []
            for ap in obs_state_aps {
                obs_state_aps_strings.append(ap.id)
            }

            // get all observable AP names that do not hold in this state
            var obs_not_state_aps_strings: [String] = []
            for ap in all_observable_aps {
                if obs_state_aps.contains(ap) || ap.output {
                    // output APs of the synthesis task can not hold in environment states, so they are skipped
                    continue
                } else {
                    // if AP is not contained it does not hold in this state
                    obs_not_state_aps_strings.append(ap.id)
                }
            }

            var ltl_string = "G(" + all_states[current_state_index].name + " -> ("

            // build positive condition section for this string which contains all observable APs that hold in this state
            if obs_state_aps_strings.count != 0 {
                ltl_string += obs_state_aps_strings.joined(separator: " && ")
            } else {
                ltl_string += "true"
            }

            // connect positive condition section with negative condition section
            ltl_string += " && "

            // build negative condition section for this string which contains all observable APs that do not hold in this state
            if obs_not_state_aps_strings.count != 0 {
                // negation of first element has to be added manually
                ltl_string += "!"

                ltl_string += obs_not_state_aps_strings.joined(separator: " && !")
            } else {
                ltl_string += "true"
            }

            ltl_string += "))"

            do {
                let ltl_condition = try LTL.parse(fromString: ltl_string)
                return_assumptions.append(ltl_condition)
            } catch {
                print("Error when parsing LTL condition " + ltl_string)
            }

            current_state_index += 1
        }

        return return_assumptions
    }

    /**
     generate Assumptions which specifiy the fact that we have to be in one (and only one!)  of the environment states at any point in time
     */
    public static func _generatePossibleStateAssumptions(auto: Automata) -> [LTL] {
        let all_states = auto.get_allStates()
        var return_assumptions: [LTL] = []

        var current_state_index = 0
        while current_state_index < all_states.count {
            // build condition for state with index 'current_state_index'
            var ltl_string = "G(" + all_states[current_state_index].name + " -> ("

            // now build conjunction with all other states negated
            var other_state_index = 0
            while other_state_index < all_states.count {
                // we do not negate the same state we are currently building the condition for
                if current_state_index == other_state_index {
                    other_state_index += 1
                    continue
                }

                ltl_string += "!" + all_states[other_state_index].name

                // if more states missing then add conjunction afterwards
                if other_state_index < (all_states.count - 1) {
                    // special case only one state follows and this is the current_state_index, in this case no further conjunctions are added
                    if (other_state_index == (all_states.count - 2)) && (current_state_index > other_state_index) {
                        other_state_index += 1
                        continue
                    } else {
                        ltl_string += " && "
                    }
                }

                other_state_index += 1
            }

            ltl_string += "))"

            do {
                let ltl_condition = try LTL.parse(fromString: ltl_string)
                return_assumptions.append(ltl_condition)
            } catch {
                print("Error when parsing LTL condition " + ltl_string)
            }

            current_state_index += 1
        }

        // add condition that we always have to be in one of the states
        var ltl_string = "G("
        current_state_index = 0
        while current_state_index < all_states.count {
            ltl_string += all_states[current_state_index].name

            // if more states missing then add disjunction afterwards
            if current_state_index < (all_states.count - 1) {
                ltl_string += " || "
            }

            current_state_index += 1
        }

        ltl_string += ")"

        do {
            let ltl_condition = try LTL.parse(fromString: ltl_string)
            return_assumptions.append(ltl_condition)
        } catch {
            print("Error when parsing LTL condition " + ltl_string)
        }

        return return_assumptions
    }

    /**
     generate Assumptions which specifiy the starting behaviour of the automaton
     */
    public static func _generateInitialStateAssumptions(auto: Automata) -> LTL {
        let initial_states = auto.initial_states

        var ltl_string = "("

        var state_index = 0
        while state_index < initial_states.count {
            ltl_string += initial_states[state_index].name

            // if more states coming add disjunction
            if state_index < (initial_states.count - 1) {
                ltl_string += " || "
            }
            state_index += 1
        }

        ltl_string += ")"

        do {
            let return_ltl = try LTL.parse(fromString: ltl_string)
            return return_ltl
        } catch {
            print("ERROR: could not generate initial StateAssumptions")
            exit(EXIT_FAILURE)
        }
    }

}
