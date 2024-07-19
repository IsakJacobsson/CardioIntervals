//
//  WorkoutTest.swift
//  Cardio Intervals
//
//  Created by Isak Jacobsson on 2024-04-06.
//

import SwiftUI

//
//  Workout.swift
//  Cardio Intervals
//
//  Created by Isak Jacobsson on 2024-04-06.
//

import SwiftUI

enum Phase: String, Codable {
    case active, rest
}

struct Interval: Codable {
    var uuid = UUID()
    var duration: Double
    var startMusicAt: Int
}

class Workout: ObservableObject {
    var id = UUID()
    var workoutName: String
    
    @Published var intervals: [Interval] = []
    @Published var numberOfIntervals = 0
    @Published var restDuration: Double = 0
    
    @Published var currentInterval = 0
    @Published var currentPhase: Phase = .rest
    
    @Published var showTimerView = false
    @Published var timerPaused = false
    
    var timer: Timer? = nil
    private var timeInterval: Double = 1
    @Published var timeRemaining: Double = 0
    
    @Published var spotifyPlaylistTitle: String = ""
    @Published var spotifyPlaylistURI: String = ""
    
    init(workoutName: String) {
        self.workoutName = workoutName
        loadData()
        self.resetTimer()
    }
    
    init(workoutName: String, numberOfIntervals: Int, activeDuation: Double, restDuration: Double, startMusicAt: Int) {
        self.workoutName = workoutName
        self.numberOfIntervals = numberOfIntervals
        self.restDuration = restDuration
        
        for _ in 1...numberOfIntervals {
            self.intervals.append(Interval(duration: activeDuation, startMusicAt: startMusicAt))
        
        }
        
        saveIntervals()
        saveRestDuration()
        
        self.resetTimer()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "\(workoutName)_intervals") {
            do {
                let decoder = JSONDecoder()
                intervals = try decoder.decode([Interval].self, from: data)
                numberOfIntervals = intervals.count
            } catch {
                print("Error loading intervals: \(error.localizedDescription)")
            }
        }
        
        self.restDuration = UserDefaults.standard.double(forKey: "\(workoutName)_restDuration")
        
        self.spotifyPlaylistTitle = UserDefaults.standard.string(forKey: "\(workoutName)_spotifyPlaylistTitle") ?? ""
        self.spotifyPlaylistURI = UserDefaults.standard.string(forKey: "\(workoutName)_spotifyPlaylistURI") ?? ""
    }
    
    func removeData() {
        UserDefaults.standard.removeObject(forKey: "\(workoutName)_intervals")
        UserDefaults.standard.removeObject(forKey: "\(workoutName)_restDuration")
        UserDefaults.standard.removeObject(forKey: "\(workoutName)_spotifyPlaylistTitle")
        UserDefaults.standard.removeObject(forKey: "\(workoutName)_spotifyPlaylistURI")
    }

   
    func saveIntervals() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(intervals)
            UserDefaults.standard.set(data, forKey: "\(workoutName)_intervals")
        } catch {
            print("Error saving intervals: \(error.localizedDescription)")
        }
    }
    
    func saveRestDuration() {
        UserDefaults.standard.set(restDuration, forKey: "\(workoutName)_restDuration")
    }
    
    func saveSpotifyPlaylist() {
        UserDefaults.standard.set(spotifyPlaylistTitle, forKey: "\(workoutName)_spotifyPlaylistTitle")
        UserDefaults.standard.set(spotifyPlaylistURI, forKey: "\(workoutName)_spotifyPlaylistURI")
    }
    
    func nextInterval() {
        if self.currentInterval == self.numberOfIntervals - 1 {
            self.stopTimer()
            return
        }
        
        if self.currentPhase == .active {
            self.timeRemaining = self.restDuration
            self.currentPhase = .rest
        } else {
            let interval = intervals[self.currentInterval]
            self.timeRemaining = interval.duration
            self.currentInterval += 1
            self.currentPhase = .active
        }
    }
    
    func moveInterval(from source: IndexSet, to destination: Int) {
        intervals.move(fromOffsets: source, toOffset: destination)
        saveIntervals()
    }
    
    func workoutTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: true) { _ in
            if self.timeRemaining <= self.timeInterval {
                self.nextInterval()
            }
            else {
                self.timeRemaining -= self.timeInterval
            }
        }
    }
    
    func startTimer() {
        self.workoutTimer()
        self.showTimerView = true
        self.timerPaused = false
    }
    
    func pauseTimer() {
        self.timerPaused = true
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
        self.showTimerView = false
        self.resetTimer()
    }
    
    func resetTimer() {
        self.currentInterval = 0
        self.currentPhase = .active
        self.timeRemaining = self.intervals[0].duration
    }
    
    func increaseIntervals(with n: Int) {
        self.numberOfIntervals += n
        let lastDuration = intervals.last?.duration ?? 45
        let lastStartMusicAt = intervals.last?.startMusicAt ?? 0
        for _ in 1...n {
            let interval = Interval(duration: lastDuration, startMusicAt: lastStartMusicAt)
            intervals.append(interval)
        }
        self.saveIntervals()
    }
    
    func decreaseIntervals() {
        if self.intervals.count == 1 {
            return
        }
        self.intervals.removeLast()
        self.numberOfIntervals -= 1
        self.saveIntervals()
    }
    
    func increaseRestDuration(with n: Int) {
        self.restDuration += Double(n)
        self.saveRestDuration()
    }
    
    func decreaseRestDuration(with n: Int) {
        if self.restDuration == 1 {
            return
        }
        self.restDuration -= Double(n)
        self.saveRestDuration()
    }
    
    func increaseActiveDuration(with n: Int) {
        for i in 0..<intervals.count {
            intervals[i].duration += Double(n)
        }
        self.saveIntervals()
        self.resetTimer()
    }
    
    func decreaseActiveDuration(with n: Int) {
        for i in 0..<intervals.count {
            if intervals[i].duration == 1 {
                continue
            }
            intervals[i].duration -= Double(n)
        }
        self.saveIntervals()
        self.resetTimer()
    }
}

