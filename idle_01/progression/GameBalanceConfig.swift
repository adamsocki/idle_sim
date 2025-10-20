//
//  GameBalanceConfig.swift
//  idle_01
//
//  Centralized game balance configuration
//  All tunable values for narrative progression, choice impacts, and endings
//

import Foundation

/// Master configuration for all game balance values.
/// Modify these constants to tune the game experience without touching core logic.
@MainActor
struct GameBalanceConfig {

    // MARK: - Choice Impact Values

    /// How much each choice pattern affects the city's trust and autonomy
    struct ChoiceImpacts {

        // STORY CHOICES - Preserve human narratives
        /// Increment to story choice counter when player chooses story-focused option
        static let storyChoiceIncrement: Int = 1

        /// How much city trust INCREASES when player preserves human stories
        /// Range: 0.0 to 1.0 (typically 0.01 - 0.10)
        /// Higher = City trusts player more quickly when they value narratives
        /// Lower = Requires more story choices to build trust
        static let storyTrustGain: Double = 0.05

        /// How much city autonomy is affected by story choices (if at all)
        /// Set to 0.0 for no impact, positive for autonomy gain
        static let storyAutonomyImpact: Double = 0.0


        // EFFICIENCY CHOICES - Optimize systems
        /// Increment to efficiency choice counter
        static let efficiencyChoiceIncrement: Int = 1

        /// How much city trust DECREASES when player optimizes for efficiency
        /// Range: 0.0 to 1.0 (typically 0.01 - 0.05)
        /// Higher = City loses trust faster when player prioritizes efficiency over stories
        /// Lower = Efficiency choices don't damage relationship as much
        /// WARNING: Setting too high makes "Optimization" ending harder to reach
        static let efficiencyTrustLoss: Double = 0.02

        /// How much city autonomy is affected by efficiency choices
        /// Negative = City feels controlled by optimization
        /// Positive = City appreciates systematic approach
        static let efficiencyAutonomyImpact: Double = -0.01


        // AUTONOMY CHOICES - Let city decide
        /// Increment to autonomy choice counter
        static let autonomyChoiceIncrement: Int = 1

        /// How much city trust changes when player grants autonomy
        /// Positive = City trusts player for giving freedom
        static let autonomyTrustImpact: Double = 0.03

        /// How much city autonomy INCREASES when player lets city decide
        /// Range: 0.0 to 1.0 (typically 0.03 - 0.10)
        /// Higher = City gains independence faster
        /// Lower = Requires more autonomy choices to reach Independence ending
        static let autonomyGain: Double = 0.05


        // CONTROL CHOICES - Direct intervention
        /// Increment to control choice counter
        static let controlChoiceIncrement: Int = 1

        /// How much city trust is affected by control choices
        /// Negative = City resents being controlled
        /// Positive = City appreciates decisive leadership (rare)
        static let controlTrustImpact: Double = -0.03

        /// How much city autonomy DECREASES when player exerts control
        /// Range: 0.0 to 1.0 (typically 0.03 - 0.10)
        /// Higher = City loses independence faster under control
        /// Lower = Control choices have gentler impact on autonomy
        /// WARNING: Setting too high makes "Silence" ending too easy to trigger
        static let controlAutonomyLoss: Double = 0.05
    }


    // MARK: - Ending Threshold Values

    /// Thresholds for determining which ending the player reaches
    struct EndingThresholds {

        // FRAGMENTATION ENDING - Over-optimized, losing coherence
        /// Minimum ratio of efficiency choices to trigger Fragmentation
        /// Range: 0.0 to 1.0 (0.7 = 70% of all choices must be efficiency)
        /// Higher = Harder to reach Fragmentation (requires near-total efficiency focus)
        /// Lower = Easier to accidentally fragment city
        static let fragmentationEfficiencyRatio: Double = 0.7

        /// Minimum destroyed moments to trigger Fragmentation
        /// Higher = Must destroy more moments to fragment city
        /// Lower = Fragmentation happens with fewer destroyed moments
        static let fragmentationDestroyedMoments: Int = 8


        // ARCHIVE ENDING - Museum of perfect memory
        /// Minimum ratio of story choices to trigger Archive
        /// Range: 0.0 to 1.0 (0.7 = 70% of all choices must be story)
        static let archiveStoryRatio: Double = 0.7

        /// Maximum destroyed moments allowed for Archive ending
        /// Lower = Must be more careful to preserve moments
        /// Higher = More forgiving, can lose some moments and still archive
        static let archiveMaxDestroyedMoments: Int = 2


        // SILENCE ENDING - City withdrew, lost trust
        /// Minimum ratio of control choices to trigger Silence
        /// Range: 0.0 to 1.0
        /// Higher = Requires more controlling behavior to trigger Silence
        /// Lower = City withdraws more easily
        static let silenceControlRatio: Double = 0.6

        /// Narrative flag that must be true to trigger Silence
        /// Set by ignoring city's questions/requests in narrative
        static let silenceRequiresIgnoredRequests: Bool = true


        // INDEPENDENCE ENDING - City chooses its own path
        /// Minimum ratio of autonomy choices to trigger Independence
        /// Range: 0.0 to 1.0
        static let independenceAutonomyRatio: Double = 0.6

        /// Minimum city autonomy value (0.0-1.0) required for Independence
        /// Higher = City must have developed strong self-direction
        static let independenceMinAutonomy: Double = 0.7


        // HARMONY ENDING - Balanced, mutual respect
        /// Combined minimum for story + autonomy choices to trigger Harmony
        /// Range: 0.0 to 1.0
        static let harmonyCombinedRatio: Double = 0.5

        /// Maximum destroyed moments for Harmony
        /// Must preserve most moments to achieve harmony
        static let harmonyMaxDestroyedMoments: Int = 3

        /// Minimum city trust required for Harmony
        /// Range: 0.0 to 1.0
        static let harmonyMinTrust: Double = 0.6


        // OPTIMIZATION ENDING - Efficient but coherent
        /// Combined minimum for efficiency + control to trigger Optimization
        static let optimizationCombinedRatio: Double = 0.5

        /// Maximum destroyed moments for coherent Optimization
        /// Too many destroyed = becomes Fragmentation instead
        static let optimizationMaxDestroyedMoments: Int = 7

        /// Minimum coherence required (tracked separately if needed)
        static let optimizationMinCoherence: Double = 0.4


        // EMERGENCE ENDING - Evolved beyond parameters
        /// Requires balanced choices (no single pattern dominates)
        /// Maximum difference between highest and lowest choice ratios
        /// Lower = Requires tighter balance
        /// Higher = More forgiving balance requirement
        static let emergenceMaxRatioDifference: Double = 0.25

        /// Specific narrative flags required for Emergence
        static let emergenceRequiredFlags: [String] = [
            "cityTranscended",
            "questionedOwnNature",
            "formedNewPattern"
        ]


        // SYMBIOSIS ENDING - Ongoing collaboration
        /// Maximum difference between any two choice pattern ratios
        /// Range: 0.0 to 1.0
        /// Lower = Requires near-perfect balance across all patterns
        /// Higher = More forgiving, allows some variation
        static let symbiosisMaxRatioDifference: Double = 0.2

        /// Narrative flag for accepting ambiguity
        static let symbiosisRequiresAmbiguityAcceptance: Bool = true

        /// Minimum total choices before Symbiosis can trigger
        /// Ensures player has engaged enough to deserve this ending
        static let symbiosisMinTotalChoices: Int = 20
    }


    // MARK: - Moment Selection Weights

    /// Weights for procedural moment selection based on player patterns
    struct MomentWeights {

        /// Base weight for all moments (neutral)
        static let baseWeight: Double = 1.0

        /// Weight multiplier when player's choice pattern aligns with moment type
        /// Example: Story choices increase weight of invisibleConnection moments
        /// Higher = Stronger affinity between patterns and moment types
        /// Lower = More random moment selection regardless of player choices
        static let patternAffinityMultiplier: Double = 2.0

        /// Weight multiplier for fragile moments when player is efficiency-focused
        /// Higher = More likely to show fragile moments to efficiency players
        /// Lower = Fragile moments shown more randomly
        static let fragileMomentMultiplier: Double = 2.5

        /// Weight reduction for moments of same type shown recently
        /// Prevents showing 3 dailyRituals in a row
        /// Range: 0.0 to 1.0 (0.3 = reduce weight to 30% of normal)
        /// Lower = Stronger variety enforcement
        /// Higher = More tolerance for repeated types
        static let recentTypeWeightReduction: Double = 0.3

        /// How many recent moments to check for type variety
        /// Higher = Enforces variety over longer history
        /// Lower = Only prevents immediate repetition
        static let recentMomentCheckCount: Int = 3
    }


    // MARK: - Act Progression

    /// Values controlling act transitions and pacing
    struct ActProgression {

        /// Minimum moments revealed before Act I can complete
        /// Higher = Longer Act I, more world-building
        /// Lower = Faster progression to choice-heavy acts
        static let actOneMomentMinimum: Int = 8

        /// Minimum moments revealed in Act II
        static let actTwoMomentMinimum: Int = 10

        /// Minimum moments revealed in Act III
        static let actThreeMomentMinimum: Int = 10

        /// Minimum total choices made before reaching Act IV
        /// Ensures player has made enough decisions to determine ending
        static let actFourMinimumChoices: Int = 15

        /// Number of scenes per act (approximate)
        /// Used for pacing narrative beats
        static let scenesPerAct: Int = 5
    }


    // MARK: - City Relationship Bounds

    /// Limits for city trust and autonomy values
    struct RelationshipBounds {

        /// Minimum city trust value (0.0 = complete distrust)
        static let minTrust: Double = 0.0

        /// Maximum city trust value (1.0 = complete trust)
        static let maxTrust: Double = 1.0

        /// Starting city trust value for new game
        /// Range: 0.0 to 1.0
        /// 0.5 = Neutral starting point
        /// Higher = City starts more trusting
        /// Lower = City starts more suspicious
        static let initialTrust: Double = 0.5

        /// Minimum city autonomy value (0.0 = fully dependent)
        static let minAutonomy: Double = 0.0

        /// Maximum city autonomy value (1.0 = fully independent)
        static let maxAutonomy: Double = 1.0

        /// Starting city autonomy value for new game
        /// Range: 0.0 to 1.0
        /// 0.5 = Neutral starting point
        /// Lower = City starts more dependent on player
        /// Higher = City starts with more self-direction
        static let initialAutonomy: Double = 0.5
    }


    // MARK: - Moment Fragility

    /// How moment fragility affects destruction probability
    struct MomentFragility {

        /// Fragility threshold above which moments are "highly fragile"
        /// Range: 1-10 (moment fragility scale)
        /// Moments with fragility >= this value are at high risk from efficiency choices
        static let highFragilityThreshold: Int = 7

        /// Fragility threshold for "moderate fragility"
        static let moderateFragilityThreshold: Int = 4

        /// Probability that efficiency choice destroys high-fragility moment
        /// Range: 0.0 to 1.0
        /// Higher = More moments destroyed by efficiency
        /// Lower = Moments more resilient
        /// WARNING: Setting too high makes Archive ending nearly impossible
        static let highFragilityDestructionChance: Double = 0.6

        /// Probability that efficiency choice destroys moderate-fragility moment
        static let moderateFragilityDestructionChance: Double = 0.3

        /// Probability that efficiency choice destroys low-fragility moment
        static let lowFragilityDestructionChance: Double = 0.1
    }


    // MARK: - Visualization Settings

    /// Visual feedback timing and intensity
    struct Visualization {

        /// Duration of ASCII pulse animation (seconds)
        /// Higher = Slower, more meditative pulse
        /// Lower = Faster, more energetic pulse
        static let pulseDuration: Double = 2.0

        /// Duration of ASCII rotation animation (seconds)
        static let rotationDuration: Double = 3.0

        /// Intensity of visualization reaction to story choices
        /// Range: 0.0 to 1.0
        /// Higher = More dramatic visual response
        static let storyChoiceIntensity: Double = 0.7

        /// Intensity of visualization reaction to efficiency choices
        /// Higher values create sharper, more angular patterns
        static let efficiencyChoiceIntensity: Double = 0.8

        /// Intensity of decay visualization when moments are destroyed
        static let decayIntensity: Double = 0.9
    }


    // MARK: - Gameplay Tuning

    /// General gameplay parameters
    struct Gameplay {

        /// Expected session duration (minutes)
        /// Used for pacing calculations, not enforced
        static let targetSessionDuration: Int = 45

        /// Whether to show hidden choice counters (debug mode)
        /// Set to true to see choice tracking for balancing
        static let debugShowChoiceCounters: Bool = false

        /// Whether to show ending probability in real-time (debug mode)
        static let debugShowEndingProbabilities: Bool = false

        /// Number of moments in initial library
        /// Guides content creation target
        static let targetMomentLibrarySize: Int = 50

        /// Minimum moments per district
        /// Ensures each district feels populated
        static let minMomentsPerDistrict: Int = 5
    }
}


// MARK: - Helper Extensions

extension GameBalanceConfig {

    /// Returns a diagnostic summary of current balance settings
    static func diagnosticSummary() -> String {
        """
        === GAME BALANCE CONFIGURATION ===

        CHOICE IMPACTS:
        - Story: +\(ChoiceImpacts.storyTrustGain) trust
        - Efficiency: -\(ChoiceImpacts.efficiencyTrustLoss) trust
        - Autonomy: +\(ChoiceImpacts.autonomyGain) autonomy
        - Control: -\(ChoiceImpacts.controlAutonomyLoss) autonomy

        ENDING THRESHOLDS:
        - Fragmentation: \(Int(EndingThresholds.fragmentationEfficiencyRatio * 100))% efficiency, \(EndingThresholds.fragmentationDestroyedMoments)+ destroyed
        - Archive: \(Int(EndingThresholds.archiveStoryRatio * 100))% story, ≤\(EndingThresholds.archiveMaxDestroyedMoments) destroyed
        - Independence: \(Int(EndingThresholds.independenceAutonomyRatio * 100))% autonomy
        - Harmony: \(Int(EndingThresholds.harmonyCombinedRatio * 100))% story+autonomy, ≤\(EndingThresholds.harmonyMaxDestroyedMoments) destroyed

        ACT PROGRESSION:
        - Act I minimum moments: \(ActProgression.actOneMomentMinimum)
        - Act IV minimum choices: \(ActProgression.actFourMinimumChoices)

        TARGET SESSION: \(Gameplay.targetSessionDuration) minutes
        TARGET MOMENT LIBRARY: \(Gameplay.targetMomentLibrarySize) moments
        """
    }

    /// Validates configuration values are within acceptable ranges
    static func validate() -> [String] {
        var warnings: [String] = []

        // Validate trust/autonomy impacts are reasonable
        if ChoiceImpacts.storyTrustGain > 0.15 {
            warnings.append("⚠️ Story trust gain (\(ChoiceImpacts.storyTrustGain)) is very high - trust will build too quickly")
        }

        if ChoiceImpacts.controlAutonomyLoss > 0.15 {
            warnings.append("⚠️ Control autonomy loss (\(ChoiceImpacts.controlAutonomyLoss)) is very high - Silence ending will trigger too easily")
        }

        // Validate ending thresholds don't conflict
        if EndingThresholds.fragmentationEfficiencyRatio < EndingThresholds.optimizationCombinedRatio {
            warnings.append("⚠️ Fragmentation threshold lower than Optimization - may cause conflicts")
        }

        // Validate moment counts are achievable
        if ActProgression.actOneMomentMinimum * 4 > Gameplay.targetMomentLibrarySize {
            warnings.append("⚠️ Act moment requirements exceed target library size")
        }

        return warnings
    }
}
