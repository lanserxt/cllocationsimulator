//
//  ContentView.swift
//  LocationSimulator
//
//  Created by Anton Gubarenko on 28.08.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Progress")
            ProgressView(value: 0.5, total: 1.0)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
