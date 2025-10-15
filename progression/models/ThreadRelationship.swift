//
//  ThreadRelationship.swift
//  idle_01
//
//  Created by Claude on 10/14/25.
//  Part of Woven Consciousness Progression System
//

import Foundation

/// Represents a relationship between two urban threads.
/// Relationships form automatically when threads are woven together.
struct ThreadRelationship: Codable, Identifiable {
    /// Unique identifier for this relationship
    var id: String = UUID().uuidString

    /// ID of the other thread in this relationship
    var otherThreadID: String

    /// The nature of the relationship
    var relationType: RelationType

    /// Strength of the relationship (0.0 to 1.0)
    /// Higher values indicate stronger connections
    var strength: Double

    /// Synergy level (-1.0 to 1.0)
    /// Positive values indicate mutual benefit, negative indicates conflict
    var synergy: Double

    /// When this relationship was formed
    var formedAt: Date

    /// Whether this relationship is between threads of the same type
    var isSameType: Bool = false

    /// Resonance level for same-type threads (0.0 to 1.0)
    /// Only meaningful when isSameType is true
    var resonance: Double? = nil

    /// Initialize a new thread relationship
    init(
        otherThreadID: String,
        relationType: RelationType,
        strength: Double,
        synergy: Double,
        formedAt: Date = Date(),
        isSameType: Bool = false,
        resonance: Double? = nil
    ) {
        self.otherThreadID = otherThreadID
        self.relationType = relationType
        self.strength = min(max(strength, 0.0), 1.0) // Clamp to 0.0-1.0
        self.synergy = min(max(synergy, -1.0), 1.0) // Clamp to -1.0-1.0
        self.formedAt = formedAt
        self.isSameType = isSameType
        self.resonance = resonance
    }
}
