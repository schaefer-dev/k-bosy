//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 01.06.20.
//

import Foundation

public class KBSConstructor {

    private let inputAutomata: Automata
    private var obsAutomata: Automata

    private var newToOldStatesMapping: [AutomataState: [AutomataState]]

    /**
     Assumes that finalize has not been called yet on given input automata
     */
    public init(input_automata: Automata) {
        input_automata.reduceToObservablePart()
        input_automata.finalize()
        self.inputAutomata = input_automata

        let newAPList = input_automata.apList

        var newAllStates = [String: AutomataState]()

        
        /**
         TODO: think later about this 'limitation' is reasonable.
         Not sure if different observable APs in different initial states can already be used to distinguish in which state the environment currently is
         */
        // Merge previous initial states into one state
        let newInitialState = KBSCUtils.mergeStatesIntoNewState(states: input_automata.initialStates)
        let newInitialStates: [AutomataState] = [newInitialState]
        newAllStates[newInitialState.name] = newInitialState

        self.newToOldStatesMapping = [AutomataState: [AutomataState]]()
        self.newToOldStatesMapping[newInitialState] = input_automata.initialStates

        self.obsAutomata = Automata(apList: newAPList, initialStates: newInitialStates, allStates: newAllStates, guarantees: input_automata.guarantees)
    }

    /**
     Perform Knowledge Based Subset Construction and return the observational Automata
     */
    public func run() -> Automata {
        // only initial states exist currently, we have to analyze all those states
        var stateAnalyzeQueue: [AutomataState] = self.obsAutomata.initialStates

        // repeat until all states have been analyzed
        while stateAnalyzeQueue.count > 0 {
            let analyzedState = stateAnalyzeQueue.removeFirst()
            // print("KBSC: analyzing state '" + analyzedState.description + "' in obs Automata now.")

            // Builds the Transitions in `new_state` according to the behaviour in the old corresponding states given in `old_states`.

            let bitsetAPIndexMap = self.obsAutomata.apList.get_bitset_ap_index_map()
            let currentBitsetCondition = Bitset(size: bitsetAPIndexMap.count, truth_value: false)

            // check behaviour for current_bitset_condition until all possible combination of truth values have been checked. This is the case whenever the bitset can no longer be incremented.
            repeat {
                // lookup old states that were merged into the currently analyzed state
                let oldStates: [AutomataState] = self.newToOldStatesMapping[analyzedState]!

                let oldStatesSuccessors = getPossibleSuccessorsUnderCondition(condition: currentBitsetCondition, startStates: oldStates)

                // divide possible successor states into sets that each contain environment-states which can not be distinguished by their APs
                let obsEqStateClasses = KBSCUtils.divideStatesByAPs(inputStates: oldStatesSuccessors)

                for obsEqStateSet in obsEqStateClasses {

                    let (obsSuccessorState, isNewState) = getObsEqState(obsEqStateSet: obsEqStateSet)

                    if isNewState {
                        // if new state was created we put it in the queue to observe its possible successors later
                        stateAnalyzeQueue.append(obsSuccessorState)
                    }

                    // create the transition from 'analyzed_state' to 'obs_successor_state' with condition 'current_bitset_condition' and add it to the state 'analyzed_state'
                    createTransitionFromBitset(bs: currentBitsetCondition, start: analyzedState, end: obsSuccessorState)
                }

            } while (currentBitsetCondition.increment())

        }
        return self.obsAutomata
    }

    /**
     Returns the set of possible successors of all states given as `start_states` with the condition `condition` holding for all taken transitions.
     */
    private func getPossibleSuccessorsUnderCondition(condition: Bitset, startStates: [AutomataState]) -> [AutomataState] {
        // determine the successor states of each of those old states for this particular bitset conditon
        var oldStateSuccessors: [AutomataState] = []
        for state in startStates {
            for transition in state.transitions {
                // check if current_bitset_condition assumption satisfies condition for this transition.
                if transition.condition.bitsetRepresentation.holdsUnderAssumption(assumptionBS: condition) {
                    oldStateSuccessors.append(transition.end)
                }
            }
        }

        // print("KBSC: Successors " + oldStateSuccessors.description + " possible according to original automata using condition " + condition.description)
        return oldStateSuccessors
    }

    /**
     Check if a state that contains all the states given as argument already exists.
     If yes, return a reference to this existing state and also return false.
     If no, create a new state that corresponds to this set of states and add it to the automata structure and then return a reference to this new state. Also return true.
     */
    private func getObsEqState(obsEqStateSet: [AutomataState]) -> (AutomataState, Bool) {
        // check before creating adding new state if it already exists
        var obsSuccessorState = KBSCUtils.mergeStatesIntoNewState(states: obsEqStateSet)
        if self.obsAutomata.get_state(name: obsSuccessorState.name) == nil {
            // obs_successor_state is in fact new and thus has to be added to the obs automata structures
            self.newToOldStatesMapping[obsSuccessorState] = obsEqStateSet
            // print("KBSC: newly discovered state " + obsSuccessorState.name + " added to observational automata.")
            self.obsAutomata.add_state(newState: obsSuccessorState)

            return (obsSuccessorState, true)
        } else {
            /**
             new_successor_state is not new -> abort newly created state and move reference to the already existing one
             such that the following transition creation links to the already existing state in the structure
            */
            obsSuccessorState = self.obsAutomata.get_state(name: obsSuccessorState.name)!
            return (obsSuccessorState, false)
        }
    }

    /**
     Create a AutomataTransition in `start` that goes from state `start` to state `end` with the condition `bs`.
     */
    private func createTransitionFromBitset(bs: Bitset, start: AutomataState, end: AutomataState) {
        let transitionFormula = KBSCUtils.naiveBitsetToFormula(bs: bs, apList: self.obsAutomata.apList)
        let newFoundTransition = AutomataTransition(start: start, condition: transitionFormula, end: end)
        start.addTransition(trans: newFoundTransition)
    }

}
