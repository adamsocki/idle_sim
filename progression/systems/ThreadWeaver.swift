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

    /// Weave a new thread into a city
    /// - Parameters:
    ///   - type: The type of thread to weave
    ///   - city: The city to weave into
    ///   - context: SwiftData model context for persistence
    /// - Returns: The newly created urban thread
    @MainActor
    func weaveThread(
        type: ThreadType,
        into city: City,
        context: ModelContext
    ) -> UrbanThread {

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

        // Log the weaving event
        let logMessage = "Thread woven: \(thread.displayName) [Coherence: \(String(format: "%.2f", thread.coherence))]"
        city.log.append(logMessage)

        return thread
    }

    /// Calculate the instance number for a new thread of the given type
    /// - Parameters:
    ///   - type: The thread type
    ///   - city: The city to check for existing threads
    /// - Returns: The next instance number (1-based)
    private func calculateInstanceNumber(type: ThreadType, city: City) -> Int {
        let sameTypeCount = city.threads.filter { $0.type == type }.count
        return sameTypeCount + 1
    }

    /// Weave multiple threads at once
    /// - Parameters:
    ///   - types: Array of thread types to weave
    ///   - city: The city to weave into
    ///   - context: SwiftData model context
    /// - Returns: Array of newly created threads
    @MainActor
    func weaveThreads(
        types: [ThreadType],
        into city: City,
        context: ModelContext
    ) -> [UrbanThread] {
        var weavedThreads: [UrbanThread] = []

        for type in types {
            let thread = weaveThread(type: type, into: city, context: context)
            weavedThreads.append(thread)
        }

        return weavedThreads
    }

    /// Check if a thread type already exists in the city
    /// - Parameters:
    ///   - type: The thread type to check
    ///   - city: The city to check
    /// - Returns: True if at least one thread of this type exists
    func threadExists(type: ThreadType, in city: City) -> Bool {
        city.threads.contains { $0.type == type }
    }

    /// Get count of threads of a specific type
    /// - Parameters:
    ///   - type: The thread type to count
    ///   - city: The city to check
    /// - Returns: Number of threads of this type
    func countThreads(type: ThreadType, in city: City) -> Int {
        city.threads.filter { $0.type == type }.count
    }

    /// Get all threads of a specific type
    /// - Parameters:
    ///   - type: The thread type to get
    ///   - city: The city to search
    /// - Returns: Array of threads of this type
    func getThreads(type: ThreadType, in city: City) -> [UrbanThread] {
        city.threads.filter { $0.type == type }
    }
}
