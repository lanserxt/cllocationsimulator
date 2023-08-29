//
//  ContentView.swift
//  LocationSimulator
//
//  Created by Anton Gubarenko on 28.08.2023.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    @State
    private var emitMode = 0
    
    @State
    private var simulationProgress: Double = 0.0
    
    @StateObject
    private var locationsSimulator: CLLocationSimulator = CLLocationSimulator(gpsDataName: "gps")
    var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack {
            Text("Progress \(simulationProgress * 100.0, specifier: "%.2f")%")
            ProgressView(value: simulationProgress, total: 1.0)
            
            Picker("What is your favorite color?", selection: $emitMode) {
                            Text("1s").tag(0)
                            Text("timestamp").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.top, 24)
            HStack {
                Button {
                    locationsSimulator.start()
                } label: {
                    Text("Start")
                }
                Spacer()
                Button {
                    locationsSimulator.pause()
                } label: {
                    Text("Pause")
                }
            }.padding()
            
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
