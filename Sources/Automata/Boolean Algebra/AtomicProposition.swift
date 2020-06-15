//
//  File.swift
//  
//
//  Created by Daniel Schäfer on 28.04.20.
//

import Foundation

public class APList {
    private var mapping: [String: AP]
    private var bitsetAPIndexMap: [String: Int]
    private var bitsetIndexToAPName: [String]

    public init() {
        mapping = [String: AP]()
        bitsetAPIndexMap = [String: Int]()
        bitsetIndexToAPName = []
    }

    public func addAP(ap: AP) {
        if mapping[ap.name] != nil {
            assert(false, "CRITICAL ERROR: tried to add already contained AP into APList")
            return
        }
        mapping[ap.name] = ap

        // add output AP to bitset_ap_index_map and bitset_index_to_ap_string
        if ap.output {
            bitsetAPIndexMap[ap.name] = bitsetAPIndexMap.count
            bitsetIndexToAPName.append(ap.name)
        }
    }

    public func lookupAP(apName: String) -> AP? {
        if let ap = mapping[apName] {
                return ap
            } else {
                return nil
            }
    }

    public func get_bitset_ap_index_map() -> [String: Int] {
        return self.bitsetAPIndexMap
    }

    public func get_bitset_index_to_ap_string_map() -> [String] {
        return self.bitsetIndexToAPName
    }

    /**
     returns all APs that are part of this Automata structure sorted by AP name
     */
    public func get_allAPs() -> [AP] {
        var apList: [AP] = []

        for ap in self.mapping {
            apList.append(ap.value)
        }

        // sorting happens to guarantee deterministic behaviour of Assumptions-generation which improves ability to test in these cases
        let apListSorted = apList.sorted { $0.name < $1.name }

        return apListSorted
    }

    /**
     returns all obversable APs that are part of this Automata structure sorted by AP name
     */
    public func get_allObservableAPs() -> [AP] {
        var apList: [AP] = []

        for ap in self.mapping {
            if ap.value.obs {
                apList.append(ap.value)
            }
        }

        // sorting happens to guarantee deterministic behaviour of Assumptions-generation which improves ability to test in these cases
        let apListSorted = apList.sorted { $0.name < $1.name }

        return apListSorted
    }

    /**
     returns all obversable APs that are part of this Automata structure sorted by AP name
     */
    public func get_allOutputAPs() -> [AP] {
        var apList: [AP] = []

        for ap in self.mapping {
            if ap.value.output {
                apList.append(ap.value)
            }
        }

        // sorting happens to guarantee deterministic behaviour of Assumptions-generation which improves ability to test in these cases
        let apListSorted = apList.sorted { $0.name < $1.name }

        return apListSorted
    }
}

// make id and obs non-changable!
public class AP: Hashable, CustomStringConvertible, Comparable {
    var name: String
    var obs: Bool
    var output: Bool

    public var description: String {
         return name
     }

    public init(name: String, observable: Bool, list: APList, output: Bool = false) {
        self.name = name
        self.obs = observable
        self.output = output

        // ERROR if already contained
        assert(list.lookupAP(apName: name) == nil, "ERROR: added AP " + name + " which was already contained in List.")

        list.addAP(ap: self)
    }

    public static func == (ap1: AP, ap2: AP) -> Bool {
        return ap1.name == ap2.name
    }

    public static func < (ap1: AP, ap2: AP) -> Bool {
        return ap1.name < ap2.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
