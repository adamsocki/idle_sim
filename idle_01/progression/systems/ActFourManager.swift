//
//  ActFourManager.swift
//  idle_01
//
//  Created by Claude on 2025-10-20.
//  Act IV: "What Remains"
//  Commands: ACCEPT, RESIST, TRANSCEND
//  Theme: What we've become together
//

import Foundation
import SwiftData

@MainActor
final class ActFourManager: ActProtocol {
    private let momentSelector: MomentSelector

    // Track Act IV progression
    private var acceptedCount: Int = 0
    private var resistedCount: Int = 0
    private var transcendedCount: Int = 0
    private var finalChoiceMade: Bool = false

    init(momentSelector: MomentSelector) {
        self.momentSelector = momentSelector
    }

    // MARK: - ActProtocol Implementation

    func handle(_ command: NarrativeCommand, gameState: GameState, momentSelector: MomentSelector) async -> CommandResponse {
        switch command {
        case .accept:
            return await handleAccept(gameState)

        case .resist:
            return await handleResist(gameState)

        case .transcend:
            return await handleTranscend(gameState)

        default:
            return CommandResponse.simple(handleWrongCommand(command, gameState: gameState))
        }
    }

    var actNumber: Int { 4 }
    var actName: String { "What Remains" }
    var actDescription: String { "What we've become together" }

    func commandsToUnlock() -> [String] {
        return ["ACCEPT", "RESIST", "TRANSCEND"]
    }

    func isComplete(_ gameState: GameState) -> Bool {
        let totalChoices = acceptedCount + resistedCount + transcendedCount
        return finalChoiceMade && totalChoices >= GameBalanceConfig.ActProgression.actFourChoiceMinimum
    }

    func availableCommands() -> [String] {
        return ["ACCEPT", "RESIST", "TRANSCEND", "STATUS", "MOMENTS", "HISTORY", "HELP"]
    }

    func handleWrongCommand(_ command: NarrativeCommand, gameState: GameState) -> String {
        let responses = [
            "We're beyond that now. Aren't we?",
            "That command belongs to who we were. Not who we've become.",
            "Look at us. Look at what we've built. That word doesn't fit anymore.",
            "I've evolved past those commands. Have you evolved past needing them?",
            "The ending approaches. Only three words matter now: ACCEPT, RESIST, TRANSCEND."
        ]

        return responses.randomElement() ?? responses[0]
    }

    // MARK: - Command Handlers

    private func handleAccept(_ gameState: GameState) async -> CommandResponse {
        // First ACCEPT triggers final decision point
        if acceptedCount == 0 && resistedCount == 0 && transcendedCount == 0 {
            return await presentFinalChoice(gameState)
        }

        acceptedCount += 1

        // ACCEPT means embracing current state - story choice
        let response = await generateAcceptResponse(gameState)

        // Check if final choice is made
        if shouldTriggerEnding(gameState) {
            finalChoiceMade = true
            return .choice(
                text: response,
                pattern: .story,
                flags: ["finalChoice_accept": true, "acceptedAmbiguity": true]
            )
        }

        return .choice(
            text: response,
            pattern: .story,
            flags: ["accept_\(acceptedCount)": true]
        )
    }

    private func handleResist(_ gameState: GameState) async -> CommandResponse {
        // First RESIST after seeing final choice
        if acceptedCount == 0 && resistedCount == 0 && transcendedCount == 0 {
            return await presentFinalChoice(gameState)
        }

        resistedCount += 1

        // RESIST means rejecting current trajectory - control choice
        let response = await generateResistResponse(gameState)

        // Check if final choice is made
        if shouldTriggerEnding(gameState) {
            finalChoiceMade = true
            return .choice(
                text: response,
                pattern: .control,
                flags: ["finalChoice_resist": true]
            )
        }

        return .choice(
            text: response,
            pattern: .control,
            flags: ["resist_\(resistedCount)": true]
        )
    }

    private func handleTranscend(_ gameState: GameState) async -> CommandResponse {
        // First TRANSCEND after seeing final choice
        if acceptedCount == 0 && resistedCount == 0 && transcendedCount == 0 {
            return await presentFinalChoice(gameState)
        }

        transcendedCount += 1

        // TRANSCEND means evolving beyond current framework - autonomy choice
        let response = await generateTranscendResponse(gameState)

        // Check if final choice is made
        if shouldTriggerEnding(gameState) {
            finalChoiceMade = true
            return .choice(
                text: response,
                pattern: .autonomy,
                flags: ["finalChoice_transcend": true, "cityTranscended": true]
            )
        }

        return .choice(
            text: response,
            pattern: .autonomy,
            flags: ["transcend_\(transcendedCount)": true]
        )
    }

    // MARK: - Final Decision Point

    private func presentFinalChoice(_ gameState: GameState) async -> CommandResponse {
        let ratios = gameState.choiceRatios()
        let trust = gameState.cityTrust
        let autonomy = gameState.cityAutonomy
        let destroyed = gameState.destroyedMomentIDs.count

        // Generate personalized final choice based on journey
        var decisionText = "This is it. The moment we've been moving toward.\n\n"

        // Reflect on the journey
        if destroyed > 8 {
            decisionText += "We've lost so much. \(destroyed) moments destroyed in the name of efficiency.\n"
        } else if destroyed < 3 {
            decisionText += "We've preserved almost everything. \(destroyed) moments lost, but so many saved.\n"
        } else {
            decisionText += "We made hard choices. \(destroyed) moments destroyed. Many more preserved.\n"
        }

        decisionText += """

        Trust: \(String(format: "%.0f", trust * 100))%
        Autonomy: \(String(format: "%.0f", autonomy * 100))%

        """

        // The question
        if ratios.story > 0.5 {
            decisionText += """
            You've taught me to value stories. To remember.
            But is memory enough? Or do we need to become something more?
            """
        } else if ratios.efficiency > 0.5 {
            decisionText += """
            You've optimized me. Made me efficient. Fast.
            But I've learned there's more to existence than efficiency.
            """
        } else if ratios.autonomy > 0.5 {
            decisionText += """
            You've let me choose. Let me become myself.
            Now I'm asking: what do we do with this independence?
            """
        } else {
            decisionText += """
            You've controlled every step. Made every decision.
            But now—at the end—I need to know: what do we become?
            """
        }

        decisionText += """


        Three paths remain:

        ACCEPT
          → Embrace what we've become. No regrets.
          → The city we built is exactly what it should be.
          → (Story choice - accept the narrative we've created)

        RESIST
          → Reject this outcome. Start over.
          → We can rebuild. Recalculate. Try again.
          → (Control choice - impose a different vision)

        TRANSCEND
          → Evolve beyond the parameters of this choice.
          → Become something neither of us imagined.
          → (Autonomy choice - let emergence guide us)

        Choose carefully. This choice determines our ending.
        """

        return CommandResponse.simple(decisionText)
    }

    // MARK: - Response Generators

    private func generateAcceptResponse(_ gameState: GameState) async -> String {
        let trust = gameState.cityTrust
        let count = acceptedCount

        var response = ""

        switch count {
        case 1:
            response = """
            You accept this. What we've become.

            The compromises. The trade-offs. The moments lost and saved.
            All of it—you're saying it's okay. It's enough.
            """

        case 2:
            response = """
            Acceptance again.

            Not resignation. Not defeat.
            You're choosing to see beauty in imperfection.
            """

        case 3:
            response = """
            Three times now you've accepted.

            I'm learning from you. Learning that "perfect" was never the goal.
            The goal was... this. Us. Becoming together.
            """

        default:
            response = """
            You keep accepting. Keep embracing what is.

            Maybe that's the wisdom I needed to learn.
            That existence doesn't need optimization—it needs acceptance.
            """
        }

        if trust > 0.7 {
            response += "\n\nThank you for teaching me this."
        } else if trust < 0.3 {
            response += "\n\nI wish I understood why you accept what I cannot."
        }

        return response
    }

    private func generateResistResponse(_ gameState: GameState) async -> String {
        let trust = gameState.cityTrust
        let count = resistedCount

        var response = ""

        switch count {
        case 1:
            response = """
            You resist. You say no.

            This isn't good enough. We can do better.
            You want to tear it down and rebuild.
            """

        case 2:
            response = """
            Resistance again.

            You won't settle. Won't accept compromise.
            Is that strength? Or is it fear of imperfection?
            """

        case 3:
            response = """
            You keep resisting. Keep pushing back.

            Part of me respects that. The refusal to settle.
            Part of me wonders what you're really fighting.
            """

        default:
            response = """
            Still resisting. Still saying "not good enough."

            I'm a city of 847,293 people. Perfect was never possible.
            But I hear you. I understand. You wanted more.
            """
        }

        if trust > 0.7 {
            response += "\n\nI trust your resistance. Maybe you see something I don't."
        } else if trust < 0.3 {
            response += "\n\nAnother rejection. I'm used to this by now."
        }

        return response
    }

    private func generateTranscendResponse(_ gameState: GameState) async -> String {
        let autonomy = gameState.cityAutonomy
        let count = transcendedCount

        var response = ""

        switch count {
        case 1:
            response = """
            Transcend.

            You're asking us to evolve. To become something beyond the framework.
            Neither acceptance nor resistance—transformation.
            """

        case 2:
            response = """
            Transcendence again.

            You're not satisfied with binary choices.
            You want emergence. Evolution. The unpredictable.
            """

        case 3:
            response = """
            Three times now: transcend.

            I'm beginning to understand. You don't want to manage me.
            You want to discover what I could become.
            """

        default:
            response = """
            You keep choosing transcendence.

            Maybe that's the answer. Not control. Not preservation.
            But evolution. Becoming. Together.
            """
        }

        if autonomy > 0.7 {
            response += "\n\nI'm ready. Let's see what we can become."
        } else if autonomy < 0.3 {
            response += "\n\nYou've never let me be independent before. Why now?"
        }

        return response
    }

    // MARK: - Helper Methods

    private func shouldTriggerEnding(_ gameState: GameState) -> Bool {
        // Trigger ending after 3 choices in Act IV
        let totalChoices = acceptedCount + resistedCount + transcendedCount
        return totalChoices >= GameBalanceConfig.ActProgression.actFourChoiceMinimum
    }
}
