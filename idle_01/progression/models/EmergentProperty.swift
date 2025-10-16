//
//  EmergentProperty.swift
//  idle_01
//
//  Created by Claude on 10/15/25.
//  Phase 4: Emergent Properties System
//

import Foundation
import SwiftData

/// An emergent property represents a new dimension of consciousness that arises
/// from the interaction of multiple threads. It does NOT create a new voice,
/// but rather expands the awareness of existing threads and the city.
///
/// Design Principle: Emergence deepens understanding, it doesn't create new entities.
@Model
final class EmergentProperty {
    var id: String
    var name: String
    var emergedAt: Date
    var sourceThreadIDs: [String]

    // NOT a voice - this property NEVER speaks
    var hasVoice: Bool { false }

    // How this emergence changes consciousness
    var consciousnessExpansionData: Data

    // Relationship to parent city
    var city: City?

    init(
        id: String = UUID().uuidString,
        name: String,
        sourceThreadIDs: [String],
        consciousnessExpansion: ConsciousnessExpansion,
        city: City? = nil
    ) {
        self.id = id
        self.name = name
        self.emergedAt = Date()
        self.sourceThreadIDs = sourceThreadIDs
        self.city = city

        // Encode consciousness expansion to Data for SwiftData persistence
        if let encoded = try? JSONEncoder().encode(consciousnessExpansion) {
            self.consciousnessExpansionData = encoded
        } else {
            self.consciousnessExpansionData = Data()
        }
    }

    /// Decode the consciousness expansion from stored data
    var consciousnessExpansion: ConsciousnessExpansion? {
        try? JSONDecoder().decode(ConsciousnessExpansion.self, from: consciousnessExpansionData)
    }
}

/// Describes how an emergent property expands consciousness
/// This is NOT about creating a new voice, but about deepening existing awareness
struct ConsciousnessExpansion: Codable {
    /// IDs of threads whose consciousness is affected
    var affectedThreadIDs: [String]

    /// New perceptions that the city gains (e.g., "walkability", "proximity as value")
    var newPerceptions: [String]

    /// How relationships between threads deepen
    var deepenedRelationships: [RelationshipDeepening]

    /// How the city's self-awareness expands (narrative description)
    var expandedSelfAwareness: String

    /// How much complexity this adds to consciousness (0.0-1.0 delta)
    var complexityIncrease: Double

    init(
        affectedThreadIDs: [String] = [],
        newPerceptions: [String] = [],
        deepenedRelationships: [RelationshipDeepening] = [],
        expandedSelfAwareness: String = "",
        complexityIncrease: Double = 0.0
    ) {
        self.affectedThreadIDs = affectedThreadIDs
        self.newPerceptions = newPerceptions
        self.deepenedRelationships = deepenedRelationships
        self.expandedSelfAwareness = expandedSelfAwareness
        self.complexityIncrease = complexityIncrease
    }
}

/// Describes how a relationship between two threads deepens through emergence
struct RelationshipDeepening: Codable {
    var threadID1: String
    var threadID2: String

    /// The quality of deepening (e.g., "spatial intimacy", "functional synergy")
    var quality: String

    /// Bonus to relationship strength (0.0-1.0 delta)
    var strengthBonus: Double

    init(
        threadID1: String,
        threadID2: String,
        quality: String,
        strengthBonus: Double
    ) {
        self.threadID1 = threadID1
        self.threadID2 = threadID2
        self.quality = quality
        self.strengthBonus = strengthBonus
    }
}

// MARK: - Emergence Rule Structures (for JSON loading)

/// Defines the conditions under which an emergent property appears
struct EmergenceRule: Codable {
    var name: String
    var conditions: EmergenceConditions
    var consciousnessExpansion: ConsciousnessExpansionTemplate
    var storyBeatID: String?

    init(
        name: String,
        conditions: EmergenceConditions,
        consciousnessExpansion: ConsciousnessExpansionTemplate,
        storyBeatID: String? = nil
    ) {
        self.name = name
        self.conditions = conditions
        self.consciousnessExpansion = consciousnessExpansion
        self.storyBeatID = storyBeatID
    }
}

/// Conditions that must be met for an emergent property to appear
struct EmergenceConditions: Codable {
    /// Thread types that must exist
    var requiredThreadTypes: [ThreadType]

    /// Minimum relationship strength between required threads (optional)
    var minimumRelationshipStrength: Double?

    /// Minimum average integration across required threads (optional)
    var minimumAverageIntegration: Double?

    /// Minimum number of total threads (optional)
    var minimumThreadCount: Int?

    /// Minimum city complexity (optional)
    var minimumCityComplexity: Double?

    init(
        requiredThreadTypes: [ThreadType] = [],
        minimumRelationshipStrength: Double? = nil,
        minimumAverageIntegration: Double? = nil,
        minimumThreadCount: Int? = nil,
        minimumCityComplexity: Double? = nil
    ) {
        self.requiredThreadTypes = requiredThreadTypes
        self.minimumRelationshipStrength = minimumRelationshipStrength
        self.minimumAverageIntegration = minimumAverageIntegration
        self.minimumThreadCount = minimumThreadCount
        self.minimumCityComplexity = minimumCityComplexity
    }
}

/// Template for consciousness expansion (used in JSON, doesn't have thread IDs yet)
struct ConsciousnessExpansionTemplate: Codable {
    var newPerceptions: [String]
    var expandedSelfAwareness: String
    var complexityIncrease: Double
    var affectedThreadTypes: [ThreadType]?
    var deepenedRelationships: [RelationshipDeepeningTemplate]?

    init(
        newPerceptions: [String] = [],
        expandedSelfAwareness: String = "",
        complexityIncrease: Double = 0.0,
        affectedThreadTypes: [ThreadType]? = nil,
        deepenedRelationships: [RelationshipDeepeningTemplate]? = nil
    ) {
        self.newPerceptions = newPerceptions
        self.expandedSelfAwareness = expandedSelfAwareness
        self.complexityIncrease = complexityIncrease
        self.affectedThreadTypes = affectedThreadTypes
        self.deepenedRelationships = deepenedRelationships
    }
}

/// Template for relationship deepening (thread types, not IDs)
struct RelationshipDeepeningTemplate: Codable {
    var type1: ThreadType
    var type2: ThreadType
    var quality: String
    var strengthBonus: Double

    init(
        type1: ThreadType,
        type2: ThreadType,
        quality: String,
        strengthBonus: Double
    ) {
        self.type1 = type1
        self.type2 = type2
        self.quality = quality
        self.strengthBonus = strengthBonus
    }
}

/// Collection of emergence rules loaded from JSON
struct EmergenceRuleCollection: Codable {
    var emergentProperties: [EmergenceRule]

    init(emergentProperties: [EmergenceRule] = []) {
        self.emergentProperties = emergentProperties
    }
}
