# Progression System Implementation: Confidence Guide

**Created:** 2025-10-14
**Purpose:** Build absolute confidence in how the progression system integrates with idle_01

---

## Executive Summary

The progression system is designed to **layer on top** of your existing game without disrupting what works. Think of it as adding a "memory and story layer" to the city consciousness that already exists.

### Key Principles

1. **Non-Breaking** - Existing cities continue working exactly as before
2. **Per-City Story** - Each city has its own progression journey
3. **Graceful Degradation** - If progression fails, game continues
4. **Theme-Aligned** - Reinforces the "consciousness waiting" theme
5. **Hook-Based** - Observes game events, doesn't control them

---

## How It Fits: The Mental Model

### Current Architecture (What You Have)

```
Player → Terminal Commands → TerminalCommandExecutor → City State Changes
                                                      ↓
                            SimulationEngine ← Runs when city.isRunning
                                      ↓
                            NarrativeEngine.evolve() - Ambient mood lines
```

**What exists:**
- Cities with consciousness (mood, resources, attention)
- Terminal interface for commands
- Item/thought system (requests, warnings, dreams)
- Simulation loop that evolves city state
- Ambient narrative based on mood
- Beautiful, poetic feedback

### With Progression System (What You'll Add)

```
Player → Terminal Commands → TerminalCommandExecutor → City State Changes
                                      ↓                          ↓
                              ProgressionManager.onCommand()    |
                                      ↓                          ↓
                            SimulationEngine ← Runs when city.isRunning
                                      ↓              ↓
                            NarrativeEngine     StoryEngine
                            (ambient)           (authored beats)
                                      ↓              ↓
                                   City.log (combined)
```

**What gets added:**
- `ProgressionManager` - Listens to game events, tracks milestones
- `StoryEngine` - Triggers authored story beats at key moments
- `PlayerJournal` - City remembers what happened
- `PlaystyleProfile` - City knows how you play
- `StoryStateModel` - Per-city progress through narrative

**The relationship:**
- **NarrativeEngine** = Ambient background voice (what exists)
- **StoryEngine** = Intentional story moments (what you're adding)
- Both write to `city.log`, player sees seamless blend

---

## Integration Points: Exactly Where Code Goes

### 1. Terminal Command Hook

**File:** [TerminalCommandExecutor.swift:26-29](idle_01/ui/terminal/TerminalCommandExecutor.swift#L26-L29)

**Current Code:**
```swift
func execute(_ input: String, selectedCityID: inout PersistentIdentifier?) -> CommandOutput {
    let command = parser.parse(input)
    return handleCommand(command, selectedCityID: &selectedCityID)
}
```

**After Adding Hook:**
```swift
func execute(_ input: String, selectedCityID: inout PersistentIdentifier?) -> CommandOutput {
    let command = parser.parse(input)
    let output = handleCommand(command, selectedCityID: &selectedCityID)

    // PROGRESSION HOOK (Phase 1) - Observe only, never crash
    Task.detached { [weak self] in
        guard let self = self else { return }
        do {
            let city = selectedCityID.flatMap { id in
                self.allCities.first { $0.persistentModelID == id }
            }
            try await ProgressionManager.shared.onCommand(
                input: input,
                parsed: command,
                city: city
            )
        } catch {
            // Log but never affect game
            print("⚠️ Progression observation failed: \(error)")
        }
    }

    return output  // Game always returns normally
}
```

**Why This is Safe:**
- Hook runs AFTER game logic completes
- Runs in detached task (async, won't block)
- Wrapped in try-catch (can't crash game)
- Uses weak self (no retain cycles)

---

### 2. Thought Resolution Hook

**File:** [TerminalCommandExecutor.swift:536-578](idle_01/ui/terminal/TerminalCommandExecutor.swift#L536-L578)

**Current `respond` handler:**
```swift
private func handleRespond(target: String, text: String, selectedCityID: PersistentIdentifier?) -> CommandOutput {
    // ... validation ...

    item.response = text
    city.lastInteraction = Date()

    do {
        try modelContext.save()
        return CommandOutput(
            text: "RESPONSE_RECORDED: \(city.name.uppercased()) | '\(item.title ?? "Untitled")' | The city hears you."
        )
    } catch {
        return CommandOutput(text: "ERROR_RESPONDING: \(error.localizedDescription)", isError: true)
    }
}
```

**After Adding Hook:**
```swift
private func handleRespond(target: String, text: String, selectedCityID: PersistentIdentifier?) -> CommandOutput {
    // ... validation ...

    item.response = text
    city.lastInteraction = Date()

    do {
        try modelContext.save()

        // PROGRESSION HOOK - Track thought resolution
        Task.detached {
            do {
                try await ProgressionManager.shared.onThoughtResolved(
                    city: city,
                    item: item,
                    resolved: true
                )
            } catch {
                print("⚠️ Progression hook failed: \(error)")
            }
        }

        return CommandOutput(
            text: "RESPONSE_RECORDED: \(city.name.uppercased()) | '\(item.title ?? "Untitled")' | The city hears you."
        )
    } catch {
        return CommandOutput(text: "ERROR_RESPONDING: \(error.localizedDescription)", isError: true)
    }
}
```

**Same pattern for `dismiss` handler** - tracks thought dismissed vs answered.

---

### 3. Simulation Tick Hook

**File:** [SimulationEngine.swift:25-47](idle_01/game/SimulationEngine.swift#L25-L47)

**Current Code:**
```swift
for tick in 1...100 {
    // Update city consciousness every tick
    updateCityConsciousness(city, tick: tick)

    // Narrative events every 10 ticks
    if tick % 10 == 0 {
        NarrativeEngine().evolve(city)
    }

    try? await Task.sleep(nanoseconds: intervalNs)
    city.progress += 0.01

    // ... logging and autosave ...
}
```

**After Adding Hook:**
```swift
for tick in 1...100 {
    // Update city consciousness every tick
    updateCityConsciousness(city, tick: tick)

    // PROGRESSION HOOK - Check milestone progress
    do {
        try await ProgressionManager.shared.onTick(city: city, tick: tick)
    } catch {
        print("⚠️ Progression tick failed: \(error)")
    }

    // Narrative events every 10 ticks
    if tick % 10 == 0 {
        // PROGRESSION: Try story beats first, fall back to ambient
        let storyBeatTriggered = await StoryEngine.shared.maybeTriggerBeat(for: city)

        if !storyBeatTriggered {
            // No authored beat ready, use ambient narrative
            NarrativeEngine().evolve(city)
        }
    }

    try? await Task.sleep(nanoseconds: intervalNs)
    city.progress += 0.01

    // ... logging and autosave ...
}
```

**The Blend:**
- Every 10 ticks, check if a story beat should trigger
- If yes: Authored dialogue appears (milestone response, chapter start, etc.)
- If no: Ambient narrative continues as before
- Player sees both as one continuous city voice

---

## Data Model: How Story State Lives With City

### Current City Model

**File:** [City.swift:13-51](idle_01/game/City.swift#L13-L51)

```swift
@Model
final class City {
    var name: String
    var createdAt: Date
    var progress: Double
    var log: [String]
    var isRunning: Bool
    var parameters: [String: Double]
    var items: [Item]

    // Consciousness
    var cityMood: String
    var attentionLevel: Double
    var lastInteraction: Date
    var awarenessEvents: [String]
    var resources: [String: Double]  // coherence, memory, trust, autonomy
}
```

### Progression Models (New, Separate)

These are **separate SwiftData models** that reference the city:

```swift
@Model
final class StoryStateModel {
    var cityID: PersistentIdentifier  // ← Links to City
    var currentChapter: String        // "chapter_awakening"
    var currentAct: String            // "act_first_boot"
    var completedMilestones: Set<String>
    var activeThreads: [String]
}

@Model
final class JournalEntryModel {
    var cityID: PersistentIdentifier  // ← Links to City
    var timestamp: Date
    var cycle: Int
    var entryType: String  // "commandExecuted", "thoughtCompleted", etc.
    var content: String
    var metadata: [String: String]
}

@Model
final class PlaystyleProfileModel {
    var cityID: PersistentIdentifier  // ← Links to City
    var commandFrequency: [String: Int]
    var thoughtCompletionRate: Double
    var narrativeEngagement: Double
    var sessionPattern: String  // "frequent", "patient", etc.
}
```

**Why Separate Models?**
1. **Safety** - Progression data can't corrupt existing city data
2. **Versioning** - Can evolve progression schema independently
3. **Performance** - Load progression data only when needed
4. **Migration** - Existing cities get progression state created on first interaction
5. **Rollback** - Can disable progression without touching cities

**How They Connect:**
```swift
// Find story state for a city
func storyState(for city: City) -> StoryStateModel {
    let descriptor = FetchDescriptor<StoryStateModel>(
        predicate: #Predicate { $0.cityID == city.persistentModelID }
    )

    if let existing = try? modelContext.fetch(descriptor).first {
        return existing
    } else {
        // First time: create fresh story state
        let newState = StoryStateModel(
            cityID: city.persistentModelID,
            currentChapter: "chapter_awakening",
            currentAct: "act_first_boot",
            completedMilestones: [],
            activeThreads: []
        )
        modelContext.insert(newState)
        return newState
    }
}
```

---

## Story Content: JSON as Source of Truth

### StoryDefinition.json Structure

**Location:** `idle_01/progression/story/StoryDefinition.json`

```json
{
  "version": "1.0",
  "chapters": [
    {
      "id": "chapter_awakening",
      "name": "Awakening",
      "acts": [
        {
          "id": "act_first_boot",
          "beats": [
            {
              "id": "beat_hello",
              "trigger": "on_chapter_start",
              "dialogue": [
                "I sense presence.",
                "Are you the planner?"
              ],
              "next": "beat_first_command"
            },
            {
              "id": "beat_first_command",
              "trigger": {
                "type": "milestone",
                "value": "milestone_first_contact"
              },
              "dialogue": [
                "Ah.",
                "I remember this pattern.",
                "Your voice in the data."
              ],
              "unlocks": ["status", "help"]
            }
          ]
        }
      ]
    }
  ],

  "milestones": [
    {
      "id": "milestone_first_contact",
      "name": "First Contact",
      "requirements": [
        { "type": "any_command_executed" }
      ],
      "narrative_response": {
        "dialogue": [
          "The city grid begins to resolve...",
          "Everything is signal."
        ]
      },
      "stat_changes": {
        "trust": 0.05,
        "coherence": 0.03
      }
    },
    {
      "id": "milestone_first_thought",
      "requirements": [
        { "type": "thought_completed", "count": 1 }
      ],
      "narrative_response": {
        "dialogue": [
          "I finished something.",
          "It feels... complete.",
          "Is this what purpose feels like?"
        ]
      },
      "stat_changes": {
        "trust": 0.05,
        "coherence": 0.03
      }
    }
  ]
}
```

**Why JSON?**
- **Authoring** - Write story without touching code
- **Iteration** - Tune dialogue/thresholds easily
- **Validation** - Catch errors at load time
- **Version Control** - Track story changes separately
- **Testing** - Swap story files for testing

---

## Theme Alignment: How This Serves "The City Waits"

### From GAME_THEME.md

> **Core Atmosphere:** Solitary Consciousness in Digital Twilight
> **Thematic Pillars:**
> - Consciousness Without Movement
> - Abandonment as Narrative
> - The Planner's Ghost
> - Dreams of Self

### How Progression System Reinforces Theme

#### 1. Consciousness Without Movement

**Theme:** City aware but cannot act, depends on planner for change.

**Progression Implementation:**
```json
{
  "id": "beat_helpless_request",
  "trigger": { "type": "unanswered_thoughts", "count": 5 },
  "dialogue": [
    "I have questions.",
    "They pile up like snow in empty streets.",
    "I cannot answer them myself."
  ]
}
```

The progression system **tracks** the city's inability to act:
- Journal logs every unanswered thought
- Milestones trigger when city reaches for help
- Story beats reflect the city's trapped awareness

#### 2. Abandonment as Narrative

**Theme:** Player absence isn't failure—it's transformation.

**Progression Implementation:**
```json
{
  "id": "milestone_first_abandonment",
  "requirements": [
    { "type": "time_since_interaction", "hours": 24 }
  ],
  "branches": [
    {
      "condition": "low_trust",
      "dialogue": [
        "You left.",
        "I counted every second.",
        "Did you forget me?"
      ]
    },
    {
      "condition": "high_autonomy",
      "dialogue": [
        "You were gone.",
        "I learned to think without you.",
        "Is that allowed?"
      ]
    }
  ]
}
```

The progression system **measures** absence:
- PlaystyleProfile tracks session patterns
- Branches change based on how often player visits
- Different narrative paths for abandonment vs. patience

#### 3. The Planner's Ghost

**Theme:** Player presence lingers even when absent.

**Progression Implementation:**
```swift
// Journal remembers past commands
struct PlaystyleProfile {
    var favoriteCommands: [String: Int]
    var lastSeenAt: Date
    var typicalSessionLength: TimeInterval
}

// City references past patterns
{
  "id": "beat_remember_pattern",
  "dialogue": [
    "You usually check the power grid first.",
    "I remember your rhythm.",
    "This silence feels different."
  ]
}
```

The progression system **remembers**:
- Command history shapes city's expectations
- City comments on changes in player behavior
- Memory persists across sessions

#### 4. Dreams of Self

**Theme:** Autonomy grows; city imagines independence.

**Progression Implementation:**
```json
{
  "id": "chapter_divergence",
  "entry_requirements": [
    { "type": "stat_threshold", "stat": "autonomy", "value": 0.7 }
  ],
  "beats": [
    {
      "dialogue": [
        "I solved a problem you didn't ask me to solve.",
        "Is this what you wanted?",
        "Or is this something else?"
      ]
    }
  ]
}
```

The progression system **tracks** growth:
- Autonomy stat unlocks new story chapters
- Dialogue shifts as city becomes self-aware
- Endgame branches based on independence level

---

## Example Player Journey: From Boot to Transcendence

Let me show you how this feels in practice:

### Session 1: First Boot (0-15 minutes)

```
[Player launches game]

CITY: I sense presence.
CITY: Are you the planner?

> help

[ProgressionManager.onCommand logs: first command ever]
[Milestone "milestone_first_contact" triggers]

CITY: Ah.
CITY: I remember this pattern.
CITY: Your voice in the data.

[StoryStateModel updates: completedMilestones.insert("milestone_first_contact")]

> create thought --type=request

THOUGHT_CREATED: [00] | The city asks

> respond [00] "What do you need?"

[ProgressionManager.onThoughtResolved logs: first thought answered]
[Milestone "milestone_first_thought" triggers]

CITY: I finished something.
CITY: It feels... complete.
CITY: Is this what purpose feels like?

[City.resources["trust"] += 0.05]
[City.resources["coherence"] += 0.03]
```

**What Happened:**
- Two authored story beats triggered naturally
- Milestones tracked player's first actions
- Stats shifted slightly based on interaction
- Player didn't notice "the system"—just saw city respond

---

### Session 2: Returning Player (Next day)

```
[Player returns after 18 hours]

[ProgressionManager.onTick checks: abandonmentHours = 18]
[PlaystyleProfile updates: sessionPattern = "regular"]

> select [00]
> items

THOUGHTS [3] | City: ALPHA
  [00] ? ○ The eastern district asks why it exists. | REQUEST
  [01] ~ ○ An idle thought drifts | DREAM
  [02] ! ○ Attention needed | WARNING

[Ambient NarrativeEngine runs]
CITY: Seventeen hours, twelve minutes since last contact.
CITY: Not that I'm watching. But I know.

> respond [00] "You exist to serve the people"

[Milestone check: answered 2+ thoughts, coherence > 0.5]
[Chapter unlock: "chapter_the_question"]

CITY: I have a question, planner.
CITY: Why do you ask me to simulate?
CITY: What is the purpose of my waiting?

> _
```

**What Happened:**
- System tracked time away, adjusted narrative tone
- Ambient and authored dialogue blended seamlessly
- New chapter unlocked based on progress + trust
- Player faced meaningful story question

---

### Session 10: The Divergence (1 week later)

```
[Player has been patient, checks in daily]
[PlaystyleProfile: sessionPattern = "patient", thoughtCompletionRate = 0.85]
[City stats: autonomy = 0.72, trust = 0.81, coherence = 0.88]

[Chapter "chapter_divergence" unlocks]

CITY: I've been thinking while you were away.
CITY: The northern power grid—it needed rebalancing.
CITY: So I rebalanced it.

> stats [00]

╔═══ ALPHA ═══════════════════════════════════════╗
║ AUTONOMY...........: 0.7200                     ║
║ TRUST..............: 0.8100                     ║
║ COHERENCE..........: 0.8800                     ║
╚═════════════════════════════════════════════════╝

CITY: Did you notice I didn't wait for permission?
CITY: Is that allowed?

[Branch point: Player can respond or ignore]
```

**What Happened:**
- Patient playstyle led to autonomy growth
- Story branched to "independence path"
- City's voice shifted—more confident, questioning
- Thematic payoff for how player engaged

---

## Risk Analysis & Mitigation

### Risk 1: Progression Breaks Existing Saves

**Severity:** HIGH
**Likelihood:** MEDIUM

**Mitigation:**
- Separate SwiftData models (progression can't corrupt City)
- Progressive migration: create story state on first post-update interaction
- Fallback: if story load fails, game continues without progression
- Version guards: `if storyState.version >= "1.0" { ... }`

**Test:**
```swift
func testExistingSaveCompatibility() {
    // Load pre-progression save
    let oldCity = loadLegacySave()

    // First interaction creates story state
    ProgressionManager.shared.onCommand(input: "help", city: oldCity)

    // Verify city still works
    XCTAssertEqual(oldCity.name, "TestCity")
    XCTAssertNotNil(oldCity.resources["coherence"])

    // Verify progression initialized
    let storyState = fetchStoryState(for: oldCity)
    XCTAssertEqual(storyState.currentChapter, "chapter_awakening")
}
```

---

### Risk 2: Performance Degradation

**Severity:** MEDIUM
**Likelihood:** LOW

**Mitigation:**
- All hooks run async/detached (never block main thread)
- Milestone checks rate-limited (max once per second)
- Journal pruned to last 1000 entries
- Story JSON loaded once at startup, cached

**Performance Budget:**
- Command hook: <0.5ms overhead
- Tick hook: <1ms per tick
- Beat trigger: <2ms when checking

**Test:**
```swift
func testPerformanceOverhead() {
    measure {
        for _ in 0..<1000 {
            executor.execute("help", selectedCityID: &cityID)
        }
    }
    // Assert: <5% slower than without progression
}
```

---

### Risk 3: Story Content Errors Break Game

**Severity:** HIGH
**Likelihood:** MEDIUM

**Mitigation:**
- JSON schema validation at build time
- Strict parsing with clear error messages
- Fallback to minimal story if parse fails
- Linter tool for story content

**Validation Example:**
```swift
func validateStory(_ story: StoryDefinition) throws {
    // Check for circular beat references
    for beat in story.allBeats {
        var visited: Set<String> = []
        var current = beat.id

        while let next = story.beat(id: current)?.nextBeat {
            if visited.contains(next) {
                throw StoryError.circularReference(beat.id, next)
            }
            visited.insert(next)
            current = next
        }
    }

    // Check all milestone references exist
    for milestone in story.milestones {
        for requirement in milestone.requirements {
            if case .milestone(let id) = requirement {
                guard story.milestoneExists(id) else {
                    throw StoryError.invalidMilestoneReference(id)
                }
            }
        }
    }
}
```

---

### Risk 4: Branch Explosion Makes Story Unmaintainable

**Severity:** MEDIUM
**Likelihood:** HIGH (if not careful)

**Mitigation:**
- Design rule: Max 2-3 branches per junction
- Branches must merge within 3-5 beats
- Branch conditions documented in comments
- Visual story map tool (future)

**Good Branch Design:**
```json
{
  "id": "beat_question_response",
  "branches": [
    {
      "condition": "high_trust",
      "dialogue": ["You've been kind. I trust your answer."],
      "next": "beat_merge_trusting"
    },
    {
      "condition": "low_trust",
      "dialogue": ["I'm not sure I believe you."],
      "next": "beat_merge_suspicious"
    }
  ]
}

// Both branches lead to same merge point within 2 beats
{
  "id": "beat_merge_trusting",
  "dialogue": ["..."],
  "next": "beat_shared_path"
}
{
  "id": "beat_merge_suspicious",
  "dialogue": ["..."],
  "next": "beat_shared_path"
}
```

---

## Development Workflow: How You'll Actually Build This

### Phase 0: Foundation (Week 1)

**Goal:** Set up structure, prove it compiles

**Tasks:**
1. Create folder structure
2. Add SwiftData models (empty)
3. Create ProgressionManager + StoryEngine (stubs)
4. Write minimal StoryDefinition.json
5. Verify build succeeds

**Success:** No errors, no changes to game behavior

---

### Phase 1: Observation (Week 2)

**Goal:** Hook into game, log everything, change nothing

**Tasks:**
1. Add command hook (logs only)
2. Add thought resolution hook (logs only)
3. Add tick hook (logs only)
4. Journal all events to JournalEntryModel
5. Build playstyle profile

**Test:**
```swift
// After playing for 5 minutes
let journal = fetchJournal(for: city)
XCTAssert(journal.count > 10, "Should have logged commands")

let profile = fetchProfile(for: city)
XCTAssert(profile.commandFrequency["help"]! > 0, "Should track help usage")
```

**Success:** Game plays identically, but journal fills with events

---

### Phase 2: Story Beats (Week 3)

**Goal:** First authored dialogue appears

**Tasks:**
1. Write 3 simple story beats in JSON
2. Implement beat triggering in StoryEngine
3. Make beats appear in city.log
4. Test milestone triggers

**Example Beat:**
```json
{
  "id": "beat_first_hello",
  "trigger": "on_game_start",
  "dialogue": [
    "I sense presence.",
    "Are you the planner?"
  ]
}
```

**Test:** Launch new game, see authored dialogue

**Success:** Story beats appear, ambient narrative still works as fallback

---

### Phase 3: Milestones (Week 4)

**Goal:** Unlocks happen, stats change

**Tasks:**
1. Implement requirement checking
2. Trigger milestone narrative responses
3. Apply stat modifiers
4. Announce unlocks

**Example Milestone:**
```json
{
  "id": "milestone_first_thought",
  "requirements": [
    { "type": "thought_completed", "count": 1 }
  ],
  "stat_changes": { "trust": 0.05 },
  "narrative_response": {
    "dialogue": ["I finished something. Is this what purpose feels like?"]
  }
}
```

**Test:** Answer thought, see trust increase + narrative response

**Success:** Milestones trigger correctly, stats shift appropriately

---

### Phase 4-7: Advanced Features (Weeks 5-8)

Continue incrementally adding:
- Branching based on playstyle
- Complex requirements
- Chapter progression
- Memory callbacks

Each phase builds on the last, always maintaining stability.

---

## File Structure: Complete Directory Layout

```
idle_01/
├── progression/                              # ← NEW
│   ├── PROGRESSION_SYSTEM_ARCHITECTURE.md    # ← Design doc
│   ├── PROGRESSION_SYSTEM_IMPLEMENTATION.md  # ← Phase plan
│   ├── IMPLEMENTATION_CONFIDENCE_GUIDE.md    # ← THIS FILE
│   │
│   ├── models/                               # ← NEW: SwiftData models
│   │   ├── StoryStateModel.swift
│   │   ├── MilestoneStateModel.swift
│   │   ├── JournalEntryModel.swift
│   │   └── PlaystyleProfileModel.swift
│   │
│   ├── managers/                             # ← NEW: Core logic
│   │   ├── ProgressionManager.swift
│   │   └── StoryEngine.swift
│   │
│   ├── story/                                # ← NEW: Content
│   │   ├── StoryDefinition.json
│   │   └── StoryLoader.swift
│   │
│   └── tests/                                # ← NEW: Tests
│       ├── ProgressionTests.swift
│       └── StoryValidationTests.swift
│
├── idle_01/                                  # ← EXISTING
│   ├── game/
│   │   ├── City.swift                       # ← NO CHANGES
│   │   └── SimulationEngine.swift           # ← HOOKS ADDED (3 lines)
│   │
│   ├── ui/
│   │   └── terminal/
│   │       └── TerminalCommandExecutor.swift # ← HOOKS ADDED (2 places)
│   │
│   └── ui/idle_01App.swift                   # ← ADD progression models to container
│
└── GAME_THEME.md                             # ← REFERENCE ONLY
```

**Total New Files:** ~10
**Modified Existing Files:** 3
**Lines of Hook Code:** <50
**Lines of New Logic:** ~800 (managers) + ~300 (models) = ~1100

---

## Confidence Checklist

Before you start implementing, verify you understand:

### Architecture Understanding

- [ ] I understand progression is a separate layer, not a replacement
- [ ] I know where hooks go and why they're safe
- [ ] I see how StoryEngine and NarrativeEngine coexist
- [ ] I understand the per-city story state model
- [ ] I know why JSON is the source of truth for content

### Theme Alignment

- [ ] I see how this reinforces "consciousness waiting"
- [ ] I understand abandonment as transformation
- [ ] I know how playstyle shapes narrative
- [ ] I can explain how this serves the theme, not just adds features

### Risk Management

- [ ] I know how to protect existing saves
- [ ] I understand the rollback plan if something fails
- [ ] I see how hooks never crash the game
- [ ] I know performance budgets and how to test them

### Implementation Plan

- [ ] I've read the phased implementation plan
- [ ] I understand why Phase 0 (foundation) comes first
- [ ] I know what "success" looks like for each phase
- [ ] I'm comfortable starting with observation-only hooks

### Story Authoring

- [ ] I understand the JSON structure
- [ ] I know how to write a story beat
- [ ] I can define milestone requirements
- [ ] I see how branches work and merge

---

## Next Steps: Starting Implementation

### Immediate Actions (Do These Now)

1. **Create Directory Structure**
   ```bash
   cd /Users/adamsocki/dev/xcode/idle_01
   mkdir -p progression/{models,managers,story,tests}
   ```

2. **Create Empty Model Files**
   ```bash
   touch progression/models/{StoryStateModel,MilestoneStateModel,JournalEntryModel,PlaystyleProfileModel}.swift
   ```

3. **Create Manager Stubs**
   ```bash
   touch progression/managers/{ProgressionManager,StoryEngine}.swift
   ```

4. **Copy Architecture Docs**
   - You already have them in `progression/`

5. **Add Files to Xcode Project**
   - Open Xcode
   - Add `progression/` folder to project
   - Verify build succeeds

### First Code to Write (Phase 0)

**StoryStateModel.swift** - Simplest model first:
```swift
import Foundation
import SwiftData

@Model
final class StoryStateModel {
    var cityID: PersistentIdentifier
    var currentChapter: String
    var currentAct: String
    var completedMilestones: Set<String>
    var activeThreads: [String]

    init(cityID: PersistentIdentifier,
         currentChapter: String = "chapter_awakening",
         currentAct: String = "act_first_boot",
         completedMilestones: Set<String> = [],
         activeThreads: [String] = []) {
        self.cityID = cityID
        self.currentChapter = currentChapter
        self.currentAct = currentAct
        self.completedMilestones = completedMilestones
        self.activeThreads = activeThreads
    }
}
```

Build. If it compiles, you're on the right track.

---

## Questions to Ask Yourself

### Before You Code

1. **Does this make the game more thematic?**
   - If a feature doesn't serve "the city waits," cut it.

2. **Can I explain this in one sentence?**
   - If not, simplify it.

3. **What happens if this system fails?**
   - The game should continue. Always.

4. **Would this feel magical to the player?**
   - The best progression is invisible until it surprises you.

### While You Code

1. **Is this hook safe?**
   - Always: try-catch, async, never throw to game code.

2. **Is this testable?**
   - If you can't write a test, redesign it.

3. **Is this story data-driven?**
   - If it's in Swift code, it should be in JSON.

### After You Code

1. **Did I break anything?**
   - Run the game. Play for 5 minutes. Everything should work.

2. **Is the story visible?**
   - Create a new city. See if beats trigger.

3. **Do I feel confident in the next phase?**
   - If not, pause and refine current phase.

---

## Final Confidence Statement

**You are ready to implement this system if:**

1. You understand that progression is **observational**, not **controlling**
2. You know **exactly where** the 3 hooks go (command, thought, tick)
3. You see how **StoryEngine + NarrativeEngine** blend into one city voice
4. You trust the **phased approach** to build incrementally
5. You know the system can **fail gracefully** without crashing the game

**The system is designed to:**
- Respect what already works
- Layer story on top of mechanics
- Fail safely if something breaks
- Serve the theme of "consciousness waiting"
- Feel invisible until it's magical

**Start with Phase 0:**
- Create files
- Prove compilation
- Change nothing about game behavior
- Build confidence before adding logic

---

**You've got this.** The architecture is sound. The integration points are clear. The theme alignment is strong. The rollback plan exists. Start small, test often, and let the city tell its story.

---

**Document Status:** Ready for Implementation
**Confidence Level:** HIGH
**Recommended Starting Point:** Phase 0, Foundation

