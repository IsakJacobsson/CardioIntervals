//
//  ContentView.swift
//  Cardio Intervals
//
//  Created by Isak Jacobsson on 2024-03-31.
//

import SwiftUI

struct WorkoutView: View {
    @ObservedObject var workout: Workout
    
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var spotifyController = SpotifyController.shared
    
    var body: some View {
        VStack {
            Group {
                if workout.showTimerView {
                    WorkoutTimerView(workout: workout)
                } else {
                    WorkoutInfoView(workout: workout)
                }
            }
        }
        .navigationTitle(workout.workoutName)
        .onOpenURL { url in
            spotifyController.setAccessToken(from: url)
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#4690E4"), colorScheme == .dark ? .black : .white, Color(hex: "#F3343E")]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}
