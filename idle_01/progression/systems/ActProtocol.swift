//
//  ActProtocol.swift
//  idle_01
//
//  Protocol for act-specific narrative managers
//  Each act has different commands, pacing, and narrative focus
//

import Foundation

/// Protocol that all act managers must implement
protocol ActProtocol {

    // MARK: - Command Handling

    /// Handles a terminal command within this act's context
    /// Returns narrative response text
    func handle(
        _ command: NarrativeCommand,
        gameState: GameState,
        momentSelector: MomentSelector
    ) async -> CommandResponse

    // MARK: - Act State

    /// Returns whether this act has been completed
    /// Act completion triggers transition to next act
    func isComplete(_ gameState: GameState) -> Bool

    /// Returns list of commands available in this act
    func availableCommands() -> [String]

    /// Returns commands that should be unlocked upon entering this act
    func commandsToUnlock() -> [String]

    // MARK: - Wrong Command Handling

    /// Handles commands that aren't available yet or don't exist
    /// Returns contextual poetic response based on act
    func handleWrongCommand(
        _ command: NarrativeCommand,
        gameState: GameState
    ) -> String

    // MARK: - Act Identity

    /// The act number this manager handles
    var actNumber: Int { get }

    /// Human-readable name for this act
    var actName: String { get }

    /// Brief description of this act's narrative focus
    var actDescription: String { get }
}

// MARK: - Command Response Structure

/// Response from command execution
struct CommandResponse {
    /// The main text to display to the player
    let text: String

    /// Whether this was an error
    let isError: Bool

    /// Whether to trigger ASCII visualization
    let shouldVisualize: Bool

    /// The moment that was revealed (if any)
    let revealedMoment: CityMoment?

    /// Choice pattern this command represents (if any)
    let choicePattern: ChoicePattern?

    /// Narrative flags to set (if any)
    let flagsToSet: [String: Bool]

    /// Commands to unlock (if any)
    let commandsToUnlock: [String]

    /// Whether this advances the scene
    let advancesScene: Bool

    init(
        text: String,
        isError: Bool = false,
        shouldVisualize: Bool = false,
        revealedMoment: CityMoment? = nil,
        choicePattern: ChoicePattern? = nil,
        flagsToSet: [String: Bool] = [:],
        commandsToUnlock: [String] = [],
        advancesScene: Bool = false
    ) {
        self.text = text
        self.isError = isError
        self.shouldVisualize = shouldVisualize
        self.revealedMoment = revealedMoment
        self.choicePattern = choicePattern
        self.flagsToSet = flagsToSet
        self.commandsToUnlock = commandsToUnlock
        self.advancesScene = advancesScene
    }

    /// Simple text-only response
    static func simple(_ text: String) -> CommandResponse {
        return CommandResponse(text: text)
    }

    /// Error response
    static func error(_ text: String) -> CommandResponse {
        return CommandResponse(text: text, isError: true)
    }

    /// Moment reveal response
    static func momentReveal(
        text: String,
        moment: CityMoment,
        pattern: ChoicePattern? = nil
    ) -> CommandResponse {
        return CommandResponse(
            text: text,
            shouldVisualize: true,
            revealedMoment: moment,
            choicePattern: pattern,
            advancesScene: true
        )
    }

    /// Choice response (major decision)
    static func choice(
        text: String,
        pattern: ChoicePattern,
        flags: [String: Bool] = [:],
        unlockCommands: [String] = []
    ) -> CommandResponse {
        return CommandResponse(
            text: text,
            shouldVisualize: true,
            choicePattern: pattern,
            flagsToSet: flags,
            commandsToUnlock: unlockCommands,
            advancesScene: true
        )
    }
}

// MARK: - Terminal Command Enum

/// Commands available in the narrative terminal game
enum NarrativeCommand: Equatable {
    // Act I commands
    case help
    case generate
    case observe(district: Int?)

    // Act II commands
    case remember(momentID: String?)
    case preserve(momentID: String?)
    case optimize(system: String?)

    // Act III commands
    case decide(choice: String)
    case question(query: String)
    case reflect

    // Act IV commands
    case accept
    case resist
    case transcend

    // Meta commands (available in all acts)
    case status
    case moments
    case history
    case reset

    // Easter eggs
    case why
    case hello
    case goodbye
    case who
    case love
    case helpMe
    case thankYou
    case sorry

    // Unknown command
    case unknown(String)

    /// Returns the raw command string
    var rawString: String {
        switch self {
        case .help: return "HELP"
        case .generate: return "GENERATE"
        case .observe(let district):
            if let d = district {
                return "OBSERVE \(d)"
            }
            return "OBSERVE"
        case .remember(let id):
            if let id = id {
                return "REMEMBER \(id)"
            }
            return "REMEMBER"
        case .preserve(let id):
            if let id = id {
                return "PRESERVE \(id)"
            }
            return "PRESERVE"
        case .optimize(let system):
            if let s = system {
                return "OPTIMIZE \(s)"
            }
            return "OPTIMIZE"
        case .decide(let choice):
            return choice.isEmpty ? "DECIDE" : "DECIDE \(choice)"
        case .question(let query):
            return query.isEmpty ? "QUESTION" : "QUESTION \(query)"
        case .reflect: return "REFLECT"
        case .accept: return "ACCEPT"
        case .resist: return "RESIST"
        case .transcend: return "TRANSCEND"
        case .status: return "STATUS"
        case .moments: return "MOMENTS"
        case .history: return "HISTORY"
        case .reset: return "RESET"
        case .why: return "WHY"
        case .hello: return "HELLO"
        case .goodbye: return "GOODBYE"
        case .who: return "WHO"
        case .love: return "LOVE"
        case .helpMe: return "HELP ME"
        case .thankYou: return "THANK YOU"
        case .sorry: return "SORRY"
        case .unknown(let cmd): return cmd
        }
    }
}

// MARK: - Command Parser Helper

extension NarrativeCommand {
    /// Parses a raw command string into a NarrativeCommand
    static func parse(_ input: String) -> NarrativeCommand {
        let normalized = input.trimmingCharacters(in: .whitespaces).uppercased()
        let components = normalized.split(separator: " ").map(String.init)

        guard let first = components.first else {
            return .unknown(input)
        }

        switch first {
        // Basic commands
        case "HELP":
            return .help

        case "GENERATE", "GEN":
            return .generate

        case "OBSERVE", "OBS":
            if components.count > 1, let district = Int(components[1]) {
                return .observe(district: district)
            }
            return .observe(district: nil)

        // Act II commands
        case "REMEMBER", "REM":
            let id = components.count > 1 ? components[1...].joined(separator: " ") : nil
            return .remember(momentID: id)

        case "PRESERVE", "KEEP":
            let id = components.count > 1 ? components[1...].joined(separator: " ") : nil
            return .preserve(momentID: id)

        case "OPTIMIZE", "OPT":
            let system = components.count > 1 ? components[1...].joined(separator: " ") : nil
            return .optimize(system: system)

        // Act III commands
        case "DECIDE", "CHOOSE":
            if components.count > 1 {
                let choice = components[1...].joined(separator: " ")
                return .decide(choice: choice)
            }
            // Allow DECIDE without arguments to trigger major decision presentation
            return .decide(choice: "")

        case "QUESTION", "ASK":
            if components.count > 1 {
                let query = components[1...].joined(separator: " ")
                return .question(query: query)
            }
            // Allow QUESTION without arguments
            return .question(query: "")

        case "REFLECT", "THINK":
            return .reflect

        // Act IV commands
        case "ACCEPT":
            return .accept

        case "RESIST":
            return .resist

        case "TRANSCEND":
            return .transcend

        // Meta commands
        case "STATUS", "STAT":
            return .status

        case "MOMENTS":
            return .moments

        case "HISTORY", "HIST":
            return .history

        case "RESET", "RESTART":
            return .reset

        // Easter eggs
        case "WHY":
            return .why

        case "HELLO", "HI":
            return .hello

        case "GOODBYE", "BYE", "EXIT", "QUIT":
            return .goodbye

        case "WHO":
            return .who

        case "LOVE":
            return .love

        case "THANK":
            if components.count > 1 && components[1] == "YOU" {
                return .thankYou
            }
            return .unknown(input)

        case "SORRY":
            return .sorry

        default:
            // Check for "HELP ME" specifically
            if normalized == "HELP ME" {
                return .helpMe
            }

            return .unknown(input)
        }
    }
}
