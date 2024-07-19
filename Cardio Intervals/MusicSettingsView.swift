//
//  SongListView.swift
//  Cardio Intervals
//
//  Created by Isak Jacobsson on 2024-04-08.
//

import SwiftUI

struct MusicSettingsView: View {
    @ObservedObject var workout: Workout
    @ObservedObject var spotifyController: SpotifyController
    
    @State private var isEditMode = false
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var songs: [String] = []

    var body: some View {
        List {
            NavigationLink(destination: PlaylistListView(workout: workout, spotifyController: spotifyController, selectedPlaylistURI: workout.spotifyPlaylistURI)) {
                Text("Playlist: \(workout.spotifyPlaylistTitle)")
            }
            .listRowBackground(Color("Seethrough"))
            
            Section(header: Text("Songs")) {
                ForEach(workout.intervals.indices, id: \.self) { index in
                    if isEditMode {
                        Stepper(value: $workout.intervals[index].startMusicAt, in: 0...99, step: 1) {
                            HStack {
                                Text("\(index+1). \(songs.count > index ? songs[index] : "")")
                                Spacer()
                                Text("At: \(workout.intervals[index].startMusicAt)s")
                            }
                        }
                        .onChange(of: workout.intervals[index].startMusicAt) {
                            workout.saveIntervals()
                        }
                    } else {
                        HStack {
                            Text("\(index+1). \(songs.count > index ? songs[index] : "")")
                            Spacer()
                            Text("At: \(workout.intervals[index].startMusicAt)s")
                        }
                    }
                }
                .listRowBackground(Color("Seethrough"))
                .listRowSeparatorTint(colorScheme == .dark ? .white.opacity(0.5) : .primary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#4690E4"), colorScheme == .dark ? .black : .white, Color(hex: "#F3343E")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .navigationTitle("Music Settings")
        .navigationBarItems(trailing:
            HStack {
                if isEditMode {
                    Button("Done") {
                        isEditMode = false
                    }
                } else {
                    Button("Edit") {
                        isEditMode.toggle()
                    }
                }
            }
        )
        .onAppear {
            spotifyController.getSongsFromPlaylist(withURI: workout.spotifyPlaylistURI) { fetchedSongs, error in
                if let error = error {
                    print("Error fetching songs: \(error.localizedDescription)")
                } else if let fetchedSongs = fetchedSongs {
                    songs = fetchedSongs
                }
            }
        }
    }
}
