//
//  StoryBeatManager.swift
//  idle_01
//
//  Manages story beat loading, trigger evaluation, and effect application
//

import Foundation
import SwiftData

actor StoryBeatManager {

    private var allBeats: [StoryBeat]

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
        let subdirectory = "progression/data/story_beats"
        let bundle = Bundle.main

        // Verbose diagnostics about where we're looking
        print("[StoryBeatManager][Debug] Requested beat file: \(filename).json")
        print("[StoryBeatManager][Debug] Bundle.bundlePath: \(bundle.bundlePath)")
        print("[StoryBeatManager][Debug] Bundle.resourcePath: \(bundle.resourcePath ?? "nil")")
        print("[StoryBeatManager][Debug] Target subdirectory: \(subdirectory)")

        if let resourceURL = bundle.resourceURL {
            let subdirURL = resourceURL.appendingPathComponent(subdirectory, isDirectory: true)
            var isDir: ObjCBool = false
            let exists = FileManager.default.fileExists(atPath: subdirURL.path, isDirectory: &isDir)
            print("[StoryBeatManager][Debug] Subdirectory URL: \(subdirURL.path)")
            print("[StoryBeatManager][Debug] Subdirectory exists: \(exists), isDirectory: \(isDir.boolValue)")

            if exists && isDir.boolValue {
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: subdirURL.path)
                    print("[StoryBeatManager][Debug] Subdirectory contents (\(contents.count) items): \(contents)")
                } catch {
                    print("[StoryBeatManager][Debug] Failed to list contents of subdirectory: \(error)")
                }
            }
        } else {
            print("[StoryBeatManager][Debug] bundle.resourceURL is nil — cannot compute subdirectory URL")
        }

        // List all JSON candidates the bundle can see in that subdirectory
        let candidates = bundle.urls(forResourcesWithExtension: "json", subdirectory: subdirectory) ?? []
        if candidates.isEmpty {
            print("[StoryBeatManager][Debug] No JSON resources found under subdirectory: \(subdirectory)")
        } else {
            let names = candidates.map { $0.lastPathComponent }
            print("[StoryBeatManager][Debug] JSON candidates under subdirectory (\(candidates.count)):\n\t\(names.joined(separator: "\n\t"))")
        }

        // Resolve the specific resource: try subdirectory first, then search anywhere in bundle
        var resolvedURL: URL? = bundle.url(forResource: filename, withExtension: "json", subdirectory: subdirectory)
        if resolvedURL == nil {
            print("[StoryBeatManager][Debug] Fallback: searching entire bundle for \(filename).json")
            let allJSON = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
            if allJSON.isEmpty {
                print("[StoryBeatManager][Debug] Fallback: no JSON files found anywhere in bundle")
            } else {
                let allNames = allJSON.map { $0.lastPathComponent }
                print("[StoryBeatManager][Debug] Fallback: found JSON files (\(allNames.count)):\n\t\(allNames.joined(separator: "\n\t"))")
            }
            if let match = allJSON.first(where: { $0.lastPathComponent == "\(filename).json" }) {
                resolvedURL = match
                print("[StoryBeatManager][Debug] Fallback: matched \(filename).json at: \(match.path)")
            }
        }

        guard let url = resolvedURL else {
            print("[StoryBeatManager] Could not find \(filename).json in subdirectory: \(subdirectory) or anywhere in bundle")
            return []
        }

        print("[StoryBeatManager][Debug] Resolved URL: \(url.path)")

        do {
            let data = try Data(contentsOf: url)
            print("[StoryBeatManager][Debug] Loaded data size: \(data.count) bytes for \(filename).json")
            let decoder = JSONDecoder()
            let collection = try decoder.decode(StoryBeatCollection.self, from: data)
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
    func checkTriggers(city: City) async -> [StoryBeat] {
        var triggeredBeats: [StoryBeat] = []

        let threadCount = await MainActor.run { city.threads.count }
        let alreadyTriggered = await MainActor.run { city.triggeredStoryBeats }

        print("[StoryBeatManager] Checking triggers for city with \(threadCount) threads")
        print("[StoryBeatManager] Already triggered beats: \(alreadyTriggered)")
        print("[StoryBeatManager] Evaluating \(allBeats.count) total beats")

        for i in allBeats.indices {
            // Skip if already occurred and is one-time-only (check persistent city state)
            if allBeats[i].oneTimeOnly && alreadyTriggered.contains(allBeats[i].id) {
                print("[StoryBeatManager] Skipping beat '\(allBeats[i].id)' - already occurred in city history")
                continue
            }

            print("[StoryBeatManager] Evaluating beat '\(allBeats[i].id)' with trigger: \(allBeats[i].trigger)")
            if await evaluateTrigger(allBeats[i].trigger, city: city) {
                print("[StoryBeatManager] ✅ Beat '\(allBeats[i].id)' triggered!")

                // Mark as triggered in city's persistent state
                if allBeats[i].oneTimeOnly {
                    let beatID = allBeats[i].id
                    await MainActor.run {
                        city.triggeredStoryBeats.append(beatID)
                    }
                }

                triggeredBeats.append(allBeats[i])
            } else {
                print("[StoryBeatManager] ❌ Beat '\(allBeats[i].id)' did not trigger")
            }
        }

        print("[StoryBeatManager] Returning \(triggeredBeats.count) triggered beats")
        return triggeredBeats
    }

    private func evaluateTrigger(_ trigger: BeatTrigger, city: City) async -> Bool {
        switch trigger {
        case .threadCreated(let count):
            let threadCount = await MainActor.run { city.threads.count }
            print("[StoryBeatManager] Evaluating threadCreated: need \(count), have \(threadCount)")
            return threadCount == count

        case .threadCreatedType(let type, let count):
            let typeCount = await MainActor.run { city.threads.filter { $0.type == type }.count }
            return typeCount == count

        case .relationshipFormed(let type1, let type2):
            return await hasRelationship(type1: type1, type2: type2, in: city)

        case .emergentProperty(_):
            // TODO: Check city.emergentProperties when Phase 4 is implemented
            return false

        case .synergy(let type1, let type2, let threshold):
            return await checkSynergy(type1, type2, threshold, in: city)

        case .tension(let type1, let type2, let threshold):
            return await checkTension(type1, type2, threshold, in: city)

        case .cityCoherence(let threshold):
            let coherence = await MainActor.run { city.resources["coherence"] ?? 0.0 }
            return coherence >= threshold

        case .threadComplexity(let type, let threshold):
            return await threadComplexity(type: type, in: city) >= threshold
        }
    }

    private func hasRelationship(type1: ThreadType, type2: ThreadType, in city: City) async -> Bool {
        // Check if any thread of type1 has a relationship with any thread of type2
        return await MainActor.run {
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
    }

    private func checkSynergy(_ type1: ThreadType, _ type2: ThreadType, _ threshold: Double, in city: City) async -> Bool {
        // Find average synergy between threads of these types
        return await MainActor.run {
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
    }

    private func checkTension(_ type1: ThreadType, _ type2: ThreadType, _ threshold: Double, in city: City) async -> Bool {
        // Find average tension (negative synergy) between threads of these types
        return await MainActor.run {
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
    }

    private func threadComplexity(type: ThreadType, in city: City) async -> Double {
        return await MainActor.run {
            let threads = city.threads.filter { $0.type == type }
            guard !threads.isEmpty else { return 0.0 }

            let totalComplexity = threads.reduce(0.0) { $0 + $1.complexity }
            return totalComplexity / Double(threads.count)
        }
    }

    // MARK: - Effects Application

    func applyEffects(_ effects: BeatEffects, to city: City) async {
        // Apply city-level effects
        if let coherence = effects.cityCoherence {
            await MainActor.run {
                let current = city.resources["coherence"] ?? 0.0
                city.resources["coherence"] = min(1.0, max(0.0, current + coherence))
            }
        }

        if let complexity = effects.cityComplexity {
            await MainActor.run {
                let current = city.resources["complexity"] ?? 0.0
                city.resources["complexity"] = min(1.0, max(0.0, current + complexity))
            }
        }

        // Apply thread-level effects
        if let threadCoherence = effects.threadCoherence {
            for (typeRaw, delta) in threadCoherence {
                if let type = ThreadType(rawValue: typeRaw) {
                    await applyThreadEffect(type: type, delta: delta, to: city, property: \.coherence)
                }
            }
        }

        if let threadComplexity = effects.threadComplexity {
            for (typeRaw, delta) in threadComplexity {
                if let type = ThreadType(rawValue: typeRaw) {
                    await applyThreadEffect(type: type, delta: delta, to: city, property: \.complexity)
                }
            }
        }
    }

    private func applyThreadEffect(
        type: ThreadType,
        delta: Double,
        to city: City,
        property: WritableKeyPath<UrbanThread, Double>
    ) async {
        await MainActor.run {
            for i in city.threads.indices where city.threads[i].type == type {
                let current = city.threads[i][keyPath: property]
                city.threads[i][keyPath: property] = min(1.0, max(0.0, current + delta))
            }
        }
    }
}

