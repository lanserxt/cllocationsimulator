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
        let _ = Self._printChanges()
        VStack {
            Text("Progress \(simulationProgress * 100.0, specifier: "%.2f")%")
                .border(.debug, width: 2.0)
            ProgressView(
                value: simulationProgress, total: 1.0)
            
            Picker("What is your favorite color?", selection: $emitMode) {
                            Text("1s").tag(0)
                            Text("timestamp").tag(1)
                        }
                        .pickerStyle(.segmented)
                        .padding(.top, 24)
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
                } label: {
                    Text("Stop")
                }
            }.padding()
            
        }
        .border(.debug, width: 2.0)
        .overlay {
            VStack {
                HStack {
                    
                Spacer()
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
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
