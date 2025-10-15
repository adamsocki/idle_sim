//
//  ThreadType.swift
//  idle_01
//
//  Created by Claude on 10/14/25.
//  Part of Woven Consciousness Progression System
//

import Foundation

/// Represents the different types of urban threads that can be woven into a city's consciousness.
/// Each type represents a distinct aspect of urban infrastructure and life.
enum ThreadType: String, Codable, CaseIterable {
    case transit
    case housing
    case culture
    case commerce
    case parks
    case water
    case power
    case sewage
    case knowledge

    /// Human-readable display name for the thread type
    var displayName: String {
        rawValue.capitalized
    }

    /// Returns the thread type as a dialogue speaker identifier
    var speakerID: String {
        rawValue
    }
}
