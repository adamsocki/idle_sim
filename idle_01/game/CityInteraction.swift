//
//  CityInteraction.swift
//  idle_01
//
//  Created by Adam Socki on 10/8/25.
//

import Foundation

extension City {
    /// Update the city's state when the player interacts with it
    func recordInteraction() {
        self.lastInteraction = Date()
        self.attentionLevel = min(1.0, self.attentionLevel + 0.1)
    }
    
    /// Process a response to a city request
    func respondToRequest(_ item: Item, response: String) {
        item.response = response
        recordInteraction()
        
        // Adjust resources based on response
        if !response.isEmpty {
            // Trust increases when you respond
            resources["trust"] = min(1.0, (resources["trust"] ?? 0.5) + 0.05)
            // Memory accumulates
            resources["memory"] = min(1.0, (resources["memory"] ?? 0.0) + 0.02)
            // Autonomy decreases slightly (city relies on you more)
            resources["autonomy"] = max(0.0, (resources["autonomy"] ?? 0.0) - 0.03)
            
            // Log the interaction
            log.append("The planner responds: '\(response)'")
            awarenessEvents.append("Response received at \(Date()): \(item.title ?? "unknown")")
        }
    }
    
    /// Get a summary of the city's current state
    var consciousnessSummary: String {
        let coherence = resources["coherence"] ?? 1.0
        let memory = resources["memory"] ?? 0.0
        let trust = resources["trust"] ?? 0.5
        let autonomy = resources["autonomy"] ?? 0.0
        
        return """
        Mood: \(cityMood)
        Attention: \(String(format: "%.1f%%", attentionLevel * 100))
        Coherence: \(String(format: "%.1f%%", coherence * 100))
        Memory: \(String(format: "%.1f%%", memory * 100))
        Trust: \(String(format: "%.1f%%", trust * 100))
        Autonomy: \(String(format: "%.1f%%", autonomy * 100))
        """
    }
}
