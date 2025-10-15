//
//  RelationshipCalculator.swift
//  idle_01
//
//  Created by Claude on 10/14/25.
//  Part of Woven Consciousness Progression System
//

import Foundation

/// Calculates relationships between urban threads.
/// Uses the RelationshipRules compatibility matrix to determine how threads relate.
struct RelationshipCalculator {

    /// Calculate a relationship between a new thread and an existing thread
    /// - Parameters:
    ///   - newThread: The newly woven thread
    ///   - existing: An existing thread in the city
    /// - Returns: A ThreadRelationship defining how these threads connect
    static func calculate(
        from newThread: UrbanThread,
        to existing: UrbanThread
    ) -> ThreadRelationship {

        // Same type = resonance relationship
        if newThread.type == existing.type {
            return createResonanceRelationship(to: existing)
        }

        // Different types = look up compatibility in rules
        return createCompatibilityRelationship(
            from: newThread.type,
            to: existing,
            existingType: existing.type
        )
    }

    /// Create a resonance relationship between two threads of the same type
    /// Resonance represents threads of the same type vibrating together
    private static func createResonanceRelationship(
        to existing: UrbanThread
    ) -> ThreadRelationship {
        return ThreadRelationship(
            otherThreadID: existing.id,
            relationType: .resonance,
            strength: 0.6,
            synergy: 0.5,
            formedAt: Date(),
            isSameType: true,
            resonance: 0.7
        )
    }

    /// Create a relationship based on compatibility rules
    private static func createCompatibilityRelationship(
        from newType: ThreadType,
        to existing: UrbanThread,
        existingType: ThreadType
    ) -> ThreadRelationship {

        // Look up the relationship template
        let template = RelationshipRules.relationship(
            between: newType,
            and: existingType
        )

        return ThreadRelationship(
            otherThreadID: existing.id,
            relationType: template.type,
            strength: template.strength,
            synergy: template.synergy,
            formedAt: Date(),
            isSameType: false,
            resonance: nil
        )
    }

    /// Calculate the overall integration level for a thread based on its relationships
    /// - Parameter thread: The thread to calculate integration for
    /// - Returns: Average strength across all relationships (0.0 to 1.0)
    static func calculateIntegrationLevel(for thread: UrbanThread) -> Double {
        guard !thread.relationships.isEmpty else { return 0.0 }

        let totalStrength = thread.relationships.reduce(0.0) { sum, relationship in
            sum + relationship.strength
        }

        return totalStrength / Double(thread.relationships.count)
    }

    /// Calculate the average synergy for a thread
    /// - Parameter thread: The thread to calculate synergy for
    /// - Returns: Average synergy across all relationships (-1.0 to 1.0)
    static func calculateAverageSynergy(for thread: UrbanThread) -> Double {
        guard !thread.relationships.isEmpty else { return 0.0 }

        let totalSynergy = thread.relationships.reduce(0.0) { sum, relationship in
            sum + relationship.synergy
        }

        return totalSynergy / Double(thread.relationships.count)
    }

    /// Check if a thread has strong integration (threshold: 0.7)
    static func hasStrongIntegration(_ thread: UrbanThread) -> Bool {
        calculateIntegrationLevel(for: thread) >= 0.7
    }

    /// Check if a thread has positive overall synergy
    static func hasPositiveSynergy(_ thread: UrbanThread) -> Bool {
        calculateAverageSynergy(for: thread) > 0.0
    }
}
