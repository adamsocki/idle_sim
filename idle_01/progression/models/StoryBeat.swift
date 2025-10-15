//
//  StoryBeat.swift
//  idle_01
//
//  Story beat system for triggering narrative moments based on game state
//

import Foundation

/// A story beat that triggers dialogue and effects based on conditions
struct StoryBeat: Codable, Identifiable {
    var id: String
    var name: String
    var trigger: BeatTrigger
    var dialogue: [DialogueLine]
    var effects: BeatEffects?
    var spawnedThought: ThoughtSpawner?
    var oneTimeOnly: Bool = true
    var hasOccurred: Bool = false
}

/// Triggers that determine when a story beat fires
enum BeatTrigger: Codable, Equatable {
    case threadCreated(count: Int)
    case threadCreatedType(type: ThreadType, count: Int)
    case relationshipFormed(type1: ThreadType, type2: ThreadType)
    case emergentProperty(name: String)
    case synergy(type1: ThreadType, type2: ThreadType, threshold: Double)
    case tension(type1: ThreadType, type2: ThreadType, threshold: Double)
    case cityCoherence(threshold: Double)
    case threadComplexity(type: ThreadType, threshold: Double)

    // Custom coding keys for JSON serialization
    enum CodingKeys: String, CodingKey {
        case triggerType = "type"
        case count
        case threadType
        case type1
        case type2
        case name
        case threshold
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let triggerType = try container.decode(String.self, forKey: .triggerType)

        switch triggerType {
        case "threadCreated":
            let count = try container.decode(Int.self, forKey: .count)
            self = .threadCreated(count: count)

        case "threadCreatedType":
            let threadType = try container.decode(ThreadType.self, forKey: .threadType)
            let count = try container.decode(Int.self, forKey: .count)
            self = .threadCreatedType(type: threadType, count: count)

        case "relationshipFormed":
            let type1 = try container.decode(ThreadType.self, forKey: .type1)
            let type2 = try container.decode(ThreadType.self, forKey: .type2)
            self = .relationshipFormed(type1: type1, type2: type2)

        case "emergentProperty":
            let name = try container.decode(String.self, forKey: .name)
            self = .emergentProperty(name: name)

        case "synergy":
            let type1 = try container.decode(ThreadType.self, forKey: .type1)
            let type2 = try container.decode(ThreadType.self, forKey: .type2)
            let threshold = try container.decode(Double.self, forKey: .threshold)
            self = .synergy(type1: type1, type2: type2, threshold: threshold)

        case "tension":
            let type1 = try container.decode(ThreadType.self, forKey: .type1)
            let type2 = try container.decode(ThreadType.self, forKey: .type2)
            let threshold = try container.decode(Double.self, forKey: .threshold)
            self = .tension(type1: type1, type2: type2, threshold: threshold)

        case "cityCoherence":
            let threshold = try container.decode(Double.self, forKey: .threshold)
            self = .cityCoherence(threshold: threshold)

        case "threadComplexity":
            let threadType = try container.decode(ThreadType.self, forKey: .threadType)
            let threshold = try container.decode(Double.self, forKey: .threshold)
            self = .threadComplexity(type: threadType, threshold: threshold)

        default:
            throw DecodingError.dataCorruptedError(
                forKey: .triggerType,
                in: container,
                debugDescription: "Unknown trigger type: \(triggerType)"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .threadCreated(let count):
            try container.encode("threadCreated", forKey: .triggerType)
            try container.encode(count, forKey: .count)

        case .threadCreatedType(let threadType, let count):
            try container.encode("threadCreatedType", forKey: .triggerType)
            try container.encode(threadType, forKey: .threadType)
            try container.encode(count, forKey: .count)

        case .relationshipFormed(let type1, let type2):
            try container.encode("relationshipFormed", forKey: .triggerType)
            try container.encode(type1, forKey: .type1)
            try container.encode(type2, forKey: .type2)

        case .emergentProperty(let name):
            try container.encode("emergentProperty", forKey: .triggerType)
            try container.encode(name, forKey: .name)

        case .synergy(let type1, let type2, let threshold):
            try container.encode("synergy", forKey: .triggerType)
            try container.encode(type1, forKey: .type1)
            try container.encode(type2, forKey: .type2)
            try container.encode(threshold, forKey: .threshold)

        case .tension(let type1, let type2, let threshold):
            try container.encode("tension", forKey: .triggerType)
            try container.encode(type1, forKey: .type1)
            try container.encode(type2, forKey: .type2)
            try container.encode(threshold, forKey: .threshold)

        case .cityCoherence(let threshold):
            try container.encode("cityCoherence", forKey: .triggerType)
            try container.encode(threshold, forKey: .threshold)

        case .threadComplexity(let threadType, let threshold):
            try container.encode("threadComplexity", forKey: .triggerType)
            try container.encode(threadType, forKey: .threadType)
            try container.encode(threshold, forKey: .threshold)
        }
    }
}

/// Effects that are applied when a story beat fires
struct BeatEffects: Codable {
    var cityCoherence: Double?
    var citySelfAwareness: Double?
    var cityComplexity: Double?
    var threadCoherence: [String: Double]?  // ThreadType.rawValue -> delta
    var threadComplexity: [String: Double]? // ThreadType.rawValue -> delta
}

/// A thought that can spawn from a story beat, potentially with choices
struct ThoughtSpawner: Codable {
    var thoughtTitle: String
    var thoughtBody: String
    var branches: [String: String]?  // Choice text -> next beat ID
}

/// Container for loading story beats from JSON
struct StoryBeatCollection: Codable {
    var beats: [StoryBeat]
}
