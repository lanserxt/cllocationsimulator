//
//  CLLocationObservableSimulator.swift
//  LocationSimulator
//
//  Created by Anton Gubarenko on 08.09.2023.
//

import MapKit
import SwiftUI

@available(iOS 17, *)
@Observable
public final class CLLocationObservableSimulator: CLLocationBaseSimulator {
    
    /// Actual locations Publisher
    public var locations: [CLLocation] = []
    
    /// Actual progress Publisher
    public var progress: Double = 0.0
    
    /// Actual active status Publisher
    public var isActive: Bool = false
    
   
    //MARK: - Overrides
    
    override func activeStateChanged(value: Bool) {
        super.activeStateChanged(value: value)
        isActive = value
    }
    
    override func progressChanged(value: Double) {
        super.progressChanged(value: value)
        progress = value
    }
    
    override func locationsChanged(value: [CLLocation]) {
        super.locationsChanged(value: value)
        locations = value
    }
}
