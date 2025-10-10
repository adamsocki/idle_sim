//
//  ItemTypeBadge.swift
//  idle_01
//
//  Created by Adam Socki on 10/8/25.
//

import SwiftUI

struct ItemTypeBadge: View {
    let itemType: ItemType
    let urgency: Double
    var compact: Bool = false
    
    var body: some View {
        HStack(spacing: compact ? 2 : 4) {
            Image(systemName: icon)
                .font(compact ? .caption2 : .caption)
            if !compact {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
            }
        }
        .foregroundColor(color)
        .padding(.horizontal, compact ? 4 : 6)
        .padding(.vertical, compact ? 2 : 3)
        .background(color.opacity(urgency * 0.2 + 0.1))
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(color.opacity(urgency * 0.5 + 0.3), lineWidth: 1)
        )
    }
    
    private var label: String {
        switch itemType {
        case .request: return "Request"
        case .memory: return "Memory"
        case .dream: return "Dream"
        case .warning: return "Warning"
        }
    }
    
    private var icon: String {
        switch itemType {
        case .request: return "questionmark.circle.fill"
        case .memory: return "archivebox.fill"
        case .dream: return "cloud.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
    
    private var color: Color {
        switch itemType {
        case .request: return .blue
        case .memory: return .purple
        case .dream: return .cyan
        case .warning: return .red
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        ItemTypeBadge(itemType: .request, urgency: 0.5)
        ItemTypeBadge(itemType: .memory, urgency: 0.3)
        ItemTypeBadge(itemType: .dream, urgency: 0.1)
        ItemTypeBadge(itemType: .warning, urgency: 0.9)
        
        Divider()
        
        HStack {
            ItemTypeBadge(itemType: .request, urgency: 0.5, compact: true)
            ItemTypeBadge(itemType: .memory, urgency: 0.3, compact: true)
            ItemTypeBadge(itemType: .dream, urgency: 0.1, compact: true)
            ItemTypeBadge(itemType: .warning, urgency: 0.9, compact: true)
        }
    }
    .padding()
}
