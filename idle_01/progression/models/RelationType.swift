//
//  RelationType.swift
//  idle_01
//
//  Created by Claude on 10/14/25.
//  Part of Woven Consciousness Progression System
//

import Foundation

/// Describes the nature of the relationship between two urban threads.
enum RelationType: String, Codable {
    /// One thread helps the other function better
    case support

    /// Threads work well together, creating synergy
    case harmony

    /// Threads conflict with each other
    case tension

    /// Same-type threads vibrating together in resonance
    case resonance

    /// One thread fundamentally needs the other to function
    case dependency

    /// Human-readable description of the relationship type
    var description: String {
        switch self {
        case .support:
            return "One helps the other function"
        case .harmony:
            return "They work well together"
        case .tension:
            return "They conflict"
        case .resonance:
            return "Same-type threads vibrating together"
        case .dependency:
            return "One needs the other to function"
        }
    }
}
