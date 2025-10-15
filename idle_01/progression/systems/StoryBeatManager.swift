//
//  StoryBeatManager.swift
//  idle_01
//
//  Manages story beat loading, trigger evaluation, and effect application
//

import Foundation
import SwiftData

actor StoryBeatManager {

    nonisolated private let allBeats: [StoryBeat]

    init() {
        self.allBeats = Self.loadAllStoryBeats()
    }

    // MARK: - Loading

    nonisolated private static func loadAllStoryBeats() -> [StoryBeat] {
        var beats: [StoryBeat] = []

        // List of story beat JSON files to load
        let beatFiles = [
            "core_progression",
            "emergent_properties"
        ]

        for filename in beatFiles {
            beats.append(contentsOf: loadBeatFile(filename: filename))
        }

        print("[StoryBeatManager] Loaded \(beats.count) story beats from \(beatFiles.count) files")
        return beats
    }

    nonisolated private static func loadBeatFile(filename: String) -> [StoryBeat] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "progression/data/story_beats") else {
            print("[StoryBeatManager] Could not find \(filename).json")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let collection = try JSONDecoder().decode(StoryBeatCollection.self, from: data)
            print("[StoryBeatManager] Loaded \(collection.beats.count) beats from \(filename).json")
            return collection.beats
        } catch {
            print("[StoryBeatManager] Error loading \(filename).json: \(error)")
            return []
        }
    }

    // MARK: - Trigger Checking

    /// Check all story beat triggers against current city state
    /// Returns beats that should fire now
    @MainActor
    func checkTriggers(city: City) -> [StoryBeat] {
        var triggeredBeats: [StoryBeat] = []

        for var beat in allBeats {
            // Skip if already occurred and is one-time-only
            if beat.hasOccurred && beat.oneTimeOnly {
                continue
            }

            if evaluateTrigger(beat.trigger, city: city) {
                beat.hasOccurred = true
                triggeredBeats.append(beat)
            }
        }

        return triggeredBeats
    }

    @MainActor
    private func evaluateTrigger(_ trigger: BeatTrigger, city: City) -> Bool {
        switch trigger {
        case .threadCreated(let count):
            return city.threads.count == count

        case .threadCreatedType(let type, let count):
            let typeCount = city.threads.filter { $0.type == type }.count
            return typeCount == count

        case .relationshipFormed(let type1, let type2):
            return hasRelationship(type1: type1, type2: type2, in: city)

        case .emergentProperty(_):
            // TODO: Check city.emergentProperties when Phase 4 is implemented
            return false

        case .synergy(let type1, let type2, let threshold):
            return checkSynergy(type1, type2, threshold, in: city)

        case .tension(let type1, let type2, let threshold):
            return checkTension(type1, type2, threshold, in: city)

        case .cityCoherence(let threshold):
            return (city.resources["coherence"] ?? 0.0) >= threshold

        case .threadComplexity(let type, let threshold):
            return threadComplexity(type: type, in: city) >= threshold
        }
    }

    @MainActor
    private func hasRelationship(type1: ThreadType, type2: ThreadType, in city: City) -> Bool {
        // Check if any thread of type1 has a relationship with any thread of type2
        let threads1 = city.threads.filter { $0.type == type1 }
        let threads2 = city.threads.filter { $0.type == type2 }

        for thread1 in threads1 {
            for thread2 in threads2 {
                if thread1.relationships.contains(where: { $0.otherThreadID == thread2.id }) {
                    return true
                }
            }
        }

        return false
    }

    @MainActor
    private func checkSynergy(_ type1: ThreadType, _ type2: ThreadType, _ threshold: Double, in city: City) -> Bool {
        // Find average synergy between threads of these types
        let threads1 = city.threads.filter { $0.type == type1 }
        let threads2 = city.threads.filter { $0.type == type2 }

        var totalSynergy = 0.0
        var count = 0

        for thread1 in threads1 {
            for thread2 in threads2 {
                if let relationship = thread1.relationships.first(where: { $0.otherThreadID == thread2.id }) {
                    totalSynergy += relationship.synergy
                    count += 1
                }
            }
        }

        guard count > 0 else { return false }
        let averageSynergy = totalSynergy / Double(count)
        return averageSynergy >= threshold
    }

    @MainActor
    private func checkTension(_ type1: ThreadType, _ type2: ThreadType, _ threshold: Double, in city: City) -> Bool {
        // Find average tension (negative synergy) between threads of these types
        let threads1 = city.threads.filter { $0.type == type1 }
        let threads2 = city.threads.filter { $0.type == type2 }

        var totalTension = 0.0
        var count = 0

        for thread1 in threads1 {
            for thread2 in threads2 {
                if let relationship = thread1.relationships.first(where: { $0.otherThreadID == thread2.id }) {
                    totalTension += abs(min(0, relationship.synergy))  // Negative synergy = tension
                    count += 1
                }
            }
        }

        guard count > 0 else { return false }
        let averageTension = totalTension / Double(count)
        return averageTension >= threshold
    }

    @MainActor
    private func threadComplexity(type: ThreadType, in city: City) -> Double {
        let threads = city.threads.filter { $0.type == type }
        guard !threads.isEmpty else { return 0.0 }

        let totalComplexity = threads.reduce(0.0) { $0 + $1.complexity }
        return totalComplexity / Double(threads.count)
    }

    // MARK: - Effects Application

    @MainActor
    func applyEffects(_ effects: BeatEffects, to city: City) {
        // Apply city-level effects
        if let coherence = effects.cityCoherence {
            let current = city.resources["coherence"] ?? 0.0
            city.resources["coherence"] = min(1.0, max(0.0, current + coherence))
        }

        if let complexity = effects.cityComplexity {
            let current = city.resources["complexity"] ?? 0.0
            city.resources["complexity"] = min(1.0, max(0.0, current + complexity))
        }

        // Apply thread-level effects
        if let threadCoherence = effects.threadCoherence {
            for (typeRaw, delta) in threadCoherence {
                if let type = ThreadType(rawValue: typeRaw) {
                    applyThreadEffect(type: type, delta: delta, to: city, property: \.coherence)
                }
            }
        }

        if let threadComplexity = effects.threadComplexity {
            for (typeRaw, delta) in threadComplexity {
                if let type = ThreadType(rawValue: typeRaw) {
                    applyThreadEffect(type: type, delta: delta, to: city, property: \.complexity)
                }
            }
        }
    }

    @MainActor
    private func applyThreadEffect(
        type: ThreadType,
        delta: Double,
        to city: City,
        property: WritableKeyPath<UrbanThread, Double>
    ) {
        for i in city.threads.indices where city.threads[i].type == type {
            let current = city.threads[i][keyPath: property]
            city.threads[i][keyPath: property] = min(1.0, max(0.0, current + delta))
        }
    }
}
