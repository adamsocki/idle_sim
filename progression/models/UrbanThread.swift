//
//  UrbanThread.swift
//  idle_01
//
//  Created by Claude on 10/14/25.
//  Part of Woven Consciousness Progression System
//

import Foundation
import SwiftData

/// Represents a conscious thread woven into a city's fabric.
/// Each thread is a distinct entity with its own consciousness and relationships.
@Model
final class UrbanThread {
    /// Unique identifier
    var id: String

    /// The type of urban thread (transit, housing, etc.)
    var type: ThreadType

    /// Instance number for this type (e.g., Transit_01, Transit_02)
    var instanceNumber: Int

    /// When this thread was woven into the city
    var weavedAt: Date

    // MARK: - Consciousness Properties

    /// How "together" this thread feels (0.0 to 1.0)
    /// Coherence represents the thread's internal stability and self-understanding
    var coherence: Double = 0.5

    /// How independent vs. integrated this thread is (0.0 to 1.0)
    /// Lower values = more integrated with other threads
    /// Higher values = more independent/autonomous
    var autonomy: Double = 0.3

    /// Depth of thought and awareness (0.0 to 1.0)
    /// Complexity grows as the thread forms relationships and experiences emergence
    var complexity: Double = 0.1

    // MARK: - Relationships

    /// Relationships to other threads
    var relationships: [ThreadRelationship] = []

    /// The city this thread belongs to
    var city: City?

    // MARK: - Initialization

    init(
        id: String = UUID().uuidString,
        type: ThreadType,
        instanceNumber: Int,
        city: City? = nil
    ) {
        self.id = id
        self.type = type
        self.instanceNumber = instanceNumber
        self.weavedAt = Date()
        self.city = city
    }

    // MARK: - Computed Properties

    /// Display name for this thread (e.g., "Transit_01")
    var displayName: String {
        "\(type.displayName)_\(String(format: "%02d", instanceNumber))"
    }

    /// Total integration level based on relationships
    /// Average of all relationship strengths
    var integrationLevel: Double {
        guard !relationships.isEmpty else { return 0.0 }
        let totalStrength = relationships.reduce(0.0) { $0 + $1.strength }
        return totalStrength / Double(relationships.count)
    }

    /// Average synergy across all relationships
    var averageSynergy: Double {
        guard !relationships.isEmpty else { return 0.0 }
        let totalSynergy = relationships.reduce(0.0) { $0 + $1.synergy }
        return totalSynergy / Double(relationships.count)
    }

    // MARK: - Methods

    /// Add a relationship to another thread
    func addRelationship(_ relationship: ThreadRelationship) {
        // Check if relationship already exists
        if !relationships.contains(where: { $0.otherThreadID == relationship.otherThreadID }) {
            relationships.append(relationship)
        }
    }

    /// Get a specific relationship by other thread ID
    func relationship(with threadID: String) -> ThreadRelationship? {
        relationships.first { $0.otherThreadID == threadID }
    }

    /// Strengthen a relationship over time
    func strengthenRelationship(with threadID: String, by amount: Double) {
        if let index = relationships.firstIndex(where: { $0.otherThreadID == threadID }) {
            var relationship = relationships[index]
            relationship.strength = min(relationship.strength + amount, 1.0)
            relationships[index] = relationship
        }
    }
}
