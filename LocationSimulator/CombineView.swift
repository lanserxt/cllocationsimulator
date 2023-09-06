//
//  CombineView.swift
//  LocationSimulator
//
//  Created by Anton Gubarenko on 28.08.2023.
//

import SwiftUI
import Combine
import CoreLocation

struct CombineView: View {
    
    @State
    private var emitMode = 0
    
    @State
    private var simulationProgress: Double = 0.0
    
    @State
    private var locations: [CLLocation] = []
    
    @StateObject
    private var locationsSimulator: CLLocationSimulator = CLLocationSimulator(gpsDataName: "gps")
    var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        NavigationView {
            VStack {
                
                VStack {
                    Image(systemName: "globe")
                    .resizable()
                        .frame(width: 32, height: 32)
                    if locations.isEmpty {
                        EmptyView()
                            .frame(height: 80)
                    } else {
                        ForEach(locations, id: \.self) { location in
                            VStack(alignment: .leading) {
                                Text("Lat:  \(location.coordinate.latitude, specifier: "%2.8f")")
                                Text("Lon:  \(location.coordinate.longitude, specifier: "%2.8f")")
                            }.padding(.all, 0)
                        }

                    }
                    Spacer()

                }.frame(height: 100).border(.debug)
                    .padding(.top, 24)
                Spacer()
                HStack {
                    Text("Progress \(simulationProgress * 100.0, specifier: "%.2f")%")
                    Spacer()
                }
                ProgressView(
                    value: simulationProgress, total: 1.0)
               
                Text("Simulation mode")
                    .font(.headline)
                    .padding(.top, 24)
                Picker("", selection: $emitMode) {
                    Text("1 second").tag(0)
                    Text("on timestamp").tag(1)
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
                        Text(locationsSimulator.isActive ? "Pause" : "Start")
                    }
                    Spacer()
                    Button {
                        locationsSimulator.reset()
                        locations = []
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
                if newValue == 0 {
                    locationsSimulator.simulationMode = .emitEveryInterval(time: 1.0)
                } else {
                    locationsSimulator.simulationMode = .emitOnTimestamp
                }
                locationsSimulator.start()
            }
            .onReceive(locationsSimulator.progressPublisher) { progress in
                simulationProgress = progress
            }
            .onReceive(locationsSimulator.locationsPublisher) { locs in
                locations = locs
            }
            .navigationTitle("Simulation")
        }
    }
}

extension ShapeStyle where Self == Color {
    static var debug: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
struct CombineView_Previews: PreviewProvider {
    static var previews: some View {
        CombineView()
    }
}
