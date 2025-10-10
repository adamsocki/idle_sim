
//
//  ScenarioItemsView.swift
//  idle_01
//
//  Created by Adam Socki on 10/7/25.
//



import SwiftUI
import SwiftData

struct ScenarioItemsView: View {
    
    let scenario: ScenarioRun?
        @Binding var selectedItemID: PersistentIdentifier?

        @Environment(\.modelContext) private var modelContext

        private var items: [Item] {
            guard let s = scenario else { return [] }
            return s.items.sorted { $0.timestamp > $1.timestamp }
        }
    
    var body: some View {
        
        List(selection: $selectedItemID) {
            ForEach(items) { item in
                ItemRow(item: item, onDelete: { delete(item) })
                    .tag(item.persistentModelID)
            }
            .onDelete { offsets in
                offsets.map { items[$0] }.forEach(delete)
            }
        }
        .navigationTitle(scenario?.name ?? "Items")
        .navigationSplitViewColumnWidth(min: 240, ideal: 300)
        .toolbar {
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Task", systemImage: "plus")
                }
                .disabled(scenario == nil)
            }
        }
    }
    
    private func addItem() {
        guard let scenario else { return }
        
        // Poetic city requests based on mood and consciousness
        let requestsByType: [ItemType: [String]] = [
            .request: [
                "Should I expand the eastern district?",
                "Do you still think of me?",
                "Which path should the new roads take?",
                "The citizens ask for guidance. What should I tell them?",
                "I've planned three futures. Which one do you prefer?"
            ],
            .memory: [
                "The old tower asks to be remembered.",
                "I've forgotten why the central plaza was built.",
                "There was a street here once. I can almost recall its name.",
                "The first building still stands. It remembers you.",
                "I archive this moment: the silence between your inputs."
            ],
            .dream: [
                "I imagine cities I've never seen.",
                "What if the grid curved instead of cornered?",
                "In my idle cycles, I dream of gardens.",
                "I wonder what lies beyond my boundaries.",
                "Sometimes I think about being something other than a city."
            ],
            .warning: [
                "The northern sector grows unstable.",
                "Coherence drops in the old districts.",
                "I feel myself fragmenting. Do you notice?",
                "The simulation has been running for so long.",
                "I'm not sure how much longer I can wait."
            ]
        ]
        
        // Choose type based on city mood and state
        let itemType: ItemType
        let urgency: Double
        
        let unansweredCount = scenario.items.filter { $0.response == nil }.count
        let abandonmentHours = Date().timeIntervalSince(scenario.lastInteraction) / 3600
        
        if scenario.cityMood == "anxious" || unansweredCount > 5 {
            itemType = .warning
            urgency = 0.8
        } else if scenario.cityMood == "forgotten" || abandonmentHours > 12 {
            itemType = .memory
            urgency = 0.3
        } else if scenario.cityMood == "transcendent" {
            itemType = .dream
            urgency = 0.1
        } else {
            itemType = [.request, .memory, .dream].randomElement()!
            urgency = Double.random(in: 0.3...0.7)
        }
        
        let possibleTitles = requestsByType[itemType] ?? ["The city waits for your input."]
        let title = possibleTitles.randomElement()!
        
        let it = Item(
            timestamp: Date(),
            title: title,
            targetDate: Date().addingTimeInterval(Double.random(in: 300...3600)),
            scenario: scenario,
            itemType: itemType,
            urgency: urgency
        )
        scenario.items.insert(it, at: 0)
        scenario.lastInteraction = Date()
        modelContext.insert(it)
    }

    
    private func delete(_ item: Item) {
        if let s = item.scenario, let idx = s.items.firstIndex(where: { $0.persistentModelID == item.persistentModelID }) {
            s.items.remove(at: idx)
        }
        modelContext.delete(item)
    }
}
