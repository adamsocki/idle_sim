//
//  MomentSelector.swift
//  idle_01
//
//  Intelligent procedural selection of moments based on player patterns
//  Ensures narrative feels responsive to choices while maintaining variety
//

import Foundation
import SwiftData

/// Handles procedural selection of moments with weighted randomization
@MainActor
final class MomentSelector {

    // MARK: - Properties

    private let modelContext: ModelContext

    // Track recently shown moment types to enforce variety
    private var recentlyShownTypes: [MomentType] = []

    // MARK: - Initialization

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Primary Selection Method

    /// Selects a moment procedurally based on context and player patterns
    /// Returns nil if no suitable moments are available
    func selectMoment(
        forAct act: Int,
        preferredType: MomentType? = nil,
        preferredDistrict: Int? = nil,
        choicePattern: ChoicePattern? = nil,
        excludeIDs: [String] = [],
        enforceVariety: Bool = true
    ) -> CityMoment? {

        // 1. Get all available moments
        var candidates = getAllAvailableMoments(
            forAct: act,
            excludeIDs: excludeIDs
        )

        guard !candidates.isEmpty else { return nil }

        // 2. Apply type filter if specified
        if let type = preferredType {
            let typed = candidates.filter { $0.type == type }
            if !typed.isEmpty {
                candidates = typed
            }
        }

        // 3. Apply district filter if specified
        if let district = preferredDistrict {
            let districted = candidates.filter { $0.district == district || $0.district == 0 }
            if !districted.isEmpty {
                candidates = districted
            }
        }

        // 4. Calculate weights for each candidate
        let weightedCandidates = candidates.map { moment -> (moment: CityMoment, weight: Double) in
            var weight = GameBalanceConfig.MomentWeights.baseWeight

            // Apply choice pattern affinity
            if let pattern = choicePattern {
                weight *= moment.selectionWeight(givenPattern: pattern)
            }

            // Reduce weight if this type was shown recently (enforce variety)
            if enforceVariety && wasShownRecently(type: moment.type) {
                weight *= GameBalanceConfig.MomentWeights.recentTypeWeightReduction
            }

            // Boost fragile moments if player is making efficiency choices
            if choicePattern == .efficiency && moment.fragility >= GameBalanceConfig.MomentFragility.highFragilityThreshold {
                weight *= GameBalanceConfig.MomentWeights.fragileMomentMultiplier
            }

            return (moment, weight)
        }

        // 5. Perform weighted random selection
        guard let selected = weightedRandomSelection(from: weightedCandidates) else {
            return nil
        }

        // 6. Track this moment type for variety enforcement
        trackShownType(selected.type)

        return selected
    }

    // MARK: - Specialized Selection Methods

    /// Selects a fragile moment (likely to be destroyed by efficiency choices)
    func selectFragileMoment(
        forAct act: Int,
        threshold: Int = 7,
        excludeIDs: [String] = []
    ) -> CityMoment? {

        let descriptor = FetchDescriptor<CityMoment>(
            predicate: #Predicate { moment in
                moment.associatedAct <= act &&
                !moment.hasBeenRevealed &&
                !moment.isDestroyed &&
                moment.fragility >= threshold
            }
        )

        guard let moments = try? modelContext.fetch(descriptor) else { return nil }

        let available = moments.filter { !excludeIDs.contains($0.momentID) }
        return available.randomElement()
    }

    /// Selects moments for a specific district
    func selectMomentForDistrict(
        _ district: Int,
        act: Int,
        excludeIDs: [String] = []
    ) -> CityMoment? {

        return selectMoment(
            forAct: act,
            preferredDistrict: district,
            excludeIDs: excludeIDs
        )
    }

    /// Selects a specific moment type (bypasses variety enforcement)
    func selectMomentOfType(
        _ type: MomentType,
        act: Int,
        excludeIDs: [String] = []
    ) -> CityMoment? {

        return selectMoment(
            forAct: act,
            preferredType: type,
            excludeIDs: excludeIDs,
            enforceVariety: false
        )
    }

    /// Selects multiple moments at once (for batch reveals)
    func selectMoments(
        count: Int,
        forAct act: Int,
        choicePattern: ChoicePattern? = nil,
        excludeIDs: [String] = []
    ) -> [CityMoment] {

        var selected: [CityMoment] = []
        var currentExclusions = excludeIDs

        for _ in 0..<count {
            if let moment = selectMoment(
                forAct: act,
                choicePattern: choicePattern,
                excludeIDs: currentExclusions
            ) {
                selected.append(moment)
                currentExclusions.append(moment.momentID)
            }
        }

        return selected
    }

    // MARK: - Query Methods

    /// Gets all moments available for the given act
    func getAllAvailableMoments(
        forAct act: Int,
        excludeIDs: [String] = []
    ) -> [CityMoment] {

        let descriptor = FetchDescriptor<CityMoment>(
            predicate: #Predicate { moment in
                moment.associatedAct <= act &&
                !moment.hasBeenRevealed &&
                !moment.isDestroyed
            }
        )

        guard let moments = try? modelContext.fetch(descriptor) else { return [] }

        return moments.filter { !excludeIDs.contains($0.momentID) }
    }

    /// Gets moments that have been revealed but not destroyed
    func getPreservedMoments() -> [CityMoment] {
        let descriptor = FetchDescriptor<CityMoment>(
            predicate: #Predicate { moment in
                moment.hasBeenRevealed && !moment.isDestroyed
            }
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// Gets moments that have been destroyed
    func getDestroyedMoments() -> [CityMoment] {
        let descriptor = FetchDescriptor<CityMoment>(
            predicate: #Predicate { moment in
                moment.isDestroyed
            }
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// Gets moments that have been remembered
    func getRememberedMoments() -> [CityMoment] {
        let descriptor = FetchDescriptor<CityMoment>(
            predicate: #Predicate { moment in
                moment.isRemembered
            }
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// Gets moments by type
    func getMoments(ofType type: MomentType, act: Int) -> [CityMoment] {
        let descriptor = FetchDescriptor<CityMoment>(
            predicate: #Predicate { moment in
                moment.associatedAct <= act &&
                moment.type == type &&
                !moment.hasBeenRevealed
            }
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// Gets moments by district
    func getMoments(inDistrict district: Int, act: Int) -> [CityMoment] {
        let descriptor = FetchDescriptor<CityMoment>(
            predicate: #Predicate { moment in
                moment.associatedAct <= act &&
                (moment.district == district || moment.district == 0) &&
                !moment.hasBeenRevealed
            }
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// Gets moments by tag
    func getMoments(withTag tag: String, act: Int) -> [CityMoment] {
        let descriptor = FetchDescriptor<CityMoment>(
            predicate: #Predicate { moment in
                moment.associatedAct <= act &&
                !moment.hasBeenRevealed
            }
        )

        guard let moments = try? modelContext.fetch(descriptor) else { return [] }

        return moments.filter { $0.tags.contains(tag) }
    }

    // MARK: - Weighted Selection Algorithm

    /// Performs weighted random selection from candidates
    private func weightedRandomSelection(
        from candidates: [(moment: CityMoment, weight: Double)]
    ) -> CityMoment? {

        guard !candidates.isEmpty else { return nil }

        // Calculate total weight
        let totalWeight = candidates.reduce(0.0) { $0 + $1.weight }

        guard totalWeight > 0 else {
            // If all weights are 0, fall back to uniform random
            return candidates.randomElement()?.moment
        }

        // Generate random value in range [0, totalWeight)
        let randomValue = Double.random(in: 0..<totalWeight)

        // Select based on cumulative weight
        var cumulativeWeight = 0.0
        for (moment, weight) in candidates {
            cumulativeWeight += weight
            if randomValue < cumulativeWeight {
                return moment
            }
        }

        // Fallback (shouldn't reach here, but safety)
        return candidates.last?.moment
    }

    // MARK: - Variety Enforcement

    /// Tracks a moment type as recently shown
    private func trackShownType(_ type: MomentType) {
        recentlyShownTypes.append(type)

        // Keep only recent history
        let maxHistory = GameBalanceConfig.MomentWeights.recentMomentCheckCount
        if recentlyShownTypes.count > maxHistory {
            recentlyShownTypes.removeFirst()
        }
    }

    /// Checks if a moment type was shown recently
    private func wasShownRecently(type: MomentType) -> Bool {
        return recentlyShownTypes.contains(type)
    }

    /// Resets the variety tracker (use when starting new act)
    func resetVarietyTracker() {
        recentlyShownTypes.removeAll()
    }

    // MARK: - Statistics

    /// Returns statistics about moment availability
    func getSelectionStats(forAct act: Int) -> MomentSelectionStats {
        let available = getAllAvailableMoments(forAct: act)

        var typeDistribution: [MomentType: Int] = [:]
        var districtDistribution: [Int: Int] = [:]
        var fragilitySum = 0

        for moment in available {
            typeDistribution[moment.type, default: 0] += 1
            districtDistribution[moment.district, default: 0] += 1
            fragilitySum += moment.fragility
        }

        let avgFragility = available.isEmpty ? 0.0 : Double(fragilitySum) / Double(available.count)

        return MomentSelectionStats(
            availableCount: available.count,
            typeDistribution: typeDistribution,
            districtDistribution: districtDistribution,
            averageFragility: avgFragility,
            recentlyShownTypes: recentlyShownTypes
        )
    }

    // MARK: - Moment Destruction Logic

    /// Attempts to destroy a moment based on its fragility
    /// Returns true if moment was destroyed
    @discardableResult
    func attemptDestruction(of moment: CityMoment) -> Bool {
        let probability = moment.destructionProbability()
        let roll = Double.random(in: 0..<1.0)

        if roll < probability {
            moment.destroy()
            return true
        }

        return false
    }

    /// Destroys fragile moments based on efficiency choice count
    /// Returns array of destroyed moment IDs
    func applyEfficiencyConsequences(
        gameState: GameState,
        count: Int = 1
    ) -> [String] {

        var destroyed: [String] = []

        // Get fragile moments that haven't been destroyed yet
        let fragileMoments = getPreservedMoments().filter {
            $0.fragility >= GameBalanceConfig.MomentFragility.moderateFragilityThreshold
        }

        // Sort by fragility (most fragile first)
        let sortedByFragility = fragileMoments.sorted { $0.fragility > $1.fragility }

        // Attempt destruction on most fragile moments
        for moment in sortedByFragility.prefix(count) {
            if attemptDestruction(of: moment) {
                destroyed.append(moment.momentID)
                gameState.destroyMoment(moment.momentID)
            }
        }

        return destroyed
    }
}

// MARK: - Statistics Structure

struct MomentSelectionStats {
    let availableCount: Int
    let typeDistribution: [MomentType: Int]
    let districtDistribution: [Int: Int]
    let averageFragility: Double
    let recentlyShownTypes: [MomentType]

    func formattedReport() -> String {
        var report = """

        === MOMENT SELECTION STATISTICS ===

        Available Moments: \(availableCount)
        Average Fragility: \(String(format: "%.1f", averageFragility))/10

        BY TYPE:
        """

        let sortedTypes = typeDistribution.sorted { $0.value > $1.value }
        for (type, count) in sortedTypes {
            report += "\n- \(type.description): \(count)"
        }

        report += "\n\nBY DISTRICT:"
        let sortedDistricts = districtDistribution.sorted { $0.key < $1.key }
        for (district, count) in sortedDistricts {
            let name = district == 0 ? "City-wide" : "District \(district)"
            report += "\n- \(name): \(count)"
        }

        if !recentlyShownTypes.isEmpty {
            report += "\n\nRECENTLY SHOWN TYPES:"
            for type in recentlyShownTypes.reversed() {
                report += "\n- \(type.description)"
            }
        }

        report += "\n===================================\n"

        return report
    }
}

// MARK: - Helper Extensions

extension MomentSelector {

    /// Debug method to print current selection stats
    func printStats(forAct act: Int) {
        let stats = getSelectionStats(forAct: act)
        print(stats.formattedReport())
    }

    /// Resets all moments to unrevealed state (for testing)
    func resetAllMoments() {
        let descriptor = FetchDescriptor<CityMoment>()
        guard let moments = try? modelContext.fetch(descriptor) else { return }

        for moment in moments {
            moment.hasBeenRevealed = false
            moment.isDestroyed = false
            moment.isRemembered = false
            moment.revealedAt = nil
        }

        try? modelContext.save()
        resetVarietyTracker()

        print("✅ Reset \(moments.count) moments to unrevealed state")
    }
}
