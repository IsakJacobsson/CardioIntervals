//
//  WorkoutManager.swift
//  Cardio Intervals
//
//  Created by Isak Jacobsson on 2024-04-21.
//

import SwiftUI

class WorkoutManager: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var workoutNames: [String] = []
    
    init() {
        loadWorkoutNames()
    }
    
    func addWorkout(workoutName: String) {
        let newWorkout = Workout(workoutName: workoutName)
        workouts.append(newWorkout)
        saveWorkoutNames()
    }
    
    func deleteWorkout(at offsets: IndexSet) {
        for index in offsets {
            let workout = workouts[index]
            workout.removeData() // Remove data associated with the workout from UserDefaults
        }
        workouts.remove(atOffsets: offsets)
        saveWorkoutNames()
    }
    
    func saveWorkoutNames() {
        let workoutNames = workouts.map { $0.workoutName }
        UserDefaults.standard.set(workoutNames, forKey: "workoutNames")
    }
    
    func loadWorkoutNames() {
        guard let savedWorkoutNames = UserDefaults.standard.stringArray(forKey: "workoutNames") else { return }
        workouts = savedWorkoutNames.map { Workout(workoutName: $0) }
        self.workoutNames = savedWorkoutNames
    }
}

