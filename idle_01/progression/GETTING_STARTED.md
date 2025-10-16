# Getting Started: First Steps for Progression Implementation

**Purpose:** Concrete actions you can take **today** to start building the progression system

---

## Decision Time (5 minutes)

Before coding, answer these questions:

### 1. Which approach?
- [ ] **Approach A (Layered)** - Story as enhancement, minimal changes
- [x] **Approach B (Core)** - Story as central system, restructure for quality
- [ ] **Hybrid** - Start with A, migrate to B after seeing it work

**My recommendation:** Approach B (Core) based on your theme

---

### 2. What's your first milestone?

Choose ONE goal for the next 2 weeks:

- [ ] **Foundation only** - Models compile, nothing runs (Phase 0)
- [ ] **First story beat** - See one authored dialogue line (Phase 0-2)
- [ ] **Milestone system** - Track and announce achievements (Phase 0-3)
- [ ] **Full Act I** - Complete awakening chapter (Phase 0-4)

**My recommendation:** "First story beat" - concrete, motivating, proves concept

---

### 3. Time commitment this week?

- [ ] **2-4 hours** - Foundation only, set up structure
- [ ] **4-8 hours** - Foundation + first integration
- [ ] **8-16 hours** - Foundation + working story beat

**My recommendation:** 4-8 hours - enough to see progress, not overwhelming

---

## Phase 0: Foundation (Today: 2-3 hours)

### Step 1: Create Directory Structure (5 minutes)

```bash
cd /Users/adamsocki/dev/xcode/idle_01

# Create directories
mkdir -p progression/models
mkdir -p progression/managers
mkdir -p progression/story
mkdir -p progression/tests

# Verify structure
tree progression
```

Expected output:
```
progression/
├── models/
├── managers/
├── story/
├── tests/
├── PROGRESSION_SYSTEM_ARCHITECTURE.md
├── PROGRESSION_SYSTEM_IMPLEMENTATION.md
├── IMPLEMENTATION_CONFIDENCE_GUIDE.md
├── REVISED_IMPLEMENTATION_STRATEGY.md
├── APPROACH_COMPARISON.md
└── GETTING_STARTED.md (this file)
```

---

### Step 2: Create Model Files (30 minutes)

Create these files with basic structure:

#### `progression/models/CityStoryState.swift`

```swift
//
//  CityStoryState.swift
//  idle_01
//
//  Story progression state for a city
//

import Foundation
import SwiftData

@Model
final class CityStoryState {
    // Link to city
    var cityID: PersistentIdentifier

    // Chapter/act tracking
    var currentChapter: String
    var currentAct: String
    var currentBeat: String?

    // Milestone tracking
    var completedMilestones: Set<String>
    var pendingMilestones: [String]

    // Story branching
    var storyFlags: [String: Bool]

    // Unlocks
    var unlockedCommands: Set<String>

    init(cityID: PersistentIdentifier,
         currentChapter: String = "chapter_awakening",
         currentAct: String = "act_first_boot",
         currentBeat: String? = nil,
         completedMilestones: Set<String> = [],
         pendingMilestones: [String] = [],
         storyFlags: [String: Bool] = [:],
         unlockedCommands: Set<String> = ["help", "status", "create"]) {
        self.cityID = cityID
        self.currentChapter = currentChapter
        self.currentAct = currentAct
        self.currentBeat = currentBeat
        self.completedMilestones = completedMilestones
        self.pendingMilestones = pendingMilestones
        self.storyFlags = storyFlags
        self.unlockedCommands = unlockedCommands
    }
}
```

#### `progression/models/JournalEntry.swift`

```swift
//
//  JournalEntry.swift
//  idle_01
//
//  Records player actions and city events
//

import Foundation
import SwiftData

enum JournalEntryType: String, Codable {
    case commandExecuted
    case thoughtCreated
    case thoughtCompleted
    case thoughtDismissed
    case milestoneReached
    case storyBeat
    case statThreshold
}

@Model
final class JournalEntry {
    var timestamp: Date
    var cityID: PersistentIdentifier
    var entryType: String  // JournalEntryType.rawValue
    var content: String
    var metadata: [String: String]

    init(timestamp: Date = Date(),
         cityID: PersistentIdentifier,
         entryType: JournalEntryType,
         content: String,
         metadata: [String: String] = [:]) {
        self.timestamp = timestamp
        self.cityID = cityID
        self.entryType = entryType.rawValue
        self.content = content
        self.metadata = metadata
    }
}
```

#### `progression/models/PlaystyleProfile.swift`

```swift
//
//  PlaystyleProfile.swift
//  idle_01
//
//  Tracks how player interacts with city
//

import Foundation
import SwiftData

@Model
final class PlaystyleProfile {
    var cityID: PersistentIdentifier

    // Command usage patterns
    var commandFrequency: [String: Int]

    // Engagement metrics
    var thoughtCompletionRate: Double
    var narrativeEngagement: Double

    // Session patterns
    var sessionPattern: String  // "frequent", "regular", "sporadic", "patient"
    var averageSessionGap: TimeInterval

    init(cityID: PersistentIdentifier,
         commandFrequency: [String: Int] = [:],
         thoughtCompletionRate: Double = 0.0,
         narrativeEngagement: Double = 0.0,
         sessionPattern: String = "new",
         averageSessionGap: TimeInterval = 0) {
        self.cityID = cityID
        self.commandFrequency = commandFrequency
        self.thoughtCompletionRate = thoughtCompletionRate
        self.narrativeEngagement = narrativeEngagement
        self.sessionPattern = sessionPattern
        self.averageSessionGap = averageSessionGap
    }
}
```

---

### Step 3: Create Manager Stubs (30 minutes)

#### `progression/managers/ProgressionManager.swift`

```swift
//
//  ProgressionManager.swift
//  idle_01
//
//  Orchestrates progression systems
//

import Foundation
import SwiftData

@MainActor
final class ProgressionManager {
    static let shared = ProgressionManager()

    private var modelContext: ModelContext?

    private init() {}

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Event Hooks

    func onCommand(input: String, city: City?) async throws {
        guard let city = city, let modelContext = modelContext else { return }

        print("📝 [Progression] Command: \(input)")

        // TODO: Log to journal
        // TODO: Update playstyle
        // TODO: Check milestones
        // TODO: Trigger story beats
    }

    func onThoughtResolved(city: City, item: Item, resolved: Bool) async throws {
        guard let modelContext = modelContext else { return }

        print("📝 [Progression] Thought resolved: \(item.title ?? "Untitled")")

        // TODO: Log to journal
        // TODO: Update completion rate
        // TODO: Check milestones
        // TODO: Trigger story beats
    }

    func onTick(city: City, tick: Int) async throws {
        guard let modelContext = modelContext else { return }

        // TODO: Check time-based milestones
        // TODO: Update playstyle metrics
    }

    // MARK: - State Management

    func ensureStoryState(for city: City) -> CityStoryState? {
        guard let modelContext = modelContext else { return nil }

        // Check if city has story state
        let descriptor = FetchDescriptor<CityStoryState>(
            predicate: #Predicate { $0.cityID == city.persistentModelID }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }

        // Create new story state
        let newState = CityStoryState(cityID: city.persistentModelID)
        modelContext.insert(newState)
        try? modelContext.save()

        print("✨ [Progression] Created story state for \(city.name)")

        return newState
    }
}
```

#### `progression/managers/StoryEngine.swift`

```swift
//
//  StoryEngine.swift
//  idle_01
//
//  Manages narrative beats and story progression
//

import Foundation
import SwiftData

@MainActor
final class StoryEngine {
    static let shared = StoryEngine()

    private init() {}

    // MARK: - Narrative Generation

    func speak(for city: City, context: NarrativeContext) async {
        print("🗣️ [Story] Speak for \(city.name), context: \(context)")

        // TODO: Check for eligible story beats
        // TODO: Generate contextual ambient if no beats
        // TODO: Emit to city.log
    }

    func maybeTriggerBeat(for city: City?) async -> Bool {
        guard let city = city else { return false }

        print("🎭 [Story] Checking beats for \(city.name)")

        // TODO: Check queued beats
        // TODO: Check trigger conditions
        // TODO: Emit beat dialogue
        // TODO: Advance story state

        return false  // No beat triggered
    }
}

enum NarrativeContext {
    case tick
    case command
    case milestone
    case startup
}
```

---

### Step 4: Add Files to Xcode (10 minutes)

1. Open Xcode
2. Right-click on `idle_01` project
3. Add Files to "idle_01"...
4. Select the entire `progression/` folder
5. ✅ Create groups
6. ✅ Add to targets: idle_01

**Verify:**
- Files appear in Project Navigator
- No red (missing file) indicators

---

### Step 5: Update App Container (10 minutes)

Modify `idle_01/ui/idle_01App.swift`:

```swift
import SwiftUI
import SwiftData

@main
struct idle_01App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            City.self,
            Item.self,
            // NEW: Add progression models
            CityStoryState.self,
            JournalEntry.self,
            PlaystyleProfile.self
        ])
    }
}
```

---

### Step 6: Build (5 minutes)

```bash
# Command+B in Xcode
```

**Expected result:** ✅ Build succeeds

**If build fails:**
- Check import statements
- Verify all files added to target
- Check model syntax

---

### Step 7: Initialize ProgressionManager (10 minutes)

Modify `idle_01/ui/SimulatorView.swift` or `RootView.swift`:

```swift
import SwiftUI
import SwiftData

struct SimulatorView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        // ... existing view code ...
        .onAppear {
            // Initialize progression system
            Task { @MainActor in
                ProgressionManager.shared.configure(modelContext: modelContext)
                print("✅ [Progression] Manager initialized")
            }
        }
    }
}
```

---

### Step 8: Test Foundation (10 minutes)

Run the app, check console for:

```
✅ [Progression] Manager initialized
```

If you see this, **Phase 0 is complete!** 🎉

---

## Phase 1: First Integration (Tomorrow: 2-3 hours)

### Step 1: Modify City Model (15 minutes)

Add relationship to `City.swift`:

```swift
@Model
final class City {
    // ... existing properties ...

    // NEW: Story progression state
    var storyStateID: PersistentIdentifier?

    // Helper to get story state
    @Transient
    var storyState: CityStoryState? {
        // Will be fetched via modelContext in real implementation
        nil
    }

    init(name: String, parameters: [String: Double] = [:], items: [Item] = []) {
        // ... existing initialization ...

        self.storyStateID = nil  // Created lazily on first interaction
    }
}
```

**Note:** SwiftData relationships are tricky. We'll use ID reference + helper for now.

---

### Step 2: Add Command Hook (20 minutes)

In `TerminalCommandExecutor.swift`, add hook:

```swift
func execute(_ input: String, selectedCityID: inout PersistentIdentifier?) -> CommandOutput {
    let command = parser.parse(input)
    let output = handleCommand(command, selectedCityID: &selectedCityID)

    // PROGRESSION HOOK
    if let cityID = selectedCityID,
       let city = allCities.first(where: { $0.persistentModelID == cityID }) {
        Task { @MainActor in
            do {
                try await ProgressionManager.shared.onCommand(input: input, city: city)
            } catch {
                print("⚠️ [Progression] Hook failed: \(error)")
            }
        }
    }

    return output
}
```

---

### Step 3: Test Hook (10 minutes)

Run app, execute a command, check console:

```
📝 [Progression] Command: help
```

If you see this, **hook is working!** 🎉

---

### Step 4: Implement Journal Logging (30 minutes)

Update `ProgressionManager.onCommand()`:

```swift
func onCommand(input: String, city: City?) async throws {
    guard let city = city, let modelContext = modelContext else { return }

    print("📝 [Progression] Command: \(input)")

    // Ensure story state exists
    _ = ensureStoryState(for: city)

    // Log to journal
    let entry = JournalEntry(
        cityID: city.persistentModelID,
        entryType: .commandExecuted,
        content: input,
        metadata: ["command": input]
    )

    modelContext.insert(entry)
    try modelContext.save()

    print("📖 [Journal] Logged command: \(input)")
}
```

---

### Step 5: Test Journal (10 minutes)

Run app, execute several commands.

Then add a temporary debug command to `TerminalCommandExecutor`:

```swift
case .debug:
    return handleDebug()

// In handler
private func handleDebug() -> CommandOutput {
    let descriptor = FetchDescriptor<JournalEntry>(
        sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
    )

    let entries = (try? modelContext.fetch(descriptor)) ?? []

    var output = "JOURNAL ENTRIES [\(entries.count)]:\n"
    for entry in entries.prefix(10) {
        output += "  \(entry.entryType): \(entry.content)\n"
    }

    return CommandOutput(text: output)
}
```

Run app, execute:
```
> debug
```

Should see:
```
JOURNAL ENTRIES [3]:
  commandExecuted: debug
  commandExecuted: help
  commandExecuted: status
```

**If you see this, Phase 1 is complete!** 🎉

---

## Phase 2: First Story Beat (Next Week: 4-6 hours)

### Step 1: Create Story JSON (1 hour)

Create `progression/story/StoryDefinition.json`:

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
              "trigger": "on_game_start",
              "dialogue": [
                "I sense presence.",
                "Are you the planner?"
              ],
              "next_beat": "beat_first_command"
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
              ]
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
    }
  ]
}
```

---

### Step 2: Create Story Loader (2 hours)

Create `progression/story/StoryLoader.swift`:

```swift
//
//  StoryLoader.swift
//  idle_01
//
//  Loads and validates story content
//

import Foundation

struct StoryDefinition: Codable {
    let version: String
    let chapters: [Chapter]
    let milestones: [Milestone]

    struct Chapter: Codable {
        let id: String
        let name: String
        let acts: [Act]
    }

    struct Act: Codable {
        let id: String
        let beats: [Beat]
    }

    struct Beat: Codable {
        let id: String
        let trigger: String  // Simplified for MVP
        let dialogue: [String]
        let nextBeat: String?

        enum CodingKeys: String, CodingKey {
            case id, trigger, dialogue
            case nextBeat = "next_beat"
        }
    }

    struct Milestone: Codable {
        let id: String
        let name: String
        let requirements: [Requirement]
        let narrativeResponse: NarrativeResponse?
        let statChanges: [String: Double]?

        enum CodingKeys: String, CodingKey {
            case id, name, requirements
            case narrativeResponse = "narrative_response"
            case statChanges = "stat_changes"
        }

        struct Requirement: Codable {
            let type: String
        }

        struct NarrativeResponse: Codable {
            let dialogue: [String]
        }
    }
}

final class StoryLoader {
    static func load() -> StoryDefinition? {
        guard let url = Bundle.main.url(forResource: "StoryDefinition", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("⚠️ [Story] Could not load StoryDefinition.json")
            return nil
        }

        do {
            let definition = try JSONDecoder().decode(StoryDefinition.self, from: data)
            print("✅ [Story] Loaded \(definition.chapters.count) chapters, \(definition.milestones.count) milestones")
            return definition
        } catch {
            print("❌ [Story] Failed to parse: \(error)")
            return nil
        }
    }
}
```

---

### Step 3: Implement Beat Triggering (2 hours)

Update `StoryEngine.swift`:

```swift
@MainActor
final class StoryEngine {
    static let shared = StoryEngine()

    private var story: StoryDefinition?

    private init() {
        self.story = StoryLoader.load()
    }

    func triggerStartupBeat(for city: City) {
        guard let story = story else { return }

        // Find "on_game_start" beat
        for chapter in story.chapters {
            for act in chapter.acts {
                for beat in act.beats where beat.trigger == "on_game_start" {
                    emitBeat(beat, to: city)
                    return
                }
            }
        }
    }

    private func emitBeat(_ beat: StoryDefinition.Beat, to city: City) {
        print("🎭 [Story] Emitting beat: \(beat.id)")

        for line in beat.dialogue {
            city.log.append("CITY: \(line)")
        }
    }
}
```

---

### Step 4: Trigger on First Launch (15 minutes)

In `SimulationEngine.swift` or wherever city starts:

```swift
func run(_ city: City) async {
    // NEW: Trigger startup beat
    await StoryEngine.shared.triggerStartupBeat(for: city)

    // ... existing simulation loop ...
}
```

---

### Step 5: Test First Beat (10 minutes)

Run app, create new city, start it.

Check terminal output for:
```
CITY: I sense presence.
CITY: Are you the planner?
```

**If you see this, you have your first story beat!** 🎉🎉🎉

---

## Success Criteria

### Phase 0 Complete When:
- [ ] All model files compile
- [ ] ProgressionManager initializes
- [ ] No build errors
- [ ] Console shows "Manager initialized"

### Phase 1 Complete When:
- [ ] Commands trigger progression hook
- [ ] Journal entries are created
- [ ] Debug command shows journal history
- [ ] Story state created for city

### Phase 2 Complete When:
- [ ] JSON loads without errors
- [ ] First story beat appears in terminal
- [ ] Beat dialogue visible to player
- [ ] System feels "alive"

---

## Troubleshooting

### "Build Failed: Cannot find type CityStoryState"
→ Verify file added to Xcode target
→ Check import statements

### "Manager not initialized"
→ Check `.onAppear` in main view
→ Verify modelContext passed

### "Story JSON not loading"
→ Add JSON to bundle (Build Phases → Copy Bundle Resources)
→ Check filename matches exactly

### "Hook not firing"
→ Check Task.detached syntax
→ Verify city parameter not nil
→ Add print statements

---

## Next Steps After Phase 2

Once you have first beat working:

1. **Add Milestone Checking**
   - Implement requirement evaluation
   - Trigger milestone beats
   - Apply stat changes

2. **Add More Content**
   - Write full Act I beats
   - Create branching paths
   - Add more milestones

3. **Progressive Unlocking**
   - Implement command registry
   - Add unlock checking
   - Show helpful hints

4. **Polish**
   - Tune pacing
   - Balance stats
   - Test edge cases

---

## Time Estimates

| Phase | Time | Cumulative |
|-------|------|------------|
| Phase 0: Foundation | 2-3 hours | 3 hours |
| Phase 1: Integration | 2-3 hours | 6 hours |
| Phase 2: First Beat | 4-6 hours | 12 hours |
| **MVP Milestone** | | **12 hours total** |

**After 12 hours of focused work, you'll have:**
- Working progression system
- Journal logging
- First story beats
- Foundation for all future content

---

## Getting Help

If you get stuck:

1. **Check console logs** - All systems print debug info
2. **Review file paths** - Common source of errors
3. **Test incrementally** - Don't add too much at once
4. **Use debug commands** - Create temporary commands to inspect state
5. **Ask for help** - Share error messages + context

---

## Celebration Milestones

- ✅ **First successful build** - Foundation works
- 🎉 **First journal entry** - Hooks working
- 🎊 **First story beat** - System alive!
- 🚀 **First milestone** - Full loop complete

---

## Final Checklist Before Starting

- [ ] I've chosen an approach (A or B)
- [ ] I have 2-3 hours available today
- [ ] Xcode is open and project compiles
- [ ] I've read Phase 0 steps
- [ ] I'm ready to create files

**If all checked, you're ready to begin!**

---

**Start with Phase 0, Step 1. Create that directory structure. Build from there.**

**You've got this.** 🚀

