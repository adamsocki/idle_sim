# Implementation Reference Guide: Woven Consciousness System

**Created:** 2025-10-14
**Purpose:** Quick reference for which documents to use during implementation

---

## Document Hierarchy & Purpose

### 🎯 **START HERE**

#### [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)
**Your primary implementation guide**
- **Use for:** Step-by-step implementation phases
- **Contains:** Data models, code examples, phased approach
- **Best for:** Active development work
- **Key sections:**
  - Phase 1: Core Thread System
  - Phase 2: Dialogue System (JSON-based)
  - Phase 3: Story Beats
  - Phase 4: Emergent Properties
  - Phase 5: Terminal Commands
  - Narrative expansion workflow

---

### 🎨 **DESIGN REFERENCE**

#### [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md)
**Your design bible**
- **Use for:** Understanding the "why" behind design decisions
- **Contains:**
  - Terminology discussions (threads vs. systems vs. layers)
  - Design decisions (fluid language, consciousness expansion, additive threading)
  - Visual representation concepts
  - Story progression examples
- **Best for:** Resolving design questions, maintaining thematic coherence
- **Reference when:**
  - Writing dialogue
  - Making architectural decisions
  - Explaining concepts to others
  - Staying true to the vision

---

### 📊 **EXISTING SYSTEM REFERENCE**

#### [PROGRESSION_SYSTEM_ARCHITECTURE.md](PROGRESSION_SYSTEM_ARCHITECTURE.md)
**The original progression system architecture**
- **Use for:** Understanding existing progression concepts
- **Contains:**
  - Story graph structure
  - Milestone system (existing)
  - Player journal/memory
  - Branching narrative system
  - Playstyle profiling
- **Best for:** Understanding how existing progression system works
- **Note:** This is the OLD system before Woven Consciousness redesign
- **Reference when:**
  - Migrating from old system
  - Understanding milestone mechanics
  - Learning about story beat triggers
  - Implementing journal/memory features

#### [story/StoryDefinition.json](story/StoryDefinition.json)
**Existing story content**
- **Use for:** Example story structure, existing milestones
- **Contains:**
  - Chapter/Act structure
  - Story beats with triggers
  - Milestone definitions
  - Branch conditions
  - Narrative moods
- **Best for:** Understanding JSON story format, copying structure
- **Reference when:**
  - Creating new story JSON files
  - Understanding trigger types
  - Designing branching paths
  - Implementing milestone requirements

---

### 🚀 **GETTING STARTED**

#### [GETTING_STARTED.md](GETTING_STARTED.md)
**Practical first steps**
- **Use for:** Initial setup and first implementation
- **Contains:**
  - Directory structure
  - Model file creation
  - Manager stub creation
  - Integration steps
  - Testing procedures
- **Best for:** Day 1 setup
- **Reference when:**
  - Starting from scratch
  - Setting up file structure
  - Creating initial models
  - Hooking into existing codebase

---

## Implementation Workflow: Which Doc When?

### **Phase 1: Planning & Setup** (Day 1)

1. **Read:** [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md)
   - Understand the vision
   - Review design decisions
   - Internalize terminology

2. **Read:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) Phase 1
   - Understand data models
   - Review code examples

3. **Reference:** [GETTING_STARTED.md](GETTING_STARTED.md)
   - Create directory structure
   - Set up initial files

### **Phase 2: Core Thread System** (Week 1)

1. **Primary:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) Phase 1
   - Copy data model code
   - Implement thread creation
   - Build relationship system

2. **Reference:** [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md)
   - Verify design alignment
   - Check terminology usage

3. **Cross-reference:** [PROGRESSION_SYSTEM_ARCHITECTURE.md](PROGRESSION_SYSTEM_ARCHITECTURE.md)
   - Understand how this differs from old system
   - See where concepts overlap

### **Phase 3: Dialogue System** (Week 2)

1. **Primary:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) Phase 2
   - Implement dialogue data models
   - Create JSON loader
   - Build dialogue manager

2. **Reference:** [story/StoryDefinition.json](story/StoryDefinition.json)
   - Copy JSON structure
   - Understand trigger format
   - See example dialogue

3. **Design Reference:** [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md)
   - Fluid terminology examples
   - Dialogue voice guidelines
   - Context-appropriate language

### **Phase 4: Story Beats** (Week 3)

1. **Primary:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) Phase 3
   - Implement story beat system
   - Create beat manager
   - Build trigger evaluation

2. **Reference:** [PROGRESSION_SYSTEM_ARCHITECTURE.md](PROGRESSION_SYSTEM_ARCHITECTURE.md)
   - Milestone trigger concepts
   - Branch condition examples
   - Story flow patterns

3. **Content Reference:** [story/StoryDefinition.json](story/StoryDefinition.json)
   - Example beats
   - Trigger types
   - Branch structures

### **Phase 5: Emergent Properties** (Week 4)

1. **Primary:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) Phase 4
   - Implement emergence detection
   - Build consciousness expansion
   - Create property effects

2. **Design Critical:** [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md) Section 2
   - Consciousness expansion (NOT separate voices)
   - Deepening existing awareness
   - Perception expansion examples

### **Phase 6: Narrative Content Creation** (Ongoing)

1. **Primary:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) Phase 6
   - Content creation workflow
   - JSON schema reference
   - Validation tools

2. **Design Reference:** [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md)
   - Voice consistency
   - Terminology variations
   - Thematic coherence

3. **Example Reference:** [story/StoryDefinition.json](story/StoryDefinition.json)
   - Copy-paste structure
   - Adapt existing beats
   - Reuse trigger patterns

---

## Quick Reference: Common Questions

### "How should threads describe themselves?"
→ **[WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md)** Section 1: Fluid Terminology
- Primary: "thread"
- Alternates: pulse, vein, chord, pathway, thought
- Context-dependent usage

### "How do emergent properties work?"
→ **[WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md)** Section 2: Emergent Properties Expand Consciousness
- NO separate voices
- Deepens existing consciousness
- Expands perception and complexity

### "What data models do I need?"
→ **[WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)** Phase 1: Data Models
- UrbanThread
- ThreadRelationship
- EmergentProperty
- ConsciousnessExpansion

### "How do I structure dialogue JSON?"
→ **[WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)** Phase 2: Dialogue Library
- DialogueFragment structure
- Speaker types
- Context tags
- Example JSON

### "What triggers can I use for story beats?"
→ **[story/StoryDefinition.json](story/StoryDefinition.json)** Examples + **[WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)** Phase 3
- on_chapter_start
- on_milestone
- on_command
- on_stat_threshold
- on_time_elapsed
- on_choice
- on_emergent_property

### "How do relationships work?"
→ **[WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)** Phase 1.3: Relationship Calculator
- Compatibility matrix
- Relationship types
- Synergy calculation

### "How should the visualization look?"
→ **[WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md)** Section 4: Visual Representation
- Abstract, pulsing consciousness field
- Command-triggered
- ASCII art examples
- Impressionistic, not literal

### "What's the old progression system?"
→ **[PROGRESSION_SYSTEM_ARCHITECTURE.md](PROGRESSION_SYSTEM_ARCHITECTURE.md)**
- Chapter/Act structure (KEEP)
- Milestone system (KEEP)
- Journal/Memory (KEEP)
- Districts (REPLACE with Threads)

---

## Document Status Legend

| Status | Meaning |
|--------|---------|
| ✅ **PRIMARY** | Use this for active implementation |
| 📚 **REFERENCE** | Consult when needed, not step-by-step |
| 🎨 **DESIGN** | Design philosophy and decisions |
| 📊 **LEGACY** | Old system, use for context only |
| 📖 **EXAMPLE** | Content examples to copy/adapt |

### Current Status

| Document | Status | When to Use |
|----------|--------|-------------|
| [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) | ✅ PRIMARY | Daily, for all implementation |
| [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md) | 🎨 DESIGN | When writing content or making design choices |
| [PROGRESSION_SYSTEM_ARCHITECTURE.md](PROGRESSION_SYSTEM_ARCHITECTURE.md) | 📚 REFERENCE | Understanding existing system concepts |
| [story/StoryDefinition.json](story/StoryDefinition.json) | 📖 EXAMPLE | Creating JSON files |
| [GETTING_STARTED.md](GETTING_STARTED.md) | 📚 REFERENCE | Initial setup only |

---

## File Creation Checklist

When creating new narrative content:

### Creating a New Thread Type

1. **Design Reference:** [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md)
   - [ ] Decide on alternate terminology
   - [ ] Define thread voice/personality
   - [ ] Consider relationship to existing threads

2. **Code Implementation:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)
   - [ ] Add to ThreadType enum
   - [ ] Create dialogue JSON file
   - [ ] Add relationship rules
   - [ ] Test thread creation

3. **Content Creation:** New JSON file
   - [ ] Use [story/StoryDefinition.json](story/StoryDefinition.json) as template
   - [ ] Write dialogue fragments for all contexts
   - [ ] Test dialogue retrieval

### Creating an Emergent Property

1. **Design Verification:** [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md) Section 2
   - [ ] Confirm it expands consciousness (not new voice)
   - [ ] Define which perceptions it adds
   - [ ] Determine consciousness expansion

2. **Implementation:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) Phase 4
   - [ ] Add to emergence rules JSON
   - [ ] Define trigger conditions
   - [ ] Write consciousness expansion
   - [ ] Create story beat

3. **Test:**
   - [ ] Verify detection triggers
   - [ ] Confirm consciousness expansion applies
   - [ ] Check story beat fires

### Creating a Story Beat

1. **Structure Reference:** [story/StoryDefinition.json](story/StoryDefinition.json)
   - [ ] Copy beat structure
   - [ ] Choose appropriate trigger type
   - [ ] Add to correct chapter/act

2. **Content Guidelines:** [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md)
   - [ ] Use fluid terminology
   - [ ] Maintain voice consistency
   - [ ] Verify thematic coherence

3. **Implementation:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) Phase 3
   - [ ] Add beat to JSON
   - [ ] Test trigger conditions
   - [ ] Verify dialogue display

---

## Migration Path from Old System

If migrating from existing progression system:

### Keep These Concepts
- ✅ Chapter/Act structure
- ✅ Milestone system
- ✅ Journal/Memory
- ✅ Playstyle profiling
- ✅ Story beat triggers

### Replace These Concepts
- ❌ Districts → Threads
- ❌ Geographic expansion → Relational deepening
- ❌ Separate zones → Woven fabric
- ❌ Hard boundaries → Fluid integration

### Reference Documents for Migration
1. [PROGRESSION_SYSTEM_ARCHITECTURE.md](PROGRESSION_SYSTEM_ARCHITECTURE.md) - Understand old concepts
2. [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md) - Understand new philosophy
3. [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) - Implement new system

---

## Content Creation Quick Links

### Writing Dialogue
- **Guide:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) Phase 2
- **Examples:** [story/StoryDefinition.json](story/StoryDefinition.json)
- **Voice Guide:** [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md) Section 1

### Designing Emergence
- **Philosophy:** [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md) Section 2
- **Implementation:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) Phase 4
- **Examples:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) Phase 4.2

### Creating Story Arcs
- **Structure:** [story/StoryDefinition.json](story/StoryDefinition.json)
- **Implementation:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) Phase 3
- **Triggers:** [PROGRESSION_SYSTEM_ARCHITECTURE.md](PROGRESSION_SYSTEM_ARCHITECTURE.md) Story Authoring

---

## Daily Development Workflow

### Morning: Planning
1. Open [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)
2. Identify current phase
3. Review phase goals

### During: Implementation
1. Follow [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) step-by-step
2. Reference [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md) for design questions
3. Copy structure from [story/StoryDefinition.json](story/StoryDefinition.json) when needed

### Content Creation: Writing
1. Check [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md) for voice/terminology
2. Use [story/StoryDefinition.json](story/StoryDefinition.json) as template
3. Follow JSON schema in [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)

### Evening: Review
1. Verify alignment with [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md)
2. Check implementation matches [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)
3. Test content against examples

---

## Summary: One-Sentence Per Document

| Document | One-Sentence Purpose |
|----------|---------------------|
| **WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md** | How to build it (step-by-step code) |
| **WOVEN_CONSCIOUSNESS_DESIGN.md** | Why we designed it this way (philosophy & decisions) |
| **PROGRESSION_SYSTEM_ARCHITECTURE.md** | How the old progression system worked (reference) |
| **story/StoryDefinition.json** | Example story content (copy this structure) |
| **GETTING_STARTED.md** | First steps for setup (day 1 only) |

---

## The Golden Rule

**When in doubt:**
1. Check [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) for HOW
2. Check [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md) for WHY
3. Check [story/StoryDefinition.json](story/StoryDefinition.json) for EXAMPLE

**Everything else is supporting context.**

---

## Document Cross-Reference Map

```
WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md (PRIMARY)
├── Phase 1: Data Models
│   └── References: WOVEN_CONSCIOUSNESS_DESIGN.md (threading concepts)
├── Phase 2: Dialogue System
│   ├── References: story/StoryDefinition.json (dialogue structure)
│   └── References: WOVEN_CONSCIOUSNESS_DESIGN.md (fluid terminology)
├── Phase 3: Story Beats
│   ├── References: PROGRESSION_SYSTEM_ARCHITECTURE.md (trigger types)
│   └── References: story/StoryDefinition.json (beat examples)
├── Phase 4: Emergent Properties
│   └── References: WOVEN_CONSCIOUSNESS_DESIGN.md (consciousness expansion)
├── Phase 5: Terminal Commands
│   └── References: WOVEN_CONSCIOUSNESS_DESIGN.md (visualization)
└── Phase 6: Narrative Tools
    └── References: story/StoryDefinition.json (content examples)

WOVEN_CONSCIOUSNESS_DESIGN.md (DESIGN BIBLE)
├── Terminology Decisions
├── Consciousness Expansion Philosophy
├── Threading Mechanics
└── Visualization Concepts

story/StoryDefinition.json (CONTENT TEMPLATE)
├── Chapter/Act structure
├── Beat trigger examples
├── Milestone definitions
└── Dialogue format

PROGRESSION_SYSTEM_ARCHITECTURE.md (LEGACY REFERENCE)
├── Milestone concepts (KEEP)
├── Trigger types (ADAPT)
└── Districts (REPLACE with Threads)
```

---

**Remember:** You're building a system where narrative content is as easy to add as editing JSON. Keep implementation flexible, keep design coherent, keep content modular.
