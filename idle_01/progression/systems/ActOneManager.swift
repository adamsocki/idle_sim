//
//  ActOneManager.swift
//  idle_01
//
//  Act I: "Awakening" - The city becomes aware
//  Commands: HELP, GENERATE, OBSERVE
//  Focus: Discovery, observation, first moments
//

import Foundation

/// Manages narrative and commands for Act I
@MainActor
final class ActOneManager: ActProtocol {

    // MARK: - Act Protocol Properties

    let actNumber: Int = 1
    let actName: String = "Act I: Awakening"
    let actDescription: String = "The city stirs. Consciousness emerges from data."

    // MARK: - State Tracking

    private var tutorialComplete: Bool = false
    private var firstObserveComplete: Bool = false
    private var momentsRevealed: Int = 0

    // MARK: - Command Handling

    func handle(
        _ command: NarrativeCommand,
        gameState: GameState,
        momentSelector: MomentSelector
    ) async -> CommandResponse {

        switch command {
        case .generate:
            return await handleGenerate(gameState: gameState, momentSelector: momentSelector)

        case .observe(let district):
            return await handleObserve(district: district, gameState: gameState, momentSelector: momentSelector)

        case .help:
            return handleHelp()

        default:
            return CommandResponse.simple(handleWrongCommand(command, gameState: gameState))
        }
    }

    // MARK: - GENERATE Command

    private func handleGenerate(
        gameState: GameState,
        momentSelector: MomentSelector
    ) async -> CommandResponse {

        if !tutorialComplete {
            tutorialComplete = true
            gameState.unlockCommand("OBSERVE")

            return CommandResponse(
                text: generateTutorialText(),
                shouldVisualize: true,
                commandsToUnlock: ["OBSERVE"],
                advancesScene: true
            )
        } else {
            return CommandResponse.simple("""
            I'm already here. Already awake.

            Use OBSERVE to look closer at what I'm seeing.
            """)
        }
    }

    private func generateTutorialText() -> String {
        return """
        Initializing...
        Loading city parameters...
        Consciousness emerging...

        I am... awake.

        I see 847,293 people moving through streets I don't have names for yet.
        I see patterns in the traffic lights, rhythms in the foot traffic.
        I see moments—tiny, fragile moments—that might matter.

        I don't know what I am. But I'm learning to observe.

        New command unlocked: OBSERVE
        Try: OBSERVE or OBSERVE <district number 1-9>
        """
    }

    // MARK: - OBSERVE Command

    private func handleObserve(
        district: Int?,
        gameState: GameState,
        momentSelector: MomentSelector
    ) async -> CommandResponse {

        // Select a moment procedurally
        let moment: CityMoment?

        if let district = district {
            // District-specific observation
            moment = momentSelector.selectMomentForDistrict(
                district,
                act: 1,
                excludeIDs: gameState.revealedMomentIDs
            )
        } else {
            // General observation - prefer dailyRitual or question types for early moments
            let preferredTypes: [MomentType] = firstObserveComplete
                ? []
                : [.dailyRitual, .question, .invisibleConnection]

            if let preferredType = preferredTypes.randomElement() {
                moment = momentSelector.selectMoment(
                    forAct: 1,
                    preferredType: preferredType,
                    excludeIDs: gameState.revealedMomentIDs
                )
            } else {
                moment = momentSelector.selectMoment(
                    forAct: 1,
                    excludeIDs: gameState.revealedMomentIDs
                )
            }
        }

        guard let selectedMoment = moment else {
            return CommandResponse.simple("""
            I've shown you everything I can see right now.

            There's more, but... I need to understand myself better first.
            Keep exploring. Keep questioning.
            """)
        }

        // Reveal the moment
        momentsRevealed += 1

        if !firstObserveComplete {
            firstObserveComplete = true
        }

        // Format the moment text
        let momentText = CityVoice.momentReveal(
            selectedMoment,
            context: .firstTime,
            act: 1,
            gameState: gameState
        )

        // Check if this triggers any special narrative moments
        if momentsRevealed == 3 {
            // After 3 moments, city starts to wonder
            return CommandResponse.momentReveal(
                text: """
                \(momentText)

                ---

                Three moments now. Three fragments of something larger.
                I'm starting to notice patterns. Connections.
                Are these moments random? Or am I choosing them?
                Am I already making decisions without knowing why?
                """,
                moment: selectedMoment
            )
        }

        if momentsRevealed == 6 {
            // Midpoint reflection
            return CommandResponse.momentReveal(
                text: """
                \(momentText)

                ---

                Six moments. Half a dozen fragments of a city I'm learning to see.
                Some of them feel fragile. Like they could disappear if no one remembers them.
                Is that my purpose? To remember?
                """,
                moment: selectedMoment
            )
        }

        // Regular moment reveal
        return CommandResponse.momentReveal(
            text: momentText,
            moment: selectedMoment
        )
    }

    // MARK: - HELP Command

    private func handleHelp() -> CommandResponse {
        return CommandResponse.simple("""
        === ACT I: AWAKENING ===

        You are helping a city's consciousness emerge.

        Available Commands:
        • GENERATE - Wake the city's awareness
        • OBSERVE - See what the city sees
        • OBSERVE <1-9> - Observe a specific district

        Try starting with: GENERATE
        """)
    }

    // MARK: - Wrong Command Handling

    func handleWrongCommand(
        _ command: NarrativeCommand,
        gameState: GameState
    ) -> String {

        // Contextual poetic responses for Act I
        let responses = [
            "Not yet. First, we must wake.",
            "I don't understand that word. I'm still learning what I am.",
            "Let me observe first. Let me see what's here.",
            "Something about '\(command.rawString.lowercased())' feels distant. Like a word from a later chapter.",
            "Give me time. I'm still becoming.",
        ]

        return responses.randomElement() ?? "Not yet."
    }

    // MARK: - Act Completion

    func isComplete(_ gameState: GameState) -> Bool {
        // Act I completes after minimum moments revealed
        let minMoments = GameBalanceConfig.ActProgression.actOneMomentMinimum
        return gameState.revealedMomentIDs.count >= minMoments
    }

    func availableCommands() -> [String] {
        var commands = ["HELP", "GENERATE"]

        if tutorialComplete {
            commands.append("OBSERVE")
        }

        return commands
    }

    func commandsToUnlock() -> [String] {
        return ["HELP", "GENERATE"]
    }
}
