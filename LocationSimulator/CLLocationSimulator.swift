//
//  CLLocationSimulator.swift
//  LocationSimulator
//
//  Created by Anton Gubarenko on 28.08.2023.
//

import Foundation
import Combine
import MapKit

/// Modes of locations emit
enum CLLocationSimulatorMode {
    case emitEveryInterval(time: TimeInterval)
    
    case emitOnTimestamp
}

final class CLLocationSimulator: ObservableObject {
    
    //Publishers
    
    /// Publisher for Locations update
    var locationsPublisher: AnyPublisher<[CLLocation], Never> {
        locations.share().eraseToAnyPublisher()
    }
    
    /// Publisher for Progress update
    var progressPublisher: AnyPublisher<Double, Never> {
        progress.share().eraseToAnyPublisher()
    }
    
    /// Actual locations Publisher
    private var locations: PassthroughSubject<[CLLocation], Never> = .init()
    
    /// Actual progress Publisher
    private var progress: PassthroughSubject<Double, Never> = .init()
    
    @Published
    var isActive: Bool = false
    
    //Inner variables
    private var locationsUsed: [LocationData] = []
    private var locationsLeft: [LocationData] = []
    
    /// Base timer to send values
    private var emitTimer: Timer?
    
    private var totalLocations: Int = 0
    
    /// Constructor
    /// - Parameter locations: lo
    init(locations: [LocationData]) {
        locationsLeft = locations
        totalLocations = locationsLeft.count
    }
    
    init(gpsDataName: String) {
        let locationsParser = LocationFileParser()
        locationsLeft = locationsParser.parseJSONFromFile(named: gpsDataName) ?? []
        totalLocations = locationsLeft.count
    }
    
    /// Mode to emit values
    var simulationMode: CLLocationSimulatorMode = .emitEveryInterval(time: 0.3)
    
    //MARK: - Timer starters
    
    /// Start sending first location from list as initial coordinate
    func initialLocationEmit() {
        
        guard !self.locationsLeft.isEmpty else {return}
        
        //First location is the starting point
        
        emitTimer?.invalidate()
        emitTimer = nil
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[weak self] timer in
            guard let self else {return}
            if let firstLocation = self.locationsLeft.first {
                locations.send([firstLocation.location])
            }
        }
        timer.tolerance = 0.5
        RunLoop.current.add(timer, forMode: .common)
        emitTimer = timer
        isActive = true
    }
    
    /// Starting simulation based on mode
    func start() {
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
    func pause() {
        emitTimer?.invalidate()
        emitTimer = nil
        isActive = false
    }
    
    /// Reseting used locations and progress
    func reset() {
        progress.send(0.0)
        
        var restoredArray = Array(locationsUsed)
        restoredArray.append(contentsOf: locationsLeft)
        locationsLeft = restoredArray
        locationsUsed.removeAll()
        
        emitTimer?.invalidate()
        emitTimer = nil
        isActive = false
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
            locations.send([newLocation.location])
            progress.send(Double(locationsUsed.count) / Double(totalLocations))
            guard !self.locationsLeft.isEmpty else {
                emitTimer?.invalidate()
                emitTimer = nil
                progress.send(1.0)
                isActive = false
                return
            }
        }
        timer.tolerance = interval / 0.5
        RunLoop.current.add(timer, forMode: .common)
        emitTimer = timer
        isActive = true
    }
    
    /// Timestamp that increases during timer ticks
    private var lastTimestamp: Double = 0.0
    
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
        lastTimestamp = (locationsLeft.first?.t ?? 0.0)
        let timer = Timer.scheduledTimer(withTimeInterval: timestampInterval, repeats: true) {[weak self] timer in
            guard let self else {return}
            
            //Increasing current timestamp
            lastTimestamp += timestampInterval
            
            let newLocation = locationsLeft.first
            //Only locaton with timestamp that passed current timestamp
            guard newLocation?.t ?? 0.0 < lastTimestamp, let newLocation else {
                return
            }
            locationsLeft.remove(at: 0)
            self.locationsUsed.append(newLocation)
            
            locations.send([newLocation.location])
            progress.send(Double(locationsUsed.count) / Double(totalLocations))
            
            guard !self.locationsLeft.isEmpty else {
                emitTimer?.invalidate()
                emitTimer = nil
                progress.send(1.0)
                isActive = false
                return
            }
        }
        timer.tolerance = timestampInterval / 0.5
        RunLoop.current.add(timer, forMode: .common)
        emitTimer = timer
        isActive = true
    }
}
