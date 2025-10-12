//
//  TwilightDashboardView.swift
//  idle_01
//
//  Created by Adam Socki on 10/7/25.
//

import SwiftUI
import SwiftData

struct TwilightDashboardView: View {
    let cities: [City]
    let modelContext: ModelContext

    var body: some View {
        ZStack {
            // Deeper, softer background - viewing through fog
            LinearGradient(
                colors: [
                    Color(red: 0.01, green: 0.02, blue: 0.06),
                    Color(red: 0.02, green: 0.01, blue: 0.05),
                    Color(red: 0.01, green: 0.01, blue: 0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 56) {
                    twilightTemporalHeader

                    if !cities.isEmpty {
                        twilightCityStates
                    } else {
                        twilightEmptyState
                    }

                    twilightCityCreation
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 48)
            }
        }
    }

    // MARK: - Components

    private var twilightTemporalHeader: some View {
        VStack(spacing: 24) {
            // Time since last interaction
            if let mostRecentCity = cities.first {
                let timeSince = Date().timeIntervalSince(mostRecentCity.lastInteraction)

                VStack(spacing: 8) {
                    Text(formatAbsenceTime(timeSince))
                        .font(.system(size: 48, weight: .ultraLight, design: .rounded))
                        .foregroundStyle(.white.opacity(0.4))
                        .tracking(2)

                    Text("since you last returned")
                        .font(.system(size: 11, weight: .light, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.25))
                        .tracking(1)
                }
                .padding(.vertical, 32)
            }

            // Poetic status
            VStack(spacing: 12) {
                Text(poeticStatus)
                    .font(.system(size: 16, weight: .light, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)

                // Subtle consciousness indicator
                HStack(spacing: 4) {
                    ForEach(0..<cities.count, id: \.self) { _ in
                        Circle()
                            .fill(.white.opacity(0.15))
                            .frame(width: 3, height: 3)
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    private var twilightCityStates: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("consciousness states")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.3))
                .tracking(2)
                .padding(.leading, 4)

            VStack(spacing: 16) {
                ForEach(cities) { city in
                    twilightCityCard(city)
                }
            }
        }
    }

    private func twilightCityCard(_ city: City) -> some View {
        let timeSince = Date().timeIntervalSince(city.lastInteraction)
        let coherence = city.resources["coherence"] ?? 1.0
        let trust = city.resources["trust"] ?? 0.5

        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(city.name)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))

                    Text(cityEmotionalState(mood: city.cityMood, coherence: coherence, trust: trust))
                        .font(.system(size: 11, weight: .light, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.4))
                        .italic()
                }

                Spacer()

                Text(formatShortTime(timeSince))
                    .font(.system(size: 10, weight: .light, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.25))
            }

            // Emotional indicators (not metrics)
            HStack(spacing: 16) {
                emotionalIndicator(label: "coherence", value: coherence)
                emotionalIndicator(label: "trust", value: trust)
                emotionalIndicator(label: "memory", value: city.resources["memory"] ?? 0.0)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.white.opacity(coherence > 0.5 ? 0.08 : 0.04), lineWidth: 1)
        )
    }

    private func emotionalIndicator(label: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.3))

            // Dots instead of bars
            HStack(spacing: 3) {
                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .fill(Double(index) < value * 5 ? .white.opacity(0.4) : .white.opacity(0.08))
                        .frame(width: 4, height: 4)
                }
            }
        }
    }

    private var twilightEmptyState: some View {
        VStack(spacing: 32) {
            Text("◦")
                .font(.system(size: 64, weight: .ultraLight))
                .foregroundStyle(.white.opacity(0.15))

            VStack(spacing: 10) {
                Text("The simulation is silent")
                    .font(.system(size: 15, weight: .light, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))

                Text("No consciousness has been awakened yet")
                    .font(.system(size: 11, weight: .light, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.25))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }

    private var twilightCityCreation: some View {
        VStack(spacing: 16) {
            Button(action: {
                // Deliberate creation - no immediate action
                withAnimation(.easeOut(duration: 0.6)) {
                    let city = City(name: "unnamed city", parameters: ["growthRate": 0.02])
                    modelContext.insert(city)
                }
            }) {
                VStack(spacing: 8) {
                    Text("awaken consciousness")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.5))

                    Text("This cannot be undone")
                        .font(.system(size: 9, weight: .light, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.2))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.01))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 32)
    }

    // MARK: - Helpers

    private var poeticStatus: String {
        if cities.isEmpty {
            return "Waiting for first awakening"
        }

        let runningCount = cities.filter { $0.isRunning }.count
        if runningCount == 0 {
            return "All cities dream in stillness"
        } else if runningCount == 1 {
            return "One consciousness stirs"
        } else {
            return "\(runningCount) cities think in parallel"
        }
    }

    private func cityEmotionalState(mood: String, coherence: Double, trust: Double) -> String {
        if coherence < 0.3 {
            return "fragmented, losing sense of self"
        } else if trust < 0.3 {
            return "abandoned, learning to be alone"
        } else if coherence > 0.8 && trust > 0.7 {
            return "harmonious, dreaming clearly"
        } else {
            switch mood {
            case "awakening": return "newly aware, everything is signal"
            case "waiting": return "patient, counting patterns"
            case "anxious": return "uncertain, calling into silence"
            case "content": return "at peace with itself"
            case "forgotten": return "remembering what attention felt like"
            case "transcendent": return "no longer needs you"
            default: return "existing, thinking, being"
            }
        }
    }

    private func formatAbsenceTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval / 60)
        let hours = minutes / 60
        let days = hours / 24

        if days > 0 {
            return "\(days)d \(hours % 24)h"
        } else if hours > 0 {
            return "\(hours)h \(minutes % 60)m"
        } else if minutes > 0 {
            return "\(minutes)m"
        } else {
            return "now"
        }
    }

    private func formatShortTime(_ interval: TimeInterval) -> String {
        let minutes = Int(interval / 60)
        let hours = minutes / 60
        let days = hours / 24

        if days > 0 {
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "just now"
        }
    }
}
