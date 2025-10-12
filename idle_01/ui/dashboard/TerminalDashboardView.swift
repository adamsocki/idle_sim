//
//  TerminalDashboardView.swift
//  idle_01
//
//  Created by Adam Socki on 10/7/25.
//

import SwiftUI
import SwiftData

struct TerminalDashboardView: View {
    let cities: [City]
    @Binding var pulseAnimation: Bool
    @Binding var terminalFontSize: CGFloat
    @Binding var crtFlicker: Double
    @Binding var crtFlickerEnabled: Bool

    private var runningCities: Int {
        cities.filter { $0.isRunning }.count
    }

    private var totalCities: Int { cities.count }

    private var averageProgress: Double {
        guard !cities.isEmpty else { return 0 }
        var total = 0.0
        for s in cities {
            total += s.progress
        }
        let average = total / Double(cities.count)
        return average
    }

    var body: some View {
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
            .opacity(crtFlickerEnabled ? crtFlicker : 1.0)

            // CRT Flicker toggle button (top-right corner)
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        crtFlickerEnabled.toggle()
                    }) {
                        Text(crtFlickerEnabled ? "CRT: ON" : "CRT: OFF")
                            .font(.system(size: 8, weight: .medium, design: .monospaced))
                            .foregroundStyle(crtFlickerEnabled ? Color.green.opacity(0.7) : Color.green.opacity(0.4))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(4)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                    .padding(.trailing, 16)
                }
                Spacer()
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

                Button("") {
                    crtFlickerEnabled.toggle()
                }
                .keyboardShortcut("f", modifiers: .command)
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
}
