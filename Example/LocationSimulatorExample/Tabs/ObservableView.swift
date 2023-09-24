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
                    Image(systemName: "globe")
                    .resizable()
                        .frame(width: 32, height: 32)
                    if locationsSimulator.locations.isEmpty {
                        EmptyView()
                            .frame(height: 80)
                    } else {
                        ForEach(locationsSimulator.locations, id: \.self) { location in
                            VStack(alignment: .leading) {
                                Text("Lat:  \(location.coordinate.latitude, specifier: "%2.8f")")
                                Text("Lon:  \(location.coordinate.longitude, specifier: "%2.8f")")
                            }.padding(.all, 0)
                        }

                    }
                    Spacer()

                }.frame(height: 100)
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
            .navigationTitle("Observable")
        }
    }
}

@available(iOS 17, *)
#Preview {
    ObservableView()
}
