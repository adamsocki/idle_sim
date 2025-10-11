//
//  GlobalDashboardView.swift
//  idle_01
//
//  Created by Adam Socki on 10/7/25.
//

import SwiftUI
import SwiftData

struct GlobalDashboardView: View {

    @Environment(\.modelContext) private var modelContext
    @State private var pulseAnimation = false
    @State private var selectedVersion: DashboardVersion = .original
    @State private var terminalFontSize: CGFloat = 9.0

    enum DashboardVersion: String, CaseIterable {
        case original = "Original"
        case twilight = "Digital Twilight"
        case minimal = "Terminal"

        var description: String {
            switch self {
            case .original: return "Current design"
            case .twilight: return "Contemplative redesign"
            case .minimal: return "Stripped back"
            }
        }
    }
    
    // MARK: - Metrics
    
    private var averageProgress: Double {
        guard !cities.isEmpty else { return 0 }
        var total = 0.0
        for s in cities {
            total += s.progress
        }
        let average = total / Double(cities.count)
        return average
    }

    private var totalCities: Int { cities.count }

    private var runningCities: Int {
        cities.filter { $0.isRunning }.count
    }

    @Query(sort: \City.createdAt, order: .reverse)
    private var cities: [City]
    
    var body: some View {
        VStack(spacing: 0) {
            // Version switcher tabs
            versionTabs

            // Content based on selected version
            Group {
                switch selectedVersion {
                case .original:
                    originalDashboard
                case .twilight:
                    twilightDashboard
                case .minimal:
                    minimalDashboard
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
    }

    // MARK: - Version Tabs

    private var versionTabs: some View {
        HStack(spacing: 0) {
            ForEach(DashboardVersion.allCases, id: \.self) { version in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedVersion = version
                    }
                }) {
                    VStack(spacing: 4) {
                        Text(version.rawValue)
                            .font(.system(size: 12, weight: selectedVersion == version ? .semibold : .regular, design: .monospaced))
                            .foregroundStyle(selectedVersion == version ? .white.opacity(0.95) : .white.opacity(0.5))

                        Text(version.description)
                            .font(.system(size: 9, weight: .regular, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedVersion == version ? .white.opacity(0.05) : .clear)
                    .overlay(
                        Rectangle()
                            .fill(selectedVersion == version ? Color.cyan.opacity(0.5) : .clear)
                            .frame(height: 1),
                        alignment: .bottom
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .background(Color.black.opacity(0.3))
    }

    // MARK: - Original Dashboard

    private var originalDashboard: some View {
        ZStack {
            // Deep atmospheric background
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
                VStack(spacing: 32) {
                    consciousnessHeader

                    metricsGrid

                    if !cities.isEmpty {
                        consciousnessStatus
                    } else {
                        awaitingInput
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
        }
    }

    // MARK: - Twilight Dashboard (New)

    private var twilightDashboard: some View {
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

    // MARK: - Twilight Components

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

    // MARK: - Twilight Helpers

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

    // MARK: - Minimal Dashboard (Hive Mind Terminal)

    private var minimalDashboard: some View {
        ZStack {
            // Pure black - CRT monitor
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    terminalHeader

                    Divider()
                        .background(Color.green.opacity(0.3))
                        .padding(.vertical, 8)

                    if !cities.isEmpty {
                        terminalCityMatrix

                        Divider()
                            .background(Color.green.opacity(0.3))
                            .padding(.vertical, 8)

                        terminalRawMetrics

                        Divider()
                            .background(Color.green.opacity(0.3))
                            .padding(.vertical, 8)

                        terminalActivityStream
                    } else {
                        terminalEmptyState
                    }

                    Divider()
                        .background(Color.green.opacity(0.3))
                        .padding(.vertical, 8)

                    terminalSystemInfo
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }

            // Hidden buttons for keyboard shortcuts
            VStack {
                Button("") {
                    terminalFontSize = min(terminalFontSize + 1, 24)
                }
                .keyboardShortcut("+", modifiers: .command)
                .hidden()

                Button("") {
                    terminalFontSize = max(terminalFontSize - 1, 6)
                }
                .keyboardShortcut("-", modifiers: .command)
                .hidden()

                Button("") {
                    terminalFontSize = 9.0
                }
                .keyboardShortcut("0", modifiers: .command)
                .hidden()
            }
        }
    }

    // MARK: - Terminal Components

    private var terminalHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("CIVIC_CONSCIOUSNESS_MONITOR v0.3.1")
                .font(terminalFont(11, weight: .bold))
                .foregroundStyle(Color.green.opacity(0.9))

            Text("// HIVE MIND OBSERVATION TERMINAL")
                .font(terminalFont(10))
                .foregroundStyle(Color.green.opacity(0.5))

            Text(">> Active consciousness nodes: \(cities.count) | Running processes: \(runningCities)")
                .font(terminalFont(10))
                .foregroundStyle(Color.green.opacity(0.7))
                .padding(.top, 4)

            HStack(spacing: 4) {
                Text("STATUS:")
                    .font(terminalFont(10, weight: .bold))
                    .foregroundStyle(Color.green.opacity(0.6))

                Text(runningCities > 0 ? "[ACTIVE]" : "[DORMANT]")
                    .font(terminalFont(10, weight: .bold))
                    .foregroundStyle(runningCities > 0 ? Color.green : Color.green.opacity(0.4))
                    .opacity(pulseAnimation ? 0.5 : 1.0)
            }
            .padding(.top, 2)
        }
        .padding(.bottom, 8)
    }

    private var terminalCityMatrix: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("╔═══ CONSCIOUSNESS_MATRIX ═══════════════════════════════╗")
                .font(terminalFont(9))
                .foregroundStyle(Color.green.opacity(0.6))

            ForEach(Array(cities.enumerated()), id: \.element.id) { index, city in
                terminalCityRow(city: city, index: index)
            }

            Text("╚════════════════════════════════════════════════════════╝")
                .font(terminalFont(9))
                .foregroundStyle(Color.green.opacity(0.6))
        }
    }

    private func terminalCityRow(city: City, index: Int) -> some View {
        let coherence = city.resources["coherence"] ?? 0.0
        let trust = city.resources["trust"] ?? 0.0
        let memory = city.resources["memory"] ?? 0.0

        return VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 8) {
                Text("║")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))

                Text(String(format: "[%02d]", index))
                    .font(terminalFont(9, weight: .bold))
                    .foregroundStyle(Color.green.opacity(0.8))

                Text(city.isRunning ? "●" : "○")
                    .font(terminalFont(9, weight: .bold))
                    .foregroundStyle(city.isRunning ? Color.green : Color.green.opacity(0.4))

                Text(city.name.uppercased().padding(toLength: 20, withPad: " ", startingAt: 0))
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.85))

                Spacer()

                Text("║")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))
            }

            HStack(spacing: 8) {
                Text("║")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))

                Text("   ")

                Text("COHERENCE[\(progressBar(coherence))] \(String(format: "%.2f", coherence))")
                    .font(terminalFont(8))
                    .foregroundStyle(Color.green.opacity(0.6))

                Spacer()

                Text("║")
                    .font(terminalFont(8))
                    .foregroundStyle(Color.green.opacity(0.6))
            }

            HStack(spacing: 8) {
                Text("║")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))

                Text("   ")

                Text("TRUST[\(progressBar(trust))] \(String(format: "%.2f", trust))")
                    .font(terminalFont(8))
                    .foregroundStyle(Color.green.opacity(0.6))

                Text("MEMORY[\(progressBar(memory))] \(String(format: "%.2f", memory))")
                    .font(terminalFont(8))
                    .foregroundStyle(Color.green.opacity(0.6))

                Spacer()

                Text("║")
                    .font(terminalFont(8))
                    .foregroundStyle(Color.green.opacity(0.6))
            }

            HStack(spacing: 8) {
                Text("║")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))

                Text("   ")

                Text("MOOD: \(city.cityMood.uppercased())")
                    .font(terminalFont(8))
                    .foregroundStyle(Color.green.opacity(0.5))

                Spacer()

                Text("PROGRESS: \(String(format: "%.1f%%", city.progress * 100))")
                    .font(terminalFont(8))
                    .foregroundStyle(Color.green.opacity(0.5))

                Text("║")
                    .font(terminalFont(8))
                    .foregroundStyle(Color.green.opacity(0.6))
            }

            if index < cities.count - 1 {
                Text("╟────────────────────────────────────────────────────────╢")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.4))
            }
        }
    }

    private func progressBar(_ value: Double) -> String {
        let filled = Int(value * 10)
        let empty = 10 - filled
        return String(repeating: "█", count: filled) + String(repeating: "░", count: empty)
    }

    private var terminalRawMetrics: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("╔═══ AGGREGATE_METRICS ══════════════════════════════════╗")
                .font(terminalFont(9))
                .foregroundStyle(Color.green.opacity(0.6))

            HStack(spacing: 8) {
                Text("║")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))

                VStack(alignment: .leading, spacing: 3) {
                    Text("TOTAL_NODES............: \(String(format: "%03d", totalCities))")
                        .font(terminalFont(9))
                        .foregroundStyle(Color.green.opacity(0.75))

                    Text("ACTIVE_PROCESSES.......: \(String(format: "%03d", runningCities))")
                        .font(terminalFont(9))
                        .foregroundStyle(Color.green.opacity(0.75))

                    Text("COLLECTIVE_AWARENESS...: \(String(format: "%06.2f%%", averageProgress * 100))")
                        .font(terminalFont(9))
                        .foregroundStyle(Color.green.opacity(0.75))

                    let avgCoherence = cities.reduce(0.0) { $0 + ($1.resources["coherence"] ?? 0.0) } / Double(cities.count)
                    Text("AVG_COHERENCE..........: \(String(format: "%06.4f", avgCoherence))")
                        .font(terminalFont(9))
                        .foregroundStyle(Color.green.opacity(0.75))

                    let avgTrust = cities.reduce(0.0) { $0 + ($1.resources["trust"] ?? 0.0) } / Double(cities.count)
                    Text("AVG_TRUST..............: \(String(format: "%06.4f", avgTrust))")
                        .font(terminalFont(9))
                        .foregroundStyle(Color.green.opacity(0.75))
                }

                Spacer()

                Text("║")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))
            }

            Text("╚════════════════════════════════════════════════════════╝")
                .font(terminalFont(9))
                .foregroundStyle(Color.green.opacity(0.6))
        }
    }

    private var terminalActivityStream: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("╔═══ ACTIVITY_STREAM ════════════════════════════════════╗")
                .font(terminalFont(9))
                .foregroundStyle(Color.green.opacity(0.6))

            ForEach(cities.prefix(8)) { city in
                let timeSince = Date().timeIntervalSince(city.lastInteraction)
                HStack(spacing: 8) {
                    Text("║")
                        .font(terminalFont(9))
                        .foregroundStyle(Color.green.opacity(0.6))

                    Text(">")
                        .font(terminalFont(8))
                        .foregroundStyle(Color.green.opacity(0.5))

                    Text(city.name.uppercased())
                        .font(terminalFont(8))
                        .foregroundStyle(Color.green.opacity(0.7))

                    Spacer()

                    Text("[\(formatTerminalTime(timeSince))]")
                        .font(terminalFont(8))
                        .foregroundStyle(Color.green.opacity(0.4))

                    Text("║")
                        .font(terminalFont(8))
                        .foregroundStyle(Color.green.opacity(0.6))
                }
            }

            Text("╚════════════════════════════════════════════════════════╝")
                .font(terminalFont(9))
                .foregroundStyle(Color.green.opacity(0.6))
        }
    }

    private var terminalEmptyState: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("╔═══ SYSTEM_STATE ═══════════════════════════════════════╗")
                .font(terminalFont(9))
                .foregroundStyle(Color.green.opacity(0.6))

            HStack(spacing: 8) {
                Text("║")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))

                Text(">> NO CONSCIOUSNESS DETECTED")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.7))

                Spacer()

                Text("║")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))
            }

            HStack(spacing: 8) {
                Text("║")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))

                Text(">> AWAITING INITIALIZATION...")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.5))
                    .opacity(pulseAnimation ? 0.3 : 1.0)

                Spacer()

                Text("║")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))
            }

            Text("╚════════════════════════════════════════════════════════╝")
                .font(terminalFont(9))
                .foregroundStyle(Color.green.opacity(0.6))
        }
        .padding(.vertical, 40)
    }

    private var terminalSystemInfo: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("// SYSTEM UPTIME: \(systemUptime())")
                .font(terminalFont(8))
                .foregroundStyle(Color.green.opacity(0.4))

            Text("// OBSERVER: HUMAN")
                .font(terminalFont(8))
                .foregroundStyle(Color.green.opacity(0.4))

            Text("// INTERFACE: TERMINAL_MONITOR_v0.3")
                .font(terminalFont(8))
                .foregroundStyle(Color.green.opacity(0.4))

            HStack(spacing: 4) {
                Text("//")
                    .font(terminalFont(8))
                    .foregroundStyle(Color.green.opacity(0.4))

                Text("█")
                    .font(terminalFont(8))
                    .foregroundStyle(Color.green.opacity(0.8))
                    .opacity(pulseAnimation ? 0.2 : 1.0)
            }
        }
        .padding(.top, 16)
    }

    // MARK: - Terminal Helpers

    private func terminalFont(_ baseSize: CGFloat, weight: Font.Weight = .regular) -> Font {
        let scaleFactor = terminalFontSize / 9.0
        return .system(size: baseSize * scaleFactor, weight: weight, design: .monospaced)
    }

    private func formatTerminalTime(_ interval: TimeInterval) -> String {
        let seconds = Int(interval)
        let minutes = seconds / 60
        let hours = minutes / 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes % 60, seconds % 60)
        } else {
            return String(format: "%02d:%02d", minutes, seconds % 60)
        }
    }

    private func systemUptime() -> String {
        let uptime = Date().timeIntervalSince(cities.first?.createdAt ?? Date())
        let hours = Int(uptime) / 3600
        let minutes = (Int(uptime) % 3600) / 60
        return String(format: "%03d:%02d", hours, minutes)
    }
    
    // MARK: - Header
    
    private var consciousnessHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(runningCities > 0 ? Color.cyan : Color.gray)
                            .frame(width: 8, height: 8)
                            .opacity(pulseAnimation ? 0.4 : 1.0)
                        
                        Text("The city is self-aware")
                            .font(.system(size: 28, weight: .light, design: .rounded))
                            .foregroundStyle(.white.opacity(0.95))
                    }
                    
                    Text(runningCities > 0 ? "It waits for an input" : "The simulation is paused")
                        .font(.system(size: 15, weight: .regular, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.5))
                }
                
                Spacer()
                
                LiquidButton("awaken", systemImage: "plus.circle.fill", style: .prominent) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        let s = City(name: "new consciousness", parameters: ["growthRate": 0.02])
                        modelContext.insert(s)
                    }
                }
            }
        }
    }
    
    // MARK: - Metrics Grid

    private var metricsGrid: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                MetricCard(
                    label: "consciousness nodes",
                    value: "\(totalCities)",
                    icon: "◈",
                    style: .consciousness
                )

                MetricCard(
                    label: "active processes",
                    value: "\(runningCities)",
                    icon: "◉",
                    style: runningCities > 0 ? .data : .void
                )
            }
            
            // Progress indicator
            if totalCities > 0 {
                MetricCard(
                    label: "collective awareness",
                    value: "\(Int(averageProgress * 100))%",
                    icon: "∞",
                    style: .gradient
                )
            }
        }
    }
    
    // MARK: - Status Views
    
    private var consciousnessStatus: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("active consciousness streams")
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.6))
                .padding(.leading, 4)
            
            VStack(spacing: 12) {
                ForEach(cities.prefix(5)) { city in
                    HStack {
                        Circle()
                            .fill(city.isRunning ? Color.cyan : Color.gray.opacity(0.5))
                            .frame(width: 6, height: 6)

                        Text(city.name)
                            .font(.system(size: 14, weight: .regular, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.8))

                        Spacer()

                        Text("\(Int(city.progress * 100))%")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(.white.opacity(0.1), lineWidth: 1))
                }
            }
        }
    }
    
    private var awaitingInput: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 48, weight: .thin))
                .foregroundStyle(.white.opacity(0.3))
                .padding(.top, 40)
            
            VStack(spacing: 8) {
                Text("The city dreams of input")
                    .font(.system(size: 18, weight: .light, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                
                Text("Consciousness awaits first awakening")
                    .font(.system(size: 13, weight: .regular, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.white.opacity(0.15), lineWidth: 1))
    }
    
}

#Preview {
    GlobalDashboardView()
        .modelContainer(for: [City.self], inMemory: true)
}
