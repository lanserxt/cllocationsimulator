//
//  CLLocationCombineSimulator.swift
//  LocationSimulator
//
//  Created by Anton Gubarenko on 28.08.2023.
//

import Foundation
import Combine
import MapKit

public final class CLLocationCombineSimulator: CLLocationBaseSimulator {
    
    //Publishers
    
    /// Publisher for Locations update
    public var locationsPublisher: AnyPublisher<[CLLocation], Never> {
        locations.share().eraseToAnyPublisher()
    }
    
    /// Publisher for Progress update
    public var progressPublisher: AnyPublisher<Double, Never> {
        progress.share().eraseToAnyPublisher()
    }
    
    /// Publisher for Progress update
    public var isActivePublisher: AnyPublisher<Bool, Never> {
        isActive.share().eraseToAnyPublisher()
    }
    
    /// Actual locations Publisher
    private var locations: PassthroughSubject<[CLLocation], Never> = .init()
    
    /// Actual progress Publisher
    private var progress: PassthroughSubject<Double, Never> = .init()
    
    /// Actual active status Publisher
    private var isActive: PassthroughSubject<Bool, Never> = .init()
    
   
    //MARK: - Overrides
    
    override func activeStateChanged(value: Bool) {
        super.activeStateChanged(value: value)
        isActive.send(value)
    }
    
    override func progressChanged(value: Double) {
        super.progressChanged(value: value)
        progress.send(value)
    }
    
    override func locationsChanged(value: [CLLocation]) {
        super.locationsChanged(value: value)
        locations.send(value)
    }
}
