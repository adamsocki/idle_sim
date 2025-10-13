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
struct TerminalCommandParser {

    func parse(_ input: String) -> TerminalCommand {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        let components = trimmed.split(separator: " ").map { String($0) }

        guard let verb = components.first?.lowercased() else {
            return .unknown(input)
        }

        // MARK: - Help Commands
        if verb == "help" {
            let topic = components.count > 1 ? components[1] : nil
            return .help(topic: topic)
        }

        // MARK: - List Commands
        if verb == "list" {
            let filter = extractFlag(from: components, flag: "--filter")
            return .list(filter: filter)
        }

        // MARK: - Create Commands (Technical & Poetic)
        if verb == "create" || verb == "awaken" || verb == "initialize" || verb == "birth" {
            guard components.count > 1 else { return .unknown(input) }
            let type = components[1].lowercased()

            if type == "city" || type == "consciousness" || type == "node" {
                let name = extractFlag(from: components, flag: "--name") ?? generateDefaultName()
                return .createCity(name: name)
            }

            if type == "thought" || type == "memory" || type == "question" {
                let thoughtType = extractFlag(from: components, flag: "--type")
                return .createThought(type: thoughtType)
            }

            return .unknown(input)
        }

        // MARK: - Select Commands (Technical & Poetic)
        if verb == "select" || verb == "focus" || verb == "attend" || verb == "observe" {
            guard components.count > 1 else { return .unknown(input) }
            let target = components[1]
            return .select(target: target)
        }

        // MARK: - Start Commands (Technical & Poetic)
        if verb == "start" || verb == "wake" || verb == "activate" || verb == "breathe" {
            let target = components.count > 1 ? components[1] : nil
            return .start(target: target)
        }

        // MARK: - Stop Commands (Technical & Poetic)
        if verb == "stop" || verb == "sleep" || verb == "pause" || verb == "rest" {
            let target = components.count > 1 ? components[1] : nil
            return .stop(target: target)
        }

        // MARK: - Delete Commands (Technical & Poetic)
        if verb == "delete" || verb == "forget" || verb == "release" || verb == "dissolve" {
            guard components.count > 1 else { return .unknown(input) }
            let target = components[1]
            return .delete(target: target)
        }

        // MARK: - Export Commands
        if verb == "export" || verb == "save" || verb == "archive" {
            let format = extractFlag(from: components, flag: "--format") ?? "json"
            let target = components.count > 1 && !components[1].hasPrefix("--") ? components[1] : nil
            return .export(target: target, format: format)
        }

        // MARK: - Stats Commands
        if verb == "stats" || verb == "status" || verb == "inspect" {
            let target = components.count > 1 ? components[1] : nil
            return .stats(target: target)
        }

        // MARK: - Set Commands
        if verb == "set" {
            guard components.count > 2 else { return .unknown(input) }
            let key = components[1]
            let value = components[2]
            return .set(key: key, value: value)
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
