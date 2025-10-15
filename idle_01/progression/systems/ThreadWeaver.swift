//
//  ThreadWeaver.swift
//  idle_01
//
//  Created by Claude on 10/14/25.
//  Part of Woven Consciousness Progression System
//

import Foundation
import SwiftData

/// Actor responsible for weaving new threads into a city's consciousness.
/// Handles thread creation and automatic relationship formation.
actor ThreadWeaver {

    // MARK: - Properties

    /// Shared dialogue manager for retrieving thread dialogue
    private let dialogueManager: DialogueManager

    // MARK: - Initialization

    init(dialogueManager: DialogueManager = DialogueManager()) {
        self.dialogueManager = dialogueManager
    }

    // MARK: - Thread Creation

    /// Weave a new thread into a city
    /// - Parameters:
    ///   - type: The type of thread to weave
    ///   - city: The city to weave into
    ///   - context: SwiftData model context for persistence
    /// - Returns: Tuple of the newly created thread and its creation dialogue
    @MainActor
    func weaveThread(
        type: ThreadType,
        into city: City,
        context: ModelContext
    ) async -> (thread: UrbanThread, dialogue: String?) {

        // Calculate instance number for this thread type
        let instanceNumber = calculateInstanceNumber(type: type, city: city)

        // Create the new thread
        let thread = UrbanThread(
            type: type,
            instanceNumber: instanceNumber,
            city: city
        )

        // Form relationships with all existing threads
        let existingThreads = city.threads
        for existing in existingThreads {
            let relationship = RelationshipCalculator.calculate(
                from: thread,
                to: existing
            )
            thread.addRelationship(relationship)

            // Also add reciprocal relationship to the existing thread
            let reciprocalRelationship = RelationshipCalculator.calculate(
                from: existing,
                to: thread
            )
            existing.addRelationship(reciprocalRelationship)
        }

        // Insert thread into SwiftData context
        context.insert(thread)

        // Add thread to city's threads array
        city.threads.append(thread)

        // Get creation dialogue for this thread (no tag filtering - all onCreation dialogue is valid)
        let dialogue = await dialogueManager.getDialogue(
            threadType: type,
            context: .onCreation
        )

        // Log the weaving event
        let logMessage = "Thread woven: \(thread.displayName) [Coherence: \(String(format: "%.2f", thread.coherence))]"
        city.log.append(logMessage)

        // Also log city dialogue if this is the first or second thread
        if city.threads.count <= 2 {
            let cityDialogue = await dialogueManager.getDialogue(
                speaker: .city,
                context: .onCreation,
                tags: city.threads.count == 1 ? ["first"] : ["second"]
            )
            if let cityDialogue = cityDialogue {
                city.log.append("CITY: \(cityDialogue)")
            }
        }

        return (thread, dialogue)
    }

    /// Calculate the instance number for a new thread of the given type
    /// - Parameters:
    ///   - type: The thread type
    ///   - city: The city to check for existing threads
    /// - Returns: The next instance number (1-based)
    @MainActor
    private func calculateInstanceNumber(type: ThreadType, city: City) -> Int {
        let sameTypeCount = city.threads.filter { $0.type == type }.count
        return sameTypeCount + 1
    }

    /// Weave multiple threads at once
    /// - Parameters:
    ///   - types: Array of thread types to weave
    ///   - city: The city to weave into
    ///   - context: SwiftData model context
    /// - Returns: Array of newly created threads with their dialogue
    @MainActor
    func weaveThreads(
        types: [ThreadType],
        into city: City,
        context: ModelContext
    ) async -> [(thread: UrbanThread, dialogue: String?)] {
        var weavedThreads: [(thread: UrbanThread, dialogue: String?)] = []

        for type in types {
            let result = await weaveThread(type: type, into: city, context: context)
            weavedThreads.append(result)
        }

        return weavedThreads
    }

    /// Check if a thread type already exists in the city
    /// - Parameters:
    ///   - type: The thread type to check
    ///   - city: The city to check
    /// - Returns: True if at least one thread of this type exists
    @MainActor
    func threadExists(type: ThreadType, in city: City) -> Bool {
        city.threads.contains { $0.type == type }
    }

    /// Get count of threads of a specific type
    /// - Parameters:
    ///   - type: The thread type to count
    ///   - city: The city to check
    /// - Returns: Number of threads of this type
    @MainActor
    func countThreads(type: ThreadType, in city: City) -> Int {
        city.threads.filter { $0.type == type }.count
    }

    /// Get all threads of a specific type
    /// - Parameters:
    ///   - type: The thread type to get
    ///   - city: The city to search
    /// - Returns: Array of threads of this type
    @MainActor
    func getThreads(type: ThreadType, in city: City) -> [UrbanThread] {
        city.threads.filter { $0.type == type }
    }
}
