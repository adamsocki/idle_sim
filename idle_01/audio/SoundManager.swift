//
//  SoundManager.swift
//  idle_01
//
//  Sound management for terminal command feedback and background music
//

import AVFoundation
import Combine
import Foundation
import SwiftUI

/// Manages sound effects and background music for the application
@MainActor
final class SoundManager: ObservableObject {
    static let shared = SoundManager()

    private var audioPlayer: AVAudioPlayer?
    private var backgroundMusicPlayer: AVAudioPlayer?

    // Published property to observe music state
    @Published private(set) var isMusicPlaying: Bool = false

    private init() {
        // Start background music on init if enabled
        startBackgroundMusicIfEnabled()

        // Observe settings changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSettingsChange),
            name: UserDefaults.didChangeNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Play the terminal command sound effect
    func playCommandSound() {
        // Read settings from UserDefaults
        let isEnabled = UserDefaults.standard.object(forKey: "audio.commandSoundEnabled") as? Bool ?? true
        let volume = UserDefaults.standard.object(forKey: "audio.commandVolume") as? Double ?? 0.3

        guard isEnabled else { return }

        // Look for sound file in bundle
        guard let soundURL = Bundle.main.url(forResource: "terminal_command", withExtension: "wav") else {
            print("Warning: terminal_command.wav not found in bundle")
            return
        }

        do {
            // Create a new player each time for overlapping sounds
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.volume = Float(volume)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play command sound: \(error)")
        }
    }

    // MARK: - Background Music

    /// Start playing background music if enabled in settings
    func startBackgroundMusicIfEnabled() {
        let isEnabled = UserDefaults.standard.object(forKey: "audio.backgroundMusicEnabled") as? Bool ?? true

        if isEnabled {
            startBackgroundMusic()
        }
    }

    /// Start or resume background music playback
    func startBackgroundMusic() {
        let volume = UserDefaults.standard.object(forKey: "audio.backgroundMusicVolume") as? Double ?? 0.5

        // If already playing, just update volume
        if let player = backgroundMusicPlayer, player.isPlaying {
            player.volume = Float(volume)
            return
        }

        // Look for background music file in bundle
        // Try multiple common audio formats
        let possibleNames = ["background_music", "bgm", "music", "ambient"]
        let possibleExtensions = ["mp3", "m4a", "wav", "aac"]

        var musicURL: URL?
        for name in possibleNames {
            for ext in possibleExtensions {
                if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                    musicURL = url
                    break
                }
            }
            if musicURL != nil { break }
        }

        guard let soundURL = musicURL else {
            print("Warning: Background music file not found. Expected one of: background_music.[mp3|m4a|wav|aac]")
            return
        }

        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: soundURL)
            backgroundMusicPlayer?.numberOfLoops = -1 // Loop indefinitely
            backgroundMusicPlayer?.volume = Float(volume)
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
            isMusicPlaying = true
            print("Background music started: \(soundURL.lastPathComponent)")
        } catch {
            print("Failed to play background music: \(error)")
        }
    }

    /// Stop background music playback
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
        backgroundMusicPlayer = nil
        isMusicPlaying = false
    }

    /// Update background music volume
    func updateMusicVolume(_ volume: Double) {
        backgroundMusicPlayer?.volume = Float(volume)
    }

    /// Toggle background music on/off
    func toggleBackgroundMusic(enabled: Bool) {
        if enabled {
            startBackgroundMusic()
        } else {
            stopBackgroundMusic()
        }
    }

    @objc private func handleSettingsChange() {
        // React to settings changes
        let musicEnabled = UserDefaults.standard.object(forKey: "audio.backgroundMusicEnabled") as? Bool ?? true
        let musicVolume = UserDefaults.standard.object(forKey: "audio.backgroundMusicVolume") as? Double ?? 0.5

        if musicEnabled {
            if backgroundMusicPlayer?.isPlaying == true {
                updateMusicVolume(musicVolume)
            } else {
                startBackgroundMusic()
            }
        } else {
            stopBackgroundMusic()
        }
    }
}
