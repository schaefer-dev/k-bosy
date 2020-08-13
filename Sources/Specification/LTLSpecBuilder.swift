//
//  LTLSpecBuilder.swift
//  Automata
//
//  Created by Daniel Schäfer on 25.06.20.
//

import Foundation
import Automata
import Utils


public class LTLSpecBuilder {
    
    
    /**
     Core Function of the main use-case. Reads input files, performs candidate state search
        followed by knowledge-based subset construction. Finalizes the automaton afterwards
        to perform optimizations and returns the resulting LTL synthesis task.
     */
    public static func KBoSyAlgorithm(automataInfoPath: String, dotGraphPath: String, tagsAsAPs: Bool, aalta_backend: Bool = false, benchmarkEnabled: Bool = false) -> SynthesisSpecification {
        
        let mainBenchmark = Benchmark(name: "main()")
        mainBenchmark.start()
        
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
        
        let candidateStateSearchBenchmark = Benchmark(name: "candidateStateSearch()")
        candidateStateSearchBenchmark.start()
        
        let modelChecker = ModelCheckCaller(preexistingTags: manualTags, aalta_backend: aalta_backend)
        
        // Annotate algorithmically the remaining knowledgeTerms
        // this adds the tags also in the list of APs of automata
        let mcTags = modelChecker.generateTagsFromGuaranteesUsingMC(automata: &automata)
        
        candidateStateSearchBenchmark.stop()
        
        let kbscBenchmark = Benchmark(name: "kbsc()")
        kbscBenchmark.start()
        
        let kbsc = KBSConstructor(input_automata: automata)
        let obsAutomata = kbsc.run()
        
        kbscBenchmark.stop()
        
        obsAutomata.finalize()

        let spec = SynthesisSpecification(automata: obsAutomata, tags: mcTags, tagsAsAPs: tagsAsAPs, tag_knowledge_mapping: modelChecker.tagMapping)
        
        mainBenchmark.stop()
        
        if benchmarkEnabled {
            print("------BENCHMARK RESULTS------")
            candidateStateSearchBenchmark.report()
            kbscBenchmark.report()
            mainBenchmark.report()
        }
        
        return spec
    }
}
