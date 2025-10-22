//
//  GameState.swift
//  idle_01
//
//  Created for Narrative Terminal Game
//

import Foundation
import SwiftData

@Model
@MainActor
final class GameState {
    // Act and scene tracking
    var currentAct: Int = 1
    var currentScene: Int = 0

    // Hidden choice tracking (not displayed to player)
    var storyChoices: Int = 0
    var efficiencyChoices: Int = 0
    var autonomyChoices: Int = 0
    var controlChoices: Int = 0

    // Command progression
    var unlockedCommands: [String] = ["HELP", "OBSERVE"]

    // Moment tracking
    var revealedMomentIDs: [String] = []
    var destroyedMomentIDs: [String] = []

    // Narrative state flags
    var narrativeFlags: [String: Bool] = [:]

    // Narrative state data (for storing strings, IDs, etc.)
    var narrativeData: [String: String] = [:]

    // Ending state
    var reachedEnding: String? = nil

    // Timestamp for session tracking
    var sessionStarted: Date = Date()

    // Relationship with city (for voice tone progression)
    var cityTrust: Double = 0.5 // 0.0 to 1.0
    var cityAutonomy: Double = 0.5 // 0.0 to 1.0

    init() {
        self.currentAct = 1
        self.currentScene = 0
        self.storyChoices = 0
        self.efficiencyChoices = 0
        self.autonomyChoices = 0
        self.controlChoices = 0
        self.unlockedCommands = ["HELP", "OBSERVE"]
        self.revealedMomentIDs = []
        self.destroyedMomentIDs = []
        self.narrativeFlags = [:]
        self.narrativeData = [:]
        self.reachedEnding = nil
        self.sessionStarted = Date()
        self.cityTrust = GameBalanceConfig.RelationshipBounds.initialTrust
        self.cityAutonomy = GameBalanceConfig.RelationshipBounds.initialAutonomy
    }

    // MARK: - Helper Methods

    func recordChoice(_ pattern: ChoicePattern) {
        switch pattern {
        case .story:
            storyChoices += GameBalanceConfig.ChoiceImpacts.storyChoiceIncrement
            cityTrust += GameBalanceConfig.ChoiceImpacts.storyTrustGain
            cityAutonomy += GameBalanceConfig.ChoiceImpacts.storyAutonomyImpact
        case .efficiency:
            efficiencyChoices += GameBalanceConfig.ChoiceImpacts.efficiencyChoiceIncrement
            cityTrust -= GameBalanceConfig.ChoiceImpacts.efficiencyTrustLoss
            cityAutonomy += GameBalanceConfig.ChoiceImpacts.efficiencyAutonomyImpact
        case .autonomy:
            autonomyChoices += GameBalanceConfig.ChoiceImpacts.autonomyChoiceIncrement
            cityTrust += GameBalanceConfig.ChoiceImpacts.autonomyTrustImpact
            cityAutonomy += GameBalanceConfig.ChoiceImpacts.autonomyGain
        case .control:
            controlChoices += GameBalanceConfig.ChoiceImpacts.controlChoiceIncrement
            cityTrust += GameBalanceConfig.ChoiceImpacts.controlTrustImpact
            cityAutonomy -= GameBalanceConfig.ChoiceImpacts.controlAutonomyLoss
        }

        // Clamp values using config bounds
        cityTrust = max(
            GameBalanceConfig.RelationshipBounds.minTrust,
            min(GameBalanceConfig.RelationshipBounds.maxTrust, cityTrust)
        )
        cityAutonomy = max(
            GameBalanceConfig.RelationshipBounds.minAutonomy,
            min(GameBalanceConfig.RelationshipBounds.maxAutonomy, cityAutonomy)
        )
    }

    func unlockCommand(_ command: String) {
        if !unlockedCommands.contains(command) {
            unlockedCommands.append(command)
        }
    }

    func isCommandUnlocked(_ command: String) -> Bool {
        return unlockedCommands.contains(command.uppercased())
    }

    func revealMoment(_ momentID: String) {
        if !revealedMomentIDs.contains(momentID) {
            revealedMomentIDs.append(momentID)
        }
    }

    func destroyMoment(_ momentID: String) {
        if !destroyedMomentIDs.contains(momentID) {
            destroyedMomentIDs.append(momentID)
        }
    }

    func setFlag(_ flag: String, value: Bool = true) {
        narrativeFlags[flag] = value
    }

    func getFlag(_ flag: String) -> Bool {
        return narrativeFlags[flag] ?? false
    }

    func advanceAct() {
        currentAct += 1
        currentScene = 0
    }

    func advanceScene() {
        currentScene += 1
    }

    // MARK: - Choice Pattern Analysis

    func totalChoices() -> Int {
        return storyChoices + efficiencyChoices + autonomyChoices + controlChoices
    }

    func choiceRatios() -> (story: Double, efficiency: Double, autonomy: Double, control: Double) {
        let total = Double(totalChoices())
        guard total > 0 else { return (0, 0, 0, 0) }

        return (
            story: Double(storyChoices) / total,
            efficiency: Double(efficiencyChoices) / total,
            autonomy: Double(autonomyChoices) / total,
            control: Double(controlChoices) / total
        )
    }

    func dominantPattern() -> ChoicePattern? {
        let ratios = choiceRatios()
        let max = Swift.max(ratios.story, ratios.efficiency, ratios.autonomy, ratios.control)

        guard max > 0 else { return nil }

        if ratios.story == max { return .story }
        if ratios.efficiency == max { return .efficiency }
        if ratios.autonomy == max { return .autonomy }
        if ratios.control == max { return .control }

        return nil
    }
}

// MARK: - Choice Pattern Enum

enum ChoicePattern: String, Codable {
    case story        // Preserve human narratives
    case efficiency   // Optimize systems
    case autonomy     // Let city decide
    case control      // Direct intervention
}
