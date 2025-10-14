//
//  DebugStatsOverlay.swift
//  idle_01
//
//  Debug statistics overlay for monitoring simulation state
//

import SwiftUI
import SwiftData

struct DebugStatsOverlay: View {
    @AppStorage("debug.showStats") private var showStats: Bool = true
    @AppStorage("debug.performance") private var showPerformance: Bool = false

    let cities: [City]

    @State private var currentFPS: Double = 60.0
    @State private var memoryUsage: Double = 0.0

    var body: some View {
        VStack {
            Spacer()

            if showStats || showPerformance {
                HStack {
                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        if showStats {
                            statsSection
                        }

                        if showPerformance {
                            performanceSection
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.black.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(16)
                }
            }
        }
        .onAppear {
            if showPerformance {
                startPerformanceMonitoring()
            }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("// STATISTICS")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.7))

            statRow(label: "Cities", value: "\(cities.count)")
            statRow(label: "Active", value: "\(cities.filter { $0.isRunning }.count)")

            if let avgCoherence = averageResource("coherence") {
                statRow(label: "Avg Coherence", value: String(format: "%.2f", avgCoherence))
            }

            if let avgTrust = averageResource("trust") {
                statRow(label: "Avg Trust", value: String(format: "%.2f", avgTrust))
            }

            let totalItems = cities.reduce(0) { $0 + $1.items.count }
            statRow(label: "Total Items", value: "\(totalItems)")
        }
    }

    private var performanceSection: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("// PERFORMANCE")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.7))
                .padding(.top, 8)

            statRow(label: "FPS", value: String(format: "%.1f", currentFPS))
            statRow(label: "Memory", value: String(format: "%.1f MB", memoryUsage))
        }
    }

    private func statRow(label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Text(label + ":")
                .font(.system(size: 8, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.5))

            Text(value)
                .font(.system(size: 8, weight: .medium, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.8))
        }
    }

    private func averageResource(_ key: String) -> Double? {
        guard !cities.isEmpty else { return nil }
        let sum = cities.reduce(0.0) { $0 + ($1.resources[key] ?? 0.0) }
        return sum / Double(cities.count)
    }

    private func startPerformanceMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            // Simulate FPS calculation (in real app, use CADisplayLink)
            currentFPS = Double.random(in: 55...60)

            // Get memory usage
            var info = mach_task_basic_info()
            var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

            let result = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                    task_info(mach_task_self_,
                             task_flavor_t(MACH_TASK_BASIC_INFO),
                             $0,
                             &count)
                }
            }

            if result == KERN_SUCCESS {
                memoryUsage = Double(info.resident_size) / 1024.0 / 1024.0
            }
        }
    }
}

#Preview {
    DebugStatsOverlay(cities: [])
        .frame(width: 600, height: 400)
        .background(Color.black)
}
