//
//  PulseRenderer.swift
//  idle_01
//
//  Renders city pulse and activity
//

import Foundation

/// Renders the city's pulse - a snapshot of current activity and state
struct PulseRenderer {

    /// Render the city's current pulse
    static func render(city: City) -> String {
        var output = ""

        output += "╔═══ PULSE ═════════════════════════════════════════════════╗\n"

        // Vital signs
        output += "║                                                           ║\n"
        output += "║  VITAL SIGNS                                              ║\n"
        output += "║                                                           ║\n"
        output += renderVitalSigns(city: city)

        // Recent activity
        output += "║                                                           ║\n"
        output += "║  RECENT ACTIVITY                                          ║\n"
        output += "║                                                           ║\n"
        output += renderRecentActivity(city: city)

        // Current state
        output += "║                                                           ║\n"
        output += "║  CURRENT STATE                                            ║\n"
        output += "║                                                           ║\n"
        output += renderCurrentState(city: city)

        output += "║                                                           ║\n"
        output += "╚═══════════════════════════════════════════════════════════╝"

        return output
    }

    /// Render vital signs (quick overview)
    private static func renderVitalSigns(city: City) -> String {
        var output = ""

        let coherence = String(format: "%.3f", city.coherence)
        let integration = String(format: "%.3f", city.integration)
        let complexity = String(format: "%.3f", city.complexity)

        output += "║    Coherence....: [\(getPulseBar(city.coherence))] \(coherence.padding(toLength: 17, withPad: " ", startingAt: 0)) ║\n"
        output += "║    Integration..: [\(getPulseBar(city.integration))] \(integration.padding(toLength: 17, withPad: " ", startingAt: 0)) ║\n"
        output += "║    Complexity...: [\(getPulseBar(city.complexity))] \(complexity.padding(toLength: 17, withPad: " ", startingAt: 0)) ║\n"

        return output
    }

    /// Render recent activity
    private static func renderRecentActivity(city: City) -> String {
        var output = ""

        // Recent threads (last 3)
        let recentThreads = city.threads.sorted(by: { $0.weavedAt > $1.weavedAt }).prefix(3)
        if !recentThreads.isEmpty {
            output += "║    Last woven threads:                                    ║\n"
            for thread in recentThreads {
                let timeAgo = timeAgoString(from: thread.weavedAt)
                output += "║      • \(thread.type.rawValue) (\(timeAgo))".padding(toLength: 60, withPad: " ", startingAt: 0) + " ║\n"
            }
        } else {
            output += "║    No threads woven yet.                                  ║\n"
        }

        // Recent emergences
        let recentProperties = city.emergentProperties.sorted(by: { $0.emergedAt > $1.emergedAt }).prefix(2)
        if !recentProperties.isEmpty {
            output += "║    Recent emergences:                                     ║\n"
            for property in recentProperties {
                let timeAgo = timeAgoString(from: property.emergedAt)
                output += "║      * \(property.name) (\(timeAgo))".padding(toLength: 60, withPad: " ", startingAt: 0) + " ║\n"
            }
        }

        return output
    }

    /// Render current state
    private static func renderCurrentState(city: City) -> String {
        var output = ""

        let threadCount = String(format: "%03d", city.threads.count)
        let propertyCount = String(format: "%02d", city.emergentProperties.count)
        let perceptionCount = String(format: "%02d", city.perceptions.count)

        output += "║    Threads........: \(threadCount.padding(toLength: 38, withPad: " ", startingAt: 0)) ║\n"
        output += "║    Properties.....: \(propertyCount.padding(toLength: 38, withPad: " ", startingAt: 0)) ║\n"
        output += "║    Perceptions....: \(perceptionCount.padding(toLength: 38, withPad: " ", startingAt: 0)) ║\n"

        // Mood
        let mood = city.cityMood.uppercased()
        output += "║    Mood...........: \(mood.padding(toLength: 38, withPad: " ", startingAt: 0)) ║\n"

        // Status
        let status = city.isRunning ? "ACTIVE" : "DORMANT"
        output += "║    Status.........: \(status.padding(toLength: 38, withPad: " ", startingAt: 0)) ║\n"

        return output
    }

    /// Get a pulse-style bar (minimal, using blocks)
    private static func getPulseBar(_ value: Double) -> String {
        let blocks = Int(value * 10)
        let filled = String(repeating: "█", count: blocks)
        let empty = String(repeating: "░", count: 10 - blocks)
        return filled + empty
    }

    /// Format time ago string
    private static func timeAgoString(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))

        if seconds < 60 {
            return "\(seconds)s ago"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            return "\(minutes)m ago"
        } else if seconds < 86400 {
            let hours = seconds / 3600
            return "\(hours)h ago"
        } else {
            let days = seconds / 86400
            return "\(days)d ago"
        }
    }
}
