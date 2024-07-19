//
//  WorkoutInfoComponent.swift
//  Cardio Intervals
//
//  Created by Isak Jacobsson on 2024-05-04.
//

import SwiftUI

struct WorkoutInfoComponent: View {
    @ObservedObject var workout: Workout
    
    @State private var isExpanded = false
    
    
    var body: some View {
        HStack {
            Spacer()
            
            if isExpanded {
                VStack {
                    HStack {
                        Button(action: {
                            workout.decreaseActiveDuration(with: 1)
                        }) {
                            Image(systemName: "minus")
                                .padding(.trailing)
                                .opacity(workout.intervals[0].duration == 1 ? 0.5 : 1)
                        }
                        .disabled(workout.intervals[0].duration == 1)
                        Spacer()
                        VStack {
                            Text("\(workout.intervals[0].duration, specifier: "%.0f")s")
                                .font(.title)
                            Text("ACTIVE")
                        }
                        Spacer()
                        Button(action: {
                            workout.increaseActiveDuration(with: 1)
                        }) {
                            Image(systemName: "plus")
                                .padding(.leading)
                        }
                    }
                    .padding(.bottom)
                    
                    HStack {
                        
                        Button(action: {
                            workout.decreaseRestDuration(with: 1)
                        }) {
                            Image(systemName: "minus")
                                .padding(.trailing)
                                .opacity(workout.restDuration == 1 ? 0.5 : 1)
                        }
                        .disabled(workout.restDuration == 1.0)
                        Spacer()
                        VStack {
                            Text("\(workout.restDuration, specifier: "%.0f")s")
                                .font(.title)
                            Text("REST")
                        }
                        Spacer()
                        Button(action: {
                            workout.increaseRestDuration(with: 1)
                        }) {
                            Image(systemName: "plus")
                                .padding(.leading)
                        }
                    }
                    .padding(.bottom)
                    
                    HStack {
                        Button(action: {
                            workout.decreaseIntervals()
                        }) {
                            Image(systemName: "minus")
                                .padding(.trailing)
                                .opacity(workout.numberOfIntervals == 1 ? 0.5 : 1)
                        }
                        .disabled(workout.numberOfIntervals == 1)
                        Spacer()
                        VStack {
                            Text("\(workout.numberOfIntervals)")
                                .font(.title)
                            Text("INTERVALS")
                        }
                        Spacer()
                        Button(action: {
                            workout.increaseIntervals(with: 1)
                        }) {
                            Image(systemName: "plus")
                                .padding(.leading)
                        }
                    }
                    .padding(.bottom)
                    
                    Button(action: {
                        isExpanded = false
                    }) {
                        Image(systemName: "chevron.compact.up")
                    }
                }
                .padding()
                .background(Color(hex: "#4690E4"))
                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                .foregroundColor(.white)
            } else {
                VStack {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                        VStack {
                            Text("\(workout.intervals[0].duration, specifier: "%.0f")s")
                                .font(.title)
                            Text("ACTIVE")
                        }

                        VStack {
                            Text("\(workout.restDuration, specifier: "%.0f")s")
                                .font(.title)
                            Text("REST")
                        }

                        VStack {
                            Text("1")
                                .font(.title)
                                .fontWeight(.bold)
                                + Text(" / \(workout.numberOfIntervals)")
                                .font(.title)
                            Text("INTERVALS")
                        }
                    }
                    .padding(.bottom)
                    
                    Image(systemName: "chevron.compact.down")
                }
                .padding()
                .background(Color(hex: "#4690E4"))
                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                .foregroundColor(.white)
                .onTapGesture {
                    isExpanded = true
                }
            }
            
            Spacer()
        }
        .onAppear {
            isExpanded = false
        }
    }
}
