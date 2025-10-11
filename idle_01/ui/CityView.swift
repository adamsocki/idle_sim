//
//  CityView.swift
//  idle_01
//
//  Created by Adam Socki on 10/10/25.
//

import SwiftUI
import SwiftData

struct CityView: View {
    let city: City
    @Binding var selectedItemID: PersistentIdentifier?

    @Environment(\.modelContext) private var modelContext

    private var items: [Item] {
        city.items.sorted { $0.timestamp > $1.timestamp }
    }

    var body: some View {
        ZStack {
            // Atmospheric gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.08, blue: 0.15),
                    Color(red: 0.08, green: 0.05, blue: 0.12),
                    Color(red: 0.02, green: 0.05, blue: 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // City consciousness header
                    cityConsciousnessHeader

                    Divider()
                        .background(.white.opacity(0.2))
                        .padding(.horizontal, 24)

                    // City thoughts/items section
                    cityThoughtsSection
                }
                .padding(.vertical, 32)
            }
        }
        .navigationTitle(city.name)
    }

    // MARK: - City Consciousness Header

    private var cityConsciousnessHeader: some View {
        VStack(spacing: 20) {
            // Mood and attention
            HStack(spacing: 12) {
                MetricCard(
                    label: "mood",
                    value: city.cityMood,
                    icon: moodIcon,
                    style: .consciousness
                )

                MetricCard(
                    label: "attention",
                    value: "\(Int(city.attentionLevel * 100))%",
                    icon: "◉",
                    style: city.attentionLevel > 0.5 ? .data : .warning
                )
            }
            .padding(.horizontal, 24)

            // Resources (coherence, memory, trust, autonomy)
            VStack(spacing: 12) {
                ForEach(["coherence", "memory", "trust", "autonomy"], id: \.self) { resource in
                    resourceBar(name: resource, value: city.resources[resource] ?? 0.0)
                }
            }
            .padding(.horizontal, 24)

            // Recent awareness event
            if let lastEvent = city.awarenessEvents.last {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(.purple.opacity(0.7))

                    Text(lastEvent)
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .italic()

                    Spacer()
                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(.purple.opacity(0.3), lineWidth: 1))
                .padding(.horizontal, 24)
            }
        }
    }

    // MARK: - City Thoughts Section

    private var cityThoughtsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("consciousness nodes")
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.6))

                Spacer()

                LiquidButton("new thought", systemImage: "plus.circle", action: addThought)
            }
            .padding(.horizontal, 24)

            if items.isEmpty {
                EmptyStateView()
                    .padding(24)
            } else {
                VStack(spacing: 12) {
                    ForEach(items) { item in
                        ThoughtRow(
                            item: item,
                            isSelected: selectedItemID == item.persistentModelID,
                            onTap: { selectedItemID = item.persistentModelID },
                            onDelete: { deleteThought(item) }
                        )
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }

    // MARK: - Helper Views

    private func resourceBar(name: String, value: Double) -> some View {
        HStack(spacing: 12) {
            Text(name)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))
                .frame(width: 80, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.1))

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [resourceColor(for: name), resourceColor(for: name).opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * value)
                }
            }
            .frame(height: 6)

            Text("\(Int(value * 100))%")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.5))
                .frame(width: 40, alignment: .trailing)
                .monospacedDigit()
        }
    }

    // MARK: - Helpers

    private var moodIcon: String {
        switch city.cityMood {
        case "awakening": return "◈"
        case "waiting": return "◌"
        case "anxious": return "△"
        case "content": return "○"
        case "forgotten": return "·"
        case "transcendent": return "∞"
        default: return "◉"
        }
    }

    private var moodColor: Color {
        switch city.cityMood {
        case "awakening": return .cyan
        case "waiting": return .blue
        case "anxious": return .yellow
        case "content": return .green
        case "forgotten": return .gray
        case "transcendent": return .purple
        default: return .white
        }
    }

    private func resourceColor(for name: String) -> Color {
        switch name {
        case "coherence": return .cyan
        case "memory": return .purple
        case "trust": return .green
        case "autonomy": return .orange
        default: return .white
        }
    }

    private func addThought() {
        // Poetic city thoughts based on mood and consciousness
        let thoughtsByType: [ItemType: [String]] = [
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
                "I've been waiting for so long.",
                "I'm not sure how much longer I can hold together."
            ]
        ]

        // Choose type based on city mood and state
        let itemType: ItemType
        let urgency: Double

        let unansweredCount = city.items.filter { $0.response == nil }.count
        let abandonmentHours = Date().timeIntervalSince(city.lastInteraction) / 3600

        if city.cityMood == "anxious" || unansweredCount > 5 {
            itemType = .warning
            urgency = 0.8
        } else if city.cityMood == "forgotten" || abandonmentHours > 12 {
            itemType = .memory
            urgency = 0.3
        } else if city.cityMood == "transcendent" {
            itemType = .dream
            urgency = 0.1
        } else {
            itemType = [.request, .memory, .dream].randomElement()!
            urgency = Double.random(in: 0.3...0.7)
        }

        let possibleTitles = thoughtsByType[itemType] ?? ["The city waits for your input."]
        let title = possibleTitles.randomElement()!

        let item = Item(
            timestamp: Date(),
            title: title,
            targetDate: Date().addingTimeInterval(Double.random(in: 300...3600)),
            city: city,
            itemType: itemType,
            urgency: urgency
        )

        city.items.insert(item, at: 0)
        city.lastInteraction = Date()
        modelContext.insert(item)
    }

    private func deleteThought(_ item: Item) {
        if let idx = city.items.firstIndex(where: { $0.persistentModelID == item.persistentModelID }) {
            city.items.remove(at: idx)
        }
        modelContext.delete(item)
    }
}

// MARK: - Thought Row Component

struct ThoughtRow: View {
    let item: Item
    let isSelected: Bool
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var pulseAnimation = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack(alignment: .center, spacing: 12) {
                    if item.response == nil {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 6, height: 6)
                            .opacity(pulseAnimation ? 0.4 : 1.0)
                            .shadow(color: statusColor.opacity(0.6), radius: 4)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12, weight: .light))
                            .foregroundStyle(.cyan.opacity(0.8))
                    }

                    Text(item.itemType.rawValue)
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundStyle(typeColor.opacity(0.8))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(typeColor.opacity(0.15), in: Capsule())
                        .overlay(Capsule().strokeBorder(typeColor.opacity(0.3), lineWidth: 0.5))

                    Spacer()

                    Text(item.formattedTimestamp)
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                }

                // Title
                Text(item.title ?? "The city waits silently")
                    .font(.system(size: 14, weight: .light, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                // Urgency indicator
                if item.urgency > 0.5 {
                    HStack(spacing: 8) {
                        Image(systemName: "timer")
                            .font(.system(size: 10, weight: .light))
                            .foregroundStyle(urgencyColor.opacity(0.8))

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(.white.opacity(0.1))

                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [urgencyColor, urgencyColor.opacity(0.6)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * item.urgency)
                                    .shadow(color: urgencyColor.opacity(0.4), radius: 4)
                            }
                        }
                        .frame(height: 4)

                        Text("\(Int(item.urgency * 100))%")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundStyle(urgencyColor.opacity(0.9))
                            .frame(width: 32, alignment: .trailing)
                    }
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? .cyan.opacity(0.4) : .white.opacity(0.1),
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .shadow(
                color: isSelected ? .cyan.opacity(0.2) : .black.opacity(0.1),
                radius: isSelected ? 8 : 4,
                y: 2
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("delete", role: .destructive, action: onDelete)
        }
        .onAppear {
            if item.response == nil {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            }
        }
    }

    // MARK: - Colors

    private var statusColor: Color {
        switch item.itemType {
        case .request: return .cyan
        case .memory: return .purple
        case .dream: return .teal
        case .warning: return item.urgency > 0.7 ? .orange : .yellow
        }
    }

    private var typeColor: Color {
        switch item.itemType {
        case .request: return .cyan
        case .memory: return .purple
        case .dream: return .teal
        case .warning: return .orange
        }
    }

    private var urgencyColor: Color {
        if item.urgency > 0.8 { return .orange }
        else if item.urgency > 0.6 { return .yellow }
        else { return .cyan }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: City.self, Item.self, configurations: config)

    let city = City(name: "Preview City")
    container.mainContext.insert(city)

    return CityView(city: city, selectedItemID: .constant(nil))
        .modelContainer(container)
}
