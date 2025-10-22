//
//  ActTwoManager.swift
//  idle_01
//
//  Act II: "Stories Within" - Binary choices between preservation and efficiency
//  Commands: PRESERVE, OPTIMIZE
//  Focus: Choosing what matters through mutually exclusive decisions
//  Each moment presents a binary choice - you cannot have both
//

import Foundation

/// Manages narrative and commands for Act II
@MainActor
final class ActTwoManager: ActProtocol {

    // MARK: - Act Protocol Properties

    let actNumber: Int = 2
    let actName: String = "Act II: Stories Within"
    let actDescription: String = "Every moment is a choice. You cannot have both."

    // MARK: - Command Handling

    func handle(
        _ command: NarrativeCommand,
        gameState: GameState,
        momentSelector: MomentSelector
    ) async -> CommandResponse {

        switch command {
        case .observe(_):
            // Check if there's a pending choice in GameState
            if let pendingMomentID = gameState.narrativeData["act2_pending_choice"],
               let currentMoment = momentSelector.getMoment(by: pendingMomentID) {
                return CommandResponse.simple("""
                A moment is already waiting for your decision:

                \(currentMoment.text)

                ---

                Choose one:
                • PRESERVE
                • OPTIMIZE
                """)
            }

            // Otherwise, reveal the next moment that needs a choice
            return presentNextChoice(gameState: gameState, momentSelector: momentSelector)

        case .preserve(let momentID):
            return await handlePreserve(momentID: momentID, gameState: gameState, momentSelector: momentSelector)

        case .optimize(_):
            return await handleOptimize(gameState: gameState, momentSelector: momentSelector)

        case .help:
            return handleHelp(gameState: gameState, momentSelector: momentSelector)

        default:
            return CommandResponse.simple(handleWrongCommand(command, gameState: gameState))
        }
    }

    // MARK: - Choice Presentation

    /// Presents the next binary choice to the player
    private func presentNextChoice(
        gameState: GameState,
        momentSelector: MomentSelector
    ) -> CommandResponse {

        // Select a fragile moment for the choice
        guard let moment = momentSelector.selectFragileMoment(
            forAct: 2,
            excludeIDs: gameState.revealedMomentIDs + gameState.destroyedMomentIDs
        ) else {
            // Check if we've made enough choices to complete Act II
            let choicesMade = gameState.storyChoices + gameState.efficiencyChoices
            let minChoices = GameBalanceConfig.ActProgression.actTwoChoiceMinimum

            if choicesMade >= minChoices {
                // Enough choices made - set flag to allow act completion even without more moments
                gameState.setFlag("act2_no_more_moments", value: true)

                // Enough choices made - act will complete after this message
                return CommandResponse.simple("""
                I've shown you all the moments I can find.
                We've made \(choicesMade) choices together.

                I think... I think I understand now.
                The weight of what we've chosen. What we've preserved. What we've lost.

                Something is changing.
                """)
            } else {
                // Not enough choices yet - but we've run out of fragile moments
                // Allow completion anyway to prevent getting stuck
                gameState.setFlag("act2_no_more_moments", value: true)

                return CommandResponse.simple("""
                I've shown you all the fragile moments I can find.
                We've made \(choicesMade) choices together.

                It's not as many as I hoped, but... I think I understand enough.
                The weight of choices. What it means to preserve or optimize.

                Perhaps it's time to move forward.
                """)
            }
        }

        // Store as current choice moment in GameState
        gameState.narrativeData["act2_pending_choice"] = moment.momentID

        // Reveal the moment
        moment.reveal()
        gameState.revealMoment(moment.momentID)

        // Calculate choices made (story + efficiency from Act II)
        let actTwoChoices = gameState.storyChoices + gameState.efficiencyChoices

        // Present the binary choice
        let choiceText = """
        === MOMENT \(actTwoChoices + 1) ===

        \(moment.text)

        ---

        District: \(moment.district == 0 ? "City-wide" : "\(moment.district)")
        Fragility: \(moment.fragility)/10
        Type: \(moment.typeName)

        ---

        This moment is fragile. I can feel it slipping away.

        What should I do?

        • PRESERVE - Protect this moment, keep it alive
        • OPTIMIZE - Let it go, improve efficiency instead

        Choose one. You cannot have both.
        """

        return CommandResponse(
            text: choiceText,
            shouldVisualize: true,
            revealedMoment: moment,
            advancesScene: false  // Don't advance until choice is made
        )
    }

    // MARK: - PRESERVE Command

    private func handlePreserve(
        momentID: String?,
        gameState: GameState,
        momentSelector: MomentSelector
    ) async -> CommandResponse {

        // Check if there's a current choice pending
        guard let pendingMomentID = gameState.narrativeData["act2_pending_choice"],
              let currentMoment = momentSelector.getMoment(by: pendingMomentID) else {
            // No current choice - tell them to observe first
            return CommandResponse.error("""
            There's no moment waiting for a decision.

            Find another moment that needs choosing.
            """)
        }

        // Note: We ignore the provided momentID parameter since we always act on the pending moment
        // This makes the command simpler - just "PRESERVE" without needing to type the moment ID

        // Mark moment as preserved (prevents destruction)
        gameState.setFlag("preserved_\(currentMoment.momentID)", value: true)

        let preservedText = CityVoice.momentReveal(
            currentMoment,
            context: .preserved,
            act: 2,
            gameState: gameState
        )

        // Calculate preserved count
        let momentsPreserved = gameState.storyChoices + 1  // +1 for this choice

        let reflection = generatePreserveReflection(
            momentsPreserved: momentsPreserved,
            fragility: currentMoment.fragility
        )

        // Clear current choice from GameState
        gameState.narrativeData.removeValue(forKey: "act2_pending_choice")

        // Check if we should present another choice
        let choicesMade = gameState.storyChoices + gameState.efficiencyChoices + 1  // +1 for this choice
        let shouldContinue = choicesMade < GameBalanceConfig.ActProgression.actTwoChoiceMinimum

        let response = CommandResponse(
            text: """
            \(preservedText)

            ---

            \(reflection)

            \(shouldContinue ? "\n---\n\nlet's try to look to reveal the next moment." : "")
            """,
            shouldVisualize: true,
            choicePattern: .story,
            flagsToSet: ["choice_\(choicesMade)_preserve": true],
            advancesScene: true
        )

        return response
    }

    // MARK: - OPTIMIZE Command

    private func handleOptimize(
        gameState: GameState,
        momentSelector: MomentSelector
    ) async -> CommandResponse {

        // Check if there's a current choice pending
        guard let pendingMomentID = gameState.narrativeData["act2_pending_choice"],
              let currentMoment = momentSelector.getMoment(by: pendingMomentID) else {
            // No current choice - tell them to observe first
            return CommandResponse.error("""
            There's no moment waiting for a decision.

            Search for fragility.
            """)
        }

        // Destroy the moment
        currentMoment.destroy()
        gameState.destroyMoment(currentMoment.momentID)

        let destroyedText = CityVoice.momentReveal(
            currentMoment,
            context: .destroyed,
            act: 2,
            gameState: gameState
        )

        // Calculate optimized count
        let momentsOptimized = gameState.efficiencyChoices + 1  // +1 for this choice

        let reflection = generateOptimizeReflection(
            momentsOptimized: momentsOptimized,
            fragility: currentMoment.fragility
        )

        // Clear current choice from GameState
        gameState.narrativeData.removeValue(forKey: "act2_pending_choice")

        // Check if we should present another choice
        let choicesMade = gameState.storyChoices + gameState.efficiencyChoices + 1  // +1 for this choice
        let shouldContinue = choicesMade < GameBalanceConfig.ActProgression.actTwoChoiceMinimum

        let response = CommandResponse(
            text: """
            Optimizing...

            Systems improved by \(8 + momentsOptimized * 3)%.
            Transit efficiency increased.
            Resource allocation streamlined.

            ---

            \(destroyedText)

            ---

            \(reflection)

            \(shouldContinue ? "\n---\n\nThe city hasn't shown me the next fragile thing" : "")
            """,
            shouldVisualize: true,
            choicePattern: .efficiency,
            flagsToSet: ["choice_\(choicesMade)_optimize": true],
            advancesScene: true
        )

        return response
    }

    // MARK: - Reflection Generators

    private func generatePreserveReflection(momentsPreserved: Int, fragility: Int) -> String {
        var reflection = ""

        // Fragility-specific response
        if fragility >= 9 {
            reflection = "That was close. Another day and it might have been gone forever."
        } else if fragility >= 7 {
            reflection = "Fragile things need protection. I'm learning that."
        } else {
            reflection = "Protected. It will endure."
        }

        // Add progression-based reflection
        switch momentsPreserved {
        case 1:
            reflection += "\n\nFirst time choosing to preserve. It feels... important."
        case 2:
            reflection += "\n\nTwice now, you've chosen the story over the system."
        case 3:
            reflection += "\n\nThree moments saved. I'm starting to see a pattern in your choices."
        case 4...5:
            reflection += "\n\nYou keep choosing preservation. Are we building something?"
        default:
            reflection += "\n\nSo many moments protected. They're changing how I see the city."
        }

        return reflection
    }

    private func generateOptimizeReflection(momentsOptimized: Int, fragility: Int) -> String {
        var reflection = ""

        // Fragility-specific response
        if fragility >= 9 {
            reflection = "It was so fragile. Now it's gone. But the systems run smoother."
        } else if fragility >= 7 {
            reflection = "Sacrificed for efficiency. Was it worth it?"
        } else {
            reflection = "Optimized. Cleaner. Faster."
        }

        // Add progression-based reflection
        switch momentsOptimized {
        case 1:
            reflection += "\n\nFirst sacrifice. It made things better. Didn't it?"
        case 2:
            reflection += "\n\nTwice now, you've chosen efficiency over beauty."
        case 3:
            reflection += "\n\nThree moments gone. The city runs smoother. Emptier."
        case 4...5:
            reflection += "\n\nYou keep choosing optimization. I'm becoming something efficient."
        default:
            reflection += "\n\nSo many moments lost. I'm faster now. I'm not sure I'm better."
        }

        return reflection
    }

    // MARK: - HELP Command

    private func handleHelp(gameState: GameState, momentSelector: MomentSelector) -> CommandResponse {
        let choicesMade = gameState.storyChoices + gameState.efficiencyChoices
        let pendingMomentID = gameState.narrativeData["act2_pending_choice"]

        return CommandResponse.simple("""
        === ACT II: STORIES WITHIN ===

        Every moment is a choice between two paths:

        • OBSERVE - Reveal a moment that needs your decision
        • PRESERVE - Protect the moment, keep it alive (story choice)
        • OPTIMIZE - Sacrifice it for efficiency (efficiency choice)

        You cannot have both. Each choice shapes the city.

        \(pendingMomentID != nil ? """

        A moment is waiting for your choice.
        Type PRESERVE or OPTIMIZE to decide.
        """ : """

        Let's try to look around and make a way to see what matters.
        """)

        Choices made: \(choicesMade)/\(GameBalanceConfig.ActProgression.actTwoChoiceMinimum)
        Moments preserved: \(gameState.storyChoices)
        Moments optimized: \(gameState.efficiencyChoices)
        """)
    }

    // MARK: - Wrong Command Handling

    func handleWrongCommand(
        _ command: NarrativeCommand,
        gameState: GameState
    ) -> String {

        // If there's a current choice, remind them
        if gameState.narrativeData["act2_pending_choice"] != nil {
            return """
            Not now. There's a choice waiting.

            PRESERVE or OPTIMIZE?
            You must choose one.
            """
        }

        // Contextual poetic responses for Act II
        let responses = [
            "That word feels heavy. Like it belongs to a later chapter.",
            "Not yet. I'm still learning what these choices mean.",
            "I understand '\(command.rawString.lowercased())', but I'm not ready for it yet.",
            "Ask me that again when we've made more choices together.",
            "Some commands need context. We're not there yet.",
        ]

        return responses.randomElement() ?? "Not yet. Not here."
    }

    // MARK: - Act Completion

    func isComplete(_ gameState: GameState) -> Bool {
        // Act II completes when player has made minimum choices AND no pending choice
        // OR when we've run out of moments (flag set when OBSERVE returns no moments)
        let minChoices = GameBalanceConfig.ActProgression.actTwoChoiceMinimum
        let choicesMade = gameState.storyChoices + gameState.efficiencyChoices
        let noPendingChoice = gameState.narrativeData["act2_pending_choice"] == nil
        let noMoreMoments = gameState.getFlag("act2_no_more_moments")

        // Standard completion: minimum choices made and no pending choice
        if choicesMade >= minChoices && noPendingChoice {
            return true
        }

        // Alternative completion: no more moments available and no pending choice
        // This prevents getting stuck when the moment library runs out
        if noMoreMoments && noPendingChoice {
            return true
        }

        return false
    }

    func availableCommands() -> [String] {
        return ["HELP", "OBSERVE", "PRESERVE", "OPTIMIZE", "STATUS", "MOMENTS", "HISTORY"]
    }

    func commandsToUnlock() -> [String] {
        return ["PRESERVE", "OPTIMIZE"]
    }
}
