//
//  DialogueManager.swift
//  idle_01
//
//  Created: 2025-10-14
//  Purpose: Manages loading and retrieval of dialogue from JSON files
//

import Foundation

/// Actor responsible for loading and managing all dialogue content
actor DialogueManager {

    // MARK: - Properties

    /// In-memory library of all loaded dialogue fragments, organized by speaker
    private var dialogueLibrary: [DialogueSpeaker: [DialogueFragment]] = [:]

    /// Alternate terminology for each speaker (e.g., "mobility pulse" for transit)
    private var alternateTerminology: [DialogueSpeaker: [String]] = [:]

    /// Whether the dialogue library has been loaded
    private var isLoaded = false

    // MARK: - Initialization

    init() {
        // Dialogue will be loaded on first access
    }

    // MARK: - Loading

    /// Load all dialogue JSON files from the app bundle
    func loadDialogueLibrary() {
        guard !isLoaded else { return }

        let dialogueFiles = [
            "city_core",
            "transit",
            "housing",
            "culture",
            "commerce",
            "parks",
            "water",
            "power",
            "sewage",
            "knowledge"
        ]

        for filename in dialogueFiles {
            loadDialogueFile(named: filename)
        }

        isLoaded = true
        print("DialogueManager: Loaded \(dialogueLibrary.keys.count) dialogue libraries")
    }

    /// Load a single dialogue JSON file
    private func loadDialogueFile(named filename: String) {
        // Try multiple possible locations for the JSON file
        var url: URL?

        // First try: in dialogue subdirectory
        url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "dialogue")

        // Second try: in progression/data/dialogue subdirectory
        if url == nil {
            url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "progression/data/dialogue")
        }

        // Third try: in data/dialogue subdirectory
        if url == nil {
            url = Bundle.main.url(forResource: filename, withExtension: "json", subdirectory: "data/dialogue")
        }

        // Fourth try: no subdirectory
        if url == nil {
            url = Bundle.main.url(forResource: filename, withExtension: "json")
        }

        guard let fileURL = url else {
            print("DialogueManager: Warning - Could not find dialogue file: \(filename).json in any location")
            print("DialogueManager: Searched: dialogue/, progression/data/dialogue/, data/dialogue/, root")
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let library = try decoder.decode(DialogueLibraryFile.self, from: data)

            // Store dialogue fragments
            dialogueLibrary[library.speaker] = library.dialogueFragments

            // Store alternate terminology if provided
            if let terminology = library.alternateTerminology {
                alternateTerminology[library.speaker] = terminology
            }

            print("DialogueManager: ✅ Loaded \(library.dialogueFragments.count) fragments for \(library.speaker.rawValue)")

        } catch {
            print("DialogueManager: ❌ Error loading \(filename).json - \(error.localizedDescription)")
        }
    }

    // MARK: - Retrieval

    /// Get a random dialogue line for a speaker in a specific context
    /// - Parameters:
    ///   - speaker: The character speaking
    ///   - context: The context for the dialogue
    ///   - tags: Optional tags to filter fragments (matches ANY tag)
    /// - Returns: A random dialogue fragment, or nil if none found
    func getDialogue(
        speaker: DialogueSpeaker,
        context: DialogueContext,
        tags: [String] = []
    ) async -> String? {
        // Ensure library is loaded
        if !isLoaded {
            loadDialogueLibrary()
        }

        guard let fragments = dialogueLibrary[speaker] else {
            print("DialogueManager: No dialogue found for speaker: \(speaker.rawValue)")
            return nil
        }

        // Filter by context
        let contextMatches = fragments.filter { $0.context == context }

        // Further filter by tags if provided
        let matches: [DialogueFragment]
        if tags.isEmpty {
            matches = contextMatches
        } else {
            matches = contextMatches.filter { fragment in
                !Set(fragment.tags).isDisjoint(with: Set(tags))
            }
        }

        // Pick a random fragment that matches
        guard let chosen = matches.randomElement() else {
            print("DialogueManager: No dialogue found for \(speaker.rawValue) in context \(context.rawValue) with tags \(tags)")
            return nil
        }

        // Pick a random variation from the fragment
        return chosen.fragments.randomElement()
    }

    /// Get a random alternate terminology for a speaker
    /// For example, "transit" might return "mobility pulse" or "movement pathway"
    func getAlternateTerminology(for speaker: DialogueSpeaker) async -> String? {
        // Ensure library is loaded
        if !isLoaded {
            loadDialogueLibrary()
        }

        return alternateTerminology[speaker]?.randomElement()
    }

    /// Get a dialogue line for a thread type
    func getDialogue(
        threadType: ThreadType,
        context: DialogueContext,
        tags: [String] = []
    ) async -> String? {
        guard let speaker = DialogueSpeaker(threadType: threadType) else {
            print("DialogueManager: Cannot convert ThreadType \(threadType.rawValue) to DialogueSpeaker")
            return nil
        }

        return await getDialogue(speaker: speaker, context: context, tags: tags)
    }

    /// Get all dialogue fragments for a speaker (useful for debugging)
    func getAllFragments(for speaker: DialogueSpeaker) async -> [DialogueFragment] {
        if !isLoaded {
            loadDialogueLibrary()
        }

        return dialogueLibrary[speaker] ?? []
    }

    /// Get all available contexts for a speaker
    func getAvailableContexts(for speaker: DialogueSpeaker) async -> [DialogueContext] {
        if !isLoaded {
            loadDialogueLibrary()
        }

        guard let fragments = dialogueLibrary[speaker] else { return [] }

        return Array(Set(fragments.map { $0.context }))
    }

    // MARK: - Validation

    /// Validate that all dialogue files are loaded and parseable
    /// Returns errors if any files are missing or malformed
    func validateDialogue() async -> [String] {
        var errors: [String] = []

        let expectedSpeakers: [DialogueSpeaker] = [
            .city, .transit, .housing, .culture, .commerce,
            .parks, .water, .power, .sewage, .knowledge
        ]

        for speaker in expectedSpeakers {
            if dialogueLibrary[speaker] == nil {
                errors.append("Missing dialogue for speaker: \(speaker.rawValue)")
            } else if let fragments = dialogueLibrary[speaker], fragments.isEmpty {
                errors.append("Empty dialogue library for speaker: \(speaker.rawValue)")
            }
        }

        return errors
    }
}
