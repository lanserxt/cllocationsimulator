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
    
    /// Publisher for Heading updates
    var headingPublisher: AnyPublisher<CLHeading, Never> {
        heading.share().eraseToAnyPublisher()
    }
    
    var progressPublisher: AnyPublisher<Double, Never> {
        progress.share().eraseToAnyPublisher()
    }
    
    /// Actual locations Publisher
    private var locations: PassthroughSubject<[CLLocation], Never> = .init()
    
    /// Actual heading Publisher
    private var heading: PassthroughSubject<CLHeading, Never> = .init()
    
    /// Actual progress Publisher
    private var progress: PassthroughSubject<Double, Never> = .init()
    
    @Published
    var isActive: Bool = false
    
    //Inner variables
    private var locationsUsed: [LocationData] = []
    private var locationsLeft: [LocationData] = []
    private var lastLocation: LocationData? = nil
    
    /// Base timer to send values
    private var emitTimer: Timer?
    
    /// Constructor
    /// - Parameter locations: lo
    init(locations: [LocationData]) {
        locationsLeft = locations
    }
    
    init(gpsDataName: String) {
        let locationsParser = LocationFileParser()
        locationsLeft = locationsParser.parseJSONFromFile(named: gpsDataName) ?? []
    }
    
    /// Mode to emit values
    var simulationMode: CLLocationSimulatorMode = .emitEveryInterval(time: 1.0)
    
    //MARK: - Timer starters
    
    /// Start sending first location from list as initial coordinate
    func initialLocationEmit() {
        
        guard !self.locationsLeft.isEmpty else {return}
        
        //First location is the starting point
        lastLocation = locationsLeft.first
        
        emitTimer?.invalidate()
        emitTimer = nil
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) {[weak self] timer in
            guard let self else {return}
            if let lastLocation {
                locations.send([lastLocation.location])
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
        
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {[weak self] timer in
            guard let self else {return}
            
            let newLocation = locationsLeft.removeFirst()
            self.lastLocation = newLocation
            self.locationsUsed.append(newLocation)
            locations.send([newLocation.location])
            progress.send(Double(locationsUsed.count) / Double(locationsLeft.count))
            
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
    
    /// Emit based on locations timestamps
    private func emitOnTimestamp() {
        
        emitTimer?.invalidate()
        emitTimer = nil
        
        guard !self.locationsLeft.isEmpty else {
            return
        }
        
        //First point emit
        var interval = 1.0
        if lastLocation != nil {
            interval = (locationsLeft.first?.t ?? 0.0) - (lastLocation?.t ?? 0.0)
        }
        
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) {[weak self] timer in
            guard let self else {return}
            let newLocation = locationsLeft.removeFirst()
            self.lastLocation = newLocation
            self.locationsUsed.append(newLocation)
            
            locations.send([newLocation.location])
            progress.send(Double(locationsUsed.count) / Double(locationsLeft.count))
            
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
}
