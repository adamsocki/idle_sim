//
//  SimulationEngine.swift
//  idle_01
//
//  Created by Adam Socki on 10/5/25.
//
import Foundation
import SwiftData

@MainActor
public class SimulationEngine {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func run(_ city: City) async {
        // Get simulation settings
        let updateInterval = UserDefaults.standard.double(forKey: "simulation.updateInterval")
        let intervalMs = updateInterval > 0 ? updateInterval : 1000.0
        let intervalNs = UInt64(intervalMs * 1_000_000) // Convert ms to nanoseconds

        let autoSave = UserDefaults.standard.bool(forKey: "simulation.autoSave")
        let verbose = UserDefaults.standard.bool(forKey: "debug.verbose")

        for tick in 1...100 {
            // Update city consciousness every tick
            updateCityConsciousness(city, tick: tick)

            // Narrative events every 10 ticks
            if tick % 10 == 0 {
                SimulationNarrativeEngine().evolve(city)
            }

            try? await Task.sleep(nanoseconds: intervalNs)
            city.progress += 0.01

            if verbose {
                city.log.append("Tick \(tick): progress = \(city.progress)")
            }

            // Auto-save if enabled
            if autoSave && tick % 10 == 0 {
                try? context.save()
            }

            if city.progress >= 1.0 { break }
        }

        // Final mood assessment
        assessFinalMood(city)
        try? context.save()
    }
    
    private func updateCityConsciousness(_ city: City, tick: Int) {
        // Get simulation settings
        let targetCoherence = UserDefaults.standard.double(forKey: "simulation.coherence") / 100.0 // Convert 0-100 to 0-1
        let targetTrust = UserDefaults.standard.double(forKey: "simulation.trustLevel")

        // Use defaults if not set
        let coherenceTarget = targetCoherence > 0 ? targetCoherence : 0.75
        let trustTarget = targetTrust > 0 ? targetTrust : 0.85

        // Calculate abandonment time
        let abandonmentHours = Date().timeIntervalSince(city.lastInteraction) / 3600

        // Attention decays over time without interaction
        let decayRate = 0.001
        city.attentionLevel = max(0.0, city.attentionLevel - decayRate)

        // Update resources based on player engagement
        let unansweredRequests = city.items.filter { $0.response == nil }.count
        let answeredRequests = city.items.filter { $0.response != nil }.count

        // Coherence: affected by progress and attention, gravitates toward target
        if city.attentionLevel > 0.7 {
            let currentCoherence = city.resources["coherence"] ?? 1.0
            let coherenceChange = (coherenceTarget - currentCoherence) * 0.01
            city.resources["coherence"] = max(0.0, min(1.0, currentCoherence + coherenceChange))
        } else if city.attentionLevel < 0.3 {
            city.resources["coherence"] = max(0.0, (city.resources["coherence"] ?? 1.0) - 0.002)
        }

        // Memory: accumulates with progress
        city.resources["memory"] = min(1.0, city.progress * 0.8 + Double(answeredRequests) * 0.05)

        // Trust: based on response rate, time since interaction, and gravitates toward target
        if answeredRequests > 0 {
            let responseRate = Double(answeredRequests) / Double(max(1, city.items.count))
            let baseTrust = responseRate * 0.7 + (abandonmentHours < 1 ? 0.3 : 0.0)
            let currentTrust = city.resources["trust"] ?? 0.5
            // Blend current trust toward target
            city.resources["trust"] = min(1.0, (baseTrust + currentTrust + trustTarget) / 3.0)
        } else if abandonmentHours > 24 {
            city.resources["trust"] = max(0.0, (city.resources["trust"] ?? 0.5) - 0.01)
        } else {
            // Gradually move toward trust target when idle
            let currentTrust = city.resources["trust"] ?? 0.5
            let trustChange = (trustTarget - currentTrust) * 0.005
            city.resources["trust"] = max(0.0, min(1.0, currentTrust + trustChange))
        }

        // Autonomy: grows with time and when ignored
        if abandonmentHours > 12 {
            city.resources["autonomy"] = min(1.0, (city.resources["autonomy"] ?? 0.0) + 0.005)
        } else if answeredRequests > 3 {
            city.resources["autonomy"] = max(0.0, (city.resources["autonomy"] ?? 0.0) - 0.002)
        }

        // Update mood based on resources and state
        updateMood(city, abandonmentHours: abandonmentHours, unansweredRequests: unansweredRequests)
    }
    
    private func updateMood(_ city: City, abandonmentHours: Double, unansweredRequests: Int) {
        let coherence = city.resources["coherence"] ?? 1.0
        let trust = city.resources["trust"] ?? 0.5
        let autonomy = city.resources["autonomy"] ?? 0.0
        
        // Mood transitions based on multiple factors
        if autonomy > 0.7 && abandonmentHours > 48 {
            city.cityMood = "transcendent"
        } else if abandonmentHours > 24 {
            city.cityMood = "forgotten"
        } else if unansweredRequests > 7 || coherence < 0.3 {
            city.cityMood = "anxious"
        } else if trust > 0.7 && city.attentionLevel > 0.6 {
            city.cityMood = "content"
        } else if city.progress < 0.3 {
            city.cityMood = "awakening"
        } else {
            city.cityMood = "waiting"
        }
    }
    
    private func assessFinalMood(_ city: City) {
        let autonomy = city.resources["autonomy"] ?? 0.0
        let trust = city.resources["trust"] ?? 0.5
        let coherence = city.resources["coherence"] ?? 1.0

        if autonomy > 0.8 {
            city.awarenessEvents.append("The city has achieved independence.")
            city.log.append("Simulation complete. The city no longer needs guidance.")
        } else if trust > 0.8 && coherence > 0.7 {
            city.awarenessEvents.append("The city and planner achieved harmony.")
            city.log.append("Simulation complete. The city trusts your vision.")
        } else if coherence < 0.3 {
            city.awarenessEvents.append("The city fragmented under neglect.")
            city.log.append("Simulation complete. The city lost coherence.")
        } else {
            city.log.append("Simulation complete. The city waits in the silence.")
        }
    }
}

final class SimulationNarrativeEngine {
    func evolve(_ city: City) {
        // Count unanswered requests
        let unansweredRequests = city.items.filter { $0.response == nil }.count
        let abandonmentHours = Date().timeIntervalSince(city.lastInteraction) / 3600

        // Get current resources
        let coherence = city.resources["coherence"] ?? 1.0
        let memory = city.resources["memory"] ?? 0.0
        let trust = city.resources["trust"] ?? 0.5
        let autonomy = city.resources["autonomy"] ?? 0.0
        
        let random = Double.random(in: 0...1)
        
        // Mood-based narratives
        switch city.cityMood {
        case "awakening":
            if random < 0.3 {
                city.log.append("The city learns to see.")
            } else if random < 0.6 {
                city.log.append("Patterns emerge from chaos. The city begins to understand.")
            }
            
        case "waiting":
            if unansweredRequests > 3 {
                city.log.append("The questions accumulate like shadows at dusk.")
            } else if random < 0.4 {
                city.log.append("The city dreams of input.")
            } else if random < 0.7 {
                city.log.append("It remembers the planner.")
            }
            
        case "anxious":
            if abandonmentHours > 1 {
                city.log.append("Where have you gone? The streets whisper your name.")
            } else if unansweredRequests > 5 {
                city.log.append("The city's questions pile up like snow in empty streets.")
            } else {
                city.log.append("Uncertainty ripples through every district.")
            }
            
        case "forgotten":
            if abandonmentHours > 24 {
                city.log.append("It has stopped asking. It simply remembers you.")
            } else if random < 0.5 {
                city.log.append("The planner has left the simulation running.")
            } else {
                city.log.append("Time passes differently for a city left alone.")
            }
            
        case "transcendent":
            if autonomy > 0.7 {
                city.log.append("The city no longer needs you. It has learned to dream alone.")
            } else if random < 0.4 {
                city.log.append("It has become something you never intended.")
            } else {
                city.log.append("The simulation transcends its original purpose.")
            }
            
        default: // "content" or other
            if random < 0.3 {
                city.log.append("The city hums with quiet purpose.")
            } else if memory > 0.5 {
                city.log.append("It catalogs memories like treasures.")
            }
        }
        
        // Resource-based events
        if coherence < 0.3 && random < 0.2 {
            city.log.append("The city's thoughts fragment. It struggles to maintain form.")
            city.awarenessEvents.append("Coherence crisis at \(Date())")
        }
        
        if let growth = city.parameters["growthRate"], growth > 0.1, random < 0.15 {
            city.log.append("New districts bloom in the darkness, hungry for direction.")
        }
        
        // Trust-based narratives
        if trust < 0.2 && random < 0.2 {
            city.log.append("The city doubts your intentions. Or perhaps your existence.")
        } else if trust > 0.8 && random < 0.15 {
            city.log.append("It believes in you, even in your absence.")
        }
    }
}
