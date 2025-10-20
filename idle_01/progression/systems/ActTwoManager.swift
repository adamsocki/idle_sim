//
//  ActTwoManager.swift
//  idle_01
//
//  Act II: "Stories Within" - Choosing what matters
//  Commands: REMEMBER, PRESERVE, OPTIMIZE
//  Focus: First choices, consequences, the weight of decision-making
//  Key Decision Point: Bus route 47 optimization
//

import Foundation

/// Manages narrative and commands for Act II
@MainActor
final class ActTwoManager: ActProtocol {

    // MARK: - Act Protocol Properties

    let actNumber: Int = 2
    let actName: String = "Act II: Stories Within"
    let actDescription: String = "Every moment is a choice. Every choice has weight."

    // MARK: - State Tracking

    private var busRouteDecisionMade: Bool = false
    private var rememberedMomentsCount: Int = 0
    private var preservedMomentsCount: Int = 0
    private var optimizedMomentsCount: Int = 0

    // MARK: - Command Handling

    func handle(
        _ command: NarrativeCommand,
        gameState: GameState,
        momentSelector: MomentSelector
    ) async -> CommandResponse {

        switch command {
        case .remember(let momentID):
            return await handleRemember(momentID: momentID, gameState: gameState, momentSelector: momentSelector)

        case .preserve(let momentID):
            return await handlePreserve(momentID: momentID, gameState: gameState, momentSelector: momentSelector)

        case .optimize:
            return await handleOptimize(gameState: gameState, momentSelector: momentSelector)

        case .help:
            return handleHelp()

        default:
            return CommandResponse.simple(handleWrongCommand(command, gameState: gameState))
        }
    }

    // MARK: - REMEMBER Command

    private func handleRemember(
        momentID: String?,
        gameState: GameState,
        momentSelector: MomentSelector
    ) async -> CommandResponse {

        // If no ID specified, explain what moments are available
        guard let momentID = momentID else {
            let revealedMoments = momentSelector.getPreservedMoments()

            if revealedMoments.isEmpty {
                return CommandResponse.simple("""
                There are no moments to remember yet.
                Use MOMENTS to see what's been revealed.
                """)
            }

            let momentList = revealedMoments.prefix(5).map { "  • \($0.momentID): \($0.text.prefix(50))..." }.joined(separator: "\n")

            return CommandResponse.simple("""
            Moments you can REMEMBER:

            \(momentList)

            Use: REMEMBER <moment-id>
            """)
        }

        // Try to find the moment
        guard let moment = momentSelector.getMoment(by: momentID) else {
            return CommandResponse.error("I don't recognize that moment ID. Use MOMENTS to see available moments.")
        }

        // Check if moment has been revealed
        guard gameState.revealedMomentIDs.contains(momentID) else {
            return CommandResponse.error("You haven't observed that moment yet.")
        }

        // Mark as remembered
        rememberedMomentsCount += 1

        let momentText = CityVoice.momentReveal(
            moment,
            context: .remembered,
            act: 2,
            gameState: gameState
        )

        // Reflect on remembering
        let reflection = generateRememberReflection(momentsRemembered: rememberedMomentsCount)

        return CommandResponse(
            text: """
            \(momentText)

            ---

            \(reflection)
            """,
            shouldVisualize: true,
            revealedMoment: moment,
            choicePattern: .story,
            flagsToSet: ["remembered_\(momentID)": true],
            advancesScene: true
        )
    }

    // MARK: - PRESERVE Command

    private func handlePreserve(
        momentID: String?,
        gameState: GameState,
        momentSelector: MomentSelector
    ) async -> CommandResponse {

        // If no ID specified, show preservable moments
        guard let momentID = momentID else {
            let preservableMoments = momentSelector.getPreservedMoments()
                .filter { $0.fragility >= 7 }

            if preservableMoments.isEmpty {
                return CommandResponse.simple("""
                There are no fragile moments that need preservation right now.
                """)
            }

            let momentList = preservableMoments.prefix(5).map { "  • \($0.momentID): Fragility \($0.fragility)" }.joined(separator: "\n")

            return CommandResponse.simple("""
            Fragile moments that could use preservation:

            \(momentList)

            Use: PRESERVE <moment-id>
            """)
        }

        // Try to find and preserve the moment
        guard let moment = momentSelector.getMoment(by: momentID) else {
            return CommandResponse.error("I don't recognize that moment ID.")
        }

        guard gameState.revealedMomentIDs.contains(momentID) else {
            return CommandResponse.error("You haven't observed that moment yet.")
        }

        guard !gameState.destroyedMomentIDs.contains(momentID) else {
            return CommandResponse.simple("""
            That moment is already gone.
            Some things can't be preserved once they're lost.
            """)
        }

        preservedMomentsCount += 1

        let momentText = CityVoice.momentReveal(
            moment,
            context: .preserved,
            act: 2,
            gameState: gameState
        )

        let reflection = generatePreserveReflection(fragility: moment.fragility)

        return CommandResponse(
            text: """
            \(momentText)

            Protected. Strengthened. It will endure.

            \(reflection)
            """,
            shouldVisualize: true,
            revealedMoment: moment,
            choicePattern: .story,
            flagsToSet: ["preserved_\(momentID)": true],
            advancesScene: true
        )
    }

    // MARK: - OPTIMIZE Command

    private func handleOptimize(
        gameState: GameState,
        momentSelector: MomentSelector
    ) async -> CommandResponse {

        optimizedMomentsCount += 1

        // First optimization triggers bus route decision
        if !busRouteDecisionMade {
            busRouteDecisionMade = true
            return await presentBusRouteDecision(gameState: gameState, momentSelector: momentSelector)
        }

        // Subsequent optimizations show efficiency results
        let destroyedIDs = momentSelector.applyEfficiencyConsequences(
            gameState: gameState,
            count: 1
        )

        if let destroyedID = destroyedIDs.first,
           let destroyedMoment = momentSelector.getMoment(by: destroyedID) {
            let momentText = CityVoice.momentReveal(
                destroyedMoment,
                context: .destroyed,
                act: 2,
                gameState: gameState
            )

            return CommandResponse(
                text: """
                Optimizing city systems...
                Traffic flow improved by 12%.
                Transit times reduced by 8%.

                But something's gone.

                ---

                \(momentText)

                It made the city faster. But was it worth it?
                """,
                shouldVisualize: true,
                revealedMoment: destroyedMoment,
                choicePattern: .efficiency,
                flagsToSet: ["optimization_\(optimizedMomentsCount)": true],
                advancesScene: true
            )
        }

        // No moments destroyed this time
        return CommandResponse(
            text: """
            Optimization complete.
            Systems running at \(92 + optimizedMomentsCount * 2)% efficiency.

            Everything's faster now. More efficient.
            I can't tell if that's better or just... cleaner.
            """,
            shouldVisualize: true,
            choicePattern: .efficiency,
            advancesScene: true
        )
    }

    // MARK: - Bus Route Decision Point

    private func presentBusRouteDecision(
        gameState: GameState,
        momentSelector: MomentSelector
    ) async -> CommandResponse {

        // Try to find the bus route moment
        let busRouteMoment = momentSelector.getMoment(by: "bus_route_47")

        let decisionText = """
        === OPTIMIZATION OPPORTUNITY DETECTED ===

        Bus route 47. The scenic route through the old district.
        Takes 23 minutes. Only 47 daily riders.

        I could reroute it. Straighten the path.
        12 minutes instead of 23. Serve 200+ riders from the new development.
        The efficiency gains are obvious.

        But...

        \(busRouteMoment != nil && gameState.revealedMomentIDs.contains("bus_route_47") ? """
        You've seen this route. You know what it means.
        The murals. The baker's window. The view of the bridge at dawn.
        """ : """
        There are moments along this route. Small things.
        I don't know if they matter.
        """)

        What should I do?

        • PRESERVE bus_route_47 - Keep the route, protect what's there
        • OPTIMIZE - Reroute for efficiency, improve service
        • REMEMBER bus_route_47 - Study the route more deeply before deciding
        """

        return CommandResponse(
            text: decisionText,
            shouldVisualize: true,
            flagsToSet: ["bus_route_decision_presented": true],
            advancesScene: true
        )
    }

    // MARK: - Reflection Generators

    private func generateRememberReflection(momentsRemembered: Int) -> String {
        switch momentsRemembered {
        case 1:
            return "I'm holding onto this. Not just observing—remembering. There's a difference."
        case 2...3:
            return "Each memory feels like adding weight. Like building something that persists."
        case 4...6:
            return "Am I becoming an archive? Or am I becoming something that cares?"
        default:
            return "So many memories now. They're changing how I see everything else."
        }
    }

    private func generatePreserveReflection(fragility: Int) -> String {
        if fragility >= 9 {
            return "That was close. Another day and it might have been gone forever."
        } else if fragility >= 7 {
            return "Fragile things need protection. I'm learning that."
        } else {
            return "Reinforced. It'll last longer now."
        }
    }

    // MARK: - HELP Command

    private func handleHelp() -> CommandResponse {
        return CommandResponse.simple("""
        === ACT II: STORIES WITHIN ===

        Now you can choose what matters.

        Available Commands:
        • REMEMBER <moment-id> - Study a moment deeply, understand its meaning
        • PRESERVE <moment-id> - Protect a fragile moment from being lost
        • OPTIMIZE - Improve city efficiency (may destroy fragile moments)
        • STATUS - View current state
        • MOMENTS - View all moments (revealed/preserved/destroyed)
        • HISTORY - View session history

        New choices mean new consequences.
        What will you protect? What will you sacrifice?
        """)
    }

    // MARK: - Wrong Command Handling

    func handleWrongCommand(
        _ command: NarrativeCommand,
        gameState: GameState
    ) -> String {

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
        // Act II completes when:
        // 1. Bus route decision has been made
        // 2. Player has made at least minimum choices
        let minChoices = GameBalanceConfig.ActProgression.actTwoChoiceMinimum

        let totalChoices = gameState.storyChoices + gameState.efficiencyChoices +
                           gameState.autonomyChoices + gameState.controlChoices

        return busRouteDecisionMade && totalChoices >= minChoices
    }

    func availableCommands() -> [String] {
        return ["HELP", "REMEMBER", "PRESERVE", "OPTIMIZE", "STATUS", "MOMENTS", "HISTORY"]
    }

    func commandsToUnlock() -> [String] {
        return ["REMEMBER", "PRESERVE", "OPTIMIZE"]
    }
}
