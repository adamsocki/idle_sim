//
//  RelationshipRules.swift
//  idle_01
//
//  Created by Claude on 10/14/25.
//  Part of Woven Consciousness Progression System
//

import Foundation

/// Template for creating relationships between threads
struct RelationshipTemplate {
    var type: RelationType
    var strength: Double
    var synergy: Double
    var description: String
}

/// Helper struct for creating thread pairs as dictionary keys
/// Order-independent: ThreadPair(.transit, .housing) == ThreadPair(.housing, .transit)
struct ThreadPair: Hashable, Equatable {
    let type1: ThreadType
    let type2: ThreadType

    init(_ t1: ThreadType, _ t2: ThreadType) {
        // Order doesn't matter for lookup - normalize to alphabetical order
        if t1.rawValue < t2.rawValue {
            type1 = t1
            type2 = t2
        } else {
            type1 = t2
            type2 = t1
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(type1)
        hasher.combine(type2)
    }

    static func == (lhs: ThreadPair, rhs: ThreadPair) -> Bool {
        lhs.type1 == rhs.type1 && lhs.type2 == rhs.type2
    }
}

/// Defines the compatibility rules between different thread types.
/// This is the primary place to expand relationship definitions.
struct RelationshipRules {

    /// The compatibility matrix defining relationships between thread types
    /// NARRATIVE EXPANDABILITY: Add new thread type relationships here
    static let compatibilityMatrix: [ThreadPair: RelationshipTemplate] = [
        // TRANSIT relationships
        ThreadPair(.transit, .housing): RelationshipTemplate(
            type: .support,
            strength: 0.75,
            synergy: 0.6,
            description: "Transit enables housing accessibility and mobility"
        ),
        ThreadPair(.transit, .commerce): RelationshipTemplate(
            type: .support,
            strength: 0.7,
            synergy: 0.5,
            description: "Transit brings customers to commerce"
        ),
        ThreadPair(.transit, .culture): RelationshipTemplate(
            type: .harmony,
            strength: 0.65,
            synergy: 0.4,
            description: "Transit connects people to cultural venues"
        ),
        ThreadPair(.transit, .parks): RelationshipTemplate(
            type: .harmony,
            strength: 0.6,
            synergy: 0.5,
            description: "Transit provides access to green spaces"
        ),

        // HOUSING relationships
        ThreadPair(.housing, .parks): RelationshipTemplate(
            type: .support,
            strength: 0.7,
            synergy: 0.8,
            description: "Parks provide quality of life for residents"
        ),
        ThreadPair(.housing, .commerce): RelationshipTemplate(
            type: .support,
            strength: 0.65,
            synergy: 0.4,
            description: "Housing needs nearby services and shops"
        ),
        ThreadPair(.housing, .culture): RelationshipTemplate(
            type: .harmony,
            strength: 0.6,
            synergy: 0.6,
            description: "Cultural amenities enrich residential life"
        ),
        ThreadPair(.housing, .water): RelationshipTemplate(
            type: .dependency,
            strength: 0.9,
            synergy: 0.5,
            description: "Housing fundamentally requires water"
        ),
        ThreadPair(.housing, .power): RelationshipTemplate(
            type: .dependency,
            strength: 0.85,
            synergy: 0.5,
            description: "Housing requires power to function"
        ),
        ThreadPair(.housing, .sewage): RelationshipTemplate(
            type: .dependency,
            strength: 0.85,
            synergy: 0.4,
            description: "Housing requires waste management"
        ),

        // CULTURE relationships
        ThreadPair(.culture, .commerce): RelationshipTemplate(
            type: .harmony,
            strength: 0.5,
            synergy: 0.3,
            description: "Culture and commerce can coexist but tension exists"
        ),
        ThreadPair(.culture, .parks): RelationshipTemplate(
            type: .harmony,
            strength: 0.75,
            synergy: 0.7,
            description: "Culture and nature complement each other"
        ),
        ThreadPair(.culture, .knowledge): RelationshipTemplate(
            type: .harmony,
            strength: 0.8,
            synergy: 0.8,
            description: "Culture and knowledge deeply reinforce each other"
        ),

        // COMMERCE relationships
        ThreadPair(.commerce, .power): RelationshipTemplate(
            type: .dependency,
            strength: 0.75,
            synergy: 0.5,
            description: "Commerce requires power to operate"
        ),
        ThreadPair(.commerce, .parks): RelationshipTemplate(
            type: .tension,
            strength: 0.3,
            synergy: -0.2,
            description: "Commerce often conflicts with park preservation"
        ),

        // INFRASTRUCTURE relationships
        ThreadPair(.power, .water): RelationshipTemplate(
            type: .dependency,
            strength: 0.85,
            synergy: 0.7,
            description: "Water systems need power to function"
        ),
        ThreadPair(.power, .sewage): RelationshipTemplate(
            type: .dependency,
            strength: 0.8,
            synergy: 0.6,
            description: "Sewage treatment requires power"
        ),
        ThreadPair(.water, .sewage): RelationshipTemplate(
            type: .support,
            strength: 0.75,
            synergy: 0.5,
            description: "Water supply and waste management are interconnected"
        ),
        ThreadPair(.water, .parks): RelationshipTemplate(
            type: .support,
            strength: 0.7,
            synergy: 0.6,
            description: "Parks need water for maintenance and life"
        ),

        // KNOWLEDGE relationships
        ThreadPair(.knowledge, .housing): RelationshipTemplate(
            type: .support,
            strength: 0.6,
            synergy: 0.5,
            description: "Education enriches communities"
        ),
        ThreadPair(.knowledge, .commerce): RelationshipTemplate(
            type: .harmony,
            strength: 0.65,
            synergy: 0.6,
            description: "Knowledge and commerce can create innovation"
        ),
    ]

    /// Get a relationship template for two thread types
    /// Returns a default moderate relationship if no specific rule exists
    static func relationship(
        between type1: ThreadType,
        and type2: ThreadType
    ) -> RelationshipTemplate {
        let pair = ThreadPair(type1, type2)

        if let template = compatibilityMatrix[pair] {
            return template
        }

        // Default: moderate support relationship
        return RelationshipTemplate(
            type: .support,
            strength: 0.4,
            synergy: 0.2,
            description: "A moderate connection exists between these threads"
        )
    }
}
