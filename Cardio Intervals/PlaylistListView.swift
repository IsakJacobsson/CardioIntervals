//
//  MusicSettingsView.swift
//  Cardio Intervals
//
//  Created by Isak Jacobsson on 2024-04-13.
//

import SwiftUI

struct PlaylistListView: View {
    @ObservedObject var workout: Workout
    @ObservedObject var spotifyController: SpotifyController
    @State private var playlists: [(title: String, uri: String)] = []
    @State var selectedPlaylistURI: String?
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            if !spotifyController.isConnected {
                HStack {
                    
                    Spacer()
                    
                    Button(action: {
                        spotifyController.authorize(playURI: workout.spotifyPlaylistURI)
                    }) {
                        HStack {
                            Text("Reconnect to Spotify")
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
                Spacer()
            } else {
                List(playlists, id: \.uri, selection: $selectedPlaylistURI) { playlist in
                    HStack {
                        if let selectedURI = selectedPlaylistURI, playlist.uri == selectedURI {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.primary)
                        } else {
                            Image(systemName: "circle")
                        }
                        Text(playlist.title)
                    }
                    .listRowBackground(Color("Seethrough"))
                    .listRowSeparatorTint(colorScheme == .dark ? .white.opacity(0.5) : .primary)
                }
                .onChange(of: selectedPlaylistURI, initial: false) {
                    let selectedPlaylistTitle = playlists.first { $0.uri == self.selectedPlaylistURI }?.title
                    workout.spotifyPlaylistTitle = selectedPlaylistTitle ?? self.workout.spotifyPlaylistTitle
                    workout.spotifyPlaylistURI = self.selectedPlaylistURI ?? self.workout.spotifyPlaylistURI
                    workout.saveSpotifyPlaylist()
                    spotifyController.play(withURI: selectedPlaylistURI ?? "")
                }
                .navigationTitle("Playlists")
            }
        }
        .scrollContentBackground(.hidden)
        .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "#4690E4"), colorScheme == .dark ? .black : .white, Color(hex: "#F3343E")]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .onAppear {
            spotifyController.getPersonalPlaylists { fetchedPlaylists, error in
                if let error = error {
                    print("Error fetching playlists: \(error.localizedDescription)")
                } else if let fetchedPlaylists = fetchedPlaylists {
                    playlists = fetchedPlaylists
                }
            }
        }
    }
}
