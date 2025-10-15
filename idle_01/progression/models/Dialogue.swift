//
//  Dialogue.swift
//  idle_01
//
//  Created: 2025-10-14
//  Purpose: Data models for the dialogue system
//

import Foundation

// MARK: - Dialogue Line

/// A single line of dialogue spoken by a thread or city
struct DialogueLine: Codable, Identifiable {
    var id: String = UUID().uuidString
    var speaker: DialogueSpeaker
    var text: String
    var emotionalTone: EmotionalTone?
    var tags: [String] = []

    init(speaker: DialogueSpeaker, text: String, emotionalTone: EmotionalTone? = nil, tags: [String] = []) {
        self.speaker = speaker
        self.text = text
        self.emotionalTone = emotionalTone
        self.tags = tags
    }
}

// MARK: - Dialogue Speaker

/// All possible speakers in the dialogue system
enum DialogueSpeaker: String, Codable {
    case city
    case transit
    case housing
    case culture
    case commerce
    case parks
    case water
    case power
    case sewage
    case knowledge

    /// Create a speaker from a ThreadType
    init?(threadType: ThreadType) {
        self.init(rawValue: threadType.rawValue)
    }

    /// Convert speaker to ThreadType (if applicable)
    var asThreadType: ThreadType? {
        ThreadType(rawValue: self.rawValue)
    }
}

// MARK: - Emotional Tone

/// The emotional quality of a dialogue line
enum EmotionalTone: String, Codable {
    case curious
    case contemplative
    case uncertain
    case confident
    case anxious
    case peaceful
    case excited
    case melancholic
    case determined
    case thoughtful
    case surprised
    case content
}

// MARK: - Dialogue Fragment

/// A collection of dialogue variations for a specific context
struct DialogueFragment: Codable, Identifiable {
    var id: String
    var speaker: DialogueSpeaker
    var fragments: [String]
    var context: DialogueContext
    var tags: [String]

    init(id: String, speaker: DialogueSpeaker, fragments: [String], context: DialogueContext, tags: [String] = []) {
        self.id = id
        self.speaker = speaker
        self.fragments = fragments
        self.context = context
        self.tags = tags
    }
}

// MARK: - Dialogue Context

/// The context in which dialogue should be retrieved
enum DialogueContext: String, Codable {
    case onCreation         // When thread is first woven
    case onRelationship     // When forming a new relationship
    case onEmergence        // When emergent property appears
    case onTension          // When conflict arises
    case onHarmony          // When synergy strengthens
    case idle               // Random thoughts
    case reflection         // Deep contemplation
    case milestone          // Reaching significant moments
    case questioning        // Self-doubt or inquiry
    case realization        // Moments of understanding
}

// MARK: - Dialogue Library File

/// Root structure for a dialogue JSON file
struct DialogueLibraryFile: Codable {
    var speaker: DialogueSpeaker
    var alternateTerminology: [String]?
    var dialogueFragments: [DialogueFragment]

    init(speaker: DialogueSpeaker, alternateTerminology: [String]? = nil, dialogueFragments: [DialogueFragment]) {
        self.speaker = speaker
        self.alternateTerminology = alternateTerminology
        self.dialogueFragments = dialogueFragments
    }
}
