//
//  WorkoutsListView.swift
//  Cardio Intervals
//
//  Created by Isak Jacobsson on 2024-04-07.
//

import SwiftUI



struct WorkoutsListView: View {
    @StateObject var workoutManager = WorkoutManager() 
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(workoutManager.workouts, id: \.id) { workout in
                    NavigationLink(destination: WorkoutView(workout: workout)) {
                        VStack(alignment: .leading) {
                            Text("\(workout.workoutName)")
                                .font(.title2)
                            Text("Active: \(workout.intervals[0].duration, specifier: "%.0f")s, Rest: \(workout.restDuration, specifier: "%.0f")s, Intervals: \(workout.numberOfIntervals)")
                                .font(.subheadline)
                        }
                    }
                    .listRowBackground(Color("Seethrough"))
                }
                .onDelete(perform: workoutManager.deleteWorkout)
                
                Section {
                    NavigationLink(destination: CreateWorkoutView(addWorkout: workoutManager.addWorkout, workoutNames: workoutManager.workoutNames)) {
                        Text("Create New Workout")
                    }
                    .listRowBackground(Color("Seethrough"))
                }
            }
            .scrollContentBackground(.hidden)
            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#4690E4"), colorScheme == .dark ? .black : .white, Color(hex: "#F3343E")]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .listRowSpacing(7)
            .navigationTitle("Workouts")
        }
        .onAppear {
            workoutManager.loadWorkoutNames()
        }
    }
}


#Preview {
    WorkoutsListView()
}
