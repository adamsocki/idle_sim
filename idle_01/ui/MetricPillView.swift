//
//  MetricPillView.swift
//  idle_01
//
//  Created by Adam Socki on 10/10/25.
//

import SwiftUI

struct MetricPillView: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                .foregroundStyle(color)
            
            Text(label)
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(color.opacity(0.3), lineWidth: 1))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack {
            MetricPillView(value: "5", label: "cities", color: .purple)
            MetricPillView(value: "3", label: "awake", color: .cyan)
            MetricPillView(value: "75%", label: "awareness", color: .blue)
        }
    }
}
