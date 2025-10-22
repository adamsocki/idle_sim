# Woven Consciousness: Implementation Checklist

**Created:** 2025-10-14
**Purpose:** Track implementation progress phase by phase

---

## How to Use This Checklist

- [ ] Check off items as you complete them
- Each phase builds on the previous
- Don't skip phases (dependencies matter)
- Test each phase before moving to the next

---

## 📋 Pre-Implementation Setup

### Documentation Review
- [ ] Read [WOVEN_CONSCIOUSNESS_DESIGN.md](WOVEN_CONSCIOUSNESS_DESIGN.md) completely
- [ ] Read [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md) Phases 1-2
- [ ] Skim [PROGRESSION_SYSTEM_ARCHITECTURE.md](PROGRESSION_SYSTEM_ARCHITECTURE.md) for context
- [ ] Review [story/StoryDefinition.json](story/StoryDefinition.json) structure

### Directory Structure
- [x] Create `progression/models/` directory
- [x] Create `progression/systems/` directory
- [x] Create `progression/data/` directory
- [x] Create `progression/data/dialogue/` directory
- [x] Create `progression/data/story_beats/` directory
- [x] Create `progression/data/emergence_rules/` directory

---

## Phase 1: Core Thread System ⚙️

**Goal:** Independent threads that form relationships
**Estimated Time:** 1-2 weeks
**Reference:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md Phase 1](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)

### 1.1 Data Models

- [x] Create `models/UrbanThread.swift`
  - [x] Basic properties (id, type, instanceNumber, weavedAt)
  - [x] Consciousness properties (coherence, autonomy, complexity)
  - [x] Relationships array
  - [x] @Model decorator and SwiftData integration

- [x] Create `models/ThreadType.swift`
  - [x] Define initial thread types (transit, housing, culture, commerce, parks)
  - [x] Codable conformance
  - [x] Easy to extend

- [x] Create `models/ThreadRelationship.swift`
  - [x] otherThreadID
  - [x] relationType (support, harmony, tension, resonance, dependency)
  - [x] strength, synergy values
  - [x] isSameType flag
  - [x] Codable conformance

- [x] Create `models/RelationType.swift`
  - [x] Enum with all relationship types
  - [x] String raw values

### 1.2 Thread Creation System

- [x] Create `systems/ThreadWeaver.swift`
  - [x] `weaveThread(type:into:context:)` method
  - [x] Instance number calculation
  - [x] Automatic relationship formation
  - [x] SwiftData integration

### 1.3 Relationship System

- [x] Create `systems/RelationshipCalculator.swift`
  - [x] `calculate(from:to:)` method
  - [x] Same-type detection (resonance)
  - [x] Different-type compatibility lookup

- [x] Create `data/RelationshipRules.swift`
  - [x] ThreadPair struct (hashable)
  - [x] RelationshipTemplate struct
  - [x] compatibilityMatrix dictionary
  - [x] Add initial relationships:
    - [x] Transit + Housing (strong support)
    - [x] Culture + Commerce (moderate harmony)
    - [x] Parks + Housing (strong support)
    - [x] Power + Water (dependency)
    - [x] 20+ total relationship definitions

### 1.4 Testing

- [x] Add models to SwiftData container in App file
- [x] Build succeeds without errors
- [ ] Create test: Weave first thread (manual testing needed)
- [ ] Create test: Weave second thread, verify relationship formed (manual testing needed)
- [ ] Create test: Weave same-type thread, verify resonance (manual testing needed)
- [ ] Verify threads persist between app launches (manual testing needed)

**Phase 1 Complete When:**
- ✅ Can create threads
- ✅ Threads form relationships automatically
- ✅ Relationships persist (SwiftData configured)
- ⚠️ Manual testing pending

---

## Phase 2: Dialogue System 💬

**Goal:** Data-driven dialogue that's trivial to expand
**Estimated Time:** 1 week
**Reference:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md Phase 2](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)

### 2.1 Dialogue Data Models

- [ ] Create `models/Dialogue.swift`
  - [ ] DialogueLine struct
  - [ ] DialogueSpeaker enum (maps to ThreadType)
  - [ ] EmotionalTone enum
  - [ ] DialogueFragment struct
  - [ ] DialogueContext enum (onCreation, onRelationship, onEmergence, etc.)

### 2.2 Dialogue JSON Files

- [ ] Create `data/dialogue/city_core.json`
  - [ ] First thread dialogue
  - [ ] Second thread dialogue
  - [ ] Emergence dialogue
  - [ ] Reflection dialogue

- [ ] Create `data/dialogue/transit.json`
  - [ ] Alternate terminology array
  - [ ] Creation dialogue (5+ variations)
  - [ ] Relationship dialogue (housing, culture, commerce)
  - [ ] Tension dialogue
  - [ ] Idle dialogue

- [ ] Create `data/dialogue/housing.json`
  - [ ] Alternate terminology array
  - [ ] Creation dialogue
  - [ ] Transit relationship dialogue
  - [ ] Emergence dialogue (walkability)
  - [ ] Idle dialogue

- [ ] Create `data/dialogue/culture.json`
  - [ ] Alternate terminology array
  - [ ] Creation dialogue
  - [ ] Commerce relationship dialogue
  - [ ] Housing relationship dialogue

### 2.3 Dialogue Manager

- [ ] Create `systems/DialogueManager.swift`
  - [ ] Actor declaration
  - [ ] `loadDialogueLibrary()` method
  - [ ] `getDialogue(speaker:context:tags:)` method
  - [ ] `getAlternateTerminology(for:)` method
  - [ ] JSON parsing with error handling
  - [ ] Add JSON files to bundle (Build Phases → Copy Bundle Resources)

### 2.4 Testing

- [ ] Test: Load all dialogue JSON files
- [ ] Test: Retrieve dialogue by speaker + context
- [ ] Test: Filter dialogue by tags
- [ ] Test: Get random alternate terminology
- [ ] Test: Malformed JSON handled gracefully
- [ ] Verify JSON files in app bundle

**Phase 2 Complete When:**
- ✅ All dialogue in JSON files
- ✅ Can retrieve dialogue by speaker, context, tags
- ✅ Alternate terminology works
- ✅ JSON parsing errors caught and logged

---

## Phase 3: Story Beats System 🎭

**Goal:** Trigger story moments based on simple conditions
**Estimated Time:** 1-2 weeks
**Reference:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md Phase 3](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)

### 3.1 Story Beat Data Models

- [ ] Create `models/StoryBeat.swift`
  - [ ] StoryBeat struct
  - [ ] BeatTrigger enum (all trigger types)
  - [ ] BeatEffects struct
  - [ ] ThoughtSpawner struct

### 3.2 Story Beat JSON Files

- [ ] Create `data/story_beats/core_progression.json`
  - [ ] beat_first_thread
  - [ ] beat_second_thread
  - [ ] beat_transit_housing_relationship
  - [ ] Add 5+ initial beats

- [ ] Create `data/story_beats/emergent_properties.json`
  - [ ] beat_walkability_emergence
  - [ ] beat_vibrancy_emergence
  - [ ] Add 3+ emergence beats

### 3.3 Story Beat Manager

- [ ] Create `systems/StoryBeatManager.swift`
  - [ ] Actor declaration
  - [ ] `loadStoryBeats()` method
  - [ ] `checkTriggers(city:)` method
  - [ ] `evaluateTrigger(_:city:)` method for each trigger type
  - [ ] `applyEffects(_:to:)` method
  - [ ] Beat state tracking (hasOccurred, oneTimeOnly)

### 3.4 Integration

- [ ] Hook into terminal command execution
  - [ ] Check triggers after each command
  - [ ] Display dialogue in terminal output

- [ ] Hook into simulation tick
  - [ ] Check triggers periodically (every N ticks)
  - [ ] Display dialogue in city log

### 3.5 Testing

- [ ] Test: Beat triggers on first thread creation
- [ ] Test: Beat triggers on milestone
- [ ] Test: Beat triggers on stat threshold
- [ ] Test: Beat effects applied correctly
- [ ] Test: One-time beats don't repeat
- [ ] Test: Beat dialogue displays in terminal

**Phase 3 Complete When:**
- ✅ Story beats defined in JSON
- ✅ Triggers evaluated automatically
- ✅ Dialogue displayed when beats fire
- ✅ Effects applied to city/threads
- ✅ One-time beats work correctly

---

## Phase 4: Emergent Properties 🌟

**Goal:** Emergent properties deepen consciousness, don't create voices
**Estimated Time:** 1 week
**Reference:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md Phase 4](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)

### 4.1 Emergent Property Data Models

- [ ] Create `models/EmergentProperty.swift`
  - [ ] EmergentProperty @Model class
  - [ ] ConsciousnessExpansion struct
  - [ ] RelationshipDeepening struct
  - [ ] hasVoice property (always false)

### 4.2 Emergence Rules JSON

- [ ] Create `data/emergence_rules/core_emergence.json`
  - [ ] Walkability (transit + housing)
  - [ ] Vibrancy (culture + commerce + housing)
  - [ ] Resilience (power + water + sewage)
  - [ ] Identity (housing + culture)
  - [ ] Add 4+ initial emergence rules

### 4.3 Emergence Detector

- [ ] Create `systems/EmergenceDetector.swift`
  - [ ] Actor declaration
  - [ ] `loadEmergenceRules()` method
  - [ ] `checkForEmergence(in:)` method
  - [ ] `evaluateConditions(_:city:)` method
  - [ ] `createEmergentProperty(from:city:)` method
  - [ ] `applyConsciousnessExpansion(_:to:)` method

### 4.4 Integration

- [ ] Update City model
  - [ ] Add `emergentProperties` array
  - [ ] Add `perceptions` array (for new perceptions)
  - [ ] Add `complexity` property

- [ ] Check for emergence after:
  - [ ] Thread creation
  - [ ] Relationship strengthening
  - [ ] Stat changes

### 4.5 Testing

- [ ] Test: Walkability emerges when conditions met
- [ ] Test: Consciousness expansion applied to affected threads
- [ ] Test: New perceptions added to city
- [ ] Test: Complexity increases correctly
- [ ] Test: No new voices created
- [ ] Test: Story beat fires on emergence

**Phase 4 Complete When:**
- ✅ Emergence rules defined in JSON
- ✅ Properties detected automatically
- ✅ Consciousness expansion works
- ✅ No new voices created (expansion only)
- ✅ Thread consciousness deepens appropriately

---

## Phase 5: Terminal Commands & Visualization 🖥️

**Goal:** Player interface for weaving and observing
**Estimated Time:** 1 week
**Reference:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md Phase 5](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)

### 5.1 Core Commands

- [ ] Add `weave` command
  - [ ] Parse thread type argument
  - [ ] Call ThreadWeaver
  - [ ] Display creation dialogue
  - [ ] Show relationship formation

- [ ] Add `threads` command
  - [ ] List all threads
  - [ ] Show stats (coherence, autonomy, complexity)
  - [ ] Show relationships
  - [ ] Format cleanly

- [ ] Add `consciousness` command
  - [ ] Generate abstract visualization
  - [ ] Show city stats
  - [ ] Display city reflection dialogue

- [ ] Add `pulse` command
  - [ ] Alternative visualization style
  - [ ] Animated if possible

- [ ] Add `fabric` command
  - [ ] Network diagram view
  - [ ] Show integration levels

### 5.2 Visualization Renderers

- [ ] Create `systems/ConsciousnessRenderer.swift`
  - [ ] `render(city:pulsePhase:)` method
  - [ ] `generateNodes(for:)` method
  - [ ] `renderNodeField(nodes:phase:)` method
  - [ ] `renderBar(_:)` method for stats
  - [ ] ASCII art symbols (◉, ○, ∿, ═, ║)

- [ ] Create `systems/ThreadListRenderer.swift`
  - [ ] `render(city:)` method
  - [ ] `renderThread(_:city:)` method
  - [ ] Format with proper spacing/alignment

### 5.3 Integration

- [ ] Update terminal command parser
  - [ ] Add new command types
  - [ ] Parse arguments correctly

- [ ] Hook command execution
  - [ ] Trigger story beats after commands
  - [ ] Update journal/playstyle
  - [ ] Check milestones

### 5.4 Testing

- [ ] Test: `weave transit` creates thread and shows dialogue
- [ ] Test: `threads` lists all threads correctly
- [ ] Test: `consciousness` shows abstract visualization
- [ ] Test: Commands trigger appropriate story beats
- [ ] Test: Terminal output formatting looks good

**Phase 5 Complete When:**
- ✅ All core commands work
- ✅ Visualizations render correctly
- ✅ Commands trigger story beats
- ✅ Terminal output is clean and readable

---

## Phase 6: Narrative Expandability Tools 🛠️

**Goal:** Make it trivial to add narrative content
**Estimated Time:** Ongoing
**Reference:** [WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md Phase 6](WOVEN_CONSCIOUSNESS_IMPLEMENTATION.md)

### 6.1 JSON Schemas

- [ ] Create `data/schemas/dialogue_schema.json`
- [ ] Create `data/schemas/story_beat_schema.json`
- [ ] Create `data/schemas/emergence_schema.json`

### 6.2 Content Validator

- [ ] Create `tools/ContentValidator.swift`
  - [ ] `validateAllContent()` method
  - [ ] `validateDialogueFiles()` method
  - [ ] `validateStoryBeatFiles()` method
  - [ ] `validateEmergenceRules()` method
  - [ ] ValidationError struct with severity

- [ ] Add validation on app launch (debug builds)

### 6.3 Documentation

- [ ] Create example files for:
  - [ ] New thread type
  - [ ] New emergent property
  - [ ] New story arc

- [ ] Document content creation workflow

### 6.4 Testing

- [ ] Test: Validator catches missing required fields
- [ ] Test: Validator catches malformed JSON
- [ ] Test: Validator provides helpful error messages
- [ ] Test: Valid content passes validation

**Phase 6 Complete When:**
- ✅ JSON schemas defined
- ✅ Content validator working
- ✅ Documentation complete
- ✅ Example templates created

---

## Integration & Polish 🎨

### City Model Updates

- [ ] Add to City model:
  - [ ] `threads: [UrbanThread]` relationship
  - [ ] `emergentProperties: [EmergentProperty]` relationship
  - [ ] `perceptions: [String]` array
  - [ ] `complexity: Double` property
  - [ ] Helper methods for thread access

### Progressive Unlocking (Optional)

- [ ] Implement command registry
- [ ] Gate commands behind milestones
- [ ] Show "locked" state with hints
- [ ] Unlock commands through story progression

### Playstyle Tracking

- [ ] Create `models/PlaystyleProfile.swift`
- [ ] Track command frequency
- [ ] Track thread creation patterns
- [ ] Calculate engagement metrics
- [ ] Use in branching narratives

### Journal System

- [ ] Create `models/JournalEntry.swift`
- [ ] Log all significant events
- [ ] Store per-city
- [ ] Add `journal` command to view history

---

## Content Creation Tasks 📝

### Initial Content (MVP)

- [ ] Write dialogue for 5 thread types
  - [ ] Transit (complete)
  - [ ] Housing (complete)
  - [ ] Culture (complete)
  - [ ] Commerce
  - [ ] Parks

- [ ] Create 10 story beats
  - [ ] First thread (complete)
  - [ ] Second thread (complete)
  - [ ] First relationship
  - [ ] First emergence
  - [ ] 6 more beats

- [ ] Define 4 emergent properties
  - [ ] Walkability (complete)
  - [ ] Vibrancy (complete)
  - [ ] Resilience
  - [ ] Identity

### Extended Content (Post-MVP)

- [ ] Add 5 more thread types
  - [ ] Water
  - [ ] Power
  - [ ] Sewage
  - [ ] Knowledge
  - [ ] History

- [ ] Create full story arc (20+ beats)
- [ ] Add 10+ emergent properties
- [ ] Write late-game content
- [ ] Add branching paths

---

## Testing & Quality Assurance ✅

### Unit Tests

- [ ] ThreadWeaver tests
- [ ] RelationshipCalculator tests
- [ ] DialogueManager tests
- [ ] StoryBeatManager tests
- [ ] EmergenceDetector tests

### Integration Tests

- [ ] Full thread creation → relationship → emergence flow
- [ ] Command execution → story beat → dialogue display
- [ ] Persistence across app launches
- [ ] Multiple cities with independent progression

### Content Tests

- [ ] All JSON files parse correctly
- [ ] All dialogue retrievable
- [ ] All story beats triggerable
- [ ] All emergent properties detectable

### Playtest

- [ ] Create new city, play through first 30 minutes
- [ ] Verify story progression feels natural
- [ ] Check pacing of beats
- [ ] Verify dialogue variations appear
- [ ] Test emergence detection
- [ ] Verify consciousness expansion

---

## Polish & Refinement 💎

### Performance

- [ ] Profile JSON loading times
- [ ] Optimize trigger checking
- [ ] Cache dialogue lookups
- [ ] Minimize SwiftData queries

### UX

- [ ] Tune dialogue pacing
- [ ] Adjust stat change values
- [ ] Balance emergence thresholds
- [ ] Polish terminal output formatting
- [ ] Add helpful command hints

### Content

- [ ] Review all dialogue for consistency
- [ ] Ensure terminology fluid but coherent
- [ ] Verify thematic alignment
- [ ] Check for typos/grammar

---

## Launch Readiness 🚀

### Final Checklist

- [ ] All phases complete
- [ ] All tests passing
- [ ] Content validated
- [ ] No critical bugs
- [ ] Performance acceptable
- [ ] Documentation up to date

### Post-Launch

- [ ] Monitor player feedback
- [ ] Track which story beats fire
- [ ] Identify confusing moments
- [ ] Plan content expansions

---

## Current Status

**Last Updated:** 2025-10-14 (Phase 1 Complete)

**Current Phase:** Phase 2 - Dialogue System (Ready to Start)

**Progress:**
- Documentation: ✅ Complete
- Phase 1: ✅ **COMPLETE** - Core Thread System
- Phase 2: ⬜ Not started (Next)
- Phase 3: ⬜ Not started
- Phase 4: ⬜ Not started
- Phase 5: ⬜ Not started
- Phase 6: ⬜ Not started

**Next Action:** Begin Phase 2 - Create dialogue data models and JSON library

**Phase 1 Achievements:**
- Created 7 Swift files implementing the core thread system
- All files compile successfully
- SwiftData integration complete
- 20+ thread relationship definitions
- Build successful ✅

---

## Notes & Learnings

**2025-10-14 - Phase 1 Implementation:**
- Actor isolation with SwiftData required `@MainActor` annotations on ThreadWeaver methods
- Files needed to be in `idle_01/progression/` directory to be included in Xcode build
- ThreadPair struct with order-independent hashing works well for relationship lookups
- SwiftData relationships between City and UrbanThread configured correctly
- All 9 thread types (transit, housing, culture, commerce, parks, water, power, sewage, knowledge) defined

**Lessons Learned:**
- Start with simple actor isolation, add @MainActor where needed
- Test build early and often
- Keep relationship rules in a separate file for easy expansion

---

## Timeline Estimate

| Phase | Estimated Time | Status |
|-------|----------------|--------|
| Pre-Implementation | 1 day | ✅ |
| Phase 1: Core Thread System | 1-2 weeks | ✅ (Completed in 1 session!) |
| Phase 2: Dialogue System | 1 week | ⬜ (Next) |
| Phase 3: Story Beats | 1-2 weeks | ⬜ |
| Phase 4: Emergent Properties | 1 week | ⬜ |
| Phase 5: Terminal Commands | 1 week | ⬜ |
| Phase 6: Narrative Tools | Ongoing | ⬜ |
| **Total** | **5-7 weeks** | **1/6 phases complete** |

---

**Remember:** This is a living document. Update it as you progress, add notes, adjust estimates, and celebrate completed phases!
