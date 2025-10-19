//
//  EmergenceDetector.swift
//  idle_01
//
//  Created by Claude on 10/15/25.
//  Phase 4: Emergent Properties System
//

import Foundation
import SwiftData

/// Actor responsible for detecting when emergent properties should appear
/// and applying consciousness expansion to city and threads.
///
/// Design Principle: Emergence deepens consciousness without creating new voices.
actor EmergenceDetector {

    /// All emergence rules loaded from JSON
    private var emergenceRules: [EmergenceRule] = []

    init() {
        // Load rules synchronously on init
        loadEmergenceRules()
    }

    // MARK: - Emergence Rule Loading

    /// Load all emergence rules from JSON files
    private func loadEmergenceRules() {
        let ruleFiles = [
            "core_emergence"
        ]

        for filename in ruleFiles {
            // Try multiple possible subdirectory paths
            let possiblePaths = [
                "emergence_rules",
                "data/emergence_rules",
                "progression/data/emergence_rules",
                nil
            ]
            
            var url: URL?
            for subdirectory in possiblePaths {
                if let foundURL = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: subdirectory) {
                    url = foundURL
                    break
                }
            }
            
            guard let url = url else {
                print("WARNING: EmergenceDetector: Could not find \(filename).json in any location")
                continue
            }

            do {
                let data = try Data(contentsOf: url)
                let collection = try JSONDecoder().decode(EmergenceRuleCollection.self, from: data)
                emergenceRules.append(contentsOf: collection.emergentProperties)
                print("Loaded \(collection.emergentProperties.count) emergence rules from \(filename).json")
            } catch {
                print("ERROR: EmergenceDetector: Failed to load \(filename).json: \(error)")
            }
        }
    }

    // MARK: - Emergence Detection

    /// Check for new emergent properties in the city
    /// Returns array of newly emerged properties
    @MainActor
    func checkForEmergence(in city: City) async -> [EmergentProperty] {
        var newProperties: [EmergentProperty] = []

        let rules = await getRulesAndEnsureLoaded()
        for rule in rules {
            // Skip if already emerged
            if city.emergentProperties.contains(where: { $0.name == rule.name }) {
                continue
            }

            // Check if conditions are met
            if evaluateConditions(rule.conditions, city: city) {
                let property = createEmergentProperty(from: rule, city: city)
                newProperties.append(property)
                print("EMERGENCE: \(rule.name) has emerged!")
            }
        }

        return newProperties
    }

    /// Get rules from actor, loading them if needed
    private func getRulesAndEnsureLoaded() async -> [EmergenceRule] {
        if emergenceRules.isEmpty {
            loadEmergenceRules()
        }
        return emergenceRules
    }

    /// Evaluate whether emergence conditions are met
    @MainActor
    private func evaluateConditions(
        _ conditions: EmergenceConditions,
        city: City
    ) -> Bool {

        // 1. Check that all required thread types exist
        for requiredType in conditions.requiredThreadTypes {
            if !city.threads.contains(where: { $0.type == requiredType }) {
                return false
            }
        }

        // 2. Check minimum thread count (if specified)
        if let minCount = conditions.minimumThreadCount {
            if city.threads.count < minCount {
                return false
            }
        }

        // 3. Check minimum city complexity (if specified)
        if let minComplexity = conditions.minimumCityComplexity {
            let complexity = city.resources["complexity"] ?? 0.0
            if complexity < minComplexity {
                return false
            }
        }

        // 4. Check minimum relationship strength (if specified)
        if let minStrength = conditions.minimumRelationshipStrength {
            let avgStrength = calculateAverageRelationshipStrength(
                between: conditions.requiredThreadTypes,
                in: city
            )
            if avgStrength < minStrength {
                return false
            }
        }

        // 5. Check minimum average integration (if specified)
        if let minIntegration = conditions.minimumAverageIntegration {
            let avgIntegration = calculateAverageIntegration(
                for: conditions.requiredThreadTypes,
                in: city
            )
            if avgIntegration < minIntegration {
                return false
            }
        }

        // All conditions met!
        return true
    }

    /// Calculate average relationship strength between required thread types
    @MainActor
    private func calculateAverageRelationshipStrength(
        between types: [ThreadType],
        in city: City
    ) -> Double {
        var totalStrength: Double = 0.0
        var count = 0

        // Find all threads of the required types
        let relevantThreads = city.threads.filter { types.contains($0.type) }

        // Calculate average strength of relationships between them
        for thread in relevantThreads {
            for relationship in thread.relationships {
                guard let otherThread = city.threads.first(where: { $0.id == relationship.otherThreadID }) else {
                    continue
                }
                if types.contains(otherThread.type) {
                    totalStrength += relationship.strength
                    count += 1
                }
            }
        }

        return count > 0 ? totalStrength / Double(count) : 0.0
    }

    /// Calculate average integration (coherence + complexity / 2) for thread types
    @MainActor
    private func calculateAverageIntegration(
        for types: [ThreadType],
        in city: City
    ) -> Double {
        let relevantThreads = city.threads.filter { types.contains($0.type) }

        guard !relevantThreads.isEmpty else { return 0.0 }

        let totalIntegration = relevantThreads.reduce(0.0) { sum, thread in
            sum + (thread.coherence + thread.complexity) / 2.0
        }

        return totalIntegration / Double(relevantThreads.count)
    }

    /// Create an emergent property from a rule and city context
    @MainActor
    private func createEmergentProperty(
        from rule: EmergenceRule,
        city: City
    ) -> EmergentProperty {

        // Find source threads (those of the required types)
        let sourceThreads = city.threads.filter {
            rule.conditions.requiredThreadTypes.contains($0.type)
        }
        let sourceThreadIDs = sourceThreads.map { $0.id }

        // Find affected threads (from template)
        let affectedThreadIDs: [String]
        if let affectedTypes = rule.consciousnessExpansion.affectedThreadTypes {
            affectedThreadIDs = city.threads
                .filter { affectedTypes.contains($0.type) }
                .map { $0.id }
        } else {
            // Default: affect source threads
            affectedThreadIDs = sourceThreadIDs
        }

        // Convert relationship deepening templates to actual relationship deepenings
        let deepenedRelationships: [RelationshipDeepening]
        if let templates = rule.consciousnessExpansion.deepenedRelationships {
            deepenedRelationships = templates.compactMap { template in
                // Find threads of the specified types
                guard let thread1 = city.threads.first(where: { $0.type == template.type1 }),
                      let thread2 = city.threads.first(where: { $0.type == template.type2 }) else {
                    return nil
                }

                return RelationshipDeepening(
                    threadID1: thread1.id,
                    threadID2: thread2.id,
                    quality: template.quality,
                    strengthBonus: template.strengthBonus
                )
            }
        } else {
            deepenedRelationships = []
        }

        // Create consciousness expansion
        let expansion = ConsciousnessExpansion(
            affectedThreadIDs: affectedThreadIDs,
            newPerceptions: rule.consciousnessExpansion.newPerceptions,
            deepenedRelationships: deepenedRelationships,
            expandedSelfAwareness: rule.consciousnessExpansion.expandedSelfAwareness,
            complexityIncrease: rule.consciousnessExpansion.complexityIncrease
        )

        return EmergentProperty(
            name: rule.name,
            sourceThreadIDs: sourceThreadIDs,
            consciousnessExpansion: expansion,
            city: city
        )
    }

    // MARK: - Consciousness Expansion Application

    /// Apply consciousness expansion to city and threads
    @MainActor
    func applyConsciousnessExpansion(
        _ expansion: ConsciousnessExpansion,
        to city: City
    ) {
        // 1. Increase city complexity
        let currentComplexity = city.resources["complexity"] ?? 0.0
        let newComplexity = min(1.0, currentComplexity + expansion.complexityIncrease)
        city.resources["complexity"] = newComplexity

        // 2. Add new perceptions to city
        city.perceptions.append(contentsOf: expansion.newPerceptions)

        // 3. Deepen relationships between affected threads
        for deepening in expansion.deepenedRelationships {
            // Find both threads
            guard let thread1 = city.threads.first(where: { $0.id == deepening.threadID1 }),
                  let thread2 = city.threads.first(where: { $0.id == deepening.threadID2 }) else {
                continue
            }

            // Strengthen the relationship from thread1 to thread2
            if let index = thread1.relationships.firstIndex(where: { $0.otherThreadID == thread2.id }) {
                let currentStrength = thread1.relationships[index].strength
                thread1.relationships[index].strength = min(1.0, currentStrength + deepening.strengthBonus)
            }

            // Strengthen the relationship from thread2 to thread1
            if let index = thread2.relationships.firstIndex(where: { $0.otherThreadID == thread1.id }) {
                let currentStrength = thread2.relationships[index].strength
                thread2.relationships[index].strength = min(1.0, currentStrength + deepening.strengthBonus)
            }
        }

        // 4. Increase complexity for affected threads
        for threadID in expansion.affectedThreadIDs {
            if let thread = city.threads.first(where: { $0.id == threadID }) {
                thread.complexity = min(1.0, thread.complexity + expansion.complexityIncrease / 2.0)
            }
        }

        print("Consciousness expanded: \(expansion.expandedSelfAwareness)")
    }

    // MARK: - Nonisolated Access

    /// Get all emergence rule names (for debugging/display)
    nonisolated func getAllEmergenceRuleNames() -> [String] {
        // Since we can't access actor state directly, return empty for now
        // This would need to be async or use a different pattern
        return []
    }
}
