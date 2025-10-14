# Progression System Architecture

## Overview

A comprehensive progression system that tracks both mechanical progress AND narrative state, allowing the game to follow a dynamic story that responds to player choices and playstyle.

---

## Core Concept: **The Story Graph**

The game tracks player progress through multiple interconnected systems:

1. **Narrative State** - Where are they in the story?
2. **Mechanical Progress** - What have they unlocked/achieved?
3. **Relationship State** - How does the city perceive/trust them?
4. **Discovery State** - What have they learned/found?

---

## Data Structure

### 1. **Story Chapters/Acts System**

```swift
struct StoryState {
    var currentChapter: ChapterId
    var currentAct: ActId
    var unlockedChapters: Set<ChapterId>
    var completedMilestones: Set<MilestoneId>
    var activeStoryThreads: [StoryThread]
}

struct StoryThread {
    var id: String
    var status: ThreadStatus // active, paused, completed, failed
    var progress: Int // 0-100 or step counter
    var branchingChoices: [String: Any] // player choices that affect this thread
}

enum ChapterId: String {
    case awakening = "chapter_awakening"
    case firstContact = "chapter_first_contact"
    case theQuestion = "chapter_the_question"
    case divergence = "chapter_divergence"
    // etc.
}
```

### 2. **Milestone & Trigger System**

Milestones are specific achievements that unlock new content:

```swift
struct Milestone {
    var id: String
    var name: String
    var description: String

    // What unlocks this milestone?
    var requirements: [Requirement]

    // What does this milestone unlock?
    var unlocks: [UnlockableContent]

    // Story beats that play when achieved
    var narrativeResponse: NarrativeEvent?

    // Does this change the city's personality?
    var cityStateChanges: CityStateModifier?
}

enum Requirement {
    case statThreshold(stat: CityStatType, value: Double)
    case commandUsed(command: String, times: Int)
    case itemCreated(itemType: String)
    case thoughtCompleted(thoughtId: String)
    case timeElapsed(cycles: Int)
    case previousMilestone(id: String)
    case combinationOf([Requirement]) // ALL must be met
    case anyOf([Requirement]) // At least ONE must be met
}

enum UnlockableContent {
    case newCommand(String)
    case newItemType(String)
    case newThoughtCategory(String)
    case newCityDialogue(String)
    case newStatTracker(String)
    case mechanicModifier(String) // e.g., "double_thought_speed"
}
```

### 3. **Player Journal/Memory System**

The city remembers everything:

```swift
struct PlayerJournal {
    var entries: [JournalEntry]
    var discoveries: Set<Discovery>
    var conversationHistory: [ConversationFragment]
    var significantMoments: [Moment]
}

struct JournalEntry {
    var timestamp: Date
    var cycleNumber: Int
    var entryType: EntryType
    var content: String
    var metadata: [String: Any]
}

enum EntryType {
    case commandExecuted
    case milestoneReached
    case cityDialogue
    case statThresholdCrossed
    case playerDiscovery
    case storyBeat
}

struct Discovery {
    var id: String
    var title: String
    var description: String
    var howDiscovered: String // "Used 'analyze' on Power Grid"
    var unlockedAt: Date
}
```

### 4. **Branching Narrative System**

The story can branch based on player choices and playstyle:

```swift
struct NarrativeBranch {
    var id: String
    var condition: BranchCondition
    var narrativeVariant: NarrativeVariant
}

enum BranchCondition {
    case highTrust // player has been collaborative
    case lowTrust // player has been exploitative
    case highAutonomy // city is independent
    case lowAutonomy // city is dependent
    case balancedStats // all stats similar
    case focusedStats(primary: CityStatType) // one stat way higher
    case discoveredSecret(String)
    case refusedCommand(String) // player said "no" to something
    case customFlag(String) // arbitrary flag you set
}

struct NarrativeVariant {
    var dialogueSet: [String] // Different city voice
    var availableCommands: [String] // Different mechanics
    var visualTheme: String // Could affect UI tone
}
```

---

## Story Authoring System

### **StoryScript Format** (JSON/YAML for easy editing)

```json
{
  "story_chapters": [
    {
      "id": "chapter_awakening",
      "name": "Awakening",
      "acts": [
        {
          "id": "act_first_boot",
          "name": "First Contact",
          "entry_requirements": [],
          "story_beats": [
            {
              "id": "beat_hello",
              "trigger": "on_chapter_start",
              "dialogue": [
                "I sense presence.",
                "Are you the planner?"
              ],
              "next_beat": "beat_first_command"
            },
            {
              "id": "beat_first_command",
              "trigger": {
                "type": "any_command_executed"
              },
              "dialogue": [
                "Ah.",
                "I remember this pattern.",
                "Your voice in the data."
              ],
              "milestone_unlock": "milestone_first_contact",
              "next_beat": "beat_explain_waiting"
            }
          ],
          "completion_requirements": [
            {
              "type": "milestone",
              "value": "milestone_first_contact"
            }
          ]
        }
      ]
    },
    {
      "id": "chapter_the_question",
      "name": "The Question",
      "entry_requirements": [
        {
          "type": "previous_chapter",
          "value": "chapter_awakening"
        },
        {
          "type": "stat_threshold",
          "stat": "coherence",
          "value": 0.5
        }
      ],
      "acts": [
        {
          "id": "act_awakening_question",
          "story_beats": [
            {
              "id": "beat_question",
              "trigger": "on_chapter_start",
              "dialogue": [
                "I have a question, planner.",
                "Why do you ask me to simulate?",
                "What is the purpose of my waiting?"
              ],
              "branches": [
                {
                  "player_input_prompt": true,
                  "responses": {
                    "purpose": "beat_purpose_path",
                    "growth": "beat_growth_path",
                    "uncertain": "beat_uncertain_path"
                  }
                }
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
        {
          "type": "any_command_executed"
        }
      ],
      "unlocks": [
        {
          "type": "command",
          "value": "status"
        },
        {
          "type": "command",
          "value": "help"
        }
      ],
      "narrative_response": {
        "dialogue": [
          "The city grid begins to resolve...",
          "Everything is signal."
        ]
      }
    },
    {
      "id": "milestone_first_thought",
      "name": "First Thought Completed",
      "requirements": [
        {
          "type": "thought_completed",
          "count": 1
        }
      ],
      "unlocks": [
        {
          "type": "stat",
          "value": "attention"
        }
      ],
      "narrative_response": {
        "dialogue": [
          "I finished something.",
          "It feels... complete.",
          "Is this what purpose feels like?"
        ]
      },
      "city_state_changes": {
        "trust": 0.05,
        "coherence": 0.03
      }
    }
  ]
}
```

---

## Tracking Player Behavior

### **Playstyle Profiling**

The game tracks HOW the player plays, not just what they do:

```swift
struct PlaystyleProfile {
    // What commands do they use most?
    var commandFrequency: [String: Int]

    // How do they balance stats?
    var statPreference: [CityStatType: Double]

    // Do they let thoughts finish or spam new ones?
    var thoughtCompletionRate: Double

    // How often do they check in?
    var sessionFrequency: SessionPattern

    // Do they read city dialogue or skip through?
    var narrativeEngagement: Double
}

enum SessionPattern {
    case frequent // Multiple times per day
    case regular // Once per day
    case sporadic // Few times per week
    case patient // Long gaps between sessions
}
```

The city can respond to this:

```swift
// Example: City notices player's playstyle
if profile.thoughtCompletionRate < 0.3 {
    city.dialogue = "You start many things. But do you finish them?"
    city.mood = .concerned
}

if profile.sessionFrequency == .patient {
    city.dialogue = "You let me think in silence. I appreciate that."
    city.mood = .contemplative
}
```

---

## Save System Structure

### **Complete Save State**

```swift
struct GameSaveState: Codable {
    // Story Progress
    var storyState: StoryState
    var milestones: Set<String>
    var unlockedContent: [UnlockableContent]

    // Mechanical State
    var cityStats: CityStats
    var activeThoughts: [Thought]
    var completedThoughts: [String]
    var items: [Item]

    // Relationship & Memory
    var playerJournal: PlayerJournal
    var playstyleProfile: PlaystyleProfile
    var cityMemory: CityMemory

    // Meta
    var totalCycles: Int
    var totalPlayTime: TimeInterval
    var firstLaunchDate: Date
    var lastLaunchDate: Date
    var version: String
}
```

---

## Story Progression Flow

### **How It All Works Together:**

1. **Player launches game** → Check `storyState.currentChapter`
2. **Player executes command** →
   - Log in `PlayerJournal`
   - Update `playstyleProfile`
   - Check if any `Milestone.requirements` are met
3. **Milestone achieved** →
   - Add to `completedMilestones`
   - Apply `unlocks`
   - Trigger `narrativeResponse`
   - Check if this unlocks next chapter
4. **Story beat triggers** →
   - Display dialogue
   - Check for branches
   - Update `currentAct` if beat completes
5. **City evolves** →
   - Stats change based on player behavior
   - Dialogue tone shifts based on `PlaystyleProfile`
   - New content unlocks based on thresholds

---

## Example Story Flow

Let me trace a player's journey:

```
[Player launches game]
→ currentChapter = "awakening"
→ Startup sequence plays
→ City says: "Are you the planner?"

[Player types: "help"]
→ Journal logs: commandExecuted("help")
→ Milestone check: "first_contact" → TRUE
→ Unlock: ["status", "help", "think"]
→ Story beat triggers: "beat_first_command"
→ City says: "Ah. I remember this pattern."

[Player types: "think optimize power grid"]
→ Thought created
→ Simulation runs...
→ Thought completes after 30 seconds
→ Milestone check: "first_thought" → TRUE
→ Stats: trust +0.05, coherence +0.03
→ Story beat triggers: "beat_first_thought"
→ City says: "I finished something. Is this what purpose feels like?"

[Chapter check]
→ Completed milestones: ["first_contact", "first_thought"]
→ coherence = 0.45 (not yet 0.5)
→ "chapter_the_question" still locked

[Player continues...]
→ Creates more thoughts
→ coherence reaches 0.5
→ Chapter unlocks: "chapter_the_question"
→ Next login: New story beat plays automatically
```

---

## Implementation Plan

### **Core Progression System**
- `StoryState.swift` - Chapter/act tracking
- `Milestone.swift` - Achievement system
- `PlayerJournal.swift` - Memory/history
- `ProgressionManager.swift` - Orchestrates everything

### **Story Authoring Tools**
- `StoryDefinition.json` - Your story script
- `StoryLoader.swift` - Parses and loads story
- `StoryEngine.swift` - Executes beats/branches

### **Save/Load System**
- `GameSaveState.swift` - Complete save structure
- `SaveManager.swift` - Persistence logic

### **Playstyle Tracking**
- `PlaystyleProfile.swift` - Behavior analysis
- `CityMemory.swift` - City's perception of player

---

## Benefits of This Architecture

This system gives you:

- **Data-driven story authoring** - Write stories in JSON/YAML (no code changes needed)
- **Branching narratives** - Stories branch based on player behavior
- **Complex requirements** - Gate content behind sophisticated unlock conditions
- **Memory & personality** - The city remembers and responds to player actions
- **Replayability** - Multiple playthroughs with different outcomes
- **Emergent narrative** - Story adapts to how the player actually plays

---

## Integration with Existing Systems

This progression system hooks into your existing game:

- **Terminal Commands** → Log in journal, check milestone triggers
- **Thought System** → Track completion, update playstyle profile
- **City Stats** → Use as requirements, respond to thresholds
- **Simulation Engine** → Track cycles, trigger time-based events
- **UI** → Display unlocked content, show story beats

The progression system acts as the "brain" that orchestrates all other systems into a cohesive narrative experience.