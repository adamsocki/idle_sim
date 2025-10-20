//
//  idle_01App.swift
//  idle_01
//
//  Created by Adam Socki on 9/29/25.
//

import SwiftUI
import SwiftData

@main
struct idle_01App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            City.self,
            UserPreferences.self,
            UrbanThread.self,
            EmergentProperty.self,
            GameState.self,
            CityMoment.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Seed moments on first launch
            let context = container.mainContext
            MomentSeeder.seedIfNeeded(modelContext: context)

            // Initialize or fetch GameState
            let descriptor = FetchDescriptor<GameState>()
            let existingStates = try? context.fetch(descriptor)

            if existingStates?.isEmpty != false {
                // Create initial game state if none exists
                let gameState = GameState()
                context.insert(gameState)
                try? context.save()
                print("✅ Initial GameState created")
            } else {
                print("✅ GameState loaded")
            }

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
            .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
