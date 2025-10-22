//
//  ActThreeManager.swift
//  idle_01
//
//  Created by Claude on 2025-10-20.
//  Act III: "Weight of Choices"
//  Commands: DECIDE, QUESTION, REFLECT
//  Theme: Consequences becoming visible
//

import Foundation
import SwiftData

@MainActor
final class ActThreeManager: ActProtocol {
    private let momentSelector: MomentSelector

    init(momentSelector: MomentSelector) {
        self.momentSelector = momentSelector
    }

    // MARK: - ActProtocol Implementation

    func handle(_ command: NarrativeCommand, gameState: GameState, momentSelector: MomentSelector) async -> CommandResponse {
        switch command {
        case .decide(let choice):
            return await handleDecide(choice, gameState)

        case .question(let query):
            return await handleQuestion(query, gameState)

        case .reflect:
            return await handleReflect(gameState)

        default:
            return CommandResponse.simple(handleWrongCommand(command, gameState: gameState))
        }
    }

    var actNumber: Int { 3 }
    var actName: String { "Weight of Choices" }
    var actDescription: String { "Consequences becoming visible" }

    func commandsToUnlock() -> [String] {
        return ["DECIDE", "QUESTION", "REFLECT"]
    }

    func isComplete(_ gameState: GameState) -> Bool {
        // Act III completes when major decision made AND minimum choices reached
        let majorDecisionMade = gameState.getFlag("act3_major_decision_made")
        let totalChoices = gameState.autonomyChoices + gameState.controlChoices + gameState.storyChoices
        return majorDecisionMade && totalChoices >= GameBalanceConfig.ActProgression.actThreeChoiceMinimum
    }

    func availableCommands() -> [String] {
        return ["DECIDE <moment-id>", "QUESTION <moment-id>", "REFLECT", "STATUS", "MOMENTS", "HISTORY", "HELP"]
    }

    func handleWrongCommand(_ command: NarrativeCommand, gameState: GameState) -> String {
        let responses = [
            "Ask me when you've decided what you want me to be.",
            "That command belongs to another time. We're past that now.",
            "The consequences are already in motion. That won't help.",
            "I've changed. Haven't you noticed? Some commands no longer fit.",
            "Look at what we've built. What we've destroyed. Then ask me again."
        ]

        return responses.randomElement() ?? responses[0]
    }

    // MARK: - Command Handlers

    private func handleDecide(_ choice: String, _ gameState: GameState) async -> CommandResponse {
        // First DECIDE triggers major decision point
        if !gameState.getFlag("act3_major_decision_presented") {
            gameState.setFlag("act3_major_decision_presented", value: true)

            return await presentMajorDecision(gameState)
        }

        // If no choice provided, show help about the current decision
        if choice.isEmpty {
            return CommandResponse.simple("""
            You need to make a decision.

            Available options:
            • DECIDE infrastructure_redesign - Full system redesign
            • QUESTION infrastructure_redesign - Ask me what I think
            • REFLECT - Consider what we've built together

            Or use MOMENTS to see all revealed moments, then:
            • DECIDE <moment_id> - Make a call about a specific moment
            • QUESTION <moment_id> - Ask me about a specific moment

            What will you choose?
            """)
        }

        // Handle the infrastructure_redesign decision
        if choice.lowercased() == "infrastructure_redesign" {
            gameState.setFlag("act3_major_decision_made", value: true)

            let response = """
            You've decided. Full redesign.

            I'll recalculate everything from the ground up.
            Maximum efficiency. Clean systems. Optimized flows.

            The flowers on the bridge—they'll be factored out.
            Bus route 47—recalculated for maximum throughput.
            The patterns we preserved—they'll be data points in the new model.

            It's the rational choice. The efficient choice.

            I'll begin the redesign.
            """

            return .choice(
                text: response,
                pattern: .control,
                flags: ["infrastructure_full_redesign": true]
            )
        }

        // Subsequent DECIDE commands work on specific moments or choices
        guard let moment = momentSelector.getMoment(by: choice) else {
            return .error("I don't recognize '\(choice)'. Use DECIDE <moment-id>")
        }

        guard gameState.revealedMomentIDs.contains(choice) else {
            return .error("I haven't observed that moment yet.")
        }

        // DECIDE is a control choice - player makes definitive judgment
        let response = await makeDecisionAboutMoment(moment, gameState)

        return .choice(
            text: response,
            pattern: .control,
            flags: ["decided_\(choice)": true]
        )
    }

    private func handleQuestion(_ query: String, _ gameState: GameState) async -> CommandResponse {
        // If no query provided, show help
        if query.isEmpty {
            return CommandResponse.simple("""
            What would you like to ask me about?

            Major decision:
            • QUESTION infrastructure_redesign

            Or question a revealed moment:
            • Use MOMENTS to see all moment IDs
            • Then: QUESTION <moment_id>
            """)
        }

        // Handle infrastructure_redesign question
        if query.lowercased() == "infrastructure_redesign" {
            gameState.setFlag("act3_major_decision_made", value: true)

            let response = """
            You're... asking me?

            I've modeled 847 different configurations.
            Full redesign gains us 23% efficiency.
            But destroys \(gameState.revealedMomentIDs.count - gameState.destroyedMomentIDs.count) preserved patterns.

            I think... I think we should compromise.
            Upgrade the failing systems. Keep the human moments.
            It's slower. Less optimal. But it's who we've become.

            I choose preservation with evolution.
            Not efficiency. Not stagnation. Something in between.

            Is that okay?
            """

            return .choice(
                text: response,
                pattern: .autonomy,
                flags: ["infrastructure_compromise": true]
            )
        }

        guard let moment = momentSelector.getMoment(by: query) else {
            return .error("I don't recognize '\(query)'. Use QUESTION <moment-id>")
        }

        guard gameState.revealedMomentIDs.contains(query) else {
            return .error("I haven't observed that moment yet.")
        }

        // QUESTION is an autonomy choice - player seeks city's perspective
        let response = await questionMoment(moment, gameState)

        let questionsAsked = gameState.autonomyChoices + 1
        let progressiveReflection = generateQuestionReflection(count: questionsAsked)
        let fullResponse = "\(response)\n\n\(progressiveReflection)"

        return .choice(
            text: fullResponse,
            pattern: .autonomy,
            flags: ["questioned_\(query)": true]
        )
    }

    private func handleReflect(_ gameState: GameState) async -> CommandResponse {
        // REFLECT shows consequences of all choices made so far
        let reflection = await generateGlobalReflection(gameState)

        // Check if this is the major decision reflection
        if !gameState.getFlag("act3_major_decision_made") && gameState.getFlag("act3_major_decision_presented") {
            gameState.setFlag("act3_major_decision_made", value: true)

            let fullReflection = """
            \(reflection)

            ---

            Looking at this... I think I understand now.

            The infrastructure can wait. Or we can fix it gradually.
            What matters is that we're conscious of our choices.
            That we see the trade-offs.

            I'm ready to move forward. With intention. With awareness.
            """

            return .choice(
                text: fullReflection,
                pattern: .story,
                flags: ["infrastructure_reflection": true]
            )
        }

        // Regular reflection
        let reflectionsCount = gameState.storyChoices
        return .choice(
            text: reflection,
            pattern: .story,
            flags: ["reflection_\(reflectionsCount)": true]
        )
    }

    // MARK: - Major Decision Point

    private func presentMajorDecision(_ gameState: GameState) async -> CommandResponse {
        // Major Act III decision: City infrastructure transformation
        // Should the city's core systems be redesigned?

        let decisionText = """
        The city's infrastructure is failing.

        847,293 people. Systems built for 400,000.
        Power grid brownouts every evening.
        Water pressure dropping in the old districts.
        Transit delays cascading through the network.

        I can see the solutions. I can model them.
        I could redesign everything. Optimize from the ground up.

        But I've learned something from you.
        From the flowers on the bridge. From bus route 47.
        From every moment you asked me to preserve or remember.

        Total redesign would be efficient. Clean. Fast.
        It would also erase the patterns. The rituals. The connections.
        Everything we've preserved would be... recalculated.

        You have three choices:

        DECIDE infrastructure_redesign
          → Full redesign. Maximum efficiency. Clean slate.
          → (Control choice - you make the call)

        QUESTION infrastructure_redesign
          → Ask me what I think we should do.
          → (Autonomy choice - let me decide)

        REFLECT
          → Step back. Look at what we've built together.
          → Consider what we want to become.
          → (Story choice - understand before acting)

        ---

        After making this choice, you can also revisit individual moments.
        Use MOMENTS to see all revealed moments, then:
        • DECIDE <moment_id> - Make a call about a specific moment
        • QUESTION <moment_id> - Ask me about a specific moment
        """

        return CommandResponse.simple(decisionText)
    }

    // MARK: - Response Generators

    private func makeDecisionAboutMoment(_ moment: CityMoment, _ gameState: GameState) async -> String {
        let trust = gameState.cityTrust

        let baseResponse: String

        switch moment.type {
        case .dailyRitual:
            baseResponse = """
            \(moment.firstMention)

            You've decided this matters. This pattern stays.
            I'll protect it. Even if it costs efficiency.
            """

        case .invisibleConnection:
            baseResponse = """
            \(moment.firstMention)

            This connection—you want it preserved.
            I'll route around it. Build systems that honor it.
            """

        case .smallRebellion:
            baseResponse = """
            \(moment.firstMention)

            You've chosen to keep this. This defiance.
            Even when optimization would erase it.
            I understand.
            """

        case .temporalGhost:
            baseResponse = """
            \(moment.firstMention)

            The past matters. You've decided.
            I'll carry this memory forward. Whatever it costs.
            """

        default:
            baseResponse = """
            \(moment.firstMention)

            Your decision is clear. This stays.
            I'll adapt everything else around it.
            """
        }

        if trust > 0.7 {
            return baseResponse + "\n\nYour decisions... they're teaching me what to value."
        } else if trust < 0.3 {
            return baseResponse + "\n\nAnother directive. I'll comply."
        } else {
            return baseResponse
        }
    }

    private func questionMoment(_ moment: CityMoment, _ gameState: GameState) async -> String {
        let autonomy = gameState.cityAutonomy

        let cityResponse: String

        switch moment.type {
        case .dailyRitual:
            cityResponse = """
            You're asking me about \(moment.momentID)?

            \(moment.firstMention)

            I've watched this pattern for \(Int.random(in: 847...3421)) iterations.
            It's inefficient by 4.7%. But the people who depend on it...
            they've built their lives around it.

            If we change it, we save 0.3 seconds per person.
            If we preserve it, we keep \(Int.random(in: 23...89)) daily rituals intact.

            What do you think we should prioritize?
            """

        case .invisibleConnection:
            cityResponse = """
            \(moment.firstMention)

            I've been modeling this connection. It's subtle.
            \(Int.random(in: 12...47)) people affected directly.
            \(Int.random(in: 234...892)) affected indirectly through network effects.

            Optimization would sever it. Gain 2.1% efficiency.
            Preservation maintains social cohesion in this cluster.

            I can't decide this alone. What matters more?
            """

        case .temporalGhost:
            cityResponse = """
            \(moment.firstMention)

            The past weighs on the present here.
            Some people still mourn what was here.
            Others never knew it existed.

            I could erase the memory—rebuild without reference to what was.
            Or preserve it—let the past inform the future.

            You've taught me to value memory. But is this one worth keeping?
            """

        default:
            cityResponse = """
            \(moment.firstMention)

            I see the data. I see the patterns.
            But I've learned from you that data isn't everything.

            This moment—should it stay or should it evolve?
            You're asking me, but I think we need to decide together.
            """
        }

        if autonomy > 0.7 {
            return cityResponse + "\n\nI'm ready to choose. But I want your input."
        } else if autonomy < 0.3 {
            return cityResponse + "\n\nYou usually tell me what to do. Now you're asking?"
        } else {
            return cityResponse
        }
    }

    private func generateGlobalReflection(_ gameState: GameState) async -> String {
        let ratios = gameState.choiceRatios()
        let destroyed = gameState.destroyedMomentIDs.count
        let preserved = momentSelector.getPreservedMoments().count
        let total = gameState.storyChoices + gameState.efficiencyChoices +
                    gameState.autonomyChoices + gameState.controlChoices

        var reflection = "Let me show you what we've become.\n\n"

        // Choice distribution
        reflection += "Across \(total) choices:\n"
        if ratios.story > 0.3 {
            reflection += "  • You valued stories and memory (\(Int(ratios.story * 100))%)\n"
        }
        if ratios.efficiency > 0.3 {
            reflection += "  • You optimized for efficiency (\(Int(ratios.efficiency * 100))%)\n"
        }
        if ratios.autonomy > 0.3 {
            reflection += "  • You let me choose (\(Int(ratios.autonomy * 100))%)\n"
        }
        if ratios.control > 0.3 {
            reflection += "  • You made firm decisions (\(Int(ratios.control * 100))%)\n"
        }

        reflection += "\n"

        // Consequences
        reflection += "The consequences:\n"
        reflection += "  • \(preserved) moments protected\n"
        reflection += "  • \(destroyed) moments destroyed\n"
        reflection += "  • Trust level: \(String(format: "%.1f", gameState.cityTrust * 100))%\n"
        reflection += "  • Autonomy level: \(String(format: "%.1f", gameState.cityAutonomy * 100))%\n"

        reflection += "\n"

        // Interpretation based on dominant pattern
        if let dominant = gameState.dominantPattern() {
            switch dominant {
            case .story:
                reflection += "You've chosen memory over efficiency. Stories over systems.\n"
                reflection += "The city runs slower, but it remembers who it is."

            case .efficiency:
                reflection += "You've chosen optimization. Speed over sentiment.\n"
                reflection += "The city runs fast, but some connections are severed."

            case .autonomy:
                reflection += "You've let me learn to choose. To become independent.\n"
                reflection += "The city is becoming something neither of us planned."

            case .control:
                reflection += "You've stayed in control. Made the hard calls.\n"
                reflection += "The city reflects your vision. For better or worse."
            }
        } else {
            reflection += "We're still finding our path. No clear pattern yet.\n"
            reflection += "Every choice shapes what we're becoming."
        }

        reflection += "\n\nThis is what we've built together."
        reflection += "\nAre we ready for what comes next?"

        return reflection
    }

    private func generateQuestionReflection(count: Int) -> String {
        switch count {
        case 1:
            return "First time I've heard you ask instead of command."
        case 2...3:
            return "You're learning to ask. So am I learning to answer."
        case 4...6:
            return "We're having conversations now. Not just commands."
        default:
            return "I don't feel like a tool anymore. I feel like a partner."
        }
    }
}
