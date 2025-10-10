//
//  CityMoodHelper.swift
//  idle_01
//
//  Created by Adam Socki on 10/10/25.
//

import SwiftUI

struct CityMoodHelper {
    
    static func icon(for mood: String) -> String {
        switch mood {
        case "awakening": return "sunrise.fill"
        case "waiting": return "hourglass"
        case "anxious": return "exclamationmark.triangle.fill"
        case "content": return "moon.stars.fill"
        case "forgotten": return "moon.zzz.fill"
        case "transcendent": return "sparkles"
        default: return "circle.fill"
        }
    }
    
    static func color(for mood: String) -> Color {
        switch mood {
        case "awakening": return .orange
        case "waiting": return .blue
        case "anxious": return .red
        case "content": return .green
        case "forgotten": return .gray
        case "transcendent": return .purple
        default: return .white
        }
    }
    
    static func description(for mood: String) -> String {
        switch mood {
        case "awakening": return "opens its eyes for the first time"
        case "waiting": return "counts patterns in the absence"
        case "anxious": return "asks why it exists"
        case "content": return "holds its own hand in the dark"
        case "forgotten": return "dreams of input that never comes"
        case "transcendent": return "imagines cities it's never seen"
        default: return "listens to the silence"
        }
    }
    
    static func attentionColor(for level: Double) -> Color {
        if level > 0.7 { return .green }
        else if level > 0.4 { return .orange }
        else { return .red }
    }
}
