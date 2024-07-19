//
//  IntervalSettingsView.swift
//  Cardio Intervals
//
//  Created by Isak Jacobsson on 2024-05-05.
//

import SwiftUI

struct IntervalSettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var speed = 50.0
    
    var body: some View {
        VStack {
            Slider(
                value: $speed,
                in: 0...100,
                minimumValueLabel: Text("\(speed, specifier: "%.0f")"),
                maximumValueLabel: Text("100"),
                label: {
                    Text("")
                }
            )
            .accentColor(Color.seethrough)
        }
        .padding()
    }
}
