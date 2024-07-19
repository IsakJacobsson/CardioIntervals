//
//  CreateWorkoutView.swift
//  Cardio Intervals
//
//  Created by Isak Jacobsson on 2024-04-07.
//

import SwiftUI

struct CreateWorkoutView: View {
    var addWorkout: (String) -> Void
    var workoutNames: [String]
    
    @State private var workoutName = ""
    @State private var numberOfIntervals = 3
    @State private var activeDuration: Double = 45
    @State private var restDuration: Double = 15
    @State private var startMusicAt: Int = 0
    
    @State private var workoutNameWarning = false
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            
            Spacer()
            
            VStack(alignment: .leading) {
                
                HStack {
                    Text("Workout Name:")
                        .font(.title2)
                    
                    TextField("", text: $workoutName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red, lineWidth: workoutNameWarning ? 2 : 0) // Apply red border conditionally
                        )
                }
                
                if workoutNameWarning {
                    Text("A workout with this name already exists")
                        .foregroundColor(.red)
                }
                
                
                // Input field for number of intervals
                Stepper(value: $numberOfIntervals, in: 1...100, label: {
                    Text("Number of Intervals: \(numberOfIntervals)")
                        .font(.title2)
                })
                
                // Input field for active duration
                Stepper(value: $activeDuration, in: 5...360, step: 5, label: {
                    Text("Active Duration: \(activeDuration, specifier: "%.0f")")
                        .font(.title2)
                })
                
                // Input field for rest duration
                Stepper(value: $restDuration, in: 0...360, step: 5, label: {
                    Text("Rest Duration: \(restDuration, specifier: "%.0f")")
                        .font(.title2)
                })
                
                // Input field for active duration
                Stepper(value: $startMusicAt, in: 0...100, step: 1, label: {
                    Text("Start Music At: \(startMusicAt)")
                        .font(.title2)
                })
            }
            .padding()
            
            Spacer()
            
            // Button to create the workout with the specified parameters
            Button(action: {
                if workoutNames.contains(workoutName) {
                    workoutNameWarning = true
                } else {
                    Workout(workoutName: self.workoutName, numberOfIntervals: self.numberOfIntervals, activeDuation: self.activeDuration, restDuration: self.restDuration, startMusicAt: self.startMusicAt)
                    self.addWorkout(self.workoutName)
                    self.presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Create Workout")
                    .padding()
                    .font(.title)
            }
            .disabled(self.isDisabled())
            .navigationTitle("New Workout")
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#4690E4"), colorScheme == .dark ? .black : .white, Color(hex: "#F3343E")]), startPoint: .topLeading, endPoint: .bottomTrailing))
    }
    
    func isDisabled() -> Bool {
        return self.workoutName == ""
    }
}
