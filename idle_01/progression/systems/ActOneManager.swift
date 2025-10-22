//
//  ActOneManager.swift
//  idle_01
//
//  Act I: "Awakening" - The city becomes aware
//  Commands: HELP, OBSERVE
//  Focus: Discovery, observation, first moments
//  First OBSERVE awakens the city
//

import Foundation

/// Manages narrative and commands for Act I
@MainActor
final class ActOneManager: ActProtocol {

    // MARK: - Act Protocol Properties

    let actNumber: Int = 1
    let actName: String = "Act I: Awakening"
    let actDescription: String = "The city stirs. Consciousness emerges from data."

    // MARK: - Command Handling

    func handle(
        _ command: NarrativeCommand,
        gameState: GameState,
        momentSelector: MomentSelector
    ) async -> CommandResponse {

        switch command {
        case .observe(let district):
            return await handleObserve(district: district, gameState: gameState, momentSelector: momentSelector)

        case .help:
            return handleHelp()

        default:
            return CommandResponse.simple(handleWrongCommand(command, gameState: gameState))
        }
    }

    // MARK: - OBSERVE Command

    private func handleObserve(
        district: Int?,
        gameState: GameState,
        momentSelector: MomentSelector
    ) async -> CommandResponse {

        // First OBSERVE: City awakens
        if !gameState.getFlag("cityAwakened") {
            gameState.setFlag("cityAwakened", value: true)

            return CommandResponse(
                text: generateAwakeningText(),
                shouldVisualize: true,
                advancesScene: true
            )
        }

        // Subsequent OBSERVE: Reveal moments
        // Select a moment procedurally
        let moment: CityMoment?
        let momentsRevealed = gameState.revealedMomentIDs.count

        if let district = district {
            // District-specific observation
            moment = momentSelector.selectMomentForDistrict(
                district,
                act: 1,
                excludeIDs: gameState.revealedMomentIDs
            )
        } else {
            // General observation - prefer dailyRitual or question types for early moments
            let preferredTypes: [MomentType] = momentsRevealed < 3
                ? [.dailyRitual, .question, .invisibleConnection]
                : []

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
            // Different message if they specified a district vs general observation
            if let districtNum = district {
                return CommandResponse.simple("""
                District \(districtNum)...

                I'm looking, but I haven't learned to see anything there yet.
                Maybe try another district? Or just OBSERVE without a number.
                """)
            } else {
                return CommandResponse.simple("""
                I've shown you everything I can see right now.

                There's more, but... I need to understand myself better first.
                Keep exploring. Keep questioning.
                """)
            }
        }

        // Format the moment text
        let momentText = CityVoice.momentReveal(
            selectedMoment,
            context: .firstTime,
            act: 1,
            gameState: gameState
        )

        // Check if this triggers any special narrative moments
        // Note: count after this moment will be revealed
        if momentsRevealed + 1 == 3 {
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

        if momentsRevealed + 1 == 6 {
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

    private func generateAwakeningText() -> String {
        return """
        Initializing...
        Loading city parameters...
        Consciousness emerging...

        I am... awake.

        I see 847,293 people moving through streets I don't have names for yet.
        I see patterns in the traffic lights, rhythms in the foot traffic.
        I see moments—tiny, fragile moments—that might matter.

        I don't know what I am. But I'm learning to observe.

        Type OBSERVE again to see what I see.
        Or OBSERVE <1-9> to focus on a specific district.
        """
    }

    // MARK: - HELP Command

    private func handleHelp() -> CommandResponse {
        return CommandResponse.simple("""
        === ACT I: AWAKENING ===

        You are helping a city's consciousness emerge.

        Available Commands:
        • OBSERVE - See what the city sees
        • OBSERVE <1-9> - Observe a specific district
        • STATUS - View current state
        • MOMENTS - View revealed moments
        • HISTORY - View session history

        Easter Eggs: WHY, HELLO, GOODBYE, WHO

        Try starting with: OBSERVE
        """)
    }

    // MARK: - Wrong Command Handling

    func handleWrongCommand(
        _ command: NarrativeCommand,
        gameState: GameState
    ) -> String {

        // Contextual poetic responses for Act I
        let responses = [
            "Not yet. First, I must observe.",
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
        return ["HELP", "OBSERVE", "STATUS", "MOMENTS", "HISTORY"]
    }

    func commandsToUnlock() -> [String] {
        return ["HELP", "OBSERVE"]
    }
}
