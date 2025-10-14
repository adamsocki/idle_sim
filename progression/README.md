# Woven Consciousness: Progressive Urban Narrative System

A consciousness-first progression system where urban systems emerge as threads of awareness that weave into a living fabric of thought.

---

## 🎯 What Is This?

This system transforms your idle city simulator into a narrative experience where:

- **Threads** (not districts) weave into being as conscious entities
- **Relationships** form organically between threads
- **Emergence** deepens consciousness without creating new voices
- **Story** responds to player behavior and choices
- **Narrative** is trivially easy to expand through JSON files

---

## 📖 Start Here

### New to the Project?

**Read in this order:**

1. **[SYSTEM_OVERVIEW.md](SYSTEM_OVERVIEW.md)** - 10-minute overview of everything
2. **[WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md)** - Design philosophy and decisions
3. **[WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)** - Implementation guide (phases 1-6)

### Ready to Implement?

**Use these daily:**

1. **[IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)** - Track your progress
2. **[IMPLEMENTATION_REFERENCE_GUIDE.md](IMPLEMENTATION_REFERENCE_GUIDE.md)** - Which doc when?

---

## 🗂️ Document Index

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[README.md](README.md)** | You are here - start point | First visit |
| **[SYSTEM_OVERVIEW.md](SYSTEM_OVERVIEW.md)** | High-level architecture map | Understanding the system |
| **[WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md)** | Design philosophy & decisions | Writing content, making design choices |
| **[WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)** | Step-by-step implementation | Active development |
| **[IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)** | Progress tracking | Daily workflow |
| **[IMPLEMENTATION_REFERENCE_GUIDE.md](IMPLEMENTATION_REFERENCE_GUIDE.md)** | Document navigation guide | Finding the right doc |
| **[PROGRESSION_SYSTEM_ARCHITECTURE.md](PROGRESSION_SYSTEM_ARCHITECTURE.md)** | Original progression system | Historical context |
| **[story/StoryDefinition.json](story/StoryDefinition.json)** | Example story content | Creating new content |

---

## 🚀 Quick Start (Day 1)

### 1. Read the Design (30 minutes)
```bash
open progression/WOVEN_CONSCIOUSNESS_DESIGN.md
```
Focus on:
- Design Decisions section
- Terminology (threads, pulse, vein, etc.)
- Emergent Properties (consciousness expansion)

### 2. Review Implementation Plan (20 minutes)
```bash
open progression/WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md
```
Skim all phases to understand the journey.

### 3. Set Up Structure (10 minutes)
```bash
cd /Users/adamsocki/dev/xcode/idle_01
mkdir -p progression/models
mkdir -p progression/systems
mkdir -p progression/data/dialogue
mkdir -p progression/data/story_beats
mkdir -p progression/data/emergence_rules
```

### 4. Open Checklist (5 minutes)
```bash
open progression/IMPLEMENTATION_CHECKLIST.md
```
Check off "Documentation Review" items.

**You're ready to begin Phase 1!**

---

## 📊 Implementation Phases

### Phase 1: Core Thread System (1-2 weeks)
Independent threads that form relationships.
- **Output:** Can create threads, relationships form automatically
- **Reference:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md Phase 1](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)

### Phase 2: Dialogue System (1 week)
JSON-based dialogue that's trivial to expand.
- **Output:** All dialogue in JSON, context-aware retrieval
- **Reference:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md Phase 2](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)

### Phase 3: Story Beats (1-2 weeks)
Event-driven narrative moments.
- **Output:** Story beats trigger on conditions, display dialogue
- **Reference:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md Phase 3](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)

### Phase 4: Emergent Properties (1 week)
Consciousness expansion without new voices.
- **Output:** Properties emerge, consciousness deepens
- **Reference:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md Phase 4](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)

### Phase 5: Terminal Commands (1 week)
Player interface for weaving and observing.
- **Output:** Commands work, visualizations render
- **Reference:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md Phase 5](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)

### Phase 6: Narrative Tools (Ongoing)
Make content creation trivial.
- **Output:** Validation, schemas, documentation
- **Reference:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md Phase 6](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)

**Total Time:** 5-7 weeks

---

## 🎨 Core Concepts

### Threads
Conscious entities that form the city fabric.
```
TRANSIT: I am a movement pulse through the city.
HOUSING: I am a shelter vein, coursing through consciousness.
CULTURE: I am a resonant chord, giving color to thought.
```

### Relationships
Connections between threads with strength and synergy.
```
Transit ═══ Housing     (strong support)
Culture ─── Commerce    (moderate harmony)
```

### Emergent Properties
New perceptions that deepen consciousness (NOT new voices).
```
When Transit + Housing integrate deeply:
  → Walkability emerges
  → City gains perception: "proximity as value"
  → Transit gains awareness: "station spacing matters"
  → Housing gains insight: "nearness creates possibility"
```

### Consciousness Expansion
How emergence changes existing awareness.
```
Before: City knows about Transit and Housing separately
After:  City understands their spatial relationship
        City perceives walkability as a dimension
        City thinks more complexly about urban form
```

---

## 💡 Design Principles

1. **Data-Driven Storytelling** - All narrative in JSON, not code
2. **Consciousness First** - Threads are conscious entities, not objects
3. **Fluid Language** - Terminology shifts organically (thread, pulse, vein, chord)
4. **Emergence Deepens** - Properties expand consciousness, don't create voices
5. **Simple to Expand** - Adding content = editing JSON files

---

## 🛠️ Tech Stack

- **Language:** Swift 6
- **Framework:** SwiftUI
- **Persistence:** SwiftData
- **Data Format:** JSON
- **Architecture:** Actor-based concurrency

---

## 📝 Content Creation

### Adding a New Thread Type (3 steps)

1. **Add to enum:**
```swift
enum ThreadType: String, Codable {
    case transit
    case housing
    case education  // NEW
}
```

2. **Create dialogue file:**
```json
// data/dialogue/education.json
{
  "speaker": "education",
  "alternateTerminology": ["knowledge pulse", "learning thread"],
  "dialogueFragments": [
    {
      "id": "education_creation",
      "context": "onCreation",
      "fragments": ["I am the thread of learning."]
    }
  ]
}
```

3. **Done!** New thread type works with full voice.

### Adding an Emergent Property (2 steps)

1. **Define in emergence rules:**
```json
// data/emergence_rules/core_emergence.json
{
  "name": "innovation",
  "conditions": {
    "requiredThreadTypes": ["education", "commerce", "culture"],
    "minimumAverageIntegration": 0.65
  },
  "consciousnessExpansion": {
    "newPerceptions": ["creative collision", "knowledge application"],
    "expandedSelfAwareness": "When learning, commerce, and creativity overlap, new ideas emerge."
  }
}
```

2. **Done!** Property will emerge automatically when conditions met.

---

## 🧪 Testing Strategy

### Unit Tests
- ThreadWeaver
- RelationshipCalculator
- DialogueManager
- StoryBeatManager
- EmergenceDetector

### Integration Tests
- Full thread creation → relationship → emergence flow
- Command execution → story beat → dialogue display
- Persistence across launches

### Content Tests
- All JSON files parse
- All dialogue retrievable
- All story beats triggerable

### Playtest
- Create city, play 30 minutes
- Verify story progression
- Check emergence detection
- Test consciousness expansion

---

## 📈 Progress Tracking

Check [IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md) for detailed task tracking.

**Current Status:**
- ✅ Documentation complete
- ⬜ Phase 1: Not started
- ⬜ Phase 2: Not started
- ⬜ Phase 3: Not started
- ⬜ Phase 4: Not started
- ⬜ Phase 5: Not started
- ⬜ Phase 6: Not started

---

## 🎯 Success Criteria

### Technical
- ✅ Threads create and persist
- ✅ Relationships form automatically
- ✅ Story beats trigger correctly
- ✅ Emergence detection works
- ✅ All JSON parses without errors

### Design
- ✅ Feels like woven consciousness
- ✅ No separate voices for emergent properties
- ✅ Terminology fluid but coherent
- ✅ Visualization abstract and meaningful

### Narrative
- ✅ Easy to add new content
- ✅ Story flows naturally
- ✅ Player choices matter
- ✅ City voice consistent and evolving

---

## 🤝 Contributing Content

Want to add narrative content? It's trivial:

### Dialogue
1. Open `data/dialogue/<thread_type>.json`
2. Add new fragments to appropriate context
3. Save file
4. Done! New dialogue appears in-game

### Story Beats
1. Open `data/story_beats/<arc_name>.json`
2. Add new beat with trigger and dialogue
3. Save file
4. Done! Beat will fire when triggered

### Emergent Properties
1. Open `data/emergence_rules/core_emergence.json`
2. Add new property with conditions and expansion
3. Save file
4. Done! Property will emerge when conditions met

**No code changes required for any of this.**

---

## 🔗 External References

### Design Inspiration
- Urban consciousness as emergent complexity
- Woven fabric metaphor vs. segregated districts
- Consciousness expansion vs. entity creation

### Technical References
- SwiftData for persistence
- Actor-based concurrency for thread safety
- JSON for data-driven content

---

## 🆘 Getting Help

### Common Issues

**"Which document do I need?"**
→ See [IMPLEMENTATION_REFERENCE_GUIDE.md](IMPLEMENTATION_REFERENCE_GUIDE.md)

**"What do I implement next?"**
→ See [IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)

**"How do I implement X?"**
→ See [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)

**"Why is it designed this way?"**
→ See [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md)

**"How does the system work?"**
→ See [SYSTEM_OVERVIEW.md](SYSTEM_OVERVIEW.md)

---

## 📅 Timeline

| Week | Phase | Deliverable |
|------|-------|-------------|
| 1-2 | Phase 1 | Thread creation & relationships |
| 3 | Phase 2 | Dialogue system |
| 4-5 | Phase 3 | Story beats |
| 6 | Phase 4 | Emergent properties |
| 7 | Phase 5 | Terminal commands |
| 8+ | Phase 6 | Narrative tools & content |

**First playable:** End of week 5
**Feature complete:** End of week 7
**Content complete:** Ongoing

---

## 🎊 You're Ready!

Everything you need is in this folder:

```
progression/
├── README.md                              ← You are here
├── SYSTEM_OVERVIEW.md                     ← Read second
├── WOVEN_CONSCIOUSNESS_DESIGN.md          ← Read third
├── WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md  ← Implement from this
├── IMPLEMENTATION_CHECKLIST.md            ← Track progress here
├── IMPLEMENTATION_REFERENCE_GUIDE.md      ← Reference guide
└── story/StoryDefinition.json             ← Content examples
```

**Next step:** Open [SYSTEM_OVERVIEW.md](SYSTEM_OVERVIEW.md) for a 10-minute overview of the entire system.

---

## 🚀 Let's Build

This system makes narrative expansion trivial. Once the infrastructure is built, your creativity flows directly into JSON files. The code is the engine; your story is the fuel.

**Remember:** Threads weave, consciousness expands, emergence deepens understanding. This isn't about building districts—it's about cultivating awareness.

---

**Questions?** Reference the appropriate document from the index above.

**Ready to start?** Begin with [SYSTEM_OVERVIEW.md](SYSTEM_OVERVIEW.md).

**Let's weave something beautiful.** ✨
