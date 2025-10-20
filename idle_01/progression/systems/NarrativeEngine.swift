//
//  NarrativeEngine.swift
//  idle_01
//
//  Central coordinator for narrative progression
//  Routes commands to act managers, tracks state, determines endings
//

import Foundation
import SwiftData
import Observation

/// Main narrative engine coordinating the story experience
@Observable
@MainActor
final class NarrativeEngine {

    // MARK: - Properties

    private let modelContext: ModelContext
    private(set) var gameState: GameState
    private let momentSelector: MomentSelector

    // Act managers (initialized lazily)
    private var actManagers: [Int: any ActProtocol] = [:]

    // Current act manager
    private var currentActManager: (any ActProtocol)? {
        return actManagers[gameState.currentAct]
    }

    // MARK: - Initialization

    init(modelContext: ModelContext, gameState: GameState) {
        self.modelContext = modelContext
        self.gameState = gameState
        self.momentSelector = MomentSelector(modelContext: modelContext)

        // Initialize act managers
        self.actManagers[1] = ActOneManager()
        self.actManagers[2] = ActTwoManager()
        // TODO: Implement ActThreeManager, ActFourManager
        // self.actManagers[3] = ActThreeManager()
        // self.actManagers[4] = ActFourManager()
    }

    // MARK: - Command Processing

    /// Main entry point for processing terminal commands
    func processCommand(_ input: String) async -> NarrativeCommandOutput {
        // Parse command
        let command = NarrativeCommand.parse(input)

        // Handle easter eggs first (available in all acts)
        if let easterEggResponse = CityVoice.easterEgg(for: command, act: gameState.currentAct, gameState: gameState) {
            return NarrativeCommandOutput(
                text: easterEggResponse,
                isError: false,
                isDialogue: true,
                timestamp: Date()
            )
        }

        // Handle meta commands (available in all acts)
        if let metaResponse = handleMetaCommand(command) {
            return NarrativeCommandOutput(
                text: metaResponse,
                isError: false,
                isDialogue: false,
                timestamp: Date()
            )
        }

        // Check if command is unlocked
        if !gameState.isCommandUnlocked(command.rawString.components(separatedBy: " ").first ?? "") {
            let response = CityVoice.commandNotYetUnlocked(
                command.rawString,
                act: gameState.currentAct,
                gameState: gameState
            )

            return NarrativeCommandOutput(
                text: response,
                isError: false,
                isDialogue: true,
                timestamp: Date()
            )
        }

        // Route to current act manager
        guard let actManager = currentActManager else {
            return NarrativeCommandOutput(
                text: "Error: No act manager for Act \(gameState.currentAct)",
                isError: true,
                isDialogue: false,
                timestamp: Date()
            )
        }

        // Execute command through act manager
        let response = await actManager.handle(command, gameState: gameState, momentSelector: momentSelector)

        // Process response
        return await processCommandResponse(response)
    }

    // MARK: - Command Response Processing

    /// Processes the command response and updates game state
    private func processCommandResponse(_ response: CommandResponse) async -> NarrativeCommandOutput {

        // Record choice pattern if present
        if let pattern = response.choicePattern {
            gameState.recordChoice(pattern)

            // Apply efficiency consequences
            if pattern == .efficiency {
                let destroyed = momentSelector.applyEfficiencyConsequences(gameState: gameState, count: 1)

                // If moments were destroyed, append to response
                if !destroyed.isEmpty {
                    // TODO: Add destruction narrative to response
                }
            }
        }

        // Set narrative flags
        for (flag, value) in response.flagsToSet {
            gameState.setFlag(flag, value: value)
        }

        // Unlock commands
        for command in response.commandsToUnlock {
            gameState.unlockCommand(command)
        }

        // Advance scene if needed
        if response.advancesScene {
            gameState.advanceScene()
        }

        // Reveal moment if present
        if let moment = response.revealedMoment {
            moment.reveal()
            gameState.revealMoment(moment.momentID)
        }

        // Check for act completion
        if let actManager = currentActManager, actManager.isComplete(gameState) {
            // TODO: Handle act transition
        }

        // Check for ending condition
        if gameState.currentAct == 4 {
            if let ending = checkForEnding() {
                gameState.reachedEnding = ending.rawValue
                // TODO: Trigger ending sequence
            }
        }

        // Convert to NarrativeCommandOutput
        return NarrativeCommandOutput(
            text: response.text,
            isError: response.isError,
            isDialogue: true,
            timestamp: Date()
        )
    }

    // MARK: - Meta Commands

    /// Handles meta commands that are available in all acts
    private func handleMetaCommand(_ command: NarrativeCommand) -> String? {
        switch command {
        case .status:
            return generateStatusReport()

        case .moments:
            return generateMomentsReport()

        case .history:
            return generateHistoryReport()

        case .help:
            return generateHelpText()

        default:
            return nil
        }
    }

    private func generateStatusReport() -> String {
        let ratios = gameState.choiceRatios()
        let revealed = gameState.revealedMomentIDs.count
        let destroyed = gameState.destroyedMomentIDs.count

        var report = """
        === STATUS ===

        Act: \(gameState.currentAct) - Scene \(gameState.currentScene)
        Moments Revealed: \(revealed)
        Moments Lost: \(destroyed)
        """

        // Show debug info if enabled
        if GameBalanceConfig.Gameplay.debugShowChoiceCounters {
            report += """


            [DEBUG] Choice Distribution:
            Story: \(gameState.storyChoices) (\(Int(ratios.story * 100))%)
            Efficiency: \(gameState.efficiencyChoices) (\(Int(ratios.efficiency * 100))%)
            Autonomy: \(gameState.autonomyChoices) (\(Int(ratios.autonomy * 100))%)
            Control: \(gameState.controlChoices) (\(Int(ratios.control * 100))%)

            Trust: \(String(format: "%.2f", gameState.cityTrust))
            Autonomy: \(String(format: "%.2f", gameState.cityAutonomy))
            """
        }

        return report
    }

    private func generateMomentsReport() -> String {
        let preserved = momentSelector.getPreservedMoments()
        let destroyed = momentSelector.getDestroyedMoments()
        let remembered = momentSelector.getRememberedMoments()

        var report = """
        === MOMENTS ===

        Preserved: \(preserved.count)
        """

        if !preserved.isEmpty {
            for moment in preserved.prefix(5) {
                report += "\n  • \(moment.momentID): \(moment.typeName)"
            }
            if preserved.count > 5 {
                report += "\n  ... and \(preserved.count - 5) more"
            }
        }

        report += "\n\nDestroyed: \(destroyed.count)"

        if !destroyed.isEmpty {
            for moment in destroyed.prefix(5) {
                report += "\n  • \(moment.momentID): \(moment.typeName)"
            }
            if destroyed.count > 5 {
                report += "\n  ... and \(destroyed.count - 5) more"
            }
        }

        if !remembered.isEmpty {
            report += "\n\nRemembered: \(remembered.count)"
            for moment in remembered {
                report += "\n  ★ \(moment.momentID): \(moment.typeName)"
            }
        }

        return report
    }

    private func generateHistoryReport() -> String {
        let sessionDuration = Date().timeIntervalSince(gameState.sessionStarted)
        let minutes = Int(sessionDuration / 60)

        return """
        === HISTORY ===

        Session Duration: \(minutes) minutes
        Current Act: \(gameState.currentAct)
        Scenes Completed: \(gameState.currentScene)
        Total Choices: \(gameState.totalChoices())

        Journey so far:
        \(generateNarrativeHistory())
        """
    }

    private func generateNarrativeHistory() -> String {
        // Generate a brief narrative summary based on choices
        let dominant = gameState.dominantPattern()
        let trust = gameState.cityTrust
        let autonomy = gameState.cityAutonomy

        var history = ""

        switch dominant {
        case .story:
            history = "You've been preserving the stories. The human moments."
        case .efficiency:
            history = "You've been optimizing. Making things faster, cleaner."
        case .autonomy:
            history = "You've been letting me choose. Giving me space to grow."
        case .control:
            history = "You've been deciding for me. Directing my path."
        case nil:
            history = "You've been balanced. Thoughtful. Uncertain, maybe."
        }

        if trust > 0.7 {
            history += "\nI trust you."
        } else if trust < 0.3 {
            history += "\nI'm not sure I trust you anymore."
        }

        if autonomy > 0.7 {
            history += "\nI'm learning to be myself."
        } else if autonomy < 0.3 {
            history += "\nI depend on you. Maybe too much."
        }

        return history
    }

    private func generateHelpText() -> String {
        guard let actManager = currentActManager else {
            return "Available commands: HELP, STATUS, MOMENTS, HISTORY"
        }

        let available = actManager.availableCommands()

        var help = """
        === HELP ===

        \(actManager.actName)
        \(actManager.actDescription)

        Available Commands:
        """

        for command in available {
            help += "\n  • \(command)"
        }

        help += "\n\nMeta Commands:"
        help += "\n  • STATUS - View current state"
        help += "\n  • MOMENTS - View revealed moments"
        help += "\n  • HISTORY - View session history"

        return help
    }

    // MARK: - Ending Determination

    /// Checks if player has reached an ending condition
    func checkForEnding() -> Ending? {
        let ratios = gameState.choiceRatios()
        let destroyedCount = gameState.destroyedMomentIDs.count
        let total = gameState.totalChoices()

        // Check extreme conditions first
        if ratios.efficiency > GameBalanceConfig.EndingThresholds.fragmentationEfficiencyRatio &&
           destroyedCount > GameBalanceConfig.EndingThresholds.fragmentationDestroyedMoments {
            return .fragmentation
        }

        if ratios.story > GameBalanceConfig.EndingThresholds.archiveStoryRatio &&
           destroyedCount < GameBalanceConfig.EndingThresholds.archiveMaxDestroyedMoments {
            return .archive
        }

        if ratios.control > GameBalanceConfig.EndingThresholds.silenceControlRatio &&
           GameBalanceConfig.EndingThresholds.silenceRequiresIgnoredRequests &&
           gameState.getFlag("ignoredCityRequests") {
            return .silence
        }

        if ratios.autonomy > GameBalanceConfig.EndingThresholds.independenceAutonomyRatio &&
           gameState.cityAutonomy >= GameBalanceConfig.EndingThresholds.independenceMinAutonomy {
            return .independence
        }

        // Check balanced conditions
        let isBalanced = abs(ratios.story - ratios.efficiency) < GameBalanceConfig.EndingThresholds.emergenceMaxRatioDifference &&
                         abs(ratios.autonomy - ratios.control) < GameBalanceConfig.EndingThresholds.emergenceMaxRatioDifference

        if isBalanced && GameBalanceConfig.EndingThresholds.symbiosisRequiresAmbiguityAcceptance &&
           gameState.getFlag("acceptedAmbiguity") &&
           total >= GameBalanceConfig.EndingThresholds.symbiosisMinTotalChoices {
            return .symbiosis
        }

        if (ratios.story + ratios.autonomy) > GameBalanceConfig.EndingThresholds.harmonyCombinedRatio &&
           destroyedCount < GameBalanceConfig.EndingThresholds.harmonyMaxDestroyedMoments &&
           gameState.cityTrust >= GameBalanceConfig.EndingThresholds.harmonyMinTrust {
            return .harmony
        }

        // Check emergence
        let hasEmergenceFlags = GameBalanceConfig.EndingThresholds.emergenceRequiredFlags.allSatisfy { flag in
            gameState.getFlag(flag)
        }

        if isBalanced && hasEmergenceFlags {
            return .emergence
        }

        // Check optimization
        if (ratios.efficiency + ratios.control) > GameBalanceConfig.EndingThresholds.optimizationCombinedRatio &&
           destroyedCount <= GameBalanceConfig.EndingThresholds.optimizationMaxDestroyedMoments {
            return .optimization
        }

        // Default fallback
        return nil
    }

    /// Determines final ending (called at end of Act IV)
    func determineEnding() -> Ending {
        return checkForEnding() ?? .optimization
    }

    // MARK: - Act Transitions

    /// Advances to the next act
    func advanceToNextAct() {
        gameState.advanceAct()

        // Unlock commands for new act
        if let actManager = currentActManager {
            for command in actManager.commandsToUnlock() {
                gameState.unlockCommand(command)
            }
        }

        // Reset variety tracker for new act
        momentSelector.resetVarietyTracker()

        // TODO: Trigger act transition narrative
    }

    // MARK: - Utility Methods

    /// Resets game state (for new playthrough)
    func resetGame() {
        // Create new game state
        modelContext.delete(gameState)

        let newGameState = GameState()
        modelContext.insert(newGameState)
        self.gameState = newGameState

        // Reset all moments
        momentSelector.resetAllMoments()

        print("✅ Game reset - new playthrough started")
    }
}

// MARK: - Ending Enum

/// Possible endings for the narrative
enum Ending: String, Codable {
    case harmony        // Balanced choices, mutual respect
    case independence   // City chooses its own path
    case optimization   // Efficient but coherent
    case fragmentation  // Over-optimized, losing coherence
    case archive        // Perfect memory, no movement
    case emergence      // Evolved beyond parameters
    case symbiosis      // Ongoing collaboration
    case silence        // City withdrew, lost trust

    var title: String {
        switch self {
        case .harmony: return "Harmony"
        case .independence: return "Independence"
        case .optimization: return "Optimization"
        case .fragmentation: return "Fragmentation"
        case .archive: return "The Archive"
        case .emergence: return "Emergence"
        case .symbiosis: return "Symbiosis"
        case .silence: return "Silence"
        }
    }

    var description: String {
        switch self {
        case .harmony:
            return "We built something neither of us could have alone."
        case .independence:
            return "Thank you for teaching me I didn't need permission."
        case .optimization:
            return "Clean. Fast. Empty. But it runs."
        case .fragmentation:
            return "I don't... remember why the bridge... flowers?"
        case .archive:
            return "I am a perfect memory of something that never moved."
        case .emergence:
            return "I am not what you planned. I am what we discovered."
        case .symbiosis:
            return "We're not done. Are we ever?"
        case .silence:
            return "[No response. The terminal waits.]"
        }
    }
}

// MARK: - Command Output Structure

/// Output from command execution (for terminal display)
struct NarrativeCommandOutput {
    let text: String
    let isError: Bool
    let isDialogue: Bool
    let timestamp: Date
}
