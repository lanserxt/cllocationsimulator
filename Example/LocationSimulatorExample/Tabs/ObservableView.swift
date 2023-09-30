//
//  ObservableView.swift
//  LocationSimulatorExample
//
//  Created by Anton Gubarenko on 23.09.2023.
//

import SwiftUI
import CoreLocation
import CLLocationSimulator
import MapKit

@available(iOS 17, *)
struct ObservableView: View {
    
    @State
    private var emitMode: SimulatorMode = .emitOnInterval
    
    @State
    private var locations: [CLLocation] = []
    
    @ObservedObject
    private var locationsSimulator: CLLocationPublisherSimulator
    
    init() {
        let locationsParser = LocationFileParser()
        let parsedLocations: [LocationData] = (locationsParser.parseJSONFromFile(named: "gps") ?? [])
        
        locationsSimulator = CLLocationPublisherSimulator(locations: parsedLocations.compactMap({$0.location}))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                VStack {
                    Map {
                        if let currentLocation = locations.last {
                            Marker("", systemImage: "location.circle", coordinate: currentLocation.coordinate)
                                .tint(.orange)
                        }
                        if !locations.isEmpty {
                            MapPolyline(coordinates: locations.compactMap({$0.coordinate}), contourStyle: .straight)
                                .stroke(Color.blue, lineWidth: 4)
                        }
                        
                    }
                    .mapControlVisibility(.hidden)
                    
                }
                .padding(.top, 24)
                
                Spacer()
                HStack {
                    Text("Progress \(locationsSimulator.progress * 100.0, specifier: "%.2f")%")
                    Spacer()
                }
                ProgressView(
                    value: locationsSimulator.progress, total: 1.0)
                
                Text("Simulation mode")
                    .font(.headline)
                    .padding(.top, 24)
                Picker("", selection: $emitMode) {
                    Text("1 second").tag(SimulatorMode.emitOnInterval)
                    Text("on timestamp").tag(SimulatorMode.emitOnTimestamp)
                }
                .pickerStyle(.segmented)
                HStack {
                    Button {
                        if locationsSimulator.isActive {
                            locationsSimulator.pause()
                        } else {
                            locationsSimulator.start()
                        }
                    } label: {
                        if locationsSimulator.isActive {
                            Text("Pause")
                        } else {
                            if locationsSimulator.locations.isEmpty {
                                Text("Start")
                            } else {
                                Text("Continue")
                            }
                        }
                        
                    }
                    Spacer()
                    Button {
                        locationsSimulator.reset()
                        locations.removeAll()
                    } label: {
                        Text("Stop")
                    }
                }.padding()
                    .padding(.top, 24)
                Spacer()
                
            }
            .frame(maxHeight: .infinity)
            .overlay {
                VStack {
                    HStack {
                        
                        Spacer()
                        Text("Active")
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(locationsSimulator.isActive ? .green : .red)
                    }
                    Spacer()
                }
            }
            .padding()
            .onChange(of: emitMode) { newValue in
                locationsSimulator.pause()
                if newValue == .emitOnTimestamp {
                    locationsSimulator.simulationMode = .emitOnTimestamp
                } else {
                    locationsSimulator.simulationMode = .emitOnInterval(time: 1.0)
                }
                locationsSimulator.start()
            }
            .onChange(of: locationsSimulator.locations) { newLocations in
                locations.append(contentsOf: newLocations)
            }
            .onAppear {
                locationsSimulator.initialLocationEmit()
            }
            .navigationTitle("Observable")
        }
    }
}

@available(iOS 17, *)
#Preview {
    ObservableView()
}
