//
//  SoundManager.swift
//  idle_01
//
//  Sound management for terminal command feedback
//

import AVFoundation
import Foundation
import SwiftUI

/// Manages sound effects for the terminal interface
@MainActor
final class SoundManager {
    static let shared = SoundManager()

    private var audioPlayer: AVAudioPlayer?

    private init() {}

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
}
