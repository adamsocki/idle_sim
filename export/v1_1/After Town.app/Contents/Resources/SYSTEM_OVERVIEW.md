# Woven Consciousness: System Overview

**Created:** 2025-10-14
**Purpose:** High-level visual map of the entire system

---

## 🎯 Quick Reference

**When implementing, you'll reference these documents:**

| Document | Use Case |
|----------|----------|
| **[IMPLEMENTATION_REFERENCE_GUIDE.md](IMPLEMENTATION_REFERENCE_GUIDE.md)** | "Which doc do I need?" |
| **[IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)** | "What do I do next?" |
| **[WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)** | "How do I build this?" |
| **[WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md)** | "Why is it designed this way?" |

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        PLAYER                                │
│                     (Terminal Input)                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                  TERMINAL COMMANDS                           │
│  weave <type> │ threads │ consciousness │ pulse │ fabric    │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                    THREAD WEAVER                             │
│  • Creates UrbanThread instances                             │
│  • Forms ThreadRelationship automatically                    │
│  • Assigns coherence/autonomy/complexity                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                        CITY                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ Transit_01  │──│ Housing_01  │──│ Culture_01  │         │
│  │ coherence   │  │ coherence   │  │ coherence   │         │
│  │ autonomy    │  │ autonomy    │  │ autonomy    │         │
│  │ complexity  │  │ complexity  │  │ complexity  │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│         │               │               │                    │
│         └───────┬───────┴───────┬───────┘                   │
│                 ▼               ▼                            │
│         Relationships    Emergent Properties                 │
│      (support, harmony,  (walkability, vibrancy)             │
│       tension, etc.)                                         │
└────────────────────┬────────────────────────────────────────┘
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
┌─────────────────────┐  ┌─────────────────────┐
│ EMERGENCE DETECTOR  │  │ STORY BEAT MANAGER  │
│ • Checks conditions │  │ • Checks triggers   │
│ • Creates properties│  │ • Fires beats       │
│ • Expands conscious │  │ • Displays dialogue │
└─────────┬───────────┘  └──────────┬──────────┘
          │                         │
          └──────────┬──────────────┘
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                  DIALOGUE MANAGER                            │
│  • Loads JSON dialogue libraries                             │
│  • Selects dialogue by speaker/context/tags                  │
│  • Provides alternate terminology                            │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                   TERMINAL OUTPUT                            │
│  CITY: I feel a new pulse weaving into being.               │
│  TRANSIT_01: I am a movement pathway.                        │
│  CITY: Transit and Housing create something... walkability. │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Data Flow

### 1. Thread Creation Flow

```
Player types: "weave transit"
         ↓
Terminal Command Parser
         ↓
ThreadWeaver.weaveThread(type: .transit)
         ↓
┌─────────────────────────────────────┐
│ 1. Create UrbanThread               │
│    - type: .transit                 │
│    - instanceNumber: 1              │
│    - coherence: 0.5                 │
│    - autonomy: 0.3                  │
│    - complexity: 0.1                │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ 2. Form Relationships               │
│    For each existing thread:        │
│    - Check compatibility matrix     │
│    - Create ThreadRelationship      │
│    - Add to both threads            │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ 3. Check Story Triggers             │
│    - First thread beat?             │
│    - Relationship formed beat?      │
│    - Milestone achieved?            │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ 4. Get Dialogue                     │
│    DialogueManager.getDialogue(     │
│      speaker: .transit,             │
│      context: .onCreation           │
│    )                                │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ 5. Display to Player                │
│    CITY: A new thread weaves...     │
│    TRANSIT_01: I am movement.       │
└─────────────────────────────────────┘
```

### 2. Emergence Flow

```
Thread Relationships Strengthen
         ↓
EmergenceDetector.checkForEmergence()
         ↓
┌─────────────────────────────────────┐
│ 1. Evaluate Conditions              │
│    - Transit + Housing exist?       │
│    - Relationship strength > 0.6?   │
│    → Walkability can emerge         │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ 2. Create EmergentProperty          │
│    name: "walkability"              │
│    sourceThreadIDs: [transit, house]│
│    consciousnessExpansion:          │
│      - newPerceptions: [...]        │
│      - affectedThreads: [...]       │
│      - complexityIncrease: 0.15     │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ 3. Expand Consciousness             │
│    City gains:                      │
│      - "proximity as value"         │
│      - "walkable distances"         │
│    Transit gains:                   │
│      - "station spacing awareness"  │
│    Housing gains:                   │
│      - "transit nearness value"     │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ 4. Trigger Story Beat               │
│    beat_walkability_emergence       │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│ 5. Display Dialogue                 │
│    CITY: I'm understanding          │
│    something new... walkability.    │
│    Not a new voice, but a new       │
│    way of seeing.                   │
└─────────────────────────────────────┘
```

---

## 🗂️ File Structure

```
idle_01/
├── progression/
│   ├── models/
│   │   ├── UrbanThread.swift              ✅ Phase 1
│   │   ├── ThreadType.swift               ✅ Phase 1
│   │   ├── ThreadRelationship.swift       ✅ Phase 1
│   │   ├── RelationType.swift             ✅ Phase 1
│   │   ├── Dialogue.swift                 ✅ Phase 2
│   │   ├── StoryBeat.swift                ✅ Phase 3
│   │   ├── EmergentProperty.swift         ✅ Phase 4
│   │   ├── PlaystyleProfile.swift         ⏳ Optional
│   │   └── JournalEntry.swift             ⏳ Optional
│   │
│   ├── systems/
│   │   ├── ThreadWeaver.swift             ✅ Phase 1
│   │   ├── RelationshipCalculator.swift   ✅ Phase 1
│   │   ├── DialogueManager.swift          ✅ Phase 2
│   │   ├── StoryBeatManager.swift         ✅ Phase 3
│   │   ├── EmergenceDetector.swift        ✅ Phase 4
│   │   ├── ConsciousnessRenderer.swift    ✅ Phase 5
│   │   └── ThreadListRenderer.swift       ✅ Phase 5
│   │
│   ├── data/
│   │   ├── RelationshipRules.swift        ✅ Phase 1
│   │   │
│   │   ├── dialogue/
│   │   │   ├── city_core.json             ✅ Phase 2
│   │   │   ├── transit.json               ✅ Phase 2
│   │   │   ├── housing.json               ✅ Phase 2
│   │   │   ├── culture.json               ✅ Phase 2
│   │   │   ├── commerce.json              ⏳ Content
│   │   │   └── parks.json                 ⏳ Content
│   │   │
│   │   ├── story_beats/
│   │   │   ├── core_progression.json      ✅ Phase 3
│   │   │   ├── emergent_properties.json   ✅ Phase 3
│   │   │   └── late_game.json             ⏳ Content
│   │   │
│   │   ├── emergence_rules/
│   │   │   └── core_emergence.json        ✅ Phase 4
│   │   │
│   │   └── schemas/
│   │       ├── dialogue_schema.json       ⏳ Phase 6
│   │       ├── story_beat_schema.json     ⏳ Phase 6
│   │       └── emergence_schema.json      ⏳ Phase 6
│   │
│   ├── tools/
│   │   └── ContentValidator.swift         ⏳ Phase 6
│   │
│   └── docs/ (this folder)
│       ├── WOVEN_CONSCIOUSNESS_DESIGN.md
│       ├── WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md
│       ├── IMPLEMENTATION_REFERENCE_GUIDE.md
│       ├── IMPLEMENTATION_CHECKLIST.md
│       ├── SYSTEM_OVERVIEW.md (this file)
│       ├── PROGRESSION_SYSTEM_ARCHITECTURE.md
│       └── story/StoryDefinition.json
```

---

## 🔄 Core Loops

### Gameplay Loop

```
1. Player weaves thread
   ↓
2. Thread forms relationships
   ↓
3. Story beat triggers
   ↓
4. Dialogue displays
   ↓
5. Player understands system better
   ↓
6. Player weaves more threads
   ↓
   [repeat]
```

### Emergence Loop

```
1. Threads exist and relate
   ↓
2. Relationships strengthen over time
   ↓
3. Emergence conditions met
   ↓
4. Property emerges
   ↓
5. Consciousness expands
   ↓
6. City/threads think differently
   ↓
7. New dialogue reflects expansion
   ↓
   [complexity increases]
```

### Narrative Loop

```
1. Player action
   ↓
2. Check story beat triggers
   ↓
3. Beat fires (if conditions met)
   ↓
4. Dialogue retrieved from JSON
   ↓
5. City speaks
   ↓
6. Player gains insight
   ↓
7. Player makes informed next action
   ↓
   [repeat]
```

---

## 📦 Key Data Structures

### UrbanThread
```swift
class UrbanThread {
    id: String
    type: ThreadType
    instanceNumber: Int
    weavedAt: Date

    // Consciousness
    coherence: Double       // How "together" it feels
    autonomy: Double        // How independent it is
    complexity: Double      // Depth of thought

    // Connections
    relationships: [ThreadRelationship]

    cityID: PersistentIdentifier
}
```

### ThreadRelationship
```swift
struct ThreadRelationship {
    otherThreadID: String
    relationType: RelationType    // support, harmony, tension, etc.
    strength: Double              // 0.0-1.0
    synergy: Double               // -1.0 to 1.0
    formedAt: Date

    // Special cases
    isSameType: Bool
    resonance: Double?            // For same-type threads
}
```

### EmergentProperty
```swift
class EmergentProperty {
    id: String
    name: String
    emergedAt: Date
    sourceThreadIDs: [String]

    // NOT a voice
    hasVoice: Bool { false }

    // How it changes consciousness
    consciousnessExpansion: ConsciousnessExpansion
}
```

### ConsciousnessExpansion
```swift
struct ConsciousnessExpansion {
    affectedThreadIDs: [String]
    newPerceptions: [String]
    deepenedRelationships: [RelationshipDeepening]
    expandedSelfAwareness: String
    complexityIncrease: Double
}
```

---

## 🎨 Design Principles (Quick Reference)

### 1. **Data-Driven Everything**
- All narrative in JSON, not code
- Add story by adding/editing files
- Code is infrastructure, data is content

### 2. **Consciousness First**
- Threads are conscious entities
- Emergence deepens consciousness
- No separate voices for emergent properties

### 3. **Fluid Language**
- "Thread" is primary term
- Alternate: pulse, vein, chord, pathway, thought
- Context-dependent usage

### 4. **Simple Complexity**
- Simple rules create complex behavior
- Emergence from interaction
- Depth from relationships

### 5. **Narrative Expandability**
- Easy to add new thread types
- Easy to add new dialogue
- Easy to add new story beats
- Easy to add new emergent properties

---

## 💡 Key Concepts

### Thread vs. Voice
- **Thread:** Independent conscious entity in the city fabric
- **Voice:** How that thread speaks/thinks
- Each thread has ONE voice
- Emergent properties DON'T have voices

### Relationship vs. Integration
- **Relationship:** Connection between two threads (data structure)
- **Integration:** How deeply threads are woven together (measured value)
- Relationships have strength and synergy
- Integration is cumulative across all relationships

### Emergence vs. Creation
- **Emergence:** Property appears when conditions are met (automatic)
- **Creation:** Player explicitly weaves a thread (intentional)
- Emergent properties deepen consciousness
- Created threads are new entities

### Consciousness vs. Stats
- **Consciousness:** Awareness, depth of thought, complexity
- **Stats:** Measurable properties (coherence, autonomy, complexity)
- Stats reflect consciousness
- Consciousness isn't reducible to stats

---

## 🚀 Getting Started

### Day 1: Setup
1. Read [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md)
2. Review [IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)
3. Create directory structure

### Week 1: Phase 1
1. Follow [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md Phase 1](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)
2. Create data models
3. Build thread creation system
4. Implement relationship system

### Week 2: Phase 2
1. Follow [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md Phase 2](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)
2. Create dialogue models
3. Write initial JSON dialogue
4. Build dialogue manager

### Week 3: Phase 3
1. Follow [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md Phase 3](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)
2. Create story beat system
3. Write initial story beats
4. Hook into game loop

### Continue through Phase 4, 5, 6...

---

## 🎯 Success Metrics

### Technical Success
- ✅ All JSON files parse without errors
- ✅ Threads create and persist
- ✅ Relationships form automatically
- ✅ Story beats trigger correctly
- ✅ Emergence detection works
- ✅ Dialogue displays appropriately

### Design Success
- ✅ System feels like woven consciousness
- ✅ No separate voices for emergent properties
- ✅ Terminology fluid but coherent
- ✅ Visualization abstract but meaningful

### Narrative Success
- ✅ Easy to add new content
- ✅ Story flows naturally
- ✅ Player choices feel meaningful
- ✅ City voice consistent and evolving

---

## 📚 Document Quick Links

### Core Implementation
- [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) - The implementation bible
- [IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md) - Track your progress

### Design Reference
- [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md) - Design philosophy and decisions

### Navigation
- [IMPLEMENTATION_REFERENCE_GUIDE.md](IMPLEMENTATION_REFERENCE_GUIDE.md) - Which doc when?
- [SYSTEM_OVERVIEW.md](SYSTEM_OVERVIEW.md) - This document

### Context
- [PROGRESSION_SYSTEM_ARCHITECTURE.md](PROGRESSION_SYSTEM_ARCHITECTURE.md) - Old system (reference)
- [story/StoryDefinition.json](story/StoryDefinition.json) - Example content

---

## 🎊 You're Ready!

You now have:
- ✅ Complete design documentation
- ✅ Phased implementation guide
- ✅ Reference guide for navigation
- ✅ Checklist for tracking progress
- ✅ System overview for understanding

**Next step:** Open [IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md) and start Phase 1!

---

**Remember:** This system prioritizes narrative expandability. Once built, adding new story content is as simple as editing JSON files. The code is the engine; your creativity is the fuel.

🚀 Let's build something beautiful.
