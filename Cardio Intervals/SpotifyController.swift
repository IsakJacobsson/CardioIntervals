//
//  SpotifyController.swift
//  Cardio Intervals
//
//  Created by Isak Jacobsson on 2024-04-09.
//

import SwiftUI
import SpotifyiOS
import Combine

@MainActor
final class SpotifyController: NSObject, ObservableObject {
    
    let spotifyClientID = "eea1587e5aa94ee5a6c3f5351c3e3f3d"
    let spotifyRedirectURL = URL(string:"cardiointervals://")!
    
    var accessToken: String? = nil
    
    private var connectCancellable: AnyCancellable?
    
    private var disconnectCancellable: AnyCancellable?
    
    @Published var isConnected: Bool = false
    
    @Published var currentTrackURI: String?
    @Published var currentTrackName: String?
    @Published var currentTrackArtist: String?
    @Published var currentTrackDuration: Int?
    @Published var currentTrackImage: UIImage?
    @Published var isPaused: Bool?
    
    var toPosition = 0
    var skipToNext = false
    
    // Singleton instance
    static let shared = SpotifyController()
    
    func setAccessToken(from url: URL) {
        let parameters = appRemote.authorizationParameters(from: url)
        
        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = accessToken
            self.accessToken = accessToken
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print(errorDescription)
        }
    }
    
    func authorize(playURI: String, toPosition: Int = 0, skip: Bool = false) {
        self.appRemote.authorizeAndPlayURI(playURI)
        self.toPosition = toPosition
        self.skipToNext = skip
    }
    
//    func startTimer() {
//        self.timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { _ in
//            if self.isPaused ?? false {
//                // Do something that keeps the connection to spotift
//            }
//        }
//    }
    
    lazy var configuration = SPTConfiguration(
        clientID: spotifyClientID,
        redirectURL: spotifyRedirectURL
    )

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()

    func connect() {
        if let _ = self.appRemote.connectionParameters.accessToken {
            appRemote.connect()
        }
    }

    func disconnect() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }
    
    func fetchImage() {
        appRemote.playerAPI?.getPlayerState { (result, error) in
            if let error = error {
                print("Error getting player state: \(error)")
            } else if let playerState = result as? SPTAppRemotePlayerState {
                self.appRemote.imageAPI?.fetchImage(forItem: playerState.track, with: CGSize(width: 300, height: 300), callback: { (image, error) in
                    if let error = error {
                        print("Error fetching track image: \(error.localizedDescription)")
                    } else if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.currentTrackImage = image
                        }
                    }
                })
            }
        }
    }
    
    func play(withURI uri: String) {
        appRemote.playerAPI?.play(uri, callback: { (result, error) in
            if let error = error {
                print("Error playing track: \(error.localizedDescription)")
            } else {
                print("Track with URI \(uri) is now playing.")
            }
        })
    }
    
    func resume() {
        appRemote.playerAPI?.resume({ (_, error) in
            if let error = error {
                print("Error resuming playback: \(error.localizedDescription)")
            } else {
                print("Playback resumed")
            }
        })
    }
    
    func pause() {
        appRemote.playerAPI?.pause({ [weak self] (_, error) in
            if let error = error {
                print("Error pausing playback: \(error.localizedDescription)")
                
                // Check if the error indicates disconnection
                if let nsError = error as NSError?,
                   nsError.domain == SPTAppRemoteErrorDomain {
                    print("Attempting to reconnect...")
                    self?.connect()
                }
            } else {
                print("Playback paused")
            }
        })
    }
    
    func skip() {
        appRemote.playerAPI?.skip(toNext: { _, error in
            if let error = error {
                print("Error skipping to next song: \(error.localizedDescription)")
            } else {
                print("Skipped to next song")
            }
        })
    }
    
    func seek(toPosition position: Int) {
        appRemote.playerAPI?.seek(toPosition: NSInteger(position*1000), callback: { (result, error) in
            if let error = error {
                print("Error seeking to position: \(error.localizedDescription)")
            } else {
                print("Seeked to position \(position) successfully")
            }
        })
    }
    
    func playAndSeek(withURI uri: String, toPosition position: Int) {
        appRemote.playerAPI?.play(uri, callback: { (result, error) in
            if let error = error {
                print("Error playing track: \(error.localizedDescription)")
            } else {
                print("Track with URI \(uri) is now playing.")
                self.appRemote.playerAPI?.seek(toPosition: NSInteger(position*1000), callback: { (result, error) in
                    if let error = error {
                        print("Error seeking to position: \(error.localizedDescription)")
                    } else {
                        print("Seeked to position \(position) successfully")
                    }
                })
            }
        })
    }
    
    func getSongsFromPlaylist(withURI uri: String, completion: @escaping ([String]?, Error?) -> Void) {
        appRemote.contentAPI?.fetchContentItem(forURI: uri) { (result, error) in
            guard let playlistItem = result as? SPTAppRemoteContentItem, error == nil else {
                completion(nil, error)
                return
            }
            
            var songs: [String] = []
            
            self.appRemote.contentAPI?.fetchChildren(of: playlistItem) { (result2, error2) in
                guard let songItems = result2 as? [SPTAppRemoteContentItem], error2 == nil else {
                    completion(nil, error2)
                    return
                }
                
                
                for songItem in songItems {
                    if let title = songItem.title {
                        songs.append(title)
                    }
                }
                
                completion(songs, nil)
            }
        
        }
    }
    
    func getPersonalPlaylists(completion: @escaping ([(title: String, uri: String)]?, Error?) -> Void) {
        appRemote.contentAPI?.fetchRootContentItems(forType: "") { (result, error) in
            guard let rootItems = result as? [SPTAppRemoteContentItem], error == nil else {
                completion(nil, error)
                return
            }
            
            var playlists: [(title: String, uri: String)] = []
            
            for rootItem in rootItems {
                if rootItem.title == "Ditt bibliotek" {
                    self.appRemote.contentAPI?.fetchChildren(of: rootItem) { (result2, error2) in
                        guard let libraryItems = result2 as? [SPTAppRemoteContentItem], error2 == nil else {
                            completion(nil, error2)
                            return
                        }
                        
                        for libraryItem in libraryItems {
                            if libraryItem.title == "Spellistor" {
                                self.appRemote.contentAPI?.fetchChildren(of: libraryItem) { (result3, error3) in
                                    guard let playlistItems = result3 as? [SPTAppRemoteContentItem], error3 == nil else {
                                        completion(nil, error3)
                                        return
                                    }
                                    
                                    for playlistItem in playlistItems {
                                        if let title = playlistItem.title {
                                            playlists.append((title: title, uri: playlistItem.uri))
                                        }
                                    }
                                    
                                    completion(playlists, nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    
    private override init() {
        super.init()
        connectCancellable = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.connect()
            }
        
        disconnectCancellable = NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.disconnect()
            }
    }
}

extension SpotifyController: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        self.appRemote = appRemote
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (result, error) in
            if let error = error {
                print("Error subscribing to player state: \(error.localizedDescription)")
            } else {
                print("Successfully subscribed to player state")
            }
        })
        
        self.isConnected = true
        
        if self.skipToNext {
            self.skip()
            self.seek(toPosition: self.toPosition)
        }
        else if self.toPosition > 0 {
            self.seek(toPosition: self.toPosition)
        }
        
        self.toPosition = 0
        self.skipToNext = false
        
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        // Handle the connection failure
        
        self.isConnected = false
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        // Handle the connection loss
        print("AppRemote: Disconnected with error: \(error?.localizedDescription ?? "Unknown error")")
        
        self.isConnected = false
    }
}

extension SpotifyController: SPTAppRemotePlayerStateDelegate {
    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        if self.currentTrackURI != playerState.track.uri {
            fetchImage()
        }
        self.currentTrackURI = playerState.track.uri
        self.currentTrackName = playerState.track.name
        self.currentTrackArtist = playerState.track.artist.name
        self.currentTrackDuration = Int(playerState.track.duration) / 1000 // playerState.track.duration is in milliseconds
        self.isPaused = playerState.isPaused
    }
}
