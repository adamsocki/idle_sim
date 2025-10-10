//
//  Item.swift
//  idle_01
//
//  Created by Adam Socki on 9/29/25.
//

import Foundation
import SwiftData

enum ItemType: String, Codable {
    case memory      // The city remembers something
    case request     // The city asks for input
    case dream       // Idle thoughts
    case warning     // Something needs attention
}

@Model
final class Item {
    var timestamp: Date
    var scenario: ScenarioRun?
    var title: String?
    var targetDate: Date?
    var itemType: ItemType
    var urgency: Double  // 0.0 to 1.0 - how badly the city needs this addressed
    var response: String?  // Player's input/decision
    
    init(timestamp: Date, title: String = "Task", targetDate: Date? = nil, scenario: ScenarioRun? = nil, itemType: ItemType = .request, urgency: Double = 0.5) {
        self.timestamp = timestamp
        self.title = title
        self.targetDate = targetDate
        self.scenario = scenario
        self.itemType = itemType
        self.urgency = urgency
        self.response = nil
    }
    
    /// The total time interval in seconds that has elapsed since this item was created.
    /// This value is computed from the current time and is not persisted.
    var elapsedTime: TimeInterval {
        Date().timeIntervalSince(timestamp)
    }

    /// A human-friendly string showing the elapsed time with milliseconds precision.
    /// Example: "3.257 s"
    var elapsedString: String {
        String(format: "%.3f s", elapsedTime)
    }
    
    var remainingTime: TimeInterval? {
        guard let t = targetDate else { return nil }
        return t.timeIntervalSinceNow
    }
    
    var remainingString: String {
           guard let seconds = remainingTime else { return "—" }
           let s = Int(seconds.rounded())
           let sign = s < 0 ? "-" : ""
           let absS = abs(s)
           let h = absS / 3600
           let m = (absS % 3600) / 60
           let sec = absS % 60
           return String(format: "%@%02d:%02d:%02d", sign, h, m, sec)
       }
}
