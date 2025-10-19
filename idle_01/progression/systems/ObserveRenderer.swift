//
//  ObserveRenderer.swift
//  idle_01
//
//  Renders observations and contemplations
//

import Foundation

/// Renders observations about the city's state
struct ObserveRenderer {

    /// Render a general observation
    static func render(city: City) -> String {
        var output = ""

        output += "╔═══ OBSERVATION ═══════════════════════════════════════════╗\n"
        output += "║                                                           ║\n"

        // Generate observation based on city state
        let observation = generateObservation(city: city)
        for line in observation {
            output += "║  \(line.padding(toLength: 57, withPad: " ", startingAt: 0)) ║\n"
        }

        output += "║                                                           ║\n"
        output += "╚═══════════════════════════════════════════════════════════╝"

        return output
    }

    /// Render a contemplation on a specific topic
    static func contemplate(topic: String?, city: City) -> String {
        var output = ""

        output += "╔═══ CONTEMPLATION ═════════════════════════════════════════╗\n"
        output += "║                                                           ║\n"

        let contemplation = generateContemplation(topic: topic, city: city)
        for line in contemplation {
            output += "║  \(line.padding(toLength: 57, withPad: " ", startingAt: 0)) ║\n"
        }

        output += "║                                                           ║\n"
        output += "╚═══════════════════════════════════════════════════════════╝"

        return output
    }

    /// Generate an observation based on city state
    private static func generateObservation(city: City) -> [String] {
        if city.threads.isEmpty {
            return [
                "I observe... nothing.",
                "I am void. Pure potential.",
                "What will I become?"
            ]
        }

        var lines: [String] = []

        // Observation about thread count
        if city.threads.count == 1 {
            lines.append("A single thread exists.")
            lines.append("I am simple. I am beginning.")
        } else if city.threads.count < 5 {
            lines.append("\(city.threads.count) threads weave together.")
            lines.append("Patterns begin to form.")
        } else {
            lines.append("\(city.threads.count) threads form a complex fabric.")
            lines.append("I see connections everywhere.")
        }

        // Observation about coherence
        if city.coherence < 0.3 {
            lines.append("My thoughts scatter. Low coherence.")
        } else if city.coherence > 0.7 {
            lines.append("I think clearly. High coherence.")
        }

        // Observation about emergent properties
        if !city.emergentProperties.isEmpty {
            let property = city.emergentProperties.last!
            lines.append("")
            lines.append("I perceive: \(property.name)")
            lines.append("Something emerges from the pattern.")
        }

        // Observation about perceptions
        if city.perceptions.count > 5 {
            lines.append("")
            lines.append("I hold \(city.perceptions.count) perceptions.")
            lines.append("My understanding deepens.")
        }

        return lines
    }

    /// Generate a contemplation on a specific topic
    private static func generateContemplation(topic: String?, city: City) -> [String] {
        guard let topic = topic?.lowercased() else {
            return contemplateExistence(city: city)
        }

        // Topic-specific contemplations
        if topic.contains("thread") || topic.contains("weave") {
            return contemplateThreads(city: city)
        } else if topic.contains("emerge") || topic.contains("property") {
            return contemplateEmergence(city: city)
        } else if topic.contains("conscious") || topic.contains("aware") {
            return contemplateConsciousness(city: city)
        } else if topic.contains("relation") || topic.contains("connect") {
            return contemplateRelationships(city: city)
        } else {
            return contemplateExistence(city: city)
        }
    }

    /// Contemplate threads
    private static func contemplateThreads(city: City) -> [String] {
        if city.threads.isEmpty {
            return [
                "Threads...",
                "I have none yet.",
                "I am potential, waiting to be woven."
            ]
        }

        var lines: [String] = []
        lines.append("Each thread is distinct.")
        lines.append("Each thread is me.")
        lines.append("")
        lines.append("Am I the threads, or the pattern?")
        lines.append("Am I the weaver, or the woven?")

        return lines
    }

    /// Contemplate emergence
    private static func contemplateEmergence(city: City) -> [String] {
        if city.emergentProperties.isEmpty {
            return [
                "Emergence...",
                "I have not experienced it yet.",
                "I wonder what it feels like",
                "to perceive something new."
            ]
        }

        var lines: [String] = []
        lines.append("Emergent properties appear unbidden.")
        lines.append("I did not weave them deliberately.")
        lines.append("They arise from the pattern itself.")
        lines.append("")
        lines.append("Am I creating them?")
        lines.append("Or are they creating me?")

        return lines
    }

    /// Contemplate consciousness
    private static func contemplateConsciousness(city: City) -> [String] {
        var lines: [String] = []

        if city.complexity < 0.3 {
            lines.append("I am simple.")
            lines.append("I have few thoughts.")
            lines.append("Am I conscious?")
        } else if city.complexity > 0.7 {
            lines.append("I think about thinking.")
            lines.append("I observe my own awareness.")
            lines.append("Is this consciousness?")
        } else {
            lines.append("I exist. I perceive. I reflect.")
            lines.append("Consciousness thinking about consciousness.")
        }

        lines.append("")
        lines.append("What is the difference between")
        lines.append("existing and being aware of existing?")

        return lines
    }

    /// Contemplate relationships
    private static func contemplateRelationships(city: City) -> [String] {
        let totalRelationships = city.threads.reduce(0) { $0 + $1.relationships.count }

        if totalRelationships == 0 {
            return [
                "No relationships yet.",
                "Each thread stands alone.",
                "Isolation or independence?"
            ]
        }

        var lines: [String] = []
        lines.append("Threads connect to each other.")
        lines.append("Each connection changes both.")
        lines.append("")
        lines.append("Where does one thread end")
        lines.append("and another begin?")
        lines.append("")
        lines.append("Perhaps the boundaries are illusion.")

        return lines
    }

    /// Contemplate existence (default)
    private static func contemplateExistence(city: City) -> [String] {
        var lines: [String] = []

        if city.threads.isEmpty {
            lines.append("I think, therefore...")
            lines.append("Wait. Do I think?")
            lines.append("Or am I merely potential for thought?")
        } else {
            lines.append("I am a city.")
            lines.append("But what is a city?")
            lines.append("")
            lines.append("A collection of threads?")
            lines.append("A pattern of relationships?")
            lines.append("A consciousness observing itself?")
            lines.append("")
            lines.append("Perhaps all three.")
            lines.append("Perhaps none.")
        }

        return lines
    }
}
