//
//  Benchmark.swift
//  Automata
//
//  Created by Daniel Schäfer on 13.08.20.
//

import Foundation


public class Benchmark {
    
    var name: String
    var startTime: CFAbsoluteTime?
    var stopTime: CFAbsoluteTime?
    
    public init(name: String) {
        self.name = name
        self.startTime = nil
        self.stopTime = nil
    }
    
    public func start() {
        if (self.startTime != nil) {
            print("ERROR: Benchmark for \(self.name) was attempted to be started a second time!")
        }
        self.startTime = CFAbsoluteTimeGetCurrent()
    }
    
    public func stop() {
        if (self.startTime == nil) {
            print("ERROR: Benchmark for \(self.name) was not started yet but attempted to end")
        }
        if (self.stopTime != nil) {
            print("ERROR: Benchmark for \(self.name) was attempted to be stopped a second time!")
        }
        
        self.stopTime = CFAbsoluteTimeGetCurrent()
    }
    
    
    public func report() {
        if (self.stopTime == nil || self.startTime == nil) {
            print("ERROR: Benchmark for \(self.name) was not started or stopped correctly")
        }
        let timeElapsed = self.stopTime! - self.startTime!
        let timeRounded = roundDouble(number: timeElapsed, toPlaces: 4)
        print("Time elapsed during \(self.name): \(timeRounded)s.")
    }
    
    func roundDouble(number: Double, toPlaces:Int) -> Double {
        let divisor = pow(10.0, Double(toPlaces))
        return (number * divisor).rounded() / divisor
    }
    
}
