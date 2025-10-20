//
//  CityMoment.swift
//  idle_01
//
//  Represents a narrative moment in the city's consciousness
//  Moments are the building blocks of the story experience
//

import Foundation
import SwiftData

// MARK: - MomentType Enum

/// Categories of moments that can occur in the city
/// Each type creates different narrative resonance and affects moment selection
enum MomentType: String, Codable, CaseIterable {
    /// Everyday rituals that give the city rhythm
    /// Examples: morning coffee routines, commuter patterns, daily greetings
    case dailyRitual

    /// Close calls and almosts - moments that nearly happened
    /// Examples: person who almost missed the train, conversation that almost started
    case nearMiss

    /// Tiny acts of defiance against the system
    /// Examples: graffiti in hidden spots, taking the long way home, choosing the inefficient path
    case smallRebellion

    /// Unseen connections between people who don't know each other
    /// Examples: two strangers reading the same book, parallel routines, shared memories of places
    case invisibleConnection

    /// Echoes of the past in the present
    /// Examples: old building remembering its former purpose, ghost of a demolished structure
    case temporalGhost

    /// Moments that ask questions without answers
    /// Examples: why does the bridge have flowers?, what makes a place home?, who decides?
    case question

    /// Transformative moments where something becomes something else
    /// Examples: neighborhood changing identity, person finding their place, city evolving
    case momentOfBecoming

    /// Small details that carry unexpected significance
    /// Examples: the specific angle of afternoon light, the sound of rain on different surfaces
    case weightOfSmallThings

    /// Returns a human-readable description of the moment type
    var description: String {
        switch self {
        case .dailyRitual:
            return "Daily Ritual"
        case .nearMiss:
            return "Near Miss"
        case .smallRebellion:
            return "Small Rebellion"
        case .invisibleConnection:
            return "Invisible Connection"
        case .temporalGhost:
            return "Temporal Ghost"
        case .question:
            return "Question"
        case .momentOfBecoming:
            return "Moment of Becoming"
        case .weightOfSmallThings:
            return "Weight of Small Things"
        }
    }

    /// Returns narrative affinity with choice patterns
    /// Higher values mean this moment type resonates more with that choice pattern
    func affinityWith(_ pattern: ChoicePattern) -> Double {
        switch (self, pattern) {
        case (.invisibleConnection, .story), (.temporalGhost, .story), (.momentOfBecoming, .story):
            return 2.0 // Story choices strongly favor narrative-heavy moments

        case (.dailyRitual, .efficiency), (.weightOfSmallThings, .efficiency):
            return 0.5 // Efficiency choices less likely to appreciate rituals and details

        case (.question, .autonomy), (.momentOfBecoming, .autonomy):
            return 1.8 // Autonomy choices favor moments about self-determination

        case (.smallRebellion, .control):
            return 0.3 // Control choices clash with rebellion moments

        case (.question, .story):
            return 1.5 // Story appreciates questions

        case (.nearMiss, .efficiency):
            return 0.7 // Efficiency might see near-misses as system failures

        default:
            return 1.0 // Neutral affinity
        }
    }
}

// MARK: - CityMoment Model

/// A narrative moment within the city's experience
/// Moments are revealed through player commands and shaped by player choices
@Model
final class CityMoment {
    // MARK: - Identity

    /// Unique identifier for this moment
    var momentID: String

    /// The core text of the moment (shown on first reveal)
    var text: String

    /// The type/category of this moment
    var type: MomentType

    // MARK: - Context

    /// Which district this moment occurs in (1-based indexing)
    /// District 0 = city-wide, Districts 1-9 = specific areas
    var district: Int

    /// How vulnerable this moment is to being destroyed by efficiency choices
    /// Range: 1-10 (1 = resilient, 10 = extremely fragile)
    /// High fragility moments are often the most human and inefficient
    var fragility: Int

    /// Which act this moment is most relevant to
    /// Moments can appear in later acts, but not earlier than this
    var associatedAct: Int

    // MARK: - Relational Text Variants

    /// Text shown the first time this moment is mentioned
    /// Should introduce the moment with wonder/discovery
    var firstMention: String

    /// Text shown if player previously preserved this moment
    /// Should reflect continuity and memory
    var ifPreserved: String

    /// Text shown if player previously destroyed this moment
    /// Should reflect loss and absence
    var ifDestroyed: String

    /// Text shown if player used REMEMBER command on this moment
    /// Should reflect deeper understanding and significance
    var ifRemembered: String

    // MARK: - State (Session-only, not persisted across games)

    /// Whether this moment has been revealed to the player this session
    var hasBeenRevealed: Bool = false

    /// Whether this moment has been destroyed this session
    var isDestroyed: Bool = false

    /// Whether player used REMEMBER on this moment
    var isRemembered: Bool = false

    /// Timestamp when moment was first revealed
    var revealedAt: Date?

    // MARK: - Metadata

    /// Tags for additional filtering (optional)
    /// Examples: "transit", "family", "music", "food"
    var tags: [String] = []

    /// Author notes (not shown to player, for development)
    var authorNotes: String?

    // MARK: - Initialization

    init(
        momentID: String,
        text: String,
        type: MomentType,
        district: Int,
        fragility: Int,
        associatedAct: Int,
        firstMention: String,
        ifPreserved: String,
        ifDestroyed: String,
        ifRemembered: String,
        tags: [String] = [],
        authorNotes: String? = nil
    ) {
        self.momentID = momentID
        self.text = text
        self.type = type
        self.district = district
        self.fragility = fragility
        self.associatedAct = associatedAct
        self.firstMention = firstMention
        self.ifPreserved = ifPreserved
        self.ifDestroyed = ifDestroyed
        self.ifRemembered = ifRemembered
        self.tags = tags
        self.authorNotes = authorNotes
        self.hasBeenRevealed = false
        self.isDestroyed = false
        self.isRemembered = false
        self.revealedAt = nil
    }

    // MARK: - Helper Methods

    /// Returns the appropriate text variant based on current state
    func getText(context: MomentContext) -> String {
        switch context {
        case .firstTime:
            return firstMention
        case .preserved:
            return ifPreserved
        case .destroyed:
            return ifDestroyed
        case .remembered:
            return ifRemembered
        case .default:
            return text
        }
    }

    /// Marks this moment as revealed
    func reveal() {
        hasBeenRevealed = true
        revealedAt = Date()
    }

    /// Marks this moment as destroyed
    func destroy() {
        isDestroyed = true
    }

    /// Marks this moment as remembered
    func remember() {
        isRemembered = true
    }

    /// Returns whether this moment should be shown in the given act
    func isAvailableInAct(_ act: Int) -> Bool {
        return act >= associatedAct
    }

    /// Calculates destruction probability based on fragility
    func destructionProbability() -> Double {
        if fragility >= GameBalanceConfig.MomentFragility.highFragilityThreshold {
            return GameBalanceConfig.MomentFragility.highFragilityDestructionChance
        } else if fragility >= GameBalanceConfig.MomentFragility.moderateFragilityThreshold {
            return GameBalanceConfig.MomentFragility.moderateFragilityDestructionChance
        } else {
            return GameBalanceConfig.MomentFragility.lowFragilityDestructionChance
        }
    }

    /// Returns weight for selection based on choice pattern affinity
    func selectionWeight(givenPattern pattern: ChoicePattern?) -> Double {
        guard let pattern = pattern else {
            return GameBalanceConfig.MomentWeights.baseWeight
        }

        let affinity = type.affinityWith(pattern)
        return GameBalanceConfig.MomentWeights.baseWeight * affinity
    }
}

// MARK: - MomentContext Enum

/// Context for determining which text variant to show
enum MomentContext {
    case firstTime      // First time revealing this moment
    case preserved      // Moment was previously preserved
    case destroyed      // Moment was previously destroyed
    case remembered     // Player used REMEMBER on this moment
    case `default`      // Default context (base text)
}

// MARK: - Helper Extensions

extension CityMoment {
    /// Convenience accessor for human-readable type name
    var typeName: String {
        return type.description
    }

    /// Returns a formatted summary for debugging
    var debugSummary: String {
        """
        Moment: \(momentID)
        Type: \(typeName)
        District: \(district)
        Fragility: \(fragility)/10
        Act: \(associatedAct)+
        Revealed: \(hasBeenRevealed)
        Destroyed: \(isDestroyed)
        Tags: \(tags.joined(separator: ", "))
        """
    }

    /// Returns true if this moment has any of the given tags
    func hasAnyTag(_ searchTags: [String]) -> Bool {
        return !Set(tags).isDisjoint(with: Set(searchTags))
    }

    /// Returns true if this moment has all of the given tags
    func hasAllTags(_ searchTags: [String]) -> Bool {
        return Set(searchTags).isSubset(of: Set(tags))
    }
}

// MARK: - Codable Support for JSON Loading

/// Simplified structure for loading moments from JSON
struct CityMomentData: Codable {
    let momentID: String
    let text: String
    let type: String // Will be converted to MomentType
    let district: Int
    let fragility: Int
    let associatedAct: Int
    let firstMention: String
    let ifPreserved: String
    let ifDestroyed: String
    let ifRemembered: String
    let tags: [String]?
    let authorNotes: String?

    /// Converts this data structure into a CityMoment model
    func toModel() -> CityMoment? {
        guard let momentType = MomentType(rawValue: type) else {
            print("⚠️ Invalid moment type: \(type)")
            return nil
        }

        return CityMoment(
            momentID: momentID,
            text: text,
            type: momentType,
            district: district,
            fragility: fragility,
            associatedAct: associatedAct,
            firstMention: firstMention,
            ifPreserved: ifPreserved,
            ifDestroyed: ifDestroyed,
            ifRemembered: ifRemembered,
            tags: tags ?? [],
            authorNotes: authorNotes
        )
    }
}

/// Container for loading moment library from JSON
struct MomentLibrary: Codable {
    let moments: [CityMomentData]
    let version: String?
    let description: String?

    /// Converts all moment data to models
    func toModels() -> [CityMoment] {
        return moments.compactMap { $0.toModel() }
    }
}
