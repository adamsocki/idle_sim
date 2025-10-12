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
    @State private var terminalFontSize: CGFloat = 14.0
    @State private var crtFlicker: Double = 1.0
    @State private var crtFlickerEnabled: Bool = false

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
                    OriginalDashboardView(
                        cities: cities,
                        modelContext: modelContext,
                        pulseAnimation: $pulseAnimation
                    )
                case .twilight:
                    TwilightDashboardView(
                        cities: cities,
                        modelContext: modelContext
                    )
                case .minimal:
                    TerminalDashboardView(
                        cities: cities,
                        pulseAnimation: $pulseAnimation,
                        terminalFontSize: $terminalFontSize,
                        crtFlicker: $crtFlicker,
                        crtFlickerEnabled: $crtFlickerEnabled
                    )
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
            startCRTFlicker { flickerValue in
                withAnimation(.linear(duration: 0.016)) {
                    crtFlicker = flickerValue
                }
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
}

#Preview {
    GlobalDashboardView()
        .modelContainer(for: [City.self], inMemory: true)
}
