//
//  TerminalCommandParser.swift
//  idle_01
//
//  Terminal command parser supporting both technical and poetic syntax
//

import Foundation

/// Command parser that supports both technical and poetic syntax
/// Technical: "create city --name=ALPHA", "start [00]"
/// Poetic: "awaken consciousness --name=ALPHA", "breathe life into [00]"
/// Aliases: "ls" -> "list", "rm" -> "delete", "cc" -> "create city"
struct TerminalCommandParser {

    // Command aliases for shortcuts
    private let aliases: [String: String] = [
        // List aliases
        "ls": "list",
        "ll": "list --filter=active",
        "la": "list",

        // Create aliases
        "cc": "create city",
        "ct": "create thought",
        "new": "create city",

        // Selection aliases
        "sel": "select",
        "cd": "select",

        // State aliases
        "run": "start",
        "pause": "stop",

        // Delete aliases
        "rm": "delete",
        "del": "delete",

        // Item aliases
        "i": "items",
        "t": "items",

        // Response aliases
        "r": "respond",
        "d": "dismiss",

        // Stats aliases
        "s": "stats",
        "st": "stats",

        // Clear aliases
        "cls": "clear",
        "clr": "clear",

        // Help aliases
        "?": "help",
        "h": "help"
    ]

    func parse(_ input: String) -> TerminalCommand {
        var trimmed = input.trimmingCharacters(in: .whitespaces)

        // Expand aliases first
        let components = trimmed.split(separator: " ").map { String($0) }
        if let firstWord = components.first, let expansion = aliases[firstWord.lowercased()] {
            // Replace the first word with its expansion
            trimmed = expansion + (components.count > 1 ? " " + components.dropFirst().joined(separator: " ") : "")
        }

        let expandedComponents = trimmed.split(separator: " ").map { String($0) }

        guard let verb = expandedComponents.first?.lowercased() else {
            return .unknown(input)
        }

        // MARK: - Help Commands
        if verb == "help" {
            let topic = expandedComponents.count > 1 ? expandedComponents[1] : nil
            return .help(topic: topic)
        }

        // MARK: - List Commands
        if verb == "list" {
            let filter = extractFlag(from: expandedComponents, flag: "--filter")
            return .list(filter: filter)
        }

        // MARK: - Create Commands (Technical & Poetic)
        if verb == "create" || verb == "awaken" || verb == "initialize" || verb == "birth" {
            guard expandedComponents.count > 1 else { return .unknown(input) }
            let type = expandedComponents[1].lowercased()

            if type == "city" || type == "consciousness" || type == "node" {
                let name = extractFlag(from: expandedComponents, flag: "--name") ?? generateDefaultName()
                return .createCity(name: name)
            }

            if type == "thought" || type == "memory" || type == "question" {
                let thoughtType = extractFlag(from: expandedComponents, flag: "--type")
                return .createThought(type: thoughtType)
            }

            return .unknown(input)
        }

        // MARK: - Select Commands (Technical & Poetic)
        if verb == "select" || verb == "focus" || verb == "attend" || verb == "observe" {
            guard expandedComponents.count > 1 else { return .unknown(input) }
            let target = expandedComponents[1]
            return .select(target: target)
        }

        // MARK: - Start Commands (Technical & Poetic)
        if verb == "start" || verb == "wake" || verb == "activate" || verb == "breathe" {
            let target = expandedComponents.count > 1 ? expandedComponents[1] : nil
            return .start(target: target)
        }

        // MARK: - Stop Commands (Technical & Poetic)
        if verb == "stop" || verb == "sleep" || verb == "pause" || verb == "rest" {
            let target = expandedComponents.count > 1 ? expandedComponents[1] : nil
            return .stop(target: target)
        }

        // MARK: - Delete Commands (Technical & Poetic)
        if verb == "delete" || verb == "forget" || verb == "release" || verb == "dissolve" {
            guard expandedComponents.count > 1 else { return .unknown(input) }
            let target = expandedComponents[1]
            return .delete(target: target)
        }

        // MARK: - Export Commands
        if verb == "export" || verb == "save" || verb == "archive" {
            let format = extractFlag(from: expandedComponents, flag: "--format") ?? "json"
            let target = expandedComponents.count > 1 && !expandedComponents[1].hasPrefix("--") ? expandedComponents[1] : nil
            return .export(target: target, format: format)
        }

        // MARK: - Stats Commands
        if verb == "stats" || verb == "status" || verb == "inspect" {
            let target = expandedComponents.count > 1 ? expandedComponents[1] : nil
            return .stats(target: target)
        }

        // MARK: - Set Commands
        if verb == "set" {
            guard expandedComponents.count > 2 else { return .unknown(input) }
            let key = expandedComponents[1]
            let value = expandedComponents[2]
            return .set(key: key, value: value)
        }

        // MARK: - Respond Commands (for items/thoughts)
        if verb == "respond" || verb == "answer" || verb == "reply" {
            guard expandedComponents.count > 2 else { return .unknown(input) }
            let target = expandedComponents[1]
            // Join remaining expandedComponents as the response text
            let responseText = expandedComponents.dropFirst(2).joined(separator: " ")
            return .respond(target: target, text: responseText)
        }

        // MARK: - Dismiss Commands (for items/thoughts)
        if verb == "dismiss" || verb == "close" || verb == "acknowledge" {
            guard expandedComponents.count > 1 else { return .unknown(input) }
            let target = expandedComponents[1]
            return .dismiss(target: target)
        }

        // MARK: - List Items Command
        if verb == "items" || verb == "thoughts" {
            let filter = extractFlag(from: expandedComponents, flag: "--filter")
            let target = expandedComponents.count > 1 && !expandedComponents[1].hasPrefix("--") ? expandedComponents[1] : nil
            return .listItems(target: target, filter: filter)
        }

        // MARK: - Clear Command
        if verb == "clear" || verb == "cls" {
            return .clear
        }

        return .unknown(input)
    }

    // MARK: - Helper Functions

    private func extractFlag(from components: [String], flag: String) -> String? {
        // Support both --flag=value and --flag value formats
        if let component = components.first(where: { $0.hasPrefix(flag + "=") }) {
            return String(component.dropFirst(flag.count + 1))
        }

        guard let index = components.firstIndex(where: { $0 == flag }),
              index + 1 < components.count else {
            return nil
        }
        return components[index + 1]
    }

    private func generateDefaultName() -> String {
        let names = ["ALPHA", "BETA", "GAMMA", "DELTA", "EPSILON", "ZETA", "ETA", "THETA"]
        return names.randomElement() ?? "UNNAMED"
    }
}

// MARK: - Terminal Command Enum

enum TerminalCommand: Equatable {
    case help(topic: String?)
    case list(filter: String?)
    case createCity(name: String)
    case createThought(type: String?)
    case select(target: String)
    case start(target: String?)
    case stop(target: String?)
    case delete(target: String)
    case export(target: String?, format: String)
    case stats(target: String?)
    case set(key: String, value: String)
    case respond(target: String, text: String)
    case dismiss(target: String)
    case listItems(target: String?, filter: String?)
    case clear
    case unknown(String)
}

// MARK: - Command Output Model

struct CommandOutput: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isError: Bool
    let timestamp: Date

    init(text: String, isError: Bool = false) {
        self.text = text
        self.isError = isError
        self.timestamp = Date()
    }

    static func == (lhs: CommandOutput, rhs: CommandOutput) -> Bool {
        lhs.id == rhs.id
    }
}
