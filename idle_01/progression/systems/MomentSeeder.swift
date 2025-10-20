//
//  MomentSeeder.swift
//  idle_01
//
//  Loads moment library from JSON into SwiftData
//

import Foundation
import SwiftData

/// Handles loading moment library from JSON and seeding into SwiftData
@MainActor
final class MomentSeeder {

    // MARK: - Properties

    private let modelContext: ModelContext
    private let jsonFileName: String

    // MARK: - Initialization

    init(modelContext: ModelContext, jsonFileName: String = "MomentLibrary") {
        self.modelContext = modelContext
        self.jsonFileName = jsonFileName
    }

    // MARK: - Seeding

    /// Loads moments from JSON and inserts them into SwiftData
    /// Returns the number of moments successfully loaded
    @discardableResult
    func seed() throws -> Int {
        // Check if moments already exist
        let descriptor = FetchDescriptor<CityMoment>()
        let existingMoments = try modelContext.fetch(descriptor)

        if !existingMoments.isEmpty {
            print("⚠️ Moments already exist in database (\(existingMoments.count) moments)")
            print("   Skipping seed. Use reseed() to force reload.")
            return existingMoments.count
        }

        // Load from JSON
        let moments = try loadMomentsFromJSON()

        // Insert into SwiftData
        for moment in moments {
            modelContext.insert(moment)
        }

        // Save context
        try modelContext.save()

        print("✅ Seeded \(moments.count) moments from \(jsonFileName).json")
        return moments.count
    }

    /// Force reseeds by deleting existing moments and reloading from JSON
    /// WARNING: This will delete all existing moment state (revealed, destroyed, etc.)
    @discardableResult
    func reseed() throws -> Int {
        // Delete all existing moments
        let descriptor = FetchDescriptor<CityMoment>()
        let existingMoments = try modelContext.fetch(descriptor)

        for moment in existingMoments {
            modelContext.delete(moment)
        }

        try modelContext.save()
        print("🗑️ Deleted \(existingMoments.count) existing moments")

        // Seed fresh
        return try seed()
    }

    /// Updates existing moments from JSON without deleting (preserves state)
    /// Useful for updating text content without resetting game state
    func updateFromJSON() throws -> Int {
        // Load moments from JSON
        let jsonMoments = try loadMomentsFromJSON()

        // Fetch existing moments
        let descriptor = FetchDescriptor<CityMoment>()
        let existingMoments = try modelContext.fetch(descriptor)

        // Create lookup dictionary
        let existingLookup = Dictionary(uniqueKeysWithValues: existingMoments.map { ($0.momentID, $0) })

        var updatedCount = 0
        var newCount = 0

        for jsonMoment in jsonMoments {
            if let existing = existingLookup[jsonMoment.momentID] {
                // Update text fields only (preserve state)
                existing.text = jsonMoment.text
                existing.firstMention = jsonMoment.firstMention
                existing.ifPreserved = jsonMoment.ifPreserved
                existing.ifDestroyed = jsonMoment.ifDestroyed
                existing.ifRemembered = jsonMoment.ifRemembered
                existing.tags = jsonMoment.tags
                existing.authorNotes = jsonMoment.authorNotes

                // Update metadata
                existing.type = jsonMoment.type
                existing.district = jsonMoment.district
                existing.fragility = jsonMoment.fragility
                existing.associatedAct = jsonMoment.associatedAct

                updatedCount += 1
            } else {
                // New moment - insert
                modelContext.insert(jsonMoment)
                newCount += 1
            }
        }

        try modelContext.save()

        print("✅ Updated \(updatedCount) moments, added \(newCount) new moments")
        return updatedCount + newCount
    }

    // MARK: - JSON Loading

    /// Loads moment library from JSON file
    private func loadMomentsFromJSON() throws -> [CityMoment] {
        // Find JSON file in bundle
        guard let url = Bundle.main.url(forResource: jsonFileName, withExtension: "json") else {
            throw MomentSeederError.fileNotFound(jsonFileName)
        }

        // Load data
        let data = try Data(contentsOf: url)

        // Decode
        let decoder = JSONDecoder()
        let library = try decoder.decode(MomentLibrary.self, from: data)

        // Convert to models
        let moments = library.toModels()

        // Validate
        guard !moments.isEmpty else {
            throw MomentSeederError.noMomentsInFile(jsonFileName)
        }

        // Log library info
        if let version = library.version {
            print("📚 Loaded moment library version \(version)")
        }
        if let description = library.description {
            print("   \(description)")
        }

        return moments
    }

    // MARK: - Diagnostics

    /// Returns statistics about the loaded moment library
    func getLibraryStats() throws -> MomentLibraryStats {
        let descriptor = FetchDescriptor<CityMoment>()
        let moments = try modelContext.fetch(descriptor)

        var typeCounts: [MomentType: Int] = [:]
        var actCounts: [Int: Int] = [:]
        var districtCounts: [Int: Int] = [:]
        var fragilitySum = 0

        for moment in moments {
            typeCounts[moment.type, default: 0] += 1
            actCounts[moment.associatedAct, default: 0] += 1
            districtCounts[moment.district, default: 0] += 1
            fragilitySum += moment.fragility
        }

        let avgFragility = moments.isEmpty ? 0.0 : Double(fragilitySum) / Double(moments.count)

        return MomentLibraryStats(
            totalMoments: moments.count,
            typeCounts: typeCounts,
            actCounts: actCounts,
            districtCounts: districtCounts,
            averageFragility: avgFragility,
            revealedCount: moments.filter({ $0.hasBeenRevealed }).count,
            destroyedCount: moments.filter({ $0.isDestroyed }).count,
            rememberedCount: moments.filter({ $0.isRemembered }).count
        )
    }

    /// Prints a diagnostic report of the moment library
    func printDiagnostics() throws {
        let stats = try getLibraryStats()
        print(stats.formattedReport())
    }
}

// MARK: - Errors

enum MomentSeederError: LocalizedError {
    case fileNotFound(String)
    case noMomentsInFile(String)
    case invalidJSON(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "Could not find \(filename).json in bundle"
        case .noMomentsInFile(let filename):
            return "No valid moments found in \(filename).json"
        case .invalidJSON(let details):
            return "Invalid JSON format: \(details)"
        }
    }
}

// MARK: - Statistics

struct MomentLibraryStats {
    let totalMoments: Int
    let typeCounts: [MomentType: Int]
    let actCounts: [Int: Int]
    let districtCounts: [Int: Int]
    let averageFragility: Double
    let revealedCount: Int
    let destroyedCount: Int
    let rememberedCount: Int

    func formattedReport() -> String {
        var report = """

        === MOMENT LIBRARY STATISTICS ===

        Total Moments: \(totalMoments)
        Average Fragility: \(String(format: "%.1f", averageFragility))/10

        STATE:
        - Revealed: \(revealedCount)
        - Destroyed: \(destroyedCount)
        - Remembered: \(rememberedCount)

        BY TYPE:
        """

        let sortedTypes = typeCounts.sorted { $0.value > $1.value }
        for (type, count) in sortedTypes {
            let percentage = totalMoments > 0 ? Double(count) / Double(totalMoments) * 100 : 0
            report += "\n- \(type.description): \(count) (\(String(format: "%.1f", percentage))%)"
        }

        report += "\n\nBY ACT:"
        let sortedActs = actCounts.sorted { $0.key < $1.key }
        for (act, count) in sortedActs {
            report += "\n- Act \(act): \(count) moments"
        }

        report += "\n\nBY DISTRICT:"
        let sortedDistricts = districtCounts.sorted { $0.key < $1.key }
        for (district, count) in sortedDistricts {
            let districtName = district == 0 ? "City-wide" : "District \(district)"
            report += "\n- \(districtName): \(count) moments"
        }

        // Validation warnings
        var warnings: [String] = []

        if totalMoments < GameBalanceConfig.Gameplay.targetMomentLibrarySize {
            warnings.append("⚠️ Library has \(totalMoments) moments, target is \(GameBalanceConfig.Gameplay.targetMomentLibrarySize)")
        }

        // Check minimum moments per district
        for (district, count) in districtCounts where district > 0 {
            if count < GameBalanceConfig.Gameplay.minMomentsPerDistrict {
                warnings.append("⚠️ District \(district) has only \(count) moments (target: \(GameBalanceConfig.Gameplay.minMomentsPerDistrict))")
            }
        }

        // Check act distribution
        for act in 1...4 {
            if (actCounts[act] ?? 0) == 0 {
                warnings.append("⚠️ Act \(act) has no moments")
            }
        }

        if !warnings.isEmpty {
            report += "\n\nVALIDATION WARNINGS:"
            for warning in warnings {
                report += "\n\(warning)"
            }
        }

        report += "\n================================\n"

        return report
    }
}

// MARK: - Helper Extensions

extension MomentSeeder {
    /// Convenience method to seed moments at app startup
    static func seedIfNeeded(modelContext: ModelContext) {
        do {
            let seeder = MomentSeeder(modelContext: modelContext)
            try seeder.seed()
        } catch {
            print("❌ Failed to seed moments: \(error.localizedDescription)")
        }
    }

    /// Convenience method to print diagnostics
    static func printDiagnostics(modelContext: ModelContext) {
        do {
            let seeder = MomentSeeder(modelContext: modelContext)
            try seeder.printDiagnostics()
        } catch {
            print("❌ Failed to get diagnostics: \(error.localizedDescription)")
        }
    }
}
