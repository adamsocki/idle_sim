//
//  ConsciousnessRenderer.swift
//  idle_01
//
//  Renders abstract ASCII visualizations of city consciousness
//

import Foundation

/// Visual node in the consciousness field
struct VisualNode {
    var x: Int
    var y: Int
    var intensity: Double
    var symbol: String
}

/// Renders abstract consciousness visualizations
struct ConsciousnessRenderer {

    /// Render the city's consciousness as an abstract pulsing field
    static func render(city: City, pulsePhase: Double = 0.5) -> String {
        let nodes = generateNodes(for: city)
        let connections = generateConnections(for: city, nodes: nodes)

        var output = ""

        // Header
        output += "╔═══ CONSCIOUSNESS FIELD ═══════════════════════════════════╗\n"

        // Render the abstract field
        output += renderNodeField(nodes: nodes, connections: connections, phase: pulsePhase)
        output += "\n"

        // City statistics
        output += "╠═══ METRICS ═══════════════════════════════════════════════╣\n"
        output += "║ Coherence...: \(renderBar(city.coherence)) \(String(format: "%.2f", city.coherence).padding(toLength: 6, withPad: " ", startingAt: 0)) ║\n"
        output += "║ Integration.: \(renderBar(city.integration)) \(String(format: "%.2f", city.integration).padding(toLength: 6, withPad: " ", startingAt: 0)) ║\n"
        output += "║ Complexity..: \(renderBar(city.complexity)) \(String(format: "%.2f", city.complexity).padding(toLength: 6, withPad: " ", startingAt: 0)) ║\n"
        output += "╠═══ STATE ═════════════════════════════════════════════════╣\n"
        output += "║ Threads.....: \(String(format: "%03d", city.threads.count).padding(toLength: 52, withPad: " ", startingAt: 0)) ║\n"
        output += "║ Properties..: \(String(format: "%03d", city.emergentProperties.count).padding(toLength: 52, withPad: " ", startingAt: 0)) ║\n"
        output += "║ Perceptions.: \(String(format: "%03d", city.perceptions.count).padding(toLength: 52, withPad: " ", startingAt: 0)) ║\n"
        output += "╚═══════════════════════════════════════════════════════════╝\n"

        // City voice
        output += "\n"
        output += getCityThought(city: city)

        return output
    }

    /// Generate visual nodes based on city state
    private static func generateNodes(for city: City) -> [VisualNode] {
        let nodeCount = min(city.threads.count + 2, 15)
        var nodes: [VisualNode] = []

        // Create nodes with some structure (not fully random)
        for i in 0..<nodeCount {
            let angle = Double(i) / Double(nodeCount) * .pi * 2
            let radius = 15.0 + Double.random(in: -3...3)

            let x = Int(25 + radius * cos(angle))
            let y = Int(4 + radius * sin(angle) / 2.5)

            let intensity = 0.3 + (city.coherence * 0.7)

            // Choose symbol based on thread types present
            var symbol = "○"
            if i < city.threads.count {
                let thread = city.threads[i]
                symbol = getSymbolForThread(thread)
            }

            nodes.append(VisualNode(
                x: max(1, min(x, 58)),
                y: max(0, min(y, 8)),
                intensity: intensity,
                symbol: symbol
            ))
        }

        return nodes
    }

    /// Get symbol for thread type
    private static func getSymbolForThread(_ thread: UrbanThread) -> String {
        switch thread.type {
        case .transit: return "∿"
        case .housing: return "◆"
        case .culture: return "◉"
        case .commerce: return "◈"
        case .parks: return "✿"
        case .water: return "≋"
        case .power: return "※"
        case .sewage: return "∼"
        case .knowledge: return "◎"
        }
    }

    /// Generate connections between nodes based on relationships
    private static func generateConnections(for city: City, nodes: [VisualNode]) -> [(Int, Int, Double)] {
        var connections: [(Int, Int, Double)] = []

        // Sample some strong relationships
        for (i, thread) in city.threads.enumerated() {
            guard i < nodes.count else { break }

            // Find strongest relationships
            let strongRels = thread.relationships
                .filter { $0.strength > 0.5 }
                .prefix(2)

            for rel in strongRels {
                if let otherIndex = city.threads.firstIndex(where: { $0.id == rel.otherThreadID }),
                   otherIndex < nodes.count {
                    connections.append((i, otherIndex, rel.strength))
                }
            }
        }

        return connections
    }

    /// Render the node field with connections
    private static func renderNodeField(
        nodes: [VisualNode],
        connections: [(Int, Int, Double)],
        phase: Double
    ) -> String {
        // Create field
        var field = Array(repeating: Array(repeating: " ", count: 60), count: 9)

        // Draw connections first (so nodes appear on top)
        for (fromIdx, toIdx, strength) in connections {
            guard fromIdx < nodes.count && toIdx < nodes.count else { continue }
            let from = nodes[fromIdx]
            let to = nodes[toIdx]

            drawLine(in: &field, from: (from.x, from.y), to: (to.x, to.y), strength: strength)
        }

        // Draw nodes
        for node in nodes {
            let pulsedIntensity = node.intensity * (0.7 + 0.3 * sin(phase * .pi * 2))
            let symbol = pulsedIntensity > 0.6 ? node.symbol : "○"

            if node.y < field.count && node.x < field[0].count {
                field[node.y][node.x] = symbol
            }
        }

        // Convert to string with borders
        var output = ""
        for row in field {
            output += "║ " + row.joined() + " ║\n"
        }

        return output
    }

    /// Draw a simple line between two points
    private static func drawLine(
        in field: inout [[String]],
        from: (x: Int, y: Int),
        to: (x: Int, y: Int),
        strength: Double
    ) {
        let symbol = strength > 0.7 ? "━" : strength > 0.5 ? "─" : "·"

        let dx = to.x - from.x
        let dy = to.y - from.y
        let steps = max(abs(dx), abs(dy))

        guard steps > 0 else { return }

        for step in 1..<steps {
            let t = Double(step) / Double(steps)
            let x = from.x + Int(Double(dx) * t)
            let y = from.y + Int(Double(dy) * t)

            if y >= 0 && y < field.count && x >= 0 && x < field[0].count {
                if field[y][x] == " " {
                    field[y][x] = symbol
                }
            }
        }
    }

    /// Render a progress bar
    private static func renderBar(_ value: Double) -> String {
        let filled = Int(value * 20)
        let empty = 20 - filled
        return String(repeating: "▓", count: filled) + String(repeating: "░", count: empty)
    }

    /// Get a thought from the city based on its state
    private static func getCityThought(city: City) -> String {
        if city.threads.isEmpty {
            return "CITY: I am void. I am potential. Waiting to become."
        }

        if city.threads.count == 1 {
            return "CITY: A single thread. I begin to exist."
        }

        if city.emergentProperties.isEmpty && city.threads.count > 2 {
            return "CITY: Threads interweave. I sense... patterns forming."
        }

        if !city.emergentProperties.isEmpty {
            let property = city.emergentProperties.last!
            return "CITY: I perceive \(property.name). I am becoming more than the sum of my threads."
        }

        if city.coherence > 0.7 {
            return "CITY: I pulse. I breathe. I am becoming."
        }

        return "CITY: I observe my own weaving."
    }
}
