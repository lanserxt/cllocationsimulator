//
//  LocationSimulatorApp.swift
//  LocationSimulator
//
//  Created by Anton Gubarenko on 28.08.2023.
//

import SwiftUI

@main
struct LocationSimulatorApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                CombineView()
                    .tabItem {
                        Label("Combine", systemImage: "location.fill")
                    }
                PublishersView()
                    .tabItem {
                        Label("Publisher", systemImage: "location.circle")
                    }
            }
        }
    }
}
