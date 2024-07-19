//
//  ContentView.swift
//  Cardio Intervals
//
//  Created by Isak Jacobsson on 2024-03-31.
//

import SwiftUI

struct WorkoutInfoView: View {
    @ObservedObject var workout: Workout
    @ObservedObject var spotifyController = SpotifyController.shared
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            WorkoutInfoComponent(workout: workout)
            
            HStack {
                Spacer()
                
                NavigationLink(destination: MusicSettingsView(workout: workout, spotifyController: spotifyController)){
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Music Settings")
                                .font(.title)
                            Text("Playlist: \(workout.spotifyPlaylistTitle)")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        if spotifyController.isConnected {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .padding()
                    .background(spotifyController.isConnected ? Color(hex: "#1ED760") : Color("Seethrough"))
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    .foregroundColor(spotifyController.isConnected ? Color.white : Color.primary.opacity(0.5))
                }
                .disabled(!spotifyController.isConnected)
                
                Spacer()
            }
            
            if !spotifyController.isConnected {
                HStack {
                    
                    Spacer()
                    
                    Button(action: {
                        spotifyController.authorize(playURI: workout.spotifyPlaylistURI)
                    }) {
                        HStack {
                            Text("Connect to Spotify")
                                .font(.title2)
                                .foregroundColor(Color(hex: "#1ED760"))
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(colorScheme == .dark ? .white.opacity(0.5) : .black.opacity(0.5))
                        }
                    }
                    .padding()
                    .background(spotifyController.isConnected ? Color(hex: "#1ED760") : Color("Seethrough"))
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    .foregroundColor(spotifyController.isConnected ? Color.white : Color.primary.opacity(0.5))
                    
                    Spacer()
                }
            }
            
            
            Spacer()
            
            Button(action: {
                if !spotifyController.isConnected {
                    spotifyController.authorize(playURI: workout.spotifyPlaylistURI, toPosition: workout.intervals[0].startMusicAt)
                } else {
                    spotifyController.playAndSeek(withURI: workout.spotifyPlaylistURI, toPosition: workout.intervals[0].startMusicAt)
                }
                
                workout.startTimer()
            }) {
                Text("Start Workout")
                    .font(.title)
                    .padding()
            }
        }
    }
}


