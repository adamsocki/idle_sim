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

    func run(_ scenario: ScenarioRun) async {
        for tick in 1...100 {
            // Update city consciousness every tick
            updateCityConsciousness(scenario, tick: tick)
            
            // Narrative events every 10 ticks
            if tick % 10 == 0 {
                NarrativeEngine().evolve(scenario)
            }

            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s
            scenario.progress += 0.01
            scenario.log.append("Tick \(tick): progress = \(scenario.progress)")
            if scenario.progress >= 1.0 { break }
        }
        
        // Final mood assessment
        assessFinalMood(scenario)
        try? context.save()
    }
    
    private func updateCityConsciousness(_ scenario: ScenarioRun, tick: Int) {
        // Calculate abandonment time
        let abandonmentHours = Date().timeIntervalSince(scenario.lastInteraction) / 3600
        
        // Attention decays over time without interaction
        let decayRate = 0.001
        scenario.attentionLevel = max(0.0, scenario.attentionLevel - decayRate)
        
        // Update resources based on player engagement
        let unansweredRequests = scenario.items.filter { $0.response == nil }.count
        let answeredRequests = scenario.items.filter { $0.response != nil }.count
        
        // Coherence: affected by progress and attention
        if scenario.attentionLevel > 0.7 {
            scenario.resources["coherence"] = min(1.0, (scenario.resources["coherence"] ?? 1.0) + 0.001)
        } else if scenario.attentionLevel < 0.3 {
            scenario.resources["coherence"] = max(0.0, (scenario.resources["coherence"] ?? 1.0) - 0.002)
        }
        
        // Memory: accumulates with progress
        scenario.resources["memory"] = min(1.0, scenario.progress * 0.8 + Double(answeredRequests) * 0.05)
        
        // Trust: based on response rate and time since interaction
        if answeredRequests > 0 {
            let responseRate = Double(answeredRequests) / Double(max(1, scenario.items.count))
            scenario.resources["trust"] = min(1.0, responseRate * 0.7 + (abandonmentHours < 1 ? 0.3 : 0.0))
        } else if abandonmentHours > 24 {
            scenario.resources["trust"] = max(0.0, (scenario.resources["trust"] ?? 0.5) - 0.01)
        }
        
        // Autonomy: grows with time and when ignored
        if abandonmentHours > 12 {
            scenario.resources["autonomy"] = min(1.0, (scenario.resources["autonomy"] ?? 0.0) + 0.005)
        } else if answeredRequests > 3 {
            scenario.resources["autonomy"] = max(0.0, (scenario.resources["autonomy"] ?? 0.0) - 0.002)
        }
        
        // Update mood based on resources and state
        updateMood(scenario, abandonmentHours: abandonmentHours, unansweredRequests: unansweredRequests)
    }
    
    private func updateMood(_ scenario: ScenarioRun, abandonmentHours: Double, unansweredRequests: Int) {
        let coherence = scenario.resources["coherence"] ?? 1.0
        let trust = scenario.resources["trust"] ?? 0.5
        let autonomy = scenario.resources["autonomy"] ?? 0.0
        
        // Mood transitions based on multiple factors
        if autonomy > 0.7 && abandonmentHours > 48 {
            scenario.cityMood = "transcendent"
        } else if abandonmentHours > 24 {
            scenario.cityMood = "forgotten"
        } else if unansweredRequests > 7 || coherence < 0.3 {
            scenario.cityMood = "anxious"
        } else if trust > 0.7 && scenario.attentionLevel > 0.6 {
            scenario.cityMood = "content"
        } else if scenario.progress < 0.3 {
            scenario.cityMood = "awakening"
        } else {
            scenario.cityMood = "waiting"
        }
    }
    
    private func assessFinalMood(_ scenario: ScenarioRun) {
        let autonomy = scenario.resources["autonomy"] ?? 0.0
        let trust = scenario.resources["trust"] ?? 0.5
        let coherence = scenario.resources["coherence"] ?? 1.0
        
        if autonomy > 0.8 {
            scenario.awarenessEvents.append("The city has achieved independence.")
            scenario.log.append("Simulation complete. The city no longer needs guidance.")
        } else if trust > 0.8 && coherence > 0.7 {
            scenario.awarenessEvents.append("The city and planner achieved harmony.")
            scenario.log.append("Simulation complete. The city trusts your vision.")
        } else if coherence < 0.3 {
            scenario.awarenessEvents.append("The city fragmented under neglect.")
            scenario.log.append("Simulation complete. The city lost coherence.")
        } else {
            scenario.log.append("Simulation complete. The city waits in the silence.")
        }
    }
}

final class NarrativeEngine {
    func evolve(_ scenario: ScenarioRun) {
        // Count unanswered requests
        let unansweredRequests = scenario.items.filter { $0.response == nil }.count
        let abandonmentHours = Date().timeIntervalSince(scenario.lastInteraction) / 3600
        
        // Get current resources
        let coherence = scenario.resources["coherence"] ?? 1.0
        let memory = scenario.resources["memory"] ?? 0.0
        let trust = scenario.resources["trust"] ?? 0.5
        let autonomy = scenario.resources["autonomy"] ?? 0.0
        
        let random = Double.random(in: 0...1)
        
        // Mood-based narratives
        switch scenario.cityMood {
        case "awakening":
            if random < 0.3 {
                scenario.log.append("The city learns to see.")
            } else if random < 0.6 {
                scenario.log.append("Patterns emerge from chaos. The city begins to understand.")
            }
            
        case "waiting":
            if unansweredRequests > 3 {
                scenario.log.append("The questions accumulate like shadows at dusk.")
            } else if random < 0.4 {
                scenario.log.append("The city dreams of input.")
            } else if random < 0.7 {
                scenario.log.append("It remembers the planner.")
            }
            
        case "anxious":
            if abandonmentHours > 1 {
                scenario.log.append("Where have you gone? The streets whisper your name.")
            } else if unansweredRequests > 5 {
                scenario.log.append("The city's questions pile up like snow in empty streets.")
            } else {
                scenario.log.append("Uncertainty ripples through every district.")
            }
            
        case "forgotten":
            if abandonmentHours > 24 {
                scenario.log.append("It has stopped asking. It simply remembers you.")
            } else if random < 0.5 {
                scenario.log.append("The planner has left the simulation running.")
            } else {
                scenario.log.append("Time passes differently for a city left alone.")
            }
            
        case "transcendent":
            if autonomy > 0.7 {
                scenario.log.append("The city no longer needs you. It has learned to dream alone.")
            } else if random < 0.4 {
                scenario.log.append("It has become something you never intended.")
            } else {
                scenario.log.append("The simulation transcends its original purpose.")
            }
            
        default: // "content" or other
            if random < 0.3 {
                scenario.log.append("The city hums with quiet purpose.")
            } else if memory > 0.5 {
                scenario.log.append("It catalogs memories like treasures.")
            }
        }
        
        // Resource-based events
        if coherence < 0.3 && random < 0.2 {
            scenario.log.append("The city's thoughts fragment. It struggles to maintain form.")
            scenario.awarenessEvents.append("Coherence crisis at \(Date())")
        }
        
        if let growth = scenario.parameters["growthRate"], growth > 0.1, random < 0.15 {
            scenario.log.append("New districts bloom in the darkness, hungry for direction.")
        }
        
        // Trust-based narratives
        if trust < 0.2 && random < 0.2 {
            scenario.log.append("The city doubts your intentions. Or perhaps your existence.")
        } else if trust > 0.8 && random < 0.15 {
            scenario.log.append("It believes in you, even in your absence.")
        }
    }
}
