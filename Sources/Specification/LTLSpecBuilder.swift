//
//  LTLSpecBuilder.swift
//  Automata
//
//  Created by Daniel Schäfer on 25.06.20.
//

import Foundation
import Automata


public class LTLSpecBuilder {
        
    public static func prepareSynthesis(automataInfoPath: String, dotGraphPath: String, tagsAsAPs: Bool) -> SynthesisSpecification {
        
        // Read Automata Info File
        let automataInfoOpt = FileParser.readAutomataInfoFile(path: automataInfoPath)
        if automataInfoOpt == nil {
            print("ERROR: something went wrong while reading AutomataInfo File")
            exit(EXIT_FAILURE)
        }
        var automataInfo = automataInfoOpt!
        print("LOADING: Automata Info read successfully")
        
        // already apply transformation rules in case they are given in automataInfo
        let tagMappingOpt = automataInfo.getTagToCandidateStatesMapping()
        
        
        let automataOpt = FileParser.readDotGraphFile(path: dotGraphPath, info: automataInfo)
        if automataOpt == nil {
            print("ERROR: something went wrong while reading Automata Graph File")
            exit(EXIT_FAILURE)
        }
        var automata = automataOpt!

        
        var manualTags: [String] = []
        
        if tagMappingOpt != nil {
            // case for mapping from tags to candidate sates is given in specification
            var candidateStateNames: [[String]] = []
            (manualTags, candidateStateNames) = tagMappingOpt!
            automata.addTagsToCandidateStates(tags: manualTags, candidateStateNames: candidateStateNames)
        }
        
        let modelChecker = ModelCheckCaller(preexistingTags: manualTags)
        
        // Annotate algorithmically the remaining knowledgeTerms
        // this adds the tags also in the list of APs of automata
        let mcTags = modelChecker.generateTagsFromGuaranteesUsingMC(automata: &automata)
        
        

        let kbsc = KBSConstructor(input_automata: automata)

        let obsAutomata = kbsc.run()
        obsAutomata.finalize()

        let spec = SynthesisSpecification(automata: obsAutomata, tags: mcTags, tagsAsAPs: tagsAsAPs, tag_knowledge_mapping: modelChecker.tagMapping)
        
        return spec
    }
}
