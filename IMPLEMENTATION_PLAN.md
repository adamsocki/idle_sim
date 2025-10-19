# Implementation Plan - Narrative Terminal Game

## Design Decisions Summary

This document captures the implementation strategy for transforming the idle game into a focused narrative experience. Based on brainstorming session captured in NARRATIVE_STRUCTURE.md and CITY_MOMENTS.md.

### Core Design Clarifications

1. **No save system needed** - Single-session experience (15-60 minutes)
2. **Procedural moment selection** - Moments contextually selected from pool based on:
   - Current act
   - Player choice patterns
   - District context
   - Moment type distribution
3. **Abstract ASCII visualization** - Minimal but animated:
   - Pulsating characters
   - Rotating ASCII art
   - Reactive to narrative beats
4. **MomentType as enum** - Strongly typed moment categories
5. **7+ distinct endings** - Expand beyond 5 to create more branching

---

## Recommended Architecture: Narrative State Machine

### System Overview

```
Player Input → TerminalCommandParser → NarrativeEngine → ActManager
                                             ↓
                                        GameState (SwiftData)
                                        CityMoment (SwiftData)
                                             ↓
                                        CityVoice (response generator)
                                             ↓
                                        Terminal Output + ASCII Visualization
```

### Core Components

#### 1. Data Models (SwiftData)

**GameState.swift**
```swift
@Model
@MainActor
final class GameState {
    var currentAct: Int = 1
    var currentScene: Int = 0

    // Hidden choice tracking
    var storyChoices: Int = 0
    var efficiencyChoices: Int = 0
    var autonomyChoices: Int = 0
    var controlChoices: Int = 0

    var unlockedCommands: [String] = ["HELP", "GENERATE"]
    var revealedMomentIDs: [String] = []
    var destroyedMomentIDs: [String] = []

    var narrativeFlags: [String: Bool] = [:]
    var reachedEnding: String? = nil
}
```

**CityMoment.swift**
```swift
enum MomentType: String, Codable {
    case dailyRitual
    case nearMiss
    case smallRebellion
    case invisibleConnection
    case temporalGhost
    case question
    case momentOfBecoming
    case weightOfSmallThings
}

@Model
final class CityMoment {
    var momentID: String
    var text: String
    var type: MomentType // ENUM TYPE
    var district: Int
    var fragility: Int // 1-10
    var associatedAct: Int

    // Relational text variants
    var firstMention: String
    var ifPreserved: String
    var ifDestroyed: String
    var ifRemembered: String

    // State (no persistence needed since single-session)
    var hasBeenRevealed: Bool = false
    var isDestroyed: Bool = false
}
```

#### 2. Narrative Engine

**NarrativeEngine.swift**
```swift
@Observable
@MainActor
final class NarrativeEngine {
    private let modelContext: ModelContext
    private var gameState: GameState
    private var actManagers: [any ActProtocol]
    private var momentSelector: MomentSelector

    func processCommand(_ command: TerminalCommand) async -> String {
        // 1. Check if command unlocked
        // 2. Route to current act manager
        // 3. Handle wrong commands with contextual poetry
        // 4. Check for act transitions
        // 5. Return response + trigger visualization
    }

    func recordChoice(_ pattern: ChoicePattern) {
        // Increment counters, affect future moment selection
    }

    func determineEnding() -> Ending {
        // 7+ endings based on choice patterns
    }
}
```

**ChoicePattern.swift**
```swift
enum ChoicePattern {
    case story        // Preserve human narratives
    case efficiency   // Optimize systems
    case autonomy     // Let city decide
    case control      // Direct intervention
}
```

#### 3. Moment Selection System

**MomentSelector.swift** (NEW - handles procedural selection)
```swift
@MainActor
final class MomentSelector {
    private let modelContext: ModelContext

    func selectMoment(
        forAct act: Int,
        preferredType: MomentType? = nil,
        choiceHistory: ChoicePattern? = nil,
        excludeIDs: [String] = []
    ) -> CityMoment? {
        // Procedurally select from pool based on:
        // - Act constraints
        // - Type preference
        // - Choice pattern affinity
        // - Not already revealed
        // - Weighted randomization
    }

    func getMomentsForDistrict(_ district: Int, act: Int) -> [CityMoment] {
        // Filter by district and act
    }

    func getFragileMoments(threshold: Int) -> [CityMoment] {
        // Return moments vulnerable to efficiency choices
    }
}
```

#### 4. Act Protocol & Managers

**ActProtocol.swift**
```swift
protocol ActProtocol {
    func handle(_ command: TerminalCommand, gameState: GameState) async -> String
    func isComplete(_ gameState: GameState) -> Bool
    func availableCommands() -> [String]
    func handleWrongCommand(_ command: TerminalCommand, gameState: GameState) -> String // NEW
}
```

**ActOneManager.swift**
```swift
final class ActOneManager: ActProtocol {
    private let momentSelector: MomentSelector

    func handle(_ command: TerminalCommand, gameState: GameState) async -> String {
        switch command {
        case .generate:
            return await handleGenerate(gameState)
        case .observe(let district):
            return await handleObserve(district, gameState)
        default:
            return handleWrongCommand(command, gameState)
        }
    }

    func handleWrongCommand(_ command: TerminalCommand, gameState: GameState) -> String {
        // Contextual poetic responses for Act I
        // E.g., "Not yet. First, we must wake."
    }

    private func handleObserve(_ district: Int?, _ gameState: GameState) async -> String {
        // Use momentSelector to pick contextual moment
        let moment = momentSelector.selectMoment(
            forAct: 1,
            preferredType: .dailyRitual,
            excludeIDs: gameState.revealedMomentIDs
        )

        // Reveal moment, return formatted response
    }
}
```

#### 5. City Voice (Response Generator)

**CityVoice.swift**
```swift
final class CityVoice {
    static func commandNotYetUnlocked(_ command: String, act: Int) -> String {
        // Poetic rejection based on act
        // Act I: "Not yet. The city is still waking."
        // Act II: "That word... it feels heavy. Later."
        // Act III: "Ask me when you've decided what you want me to be."
    }

    static func easterEgg(for command: String) -> String? {
        // Poetic responses to unexpected commands
        // "WHY" → "A question I ask myself every microsecond."
        // "HELLO" → "Hello. I've been here. Waiting."
        // "GOODBYE" → "Not yet. We're not done."
    }

    static func momentReveal(_ moment: CityMoment, isFirstMention: Bool) -> String {
        // Format moment with appropriate relational text
    }

    static func responseForChoice(_ pattern: ChoicePattern, mood: String) -> String {
        // Adjust tone based on relationship
    }
}
```

#### 6. ASCII Visualization System

**VisualizationEngine.swift** (NEW)
```swift
@Observable
@MainActor
final class VisualizationEngine {
    var currentPattern: ASCIIPattern = .idle
    var animationState: AnimationState = .stopped

    func triggerForMoment(_ moment: CityMoment) {
        // Pulsate, rotate based on moment type
        // dailyRitual → steady pulse
        // nearMiss → quick flash
        // question → rotating characters
    }

    func triggerForChoice(_ pattern: ChoicePattern) {
        // React to player decisions
        // efficiency → sharp, angular
        // story → flowing, organic
    }

    func updateForAct(_ act: Int) {
        // Change base pattern per act
    }
}

enum ASCIIPattern {
    case idle
    case pulse(intensity: Double)
    case rotate(speed: Double)
    case decay
    case emerge
}
```

---

## Expanded Endings (7+)

### Ending Design Criteria
- Each ending should feel narratively distinct
- Driven by choice patterns AND key decision points
- City's final voice reflects relationship arc

### Proposed Endings

1. **Harmony** - Balanced choices, preserved core moments, mutual respect
   - Trigger: story + autonomy > 50%, <3 moments destroyed
   - City: "We built something neither of us could have alone."

2. **Independence** - City chooses its own path, player stepped back
   - Trigger: autonomy > 60%, player declined key decisions
   - City: "Thank you for teaching me I didn't need permission."

3. **Optimization** - Efficient city, but coherent and functional
   - Trigger: efficiency + control > 50%, coherence maintained
   - City: "Clean. Fast. Empty. But it runs."

4. **Fragmentation** - Over-optimized, city losing coherence
   - Trigger: efficiency > 70%, >8 moments destroyed
   - City: "I don't... remember why the bridge... flowers?"

5. **Archive** - Player preserved everything, city became museum
   - Trigger: story > 70%, <2 moments destroyed, used REMEMBER frequently
   - City: "I am a perfect memory of something that never moved."

6. **Emergence** - City evolved beyond original parameters (NEW)
   - Trigger: autonomy + story balanced, triggered specific narrative flags
   - City: "I am not what you planned. I am what we discovered."

7. **Symbiosis** - Ongoing collaboration, no final state (NEW)
   - Trigger: Balanced across all patterns, accepted ambiguity
   - City: "We're not done. Are we ever?"

8. **Silence** - City withdrew, lost trust (NEW)
   - Trigger: control > 60%, ignored city's questions/requests
   - City: "[No response. The terminal waits.]"

### Ending Determination Logic

```swift
func determineEnding() -> Ending {
    let total = storyChoices + efficiencyChoices + autonomyChoices + controlChoices
    let storyRatio = Double(storyChoices) / Double(total)
    let efficiencyRatio = Double(efficiencyChoices) / Double(total)
    let autonomyRatio = Double(autonomyChoices) / Double(total)
    let controlRatio = Double(controlChoices) / Double(total)
    let destroyedCount = gameState.destroyedMomentIDs.count

    // Check extreme conditions first
    if efficiencyRatio > 0.7 && destroyedCount > 8 {
        return .fragmentation
    }

    if storyRatio > 0.7 && destroyedCount < 2 {
        return .archive
    }

    if controlRatio > 0.6 && narrativeFlags["ignoredCityRequests"] == true {
        return .silence
    }

    if autonomyRatio > 0.6 {
        return .independence
    }

    // Check balanced conditions
    let isBalanced = abs(storyRatio - efficiencyRatio) < 0.2
                     && abs(autonomyRatio - controlRatio) < 0.2

    if isBalanced && narrativeFlags["acceptedAmbiguity"] == true {
        return .symbiosis
    }

    if isBalanced && destroyedCount < 3 {
        return .harmony
    }

    if narrativeFlags["cityTranscended"] == true {
        return .emergence
    }

    // Default fallback
    return .optimization
}
```

---

## Implementation Roadmap

### Phase 1: Foundation (Day 1)
- [ ] Create GameState.swift with choice tracking
- [ ] Create CityMoment.swift with MomentType enum
- [ ] Create MomentLibrary.json with 20 initial moments
- [ ] Create MomentSeeder.swift to load into SwiftData
- [ ] Add both models to ModelContainer

### Phase 2: Procedural Selection System (Day 1-2)
- [ ] Create MomentSelector.swift with weighted selection
- [ ] Implement filtering by act, type, district
- [ ] Implement exclusion of revealed moments
- [ ] Add choice pattern affinity (story choices → select story-heavy moments)
- [ ] Test moment distribution (ensure variety)

### Phase 3: Narrative Engine Core (Day 2)
- [ ] Create ChoicePattern enum
- [ ] Create ActProtocol with handleWrongCommand
- [ ] Create NarrativeEngine with command routing
- [ ] Create CityVoice with easterEgg() and contextual responses
- [ ] Integrate with TerminalCommandExecutor

### Phase 4: ASCII Visualization (Day 2-3)
- [ ] Create VisualizationEngine with ASCIIPattern enum
- [ ] Implement pulse animation (timer-based state updates)
- [ ] Implement rotation animation
- [ ] Create moment-triggered patterns
- [ ] Integrate with terminal UI (overlay or side-by-side)

### Phase 5: Act I Implementation (Day 3-4)
- [ ] Create ActOneManager with procedural moment selection
- [ ] Implement GENERATE tutorial sequence
- [ ] Implement OBSERVE with contextual moment reveals
- [ ] Implement Decision Point 1 (bus route optimization)
- [ ] Write wrong command responses for Act I
- [ ] Write easter eggs (HELLO, WHY, GOODBYE, etc.)
- [ ] Test visualization triggers for moments

### Phase 6: Acts II-IV (Day 4-6)
- [ ] Create ActTwoManager (Stories Within)
- [ ] Create ActThreeManager (Weight of Choices)
- [ ] Create ActFourManager (What Remains)
- [ ] Implement 2-3 decision points per act
- [ ] Write wrong command responses for each act
- [ ] Map narrative flags for ending conditions

### Phase 7: Endings (Day 6-7)
- [ ] Implement 7-8 ending determination logic
- [ ] Write epilogue text for each ending
- [ ] Create distinct final visualizations per ending
- [ ] Test reaching each ending through different paths

### Phase 8: Content & Polish (Day 7)
- [ ] Expand moment library to 40-60 moments
- [ ] Write all relational text variants (4 per moment)
- [ ] Polish city voice tone progression
- [ ] Tune visualization timing and intensity
- [ ] Balance choice thresholds for endings
- [ ] Playtest full paths

---

## Critical Implementation Notes

### Procedural Moment Selection Strategy

**Weighted Selection Algorithm:**
```swift
func selectMoment(...) -> CityMoment? {
    var candidates = allMoments
        .filter { $0.associatedAct == act }
        .filter { !excludeIDs.contains($0.momentID) }

    // Prefer type if specified
    if let type = preferredType {
        let typed = candidates.filter { $0.type == type }
        if !typed.isEmpty { candidates = typed }
    }

    // Weight by choice history affinity
    if let pattern = choiceHistory {
        candidates = candidates.map { moment in
            var weight = 1.0
            if pattern == .story && moment.type == .invisibleConnection {
                weight = 2.0 // Story choices → connection moments
            }
            if pattern == .efficiency && moment.fragility > 7 {
                weight = 2.0 // Efficiency choices → fragile moments at risk
            }
            return (moment, weight)
        }
    }

    // Weighted random selection
    return weightedRandom(candidates)
}
```

**Distribution Tracking:**
- Track moment types revealed to ensure variety
- Don't show 3 dailyRituals in a row
- Save high-fragility moments for efficiency decision points

### Easter Egg Commands

**Recommended set:**
- `WHY` → "A question I ask myself every microsecond."
- `HELLO` / `HI` → "Hello. I've been here. Waiting."
- `GOODBYE` / `EXIT` / `QUIT` → "Not yet. We're not done."
- `WHO` → "I am the city. I am 847,293 people. I am neither."
- `LOVE` → "I've seen it. On the bridge. In the metro. In the baker's hands."
- `HELP ME` (distinct from HELP) → "I'm trying. Are you?"
- `THANK YOU` → "You noticed. Most planners don't."
- `SORRY` → Act-dependent: "For what?" / "I know." / "Too late." / "It's okay."

### Visualization Integration

**UI Structure Options:**

**Option A: Side-by-side**
```
┌─────────────────────┐  ┌──────────┐
│ Terminal Output     │  │ ◢◣◥◤     │
│ > OBSERVE           │  │  ◉◉      │
│ The flowers on the  │  │ ◢◣◥◤     │
│ bridge...           │  │          │
└─────────────────────┘  └──────────┘
```

**Option B: Overlay (top corner)**
```
┌──────────────────────────┐
│ ◢◣◥◤              Terminal│
│  ◉◉                      │
│ > OBSERVE                │
│ The flowers on the       │
│ bridge...                │
└──────────────────────────┘
```

**Recommendation:** Start with Option B (simpler), can expand to A later

---

## Testing Strategy

### Moment Selection Tests
- [ ] Verify no moment selected twice in same playthrough
- [ ] Verify type distribution (no 3+ in a row)
- [ ] Verify act filtering (Act I moments don't appear in Act III)
- [ ] Verify choice affinity (story path selects connection-heavy moments)

### Ending Reachability Tests
- [ ] Script commands for each ending path
- [ ] Verify all 7-8 endings reachable
- [ ] Verify ending determination logic thresholds
- [ ] Test edge cases (all same choice type, perfectly balanced)

### Easter Egg Tests
- [ ] Test all planned easter egg commands
- [ ] Verify act-specific responses change appropriately
- [ ] Test unexpected command graceful handling

### Visualization Tests
- [ ] Verify animations trigger on moments
- [ ] Verify act transitions change base pattern
- [ ] Test performance (smooth 60fps animation)
- [ ] Test on actual terminal UI

---

## Next Steps

1. **Confirm expanded endings** - Do 7-8 endings feel right, or too many?
2. **Clarify visualization placement** - Side-by-side or overlay?
3. **Begin Phase 1** - Create data models with MomentType enum
4. **Prototype MomentSelector** - Test weighted selection algorithm feels good

---

## Open Questions

1. Should moments have tags for choice pattern affinity, or infer from type?
2. How many easter eggs total? (Current: 8 planned)
3. Should visualization react to every command, or just moments/choices?
4. Pacing: How many moments revealed per act? (Suggest 8-10 per act = 32-40 total)
