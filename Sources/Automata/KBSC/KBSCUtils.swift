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

        let bitset_as_formula_string = bs.get_conjunction_string(bitset_ap_mapping: apList.get_bitset_index_to_ap_string_map())

        let formula = FormulaParser.parseDNFFormula(input_str: bitset_as_formula_string, apList: apList)

        return formula!
    }

    /**
     Devides the given set of input_states into different sets of states. Every given state will only contain in ONE of those sets. Every state that is contained in the same set than another state has to share all his (observable) APs with that state he is in the same set with.
     
     The minimal number of Sets is guaranteed to be returned (minimum amount of observational equivalence classes required).
     */
    public static func divideStatesByAPs(input_states: [AutomataState]) -> [[AutomataState]] {
        var obs_eq_state_mapping = [[AP]: [AutomataState]]()

        // TODO: order matters so we have to make sure that list of APs contained in every state is sorted!!
        // use dictionary to track the states that share the same list of APs
        for input_state in input_states {
            var obs_eq_states = obs_eq_state_mapping.removeValue(forKey: input_state.propositions)
            if obs_eq_states == nil {
                // no state list was setup here until now
                obs_eq_state_mapping[input_state.propositions] = [input_state]
            } else {
                // state list already existed, add this state to this list
                obs_eq_states!.append(input_state)
                obs_eq_state_mapping[input_state.propositions] = obs_eq_states
            }
        }

        var return_array: [[AutomataState]] = []

        for (_, obs_eq_states) in obs_eq_state_mapping {
            return_array.append(obs_eq_states)
        }

        return return_array
    }

    public static func getObservableAPList(input_list: APList) -> APList {
        let new_apList = APList()

        // add all non-hidden APs
        for ap in input_list.get_allAPs() {
            if ap.obs || ap.output {
                new_apList.addAP(ap: ap)
            }
        }

        return new_apList
    }

    /**
     Returns new state resulting from the merging of n > 0 States
     Name of the new state = (s1.name + s2.name + s3.name + ....) with the names sorted (so its unique).
     
     Verifies that it makes sense to merge these states by requireing that the APs in all original states are equal
     */
    public static func mergeStatesIntoNewState(states: [AutomataState]) -> AutomataState {

        assert(states.count > 0)

        // states can only be merged if they have the same observable APs (because otherwise we could distinguish them and they could never be combined into one state during KBSC)
        let required_propositions = states[0].propositions
        var source_state_names: [String] = []
        for state in states {
            assert(required_propositions == state.propositions, "states with different APs attempted to be merged")
            source_state_names.append(state.name)
        }

        let new_state_name = constructStateName(source_names: source_state_names)

        let common_tags = getCommonTags(states: states)

        // create new state that represents the marged state
        let new_state = AutomataState(name: new_state_name, propositions: required_propositions)

        for common_tag in common_tags {
            new_state.addAnnotation(annotation_name: common_tag)
        }

        return new_state
    }

    /**
     Goes through set of states and returns all tags which are included in ALL of these states
     */
    private static func getCommonTags(states: [AutomataState]) -> [String] {
        assert(states.count > 0)

        var return_array: [String] = []

        let tags = states[0].getAnnotation()

        for tag in tags {
            var tag_valid_forall_states = true

            for state in states {
                if !(state.containsAnnotation(annotationName: tag)) {
                    tag_valid_forall_states = false
                    break
                }
            }
            // if tag valid for all states add it to the returnlist
            if tag_valid_forall_states {
                return_array.append(tag)
            }
        }

        return return_array
    }

    /**
     Helper function that constructs unique state name whenever a set of states is merged to identify that merged state
     */
    public static func constructStateName(source_names: [String]) -> String {
        // build new state name with sorting on contained state-names so we maintain correctness
        var new_state_name_set = Set<String>()
        var new_state_name_array: [String] = []

        for name in source_names {
            let contained_numbers = name.split(separator: "s")
            for number in contained_numbers {
                let number_string = String(number)
                if !new_state_name_set.contains(number_string) {
                    new_state_name_set.insert(number_string)
                    new_state_name_array.append(number_string)
                }
            }
        }
        let new_state_name = "s" + new_state_name_array.sorted().joined(separator: "s")
        return new_state_name
    }

}
