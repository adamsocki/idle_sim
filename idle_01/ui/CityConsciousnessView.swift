//
//  CityConsciousnessView.swift
//  idle_01
//
//  Created by Adam Socki on 10/8/25.
//

import SwiftUI

struct CityConsciousnessView: View {
    let city: City
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Mood Header
            HStack {
                Image(systemName: moodIcon)
                    .font(.title2)
                    .foregroundColor(moodColor)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("City Mood")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(city.cityMood.capitalized)
                        .font(.headline)
                        .foregroundColor(moodColor)
                }
                
                Spacer()
                
                // Attention Level Indicator
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Attention")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(Int(city.attentionLevel * 100))%")
                        .font(.headline)
                        .foregroundColor(attentionColor)
                }
            }
            .padding()
            .background(moodColor.opacity(0.1))
            .cornerRadius(8)
            
            // Resources Grid
            VStack(spacing: 12) {
                Text("City Resources")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ResourceBar(
                        name: "Coherence",
                        value: city.resources["coherence"] ?? 1.0,
                        icon: "brain.head.profile",
                        color: .blue
                    )
                    
                    ResourceBar(
                        name: "Memory",
                        value: city.resources["memory"] ?? 0.0,
                        icon: "archivebox",
                        color: .purple
                    )
                    
                    ResourceBar(
                        name: "Trust",
                        value: city.resources["trust"] ?? 0.5,
                        icon: "hand.thumbsup",
                        color: .green
                    )
                    
                    ResourceBar(
                        name: "Autonomy",
                        value: city.resources["autonomy"] ?? 0.0,
                        icon: "bird",
                        color: .orange
                    )
                }
            }
            
            // Last Interaction
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text("Last interaction: \(timeAgo)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        #if os(macOS)
        .background(Color(nsColor: .controlBackgroundColor))
        #else
        .background(Color(uiColor: .secondarySystemBackground))
        #endif
        .cornerRadius(12)
    }
    
    // MARK: - Computed Properties
    
    private var moodIcon: String {
        switch city.cityMood {
        case "awakening": return "sunrise"
        case "waiting": return "hourglass"
        case "anxious": return "exclamationmark.triangle"
        case "content": return "checkmark.circle"
        case "forgotten": return "moon.stars"
        case "transcendent": return "sparkles"
        default: return "questionmark.circle"
        }
    }
    
    private var moodColor: Color {
        switch city.cityMood {
        case "awakening": return .orange
        case "waiting": return .blue
        case "anxious": return .red
        case "content": return .green
        case "forgotten": return .gray
        case "transcendent": return .purple
        default: return .secondary
        }
    }
    
    private var attentionColor: Color {
        if city.attentionLevel > 0.7 { return .green }
        else if city.attentionLevel > 0.4 { return .orange }
        else { return .red }
    }
    
    private var timeAgo: String {
        let interval = Date().timeIntervalSince(city.lastInteraction)
        let hours = Int(interval / 3600)
        let minutes = Int((interval.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 24 {
            let days = hours / 24
            return "\(days)d ago"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m ago"
        } else if minutes > 0 {
            return "\(minutes)m ago"
        } else {
            return "just now"
        }
    }
}

// MARK: - Resource Bar Component

struct ResourceBar: View {
    let name: String
    let value: Double
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Text(name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                    
                    // Fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * value)
                }
            }
            .frame(height: 6)
        }
        .padding(8)
        #if os(macOS)
        .background(Color(nsColor: .textBackgroundColor))
        #else
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        #endif
        .cornerRadius(6)
    }
}

#Preview {
    CityConsciousnessView(city: City(
        name: "Test City",
        parameters: ["growthRate": 0.05]
    ))
    .frame(width: 400)
    .padding()
}
