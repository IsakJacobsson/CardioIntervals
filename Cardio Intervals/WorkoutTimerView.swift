//
//  WorkoutTimerView.swift
//  Cardio Intervals
//
//  Created by Isak Jacobsson on 2024-04-06.
//

import SwiftUI

struct WorkoutTimerView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var workout: Workout
    @ObservedObject var spotifyController = SpotifyController.shared
    
    @State private var skipButtonIsPressed = false
    
    @State private var showSheet = false
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                if let currentTrackImage = spotifyController.currentTrackImage {
                    Image(uiImage: currentTrackImage)
                        .resizable()
                        .scaledToFit()
                        .blur(radius: 2)
                        .edgesIgnoringSafeArea(.all)
                        .overlay(
                                Rectangle()
                                    .foregroundColor(colorScheme == .dark ? Color.black.opacity(0.5) : Color.white.opacity(0.5))
                            )
                }
                
                VStack {
                    if workout.currentPhase == .active {
                        Text("ACTIVE")
                            .font(.largeTitle)
                            .onAppear {
                                if workout.currentInterval != 0 {
                                    spotifyController.skip()
                                    
                                    if !spotifyController.isConnected {
                                        spotifyController.authorize(playURI: "", toPosition: workout.intervals[workout.currentInterval].startMusicAt, skip: true)
                                    }
                                }
                                let startMusicAt = workout.intervals[workout.currentInterval].startMusicAt
                                spotifyController.seek(toPosition: startMusicAt)
                            }
                    } else {
                        Text("REST")
                            .font(.largeTitle)
                            .onAppear {
                                spotifyController.pause()
                            }
                    }
                    
                    
                    Text("\(floor(workout.timeRemaining), specifier: "%.0f")")
                        .font(.system(size: 150))
                    
                    Text("Interval ")
                        .font(.title)
                    + Text("\(workout.currentInterval+1)")
                        .fontWeight(.bold)
                        .font(.title)
                    + Text(" / \(workout.numberOfIntervals)")
                        .font(.title)
                    
                }
            }
            .frame(width: 300, height: 300)
            .foregroundColor(colorScheme == .dark ? .white : .black)
            //.background(workout.currentPhase == .active ? Color(hex: "#4690E4") : Color(hex: "#F3343E"))
            .clipShape(RoundedRectangle(cornerRadius: 24.0))
            .shadow(radius: 8)
            
            Spacer()
            
            HStack {
                HStack {
                    Spacer()
                    Button(action: {
                        showSheet = true
                    }) {
                        Image(systemName: "stop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 75, height: 75)
                            .foregroundColor(workout.timerPaused ? .red : .gray)
                    }
                    .actionSheet(isPresented: $showSheet) {
                        ActionSheet(
                            title: Text("End Workout?"),
                            buttons:
                                [
                                    .destructive(Text("Yes, I'm Done!"),
                                                 action: {
                                                     workout.stopTimer()
                                                 }),
                                    .cancel()
                                ]
                        )
                    }
                    .disabled(!self.workout.timerPaused)
                    
                    Spacer()
                    
                    if workout.timerPaused {
                        Button(action: {
                            workout.startTimer()
                            
                            if workout.currentPhase == .active {
                                if !spotifyController.isConnected {
                                    spotifyController.authorize(playURI: "")
                                }
                                else {
                                    spotifyController.resume()
                                }
                            }
                        }) {
                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 75, height: 75)
                                .foregroundColor(.green)
                        }
                        .padding()
                    } else {
                        Button(action: {
                            workout.pauseTimer()
                            
                            spotifyController.pause()
                        }) {
                            Image(systemName: "pause.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 75, height: 75)
                                .foregroundColor(.yellow)
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        workout.nextInterval()
                    }) {
                        Image(systemName: "forward.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 75, height: 75)
                            .foregroundColor(.orange)
                    }
                    Spacer()
                }
                .background(Color("Seethrough"))
                .clipShape(RoundedRectangle(cornerRadius: 24.0))
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            spotifyController.pause()
        }
    }
}


