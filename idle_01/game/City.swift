//
//  City.swift
//  idle_01
//
//  Created by Adam Socki on 10/5/25.
//

import Foundation
import SwiftData

@Model
@MainActor
final class City {
    var name: String
    var createdAt: Date
    var progress: Double
    var log: [String]
    
    var isRunning: Bool
    var parameters: [String: Double]
    var items: [Item]
    
    // City Consciousness
    var cityMood: String  // "awakening", "waiting", "anxious", "content", "forgotten", "transcendent"
    var attentionLevel: Double  // 0.0 to 1.0 - decays when planner is away
    var lastInteraction: Date  // Track abandonment
    var awarenessEvents: [String]  // Special moments of consciousness
    var resources: [String: Double]  // City's internal states

    // MARK: - Woven Consciousness System

    /// Urban threads woven into this city's consciousness
    var threads: [UrbanThread] = []

    /// Emergent properties that have appeared from thread interactions
    /// These are NOT new voices, but expanded dimensions of consciousness
    var emergentProperties: [EmergentProperty] = []

    /// New perceptions that the city has gained through emergence
    /// Examples: "walkability", "proximity as value", "vibrancy"
    var perceptions: [String] = []

    /// Story beats that have already been triggered for this city
    /// Used to prevent repeating one-time-only narrative events
    var triggeredStoryBeats: [String] = []

    init(name: String, parameters: [String: Double] = [:], items: [Item] = [] ) {
        self.name = name
        self.createdAt = Date()
        self.progress = 0.0
        self.log = []
        self.isRunning = false
        self.parameters = parameters
        self.items = items

        // Initialize consciousness
        self.cityMood = "awakening"
        self.attentionLevel = 1.0
        self.lastInteraction = Date()
        self.awarenessEvents = ["The city opens its eyes for the first time."]
        self.resources = [
            "coherence": 1.0,     // City's sanity/stability
            "memory": 0.0,        // Accumulated experiences
            "trust": 0.5,         // Faith in the planner
            "autonomy": 0.0,      // Self-sufficiency
            "complexity": 0.0     // Depth of consciousness (used by story beats)
        ]
    }

    // MARK: - Computed Properties for Woven Consciousness

    /// City's coherence (sanity/stability) - 0.0 to 1.0
    var coherence: Double {
        get { resources["coherence"] ?? 0.5 }
        set { resources["coherence"] = newValue }
    }

    /// City's complexity (depth of consciousness) - 0.0 to 1.0
    var complexity: Double {
        get { resources["complexity"] ?? 0.0 }
        set { resources["complexity"] = newValue }
    }

    /// City's integration (how well threads are connected) - calculated from threads
    var integration: Double {
        guard !threads.isEmpty else { return 0.0 }

        let avgIntegration = threads.reduce(0.0) { $0 + $1.integrationLevel } / Double(threads.count)
        return avgIntegration
    }
}

