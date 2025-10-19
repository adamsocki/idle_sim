//
//  FabricRenderer.swift
//  idle_01
//
//  Renders thread fabric and relationships
//

import Foundation

/// Renders the woven fabric of threads and their relationships
struct FabricRenderer {

    /// Render the city's fabric showing all threads and relationships
    static func render(city: City) -> String {
        if city.threads.isEmpty {
            return """
            ╔═══ FABRIC ════════════════════════════════════════════════╗
            ║                                                           ║
            ║                    The fabric is empty.                   ║
            ║                  Nothing has been woven.                  ║
            ║                                                           ║
            ╚═══════════════════════════════════════════════════════════╝
            """
        }

        var output = ""
        output += "╔═══ WOVEN FABRIC ══════════════════════════════════════════╗\n"
        output += "║                                                           ║\n"

        // Group threads by type
        let groupedThreads = Dictionary(grouping: city.threads) { $0.type }

        for (type, threads) in groupedThreads.sorted(by: { $0.key.rawValue < $1.key.rawValue }) {
            let count = threads.count
            let avgCoherence = threads.reduce(0.0) { $0 + $1.coherence } / Double(count)
            let symbol = getSymbolForType(type)

            output += "║  \(symbol) \(type.rawValue.uppercased().padding(toLength: 12, withPad: " ", startingAt: 0)) × \(String(format: "%02d", count))  "
            output += "COH: \(String(format: "%.2f", avgCoherence).padding(toLength: 24, withPad: " ", startingAt: 0)) ║\n"
        }

        output += "║                                                           ║\n"
        output += "╠═══ RELATIONSHIPS ═════════════════════════════════════════╣\n"

        // Show strongest relationships
        let allRelationships = getAllRelationships(city: city)
        let topRelationships = Array(allRelationships
            .sorted(by: { $0.strength > $1.strength })
            .prefix(8))

        if topRelationships.isEmpty {
            output += "║            No relationships formed yet.                   ║\n"
        } else {
            for rel in topRelationships {
                let connector = getRelationshipConnector(rel.type, strength: rel.strength)
                let line = "║  \(rel.from.padding(toLength: 10, withPad: " ", startingAt: 0)) \(connector) \(rel.to.padding(toLength: 10, withPad: " ", startingAt: 0)) "
                let strength = String(format: "%.2f", rel.strength)
                output += "\(line)\(strength.padding(toLength: 18, withPad: " ", startingAt: 0)) ║\n"
            }
        }

        output += "║                                                           ║\n"
        output += "╠═══ EMERGENT PROPERTIES ═══════════════════════════════════╣\n"

        if city.emergentProperties.isEmpty {
            output += "║        No emergent properties yet.                        ║\n"
        } else {
            for property in city.emergentProperties {
                output += "║  * \(property.name.uppercased().padding(toLength: 54, withPad: " ", startingAt: 0)) ║\n"
            }
        }

        output += "║                                                           ║\n"
        output += "╚═══════════════════════════════════════════════════════════╝"

        return output
    }

    /// Get all relationships from the city
    private static func getAllRelationships(city: City) -> [(from: String, to: String, strength: Double, type: RelationType)] {
        var relationships: [(from: String, to: String, strength: Double, type: RelationType)] = []
        var seen = Set<String>()

        for thread in city.threads {
            for rel in thread.relationships {
                guard let otherThread = city.threads.first(where: { $0.id == rel.otherThreadID }) else {
                    continue
                }

                // Create unique key (sorted to avoid duplicates)
                let key = [thread.id, otherThread.id].sorted().joined(separator: "-")
                guard !seen.contains(key) else { continue }
                seen.insert(key)

                relationships.append((
                    from: thread.type.rawValue,
                    to: otherThread.type.rawValue,
                    strength: rel.strength,
                    type: rel.relationType
                ))
            }
        }

        return relationships
    }

    /// Get symbol for thread type
    private static func getSymbolForType(_ type: ThreadType) -> String {
        switch type {
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

    /// Get relationship connector symbol
    private static func getRelationshipConnector(_ type: RelationType, strength: Double) -> String {
        let baseConnector: String
        switch type {
        case .support: baseConnector = "───"
        case .harmony: baseConnector = "═══"
        case .tension: baseConnector = "╌╌╌"
        case .resonance: baseConnector = "∿∿∿"
        case .dependency: baseConnector = "──→"
        }

        // Modify based on strength
        return strength > 0.7 ? baseConnector : (strength > 0.4 ? baseConnector : "···")
    }
}
