//
//  CLLocationBaseSimulator.swift
//  LocationSimulator
//
//  Created by Anton Gubarenko on 08.09.2023.
//

import Foundation
import MapKit

/// Modes of locations emit
public enum CLLocationSimulatorMode {
    case emitEveryInterval(time: TimeInterval)
    
    case emitOnTimestamp
}

public class CLLocationBaseSimulator {
    
    //Methods to update values

    func activeStateChanged(value: Bool) {}
    
    func progressChanged(value: Double) {}
    
    func locationsChanged(value: [CLLocation]) {}
    
    //Inner variables
    private var locationsUsed: [CLLocation] = []
    private var locationsLeft: [CLLocation] = []
    
    /// Base timer to send values
    private var emitTimer: Timer?
    
    private var totalLocations: Int = 0
    
    /// Constructor
    /// - Parameter locations: CLLocations array
    public init(locations: [CLLocation]) {
        locationsLeft = locations
        totalLocations = locationsLeft.count
    }
    
    /// Mode to emit values
    public var simulationMode: CLLocationSimulatorMode = .emitEveryInterval(time: 1.0)
    
    //MARK: - Timer starters
    
    /// Start sending first location from list as initial coordinate
    public func initialLocationEmit() {
        
        guard !self.locationsLeft.isEmpty else {return}
        
        //First location is the starting point
        
        emitTimer?.invalidate()
        emitTimer = nil
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[weak self] timer in
            guard let self else {return}
            if let firstLocation = self.locationsLeft.first {
                locationsChanged(value: [firstLocation])
            }
        }
        timer.tolerance = 0.5
        RunLoop.current.add(timer, forMode: .common)
        emitTimer = timer
        activeStateChanged(value: true)
    }
    
    /// Starting simulation based on mode
    public func start() {
        switch simulationMode {
        case .emitEveryInterval(time: let interval):
            emitOnInterval(interval: interval)
            break
        case .emitOnTimestamp:
            emitOnTimestamp()
            break
        }
    }
    
    /// Pause simulation
    public func pause() {
        emitTimer?.invalidate()
        emitTimer = nil
        activeStateChanged(value: false)
    }
    
    /// Reseting used locations and progress
    public func reset() {
        progressChanged(value: 0.0)
        
        var restoredArray = Array(locationsUsed)
        restoredArray.append(contentsOf: locationsLeft)
        locationsLeft = restoredArray
        locationsUsed.removeAll()
        
        emitTimer?.invalidate()
        emitTimer = nil
        
        progressChanged(value: 0.0)
        activeStateChanged(value: false)
        locationsChanged(value: [])
    }
    
    /// Emitting locations based on interval
    /// - Parameter interval: TimeInverval to send the new ones
    private func emitOnInterval(interval: TimeInterval) {
        
        emitTimer?.invalidate()
        emitTimer = nil
        
        guard !self.locationsLeft.isEmpty else {
            return
        }
        
        //Startign the timer based on set interval
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {[weak self] timer in
            guard let self else {return}
            
            let newLocation = locationsLeft.removeFirst()
            self.locationsUsed.append(newLocation)
            locationsChanged(value: [newLocation])
            progressChanged(value: Double(locationsUsed.count) / Double(totalLocations))
            guard !self.locationsLeft.isEmpty else {
                emitTimer?.invalidate()
                emitTimer = nil
                progressChanged(value: 1.0)
                activeStateChanged(value: false)
                return
            }
        }
        timer.tolerance = interval / 0.5
        RunLoop.current.add(timer, forMode: .common)
        emitTimer = timer
        timer.fire()
        activeStateChanged(value: true)
    }
    
    /// Timestamp that increases during timer ticks
    private var lastTimestamp: Date = Date(timeIntervalSince1970: 0)
    
    /// Timer interval for timestamp emits
    private let timestampInterval: Double = 0.3
    
    /// Emit based on locations timestamps
    private func emitOnTimestamp() {
        
        emitTimer?.invalidate()
        emitTimer = nil
        
        guard !self.locationsLeft.isEmpty else {
            return
        }
        
        //First point timestamp to sum on block
        lastTimestamp = (locationsLeft.first?.timestamp ?? Date())
        let timer = Timer.scheduledTimer(withTimeInterval: timestampInterval, repeats: true) {[weak self] timer in
            guard let self else {return}
            
            //Increasing current timestamp
            lastTimestamp += timestampInterval
            
            let newLocation = locationsLeft.first
            //Only locaton with timestamp that passed current timestamp
            guard newLocation?.timestamp ?? Date() < lastTimestamp, let newLocation else {
                return
            }
            locationsLeft.remove(at: 0)
            self.locationsUsed.append(newLocation)
            
            locationsChanged(value: [newLocation])
            progressChanged(value: Double(locationsUsed.count) / Double(totalLocations))
            
            guard !self.locationsLeft.isEmpty else {
                emitTimer?.invalidate()
                emitTimer = nil
                progressChanged(value: 1.0)
                activeStateChanged(value: false)
                return
            }
        }
        timer.tolerance = timestampInterval / 0.5
        RunLoop.current.add(timer, forMode: .common)
        emitTimer = timer
        activeStateChanged(value: true)
    }
}
