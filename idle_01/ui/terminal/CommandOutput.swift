//
//  CommandOutput.swift
//  idle_01
//
//  Terminal command output model
//

import Foundation

struct CommandOutput: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isError: Bool
    let isDialogue: Bool  // Special formatting for dialogue from narrative engine
    let timestamp: Date

    init(text: String, isError: Bool = false, isDialogue: Bool = false) {
        self.text = text
        self.isError = isError
        self.isDialogue = isDialogue
        self.timestamp = Date()
    }
}
