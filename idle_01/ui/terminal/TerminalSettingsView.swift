//
//  TerminalSettingsView.swift
//  idle_01
//
//  Terminal settings interface for right detail column
//  Uses @AppStorage for persistent settings
//

import SwiftUI
import SwiftData

struct TerminalSettingsView: View {
    // Display Settings
    @AppStorage("terminal.crtEffect") private var crtEffectEnabled: Bool = true
    @AppStorage("terminal.fontSize") private var fontSize: Double = 12
    @AppStorage("terminal.lineSpacing") private var lineSpacing: Double = 1.2
    @AppStorage("terminal.cursorBlink") private var cursorBlinkEnabled: Bool = true

    // Audio Settings
    @AppStorage("audio.commandSoundEnabled") private var commandSoundEnabled: Bool = true
    @AppStorage("audio.commandVolume") private var commandVolume: Double = 0.3

    // Simulation Settings
    @AppStorage("simulation.autoSave") private var autoSaveEnabled: Bool = true
    @AppStorage("simulation.coherence") private var coherence: Double = 75
    @AppStorage("simulation.trustLevel") private var trustLevel: Double = 0.85
    @AppStorage("simulation.updateInterval") private var updateInterval: Double = 1000

    // Debug Settings
    @AppStorage("debug.verbose") private var verboseLogging: Bool = false
    @AppStorage("debug.showStats") private var showStats: Bool = true
    @AppStorage("debug.performance") private var performanceMonitor: Bool = false

    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                header

                TerminalDivider()

                // Display Settings
                displaySettingsSection

                TerminalDivider(label: "Audio")

                // Audio Settings
                audioSettingsSection

                TerminalDivider(label: "Simulation")

                // Simulation Settings
                simulationSettingsSection

                TerminalDivider(label: "Debug")

                // Debug Settings
                debugSettingsSection

                TerminalDivider()

                // Action Buttons
                actionButtonsSection

                #if DEBUG
                TerminalDivider(label: "Developer")

                // Developer Section (Debug only)
                developerSection
                #endif

                Spacer()
            }
            .padding(16)
        }
        .background(Color.black)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        #if DEBUG
        .alert("Delete All Data?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                deleteAllSwiftData()
            }
        } message: {
            Text("This will permanently delete all SwiftData from the app. This action cannot be undone.")
        }
        #endif
    }

    // MARK: - Sections

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("TERMINAL_SETTINGS")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.9))

            Text("// Configuration Interface")
                .font(.system(size: 10, design: .monospaced))
                .foregroundStyle(Color.green.opacity(0.5))
        }
    }

    private var displaySettingsSection: some View {
        TerminalBox(title: "Display Settings") {
            VStack(spacing: 12) {
                TerminalToggle(label: "CRT Effect", isOn: $crtEffectEnabled)
                TerminalToggle(label: "Cursor Blink", isOn: $cursorBlinkEnabled)

                TerminalSlider(
                    label: "Font Size",
                    value: $fontSize,
                    range: 8...24,
                    step: 1,
                    unit: "pt"
                )

                TerminalSlider(
                    label: "Line Spacing",
                    value: $lineSpacing,
                    range: 1.0...2.0,
                    step: 0.1
                )
            }
        }
    }

    private var audioSettingsSection: some View {
        TerminalBox(title: "Audio Settings") {
            VStack(spacing: 12) {
                TerminalToggle(label: "Command Sound", isOn: $commandSoundEnabled)

                TerminalSlider(
                    label: "Volume",
                    value: $commandVolume,
                    range: 0.0...1.0,
                    step: 0.05
                )
            }
        }
    }

    private var simulationSettingsSection: some View {
        TerminalBox(title: "Simulation Settings") {
            VStack(spacing: 12) {
                TerminalToggle(label: "Auto Save", isOn: $autoSaveEnabled)

                TerminalSlider(
                    label: "Coherence",
                    value: $coherence,
                    range: 0...100,
                    step: 1,
                    unit: "%"
                )

                TerminalSlider(
                    label: "Trust Level",
                    value: $trustLevel,
                    range: 0...1,
                    step: 0.01
                )

                TerminalSlider(
                    label: "Update Interval",
                    value: $updateInterval,
                    range: 100...5000,
                    step: 100,
                    unit: "ms"
                )
            }
        }
    }

    private var debugSettingsSection: some View {
        TerminalBox(title: "Debug Settings") {
            VStack(spacing: 12) {
                TerminalToggle(label: "Verbose Logging", isOn: $verboseLogging)
                TerminalToggle(label: "Show Statistics", isOn: $showStats)
                TerminalToggle(label: "Performance Monitor", isOn: $performanceMonitor)
            }
        }
    }

    private var actionButtonsSection: some View {
        VStack(spacing: 12) {
            TerminalButton(label: "Apply Settings", action: applySettings)

            HStack(spacing: 12) {
                TerminalButton(
                    label: "Reset to Defaults",
                    action: resetToDefaults,
                    style: .secondary
                )

                TerminalButton(
                    label: "Export Config",
                    action: exportConfig,
                    style: .secondary
                )
            }
        }
    }

    // MARK: - Actions

    private func applySettings() {
        // Settings are automatically saved via @AppStorage
        // This could trigger additional actions like notifying other views
        print("Settings applied")
    }

    private func resetToDefaults() {
        crtEffectEnabled = true
        fontSize = 12
        lineSpacing = 1.2
        cursorBlinkEnabled = true

        commandSoundEnabled = true
        commandVolume = 0.3

        autoSaveEnabled = true
        coherence = 75
        trustLevel = 0.85
        updateInterval = 1000

        verboseLogging = false
        showStats = true
        performanceMonitor = false

        print("Settings reset to defaults")
    }

    private func exportConfig() {
        // TODO: Implement config export functionality
        print("Export config not yet implemented")
    }

    #if DEBUG
    private var developerSection: some View {
        TerminalBox(title: "Developer Tools") {
            VStack(spacing: 12) {
                TerminalButton(
                    label: "⚠️ Delete All SwiftData",
                    action: { showDeleteConfirmation = true },
                    style: .secondary
                )
                .foregroundStyle(Color.red.opacity(0.8))

                Text("Deletes all persistent SwiftData from the app")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(Color.green.opacity(0.4))
            }
        }
    }

    private func deleteAllSwiftData() {
        do {
            // Delete all data for each model in your schema
            try modelContext.delete(model: City.self)
            // Add more delete calls for each of your SwiftData models if needed
            
            try modelContext.save()
            print("✅ All SwiftData deleted successfully")
        } catch {
            print("❌ Error deleting SwiftData: \(error.localizedDescription)")
        }
    }
    #endif
}

#Preview {
    TerminalSettingsView()
}
