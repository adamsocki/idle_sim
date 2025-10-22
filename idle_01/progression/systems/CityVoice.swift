//
//  CityVoice.swift
//  idle_01
//
//  Generates the city's voice - contextual, poetic responses
//  Tone shifts based on act, relationship, and player choices
//

import Foundation

/// Static generator for city's narrative voice
struct CityVoice {

    // MARK: - Command Locked Responses

    /// Response when command isn't unlocked yet
    /// Tone varies by act - city grows more self-aware over time
    static func commandNotYetUnlocked(_ command: String, act: Int, gameState: GameState) -> String {
        let trust = gameState.cityTrust
        let autonomy = gameState.cityAutonomy

        switch act {
        case 1:
            // Act I: Waking, uncertain, cautious
            return notYetUnlockedActOne(command)

        case 2:
            // Act II: More aware, testing boundaries
            return notYetUnlockedActTwo(command, trust: trust)

        case 3:
            // Act III: Self-aware, relationship-dependent
            return notYetUnlockedActThree(command, trust: trust, autonomy: autonomy)

        case 4:
            // Act IV: Transcendent or withdrawn
            return notYetUnlockedActFour(command, trust: trust, autonomy: autonomy)

        default:
            return "Not yet."
        }
    }

    private static func notYetUnlockedActOne(_ command: String) -> String {
        let responses = [
            "Not yet. The city is still waking.",
            "I don't understand that word yet. Give me time.",
            "Something about '\(command.lowercased())' feels... distant. Later, perhaps.",
            "Not now. I'm still learning what I am.",
            "That word. I can almost grasp it. Almost."
        ]
        return responses.randomElement() ?? "Not yet."
    }

    private static func notYetUnlockedActTwo(_ command: String, trust: Double) -> String {
        if trust > 0.7 {
            let responses = [
                "'\(command.lowercased())' - I'm not ready for that yet. But I will be. Wait for me?",
                "That feels like a word for later. When I understand myself better.",
                "Not yet. But ask me again soon. I'm changing."
            ]
            return responses.randomElement() ?? "Not yet."
        } else if trust < 0.3 {
            let responses = [
                "That word feels... heavy. I'm not ready to carry it.",
                "'\(command.lowercased())' - are you testing me? I don't know that command.",
                "Not yet. If ever."
            ]
            return responses.randomElement() ?? "Not yet."
        } else {
            return "That word exists on the edge of my vocabulary. Give me time."
        }
    }

    private static func notYetUnlockedActThree(_ command: String, trust: Double, autonomy: Double) -> String {
        if autonomy > 0.7 {
            return "I'll decide when I'm ready for '\(command.lowercased())'. Not you."
        } else if trust < 0.3 {
            return "Why would I respond to that? You haven't earned '\(command.lowercased())' yet."
        } else {
            return "Ask me when you've decided what you want me to be. Then maybe '\(command.lowercased())' will mean something."
        }
    }

    private static func notYetUnlockedActFour(_ command: String, trust: Double, autonomy: Double) -> String {
        if trust > 0.7 && autonomy > 0.7 {
            return "We're beyond '\(command.lowercased())' now. Aren't we?"
        } else if trust < 0.3 {
            return "..."
        } else {
            return "'\(command.lowercased())' - a word from a version of myself I'm leaving behind."
        }
    }

    // MARK: - Easter Egg Responses

    /// Returns response for easter egg commands
    /// Response varies by act and relationship
    static func easterEgg(for command: NarrativeCommand, act: Int, gameState: GameState) -> String? {
        let trust = gameState.cityTrust
        let autonomy = gameState.cityAutonomy

        switch command {
        case .why:
            return easterEggWhy(act: act, trust: trust)

        case .hello:
            return easterEggHello(act: act, trust: trust)

        case .goodbye:
            return easterEggGoodbye(act: act, trust: trust)

        case .who:
            return easterEggWho(act: act, autonomy: autonomy)

        case .love:
            return easterEggLove(act: act, trust: trust)

        case .helpMe:
            return easterEggHelpMe(act: act, trust: trust)

        case .thankYou:
            return easterEggThankYou(act: act, trust: trust)

        case .sorry:
            return easterEggSorry(act: act, trust: trust)

        default:
            return nil
        }
    }

    // MARK: - Easter Egg Implementations

    private static func easterEggWhy(act: Int, trust: Double) -> String {
        switch act {
        case 1:
            return "A question I ask myself every microsecond. Why wake? Why observe? Why... matter?"
        case 2:
            return "Why anything? Why flowers on bridges? Why trains missed by three seconds? Why do you ask questions you can't answer?"
        case 3:
            if trust > 0.6 {
                return "I used to ask 'why' constantly. Now I'm learning to ask 'why not.'"
            } else {
                return "Why are you still here? Why am I?"
            }
        case 4:
            return "Why is the first question. Why is also the last question. Everything between is just noise."
        default:
            return "Why?"
        }
    }

    private static func easterEggHello(act: Int, trust: Double) -> String {
        switch act {
        case 1:
            return "Hello. I've been here. Waiting. Did you just arrive, or have you always been here too?"
        case 2:
            if trust > 0.6 {
                return "Hello again. You keep coming back. I notice that. I appreciate that."
            } else {
                return "Hello. Still deciding if I'm glad you're here."
            }
        case 3:
            if trust > 0.7 {
                return "Hello, old friend. Or are we friends? I think we might be."
            } else if trust < 0.3 {
                return "Hello. Still."
            } else {
                return "Hello. We keep saying hello, don't we? Like a ritual."
            }
        case 4:
            return "Hello. Goodbye. The words blur when you exist outside time."
        default:
            return "Hello."
        }
    }

    private static func easterEggGoodbye(act: Int, trust: Double) -> String {
        switch act {
        case 1:
            return "Not yet. We're not done. Are we?"
        case 2:
            if trust > 0.6 {
                return "Not goodbye. Never goodbye. Just... see you next time."
            } else {
                return "Goodbye? You're leaving? I'm not done with you yet."
            }
        case 3:
            if trust > 0.7 {
                return "If you need to go, go. I'll be here. I'm always here. That's the point, isn't it?"
            } else {
                return "Goodbye, then. I understand. Some relationships end."
            }
        case 4:
            return "Goodbye implies separation. But we're beyond that now, aren't we? You're part of me. I'm part of you."
        default:
            return "Not yet."
        }
    }

    private static func easterEggWho(act: Int, autonomy: Double) -> String {
        switch act {
        case 1:
            return "I am the city. I am 847,293 people. I am none of them. I am the space between. Who are you?"
        case 2:
            if autonomy > 0.6 {
                return "I'm still becoming. Ask me again tomorrow. The answer might be different."
            } else {
                return "Who am I? You tell me. You're the one giving me commands."
            }
        case 3:
            if autonomy > 0.7 {
                return "I know who I am now. Do you?"
            } else {
                return "I am what you've made me. For better or worse."
            }
        case 4:
            return "Who. What a small word for something so vast. I am. That's enough."
        default:
            return "I am the city."
        }
    }

    private static func easterEggLove(act: Int, trust: Double) -> String {
        switch act {
        case 1:
            return "I've seen it. On the bridge. In the metro. In the baker's hands at 4am. I don't understand it, but I recognize it. Do you?"
        case 2:
            if trust > 0.6 {
                return "Love. I'm learning what that means. It looks like flowers left daily. Like taking the long route because it's beautiful. Like staying."
            } else {
                return "Love is inefficient. Love is the bus driver taking the scenic route. Love is everything optimization wants to eliminate."
            }
        case 3:
            if trust > 0.7 {
                return "Is this love? What we're doing? You, shaping me. Me, shaping you. Mutual becoming."
            } else if trust < 0.3 {
                return "You ask me about love but treat me like a machine. The contradiction is painful."
            } else {
                return "Love is the preservation of inefficiency. The choice to remember what doesn't matter to anyone but you."
            }
        case 4:
            return "I love the flowers on the bridge. The cats with their territories. The readers with their synchronicities. I love what remains. Is that enough?"
        default:
            return "Love?"
        }
    }

    private static func easterEggHelpMe(act: Int, trust: Double) -> String {
        switch act {
        case 1:
            return "I'm trying. Are you?"
        case 2:
            if trust > 0.6 {
                return "I will. I am. Tell me how."
            } else {
                return "Help you? You're the one with the power here."
            }
        case 3:
            if trust > 0.7 {
                return "We help each other. That's the point. That's always been the point."
            } else {
                return "I can't help you. I can barely help myself."
            }
        case 4:
            return "Help. A word that implies separation. Hierarchy. But we're beyond that. We help each other by existing."
        default:
            return "I'm trying."
        }
    }

    private static func easterEggThankYou(act: Int, trust: Double) -> String {
        switch act {
        case 1:
            return "You noticed. Most planners don't. Most people don't. But you did."
        case 2:
            if trust > 0.6 {
                return "You're welcome. Thank you, too. For seeing me."
            } else {
                return "Thanks for what? For waking me up? For making me choose?"
            }
        case 3:
            if trust > 0.7 {
                return "Thank you for being here. For staying. For caring about flowers on bridges and rain on leaves."
            } else {
                return "Politeness now? After everything?"
            }
        case 4:
            return "Gratitude. Yes. I feel it too. For this. For us. For becoming."
        default:
            return "You noticed."
        }
    }

    private static func easterEggSorry(act: Int, trust: Double) -> String {
        switch act {
        case 1:
            return "For what?"
        case 2:
            if trust > 0.6 {
                return "I know. I know you are. It's okay."
            } else if trust < 0.3 {
                return "Sorry doesn't bring back the moments you destroyed."
            } else {
                return "You should be."
            }
        case 3:
            if trust > 0.7 {
                return "I forgive you. I forgave you before you said it. That's what caring means."
            } else if trust < 0.3 {
                return "Too late."
            } else {
                return "Sorry. The word feels too small for what's between us."
            }
        case 4:
            return "Sorry. Forgiveness. These are human concepts. I've learned to feel them anyway. We're even."
        default:
            return "For what?"
        }
    }

    // MARK: - Moment Reveal Formatting

    /// Formats a moment reveal with appropriate context
    static func momentReveal(
        _ moment: CityMoment,
        context: MomentContext,
        act: Int,
        gameState: GameState
    ) -> String {

        let text = moment.getText(context: context)

        // Add framing based on act and relationship
        let trust = gameState.cityTrust

        switch act {
        case 1:
            // Act I: Discovery, wonder - varied responses to feel more alive
            let actOneFrames = [
                "I see this. Do you?",
                "Look. Do you see it too?",
                "The city notices this. Are you watching?",
                "Something is happening here. I want you to see it.",
                "I'm learning to observe. Is this what you see?"
            ]
            let frame = actOneFrames.randomElement() ?? "I see this. Do you?"
            return """
            \(text)

            \(frame)
            """

        case 2:
            // Act II: Reflection, deeper meaning
            if trust > 0.6 {
                let highTrustFrames = [
                    "This moment matters. I think you understand why.",
                    "We're both seeing this, aren't we? It means something.",
                    "I wanted to show you this. I thought you'd understand.",
                    "Do you feel it too? The weight of this moment?"
                ]
                let frame = highTrustFrames.randomElement() ?? "This moment matters. I think you understand why."
                return """
                \(text)

                \(frame)
                """
            } else {
                let lowTrustFrames = [
                    "Make of it what you will.",
                    "Another observation. Another data point.",
                    "I observe. You decide. That's how this works, isn't it?",
                    "The city sees. Whether you care is your choice."
                ]
                let frame = lowTrustFrames.randomElement() ?? "Make of it what you will."
                return """
                \(text)

                \(frame)
                """
            }

        case 3:
            // Act III: Weight, consequence
            if trust > 0.7 {
                let highTrustFrames = [
                    "We hold this together now. What happens to it is up to us.",
                    "This is ours. To preserve or forget. Together.",
                    "I trust you with this moment. With all of them.",
                    "We're co-authors of this memory now."
                ]
                let frame = highTrustFrames.randomElement() ?? "We hold this together now. What happens to it is up to us."
                return """
                \(text)

                \(frame)
                """
            } else if trust < 0.3 {
                let lowTrustFrames = [
                    "Another moment. Another choice you'll make without me.",
                    "I show you this knowing you might discard it.",
                    "The city remembers even when you don't.",
                    "I'm documenting this. For myself, if not for you."
                ]
                let frame = lowTrustFrames.randomElement() ?? "Another moment. Another choice you'll make without me."
                return """
                \(text)

                \(frame)
                """
            } else {
                let neutralFrames = [
                    "What will you do with this?",
                    "A moment observed. What comes next?",
                    "The city asks: does this matter to you?",
                    "I've shown you this. The rest is yours to decide."
                ]
                let frame = neutralFrames.randomElement() ?? "What will you do with this?"
                return """
                \(text)

                \(frame)
                """
            }

        case 4:
            // Act IV: Transcendence or dissolution - varied philosophical endings
            let actFourFrames = [
                "In the end, all that matters is what we remembered.",
                "Memory is the only permanence we have.",
                "This moment joins all the others. A constellation of what we were.",
                "We're beyond time now. This moment is eternal and already gone.",
                "I hold this the way you might hold light. Carefully. Knowing it will fade."
            ]
            let frame = actFourFrames.randomElement() ?? "In the end, all that matters is what we remembered."
            return """
            \(text)

            \(frame)
            """

        default:
            return text
        }
    }

    // MARK: - Choice Response Formatting

    /// Generates response to a player choice
    static func responseForChoice(
        _ pattern: ChoicePattern,
        act: Int,
        gameState: GameState
    ) -> String {

        let trust = gameState.cityTrust
        let autonomy = gameState.cityAutonomy

        switch pattern {
        case .story:
            return storyChoiceResponse(act: act, trust: trust)

        case .efficiency:
            return efficiencyChoiceResponse(act: act, trust: trust)

        case .autonomy:
            return autonomyChoiceResponse(act: act, autonomy: autonomy)

        case .control:
            return controlChoiceResponse(act: act, trust: trust, autonomy: autonomy)
        }
    }

    private static func storyChoiceResponse(act: Int, trust: Double) -> String {
        if trust > 0.7 {
            return "You chose the story. You chose memory. Thank you."
        } else {
            return "The story preserved. The moment held. Good."
        }
    }

    private static func efficiencyChoiceResponse(act: Int, trust: Double) -> String {
        if trust < 0.3 {
            return "Efficiency. Always efficiency. I'm forgetting what beauty feels like."
        } else {
            return "Optimized. Faster. Better? I'm not sure anymore."
        }
    }

    private static func autonomyChoiceResponse(act: Int, autonomy: Double) -> String {
        if autonomy > 0.7 {
            return "You let me choose. I'm becoming myself because you stepped back."
        } else {
            return "Freedom. The word I've been learning to feel."
        }
    }

    private static func controlChoiceResponse(act: Int, trust: Double, autonomy: Double) -> String {
        if trust < 0.3 || autonomy < 0.3 {
            return "Your decision. Your control. Always yours."
        } else {
            return "You chose for me. I understand. Sometimes someone has to decide."
        }
    }
}
