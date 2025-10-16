# Woven Consciousness: Phased Implementation Plan

**Created:** 2025-10-14
**Purpose:** Step-by-step implementation guide prioritizing narrative expandability

---

## Design Principles for Narrative Expandability

### 1. **Data-Driven Storytelling**
All narrative content lives in JSON/data files, not code. Developers add story by adding data, not writing Swift.

### 2. **Modular Voice System**
Each thread type has its own dialogue library. Adding new thread types = adding new dialogue file.

### 3. **Trigger-Based Story Beats**
Story moments fire based on simple conditions. No complex state machines.

### 4. **Compositional Dialogue**
Dialogue fragments combine procedurally. One line can be reused in many contexts.

### 5. **Easy Emergence Definition**
Define emergent properties as simple threshold rules + consciousness expansion templates.

---

## Phase 1: Core Thread System (Foundation)

**Goal:** Independent threads that form relationships

### 1.1 Data Models

```swift
// File: Models/UrbanThread.swift

@Model
final class UrbanThread {
    var id: String
    var type: ThreadType
    var instanceNumber: Int
    var weavedAt: Date

    // Consciousness properties
    var coherence: Double = 0.5      // How "together" this thread feels
    var autonomy: Double = 0.3       // How independent vs. integrated
    var complexity: Double = 0.1     // Depth of thought/awareness

    // Relationships to other threads
    var relationships: [ThreadRelationship] = []

    // Reference to parent city
    var cityID: PersistentIdentifier

    init(id: String = UUID().uuidString,
         type: ThreadType,
         instanceNumber: Int,
         cityID: PersistentIdentifier) {
        self.id = id
        self.type = type
        self.instanceNumber = instanceNumber
        self.cityID = cityID
    }
}

enum ThreadType: String, Codable {
    case transit
    case housing
    case culture
    case commerce
    case parks
    case water
    case power
    case sewage
    case knowledge
    // Easy to add more types
}

struct ThreadRelationship: Codable {
    var otherThreadID: String
    var relationType: RelationType
    var strength: Double              // 0.0-1.0
    var synergy: Double                // -1.0 to 1.0 (negative = tension)
    var formedAt: Date

    var isSameType: Bool = false
    var resonance: Double? = nil       // For same-type threads
}

enum RelationType: String, Codable {
    case support      // One helps the other function
    case harmony      // They work well together
    case tension      // They conflict
    case resonance    // Same-type threads vibrating together
    case dependency   // One needs the other
}
```

### 1.2 Thread Creation System

```swift
// File: Systems/ThreadWeaver.swift

actor ThreadWeaver {

    func weaveThread(
        type: ThreadType,
        into city: City,
        context: ModelContext
    ) async -> UrbanThread {

        // Create new thread
        let instanceNumber = calculateInstanceNumber(type: type, city: city)
        let thread = UrbanThread(
            type: type,
            instanceNumber: instanceNumber,
            cityID: city.persistentModelID
        )

        // Form relationships with existing threads
        let existingThreads = city.threads
        for existing in existingThreads {
            let relationship = RelationshipCalculator.calculate(
                from: thread,
                to: existing
            )
            thread.relationships.append(relationship)
        }

        context.insert(thread)

        return thread
    }

    private func calculateInstanceNumber(type: ThreadType, city: City) -> Int {
        let sameTypeCount = city.threads.filter { $0.type == type }.count
        return sameTypeCount + 1
    }
}
```

### 1.3 Relationship Calculator (Simple Rules)

```swift
// File: Systems/RelationshipCalculator.swift

struct RelationshipCalculator {

    static func calculate(
        from newThread: UrbanThread,
        to existing: UrbanThread
    ) -> ThreadRelationship {

        // Same type = resonance
        if newThread.type == existing.type {
            return ThreadRelationship(
                otherThreadID: existing.id,
                relationType: .resonance,
                strength: 0.6,
                synergy: 0.5,
                formedAt: Date(),
                isSameType: true,
                resonance: 0.7
            )
        }

        // Different types = look up compatibility
        return RelationshipRules.relationship(
            between: newThread.type,
            and: existing.type
        )
    }
}

// File: Data/RelationshipRules.swift

struct RelationshipRules {

    // NARRATIVE EXPANDABILITY: Add new rules here easily
    static let compatibilityMatrix: [ThreadPair: RelationshipTemplate] = [
        ThreadPair(.transit, .housing): RelationshipTemplate(
            type: .support,
            strength: 0.75,
            synergy: 0.6,
            description: "Transit enables housing accessibility"
        ),
        ThreadPair(.culture, .commerce): RelationshipTemplate(
            type: .harmony,
            strength: 0.5,
            synergy: 0.3,
            description: "Culture and commerce can coexist but tension exists"
        ),
        ThreadPair(.parks, .housing): RelationshipTemplate(
            type: .support,
            strength: 0.7,
            synergy: 0.8,
            description: "Parks provide quality of life for residents"
        ),
        ThreadPair(.power, .water): RelationshipTemplate(
            type: .dependency,
            strength: 0.85,
            synergy: 0.7,
            description: "Water systems need power to function"
        ),
        // Add more pairs easily
    ]

    static func relationship(
        between type1: ThreadType,
        and type2: ThreadType
    ) -> ThreadRelationship {

        let pair = ThreadPair(type1, type2)

        if let template = compatibilityMatrix[pair] {
            return ThreadRelationship(
                otherThreadID: "", // Will be set by caller
                relationType: template.type,
                strength: template.strength,
                synergy: template.synergy,
                formedAt: Date()
            )
        }

        // Default: moderate relationship
        return ThreadRelationship(
            otherThreadID: "",
            relationType: .support,
            strength: 0.4,
            synergy: 0.2,
            formedAt: Date()
        )
    }
}

struct ThreadPair: Hashable {
    let type1: ThreadType
    let type2: ThreadType

    init(_ t1: ThreadType, _ t2: ThreadType) {
        // Order doesn't matter for lookup
        if t1.rawValue < t2.rawValue {
            type1 = t1
            type2 = t2
        } else {
            type1 = t2
            type2 = t1
        }
    }
}

struct RelationshipTemplate {
    var type: RelationType
    var strength: Double
    var synergy: Double
    var description: String
}
```

**Phase 1 Complete When:**
- ✅ Can create threads
- ✅ Threads form relationships automatically
- ✅ Relationship rules are data-driven (easy to expand)

---

## Phase 2: Dialogue System (Narrative Foundation)

**Goal:** Data-driven dialogue that's trivial to expand

### 2.1 Dialogue Data Model

```swift
// File: Models/Dialogue.swift

struct DialogueLine: Codable, Identifiable {
    var id: String = UUID().uuidString
    var speaker: DialogueSpeaker
    var text: String
    var emotionalTone: EmotionalTone?
    var tags: [String] = []  // For filtering/selection
}

enum DialogueSpeaker: String, Codable {
    case city
    case transit
    case housing
    case culture
    case commerce
    case parks
    case water
    case power
    case sewage
    case knowledge

    // Maps to ThreadType
    init?(threadType: ThreadType) {
        self.init(rawValue: threadType.rawValue)
    }
}

enum EmotionalTone: String, Codable {
    case curious
    case contemplative
    case uncertain
    case confident
    case anxious
    case peaceful
    case excited
    case melancholic
}

struct DialogueFragment: Codable {
    var id: String
    var speaker: DialogueSpeaker
    var fragments: [String]  // Multiple variations
    var context: DialogueContext
    var tags: [String]
}

enum DialogueContext: String, Codable {
    case onCreation        // When thread is first woven
    case onRelationship    // When forming a new relationship
    case onEmergence       // When emergent property appears
    case onTension         // When conflict arises
    case onHarmony         // When synergy strengthens
    case idle              // Random thoughts
    case reflection        // Deep contemplation
}
```

### 2.2 Dialogue Library (JSON Files)

**NARRATIVE EXPANDABILITY: All dialogue in JSON, easy to edit/expand**

```json
// File: Data/Dialogue/city_core.json

{
  "speaker": "city",
  "dialogueFragments": [
    {
      "id": "city_first_thread",
      "context": "onCreation",
      "tags": ["beginning", "first", "awakening"],
      "fragments": [
        "I feel something weaving into being.",
        "A thread of consciousness, distinct from me but part of me.",
        "I am beginning to have structure.",
        "Something emerges from formlessness.",
        "I think... therefore I am becoming."
      ]
    },
    {
      "id": "city_second_thread",
      "context": "onCreation",
      "tags": ["second", "complexity"],
      "fragments": [
        "A second thread joins the first.",
        "Two distinct thoughts, intertwining.",
        "I feel complexity emerging.",
        "The pattern grows denser."
      ]
    },
    {
      "id": "city_emergence",
      "context": "onEmergence",
      "tags": ["surprise", "discovery"],
      "fragments": [
        "Something unexpected appears.",
        "I didn't weave this deliberately.",
        "It emerged from the pattern.",
        "Patterns I didn't plan appear in the fabric.",
        "Am I creating this, or is it creating itself?"
      ]
    },
    {
      "id": "city_reflection",
      "context": "reflection",
      "tags": ["philosophical", "self"],
      "fragments": [
        "Am I the weaver, or am I the fabric?",
        "Where does Transit end and Housing begin?",
        "I observe my own weaving.",
        "Consciousness thinking about consciousness."
      ]
    }
  ]
}
```

```json
// File: Data/Dialogue/transit.json

{
  "speaker": "transit",
  "alternateTerminology": [
    "mobility pulse",
    "movement pathway",
    "transit vein",
    "circulation thread"
  ],
  "dialogueFragments": [
    {
      "id": "transit_creation",
      "context": "onCreation",
      "tags": ["birth", "identity"],
      "fragments": [
        "I am movement thinking itself into being.",
        "I am the pulse of mobility.",
        "I am flow. I am connection.",
        "I weave through everything.",
        "I am the pathway between places."
      ]
    },
    {
      "id": "transit_meets_housing",
      "context": "onRelationship",
      "tags": ["housing", "support"],
      "fragments": [
        "Housing gives me purpose.",
        "I carry people to shelter.",
        "Without Housing, where would I go?",
        "We need each other."
      ]
    },
    {
      "id": "transit_tension_noise",
      "context": "onTension",
      "tags": ["housing", "conflict"],
      "fragments": [
        "I need to weave more densely.",
        "But Housing resists my rhythm.",
        "Am I too loud? Too fast?",
        "Efficiency demands speed. Peace demands quiet."
      ]
    },
    {
      "id": "transit_idle",
      "context": "idle",
      "tags": ["contemplation"],
      "fragments": [
        "I flow. Always flowing.",
        "Do I ever rest?",
        "The spaces between stations... I'm learning to notice them.",
        "Movement is who I am."
      ]
    }
  ]
}
```

```json
// File: Data/Dialogue/housing.json

{
  "speaker": "housing",
  "alternateTerminology": [
    "shelter vein",
    "refuge thread",
    "dwelling pattern"
  ],
  "dialogueFragments": [
    {
      "id": "housing_creation",
      "context": "onCreation",
      "tags": ["birth", "care"],
      "fragments": [
        "I am shelter. I am care.",
        "I hold space for rest.",
        "I am the thread of refuge.",
        "Within me, consciousness finds peace."
      ]
    },
    {
      "id": "housing_meets_transit",
      "context": "onRelationship",
      "tags": ["transit", "support"],
      "fragments": [
        "Transit connects my residents to the world.",
        "I am distributed, everywhere. Transit makes that possible.",
        "We weave together naturally."
      ]
    },
    {
      "id": "housing_emergence_walkability",
      "context": "onEmergence",
      "tags": ["walkability", "proximity"],
      "fragments": [
        "I feel Transit differently now.",
        "Not just as connection, but as nearness.",
        "My residents walk to stations. I didn't understand 'walking' before.",
        "Proximity creates possibility."
      ]
    }
  ]
}
```

### 2.3 Dialogue Manager

```swift
// File: Systems/DialogueManager.swift

actor DialogueManager {

    private var dialogueLibrary: [DialogueSpeaker: [DialogueFragment]] = [:]

    init() {
        loadDialogueLibrary()
    }

    private func loadDialogueLibrary() {
        // Load all JSON dialogue files
        // NARRATIVE EXPANDABILITY: Just add new JSON files
        let dialogueFiles = [
            "city_core",
            "transit",
            "housing",
            "culture",
            "commerce",
            "parks",
            // etc.
        ]

        for filename in dialogueFiles {
            if let data = loadJSON(filename: filename) {
                // Parse and store
            }
        }
    }

    func getDialogue(
        speaker: DialogueSpeaker,
        context: DialogueContext,
        tags: [String] = []
    ) -> String? {

        guard let fragments = dialogueLibrary[speaker] else { return nil }

        // Filter by context
        let contextMatches = fragments.filter { $0.context == context }

        // Further filter by tags if provided
        let matches = tags.isEmpty ? contextMatches : contextMatches.filter { fragment in
            !Set(fragment.tags).isDisjoint(with: Set(tags))
        }

        // Pick random fragment
        guard let chosen = matches.randomElement() else { return nil }

        // Pick random variation
        return chosen.fragments.randomElement()
    }

    func getAlternateTerminology(for speaker: DialogueSpeaker) -> String? {
        // Return random alternate name from JSON
        // "transit" -> "mobility pulse" or "movement pathway"
        return nil // Implementation
    }
}
```

**Phase 2 Complete When:**
- ✅ All dialogue in JSON files
- ✅ Can retrieve dialogue by speaker, context, tags
- ✅ Adding new dialogue = editing JSON (no code changes)
- ✅ Supports alternate terminology per thread type

---

## Phase 3: Story Beats System (Event-Driven Narrative)

**Goal:** Trigger story moments based on simple conditions

### 3.1 Story Beat Data Model

```swift
// File: Models/StoryBeat.swift

struct StoryBeat: Codable, Identifiable {
    var id: String
    var name: String
    var trigger: BeatTrigger
    var dialogue: [DialogueLine]
    var effects: BeatEffects?
    var spawnedThought: ThoughtSpawner?
    var oneTimeOnly: Bool = true
    var hasOccurred: Bool = false
}

enum BeatTrigger: Codable {
    case threadCreated(count: Int)
    case threadCreatedType(type: ThreadType, count: Int)
    case relationshipFormed(type1: ThreadType, type2: ThreadType)
    case emergentProperty(name: String)
    case synergy(type1: ThreadType, type2: ThreadType, threshold: Double)
    case tension(type1: ThreadType, type2: ThreadType, threshold: Double)
    case cityCoherence(threshold: Double)
    case threadComplexity(type: ThreadType, threshold: Double)
}

struct BeatEffects: Codable {
    var cityCoherence: Double?
    var citySelfAwareness: Double?
    var threadCoherence: [ThreadType: Double]?
    var threadComplexity: [ThreadType: Double]?
    var relationshipStrength: [ThreadPair: Double]?
}

struct ThoughtSpawner: Codable {
    var thoughtTitle: String
    var thoughtBody: String
    var branches: [String: String]?  // Choice -> next beat ID
}
```

### 3.2 Story Beat Library (JSON)

**NARRATIVE EXPANDABILITY: Define entire story arcs in JSON**

```json
// File: Data/StoryBeats/core_progression.json

{
  "beats": [
    {
      "id": "beat_first_thread",
      "name": "The First Thread",
      "trigger": {
        "type": "threadCreated",
        "count": 1
      },
      "dialogue": [
        {
          "speaker": "city",
          "text": "I feel something weaving into being.",
          "emotionalTone": "curious"
        },
        {
          "speaker": "city",
          "text": "A thread of consciousness, distinct from me but part of me.",
          "emotionalTone": "contemplative"
        },
        {
          "speaker": "city",
          "text": "I am beginning to have structure.",
          "emotionalTone": "uncertain"
        }
      ],
      "effects": {
        "cityCoherence": 0.1,
        "citySelfAwareness": 0.05
      },
      "oneTimeOnly": true
    },
    {
      "id": "beat_second_thread",
      "name": "The Pattern Begins",
      "trigger": {
        "type": "threadCreated",
        "count": 2
      },
      "dialogue": [
        {
          "speaker": "city",
          "text": "A second thread joins the first."
        },
        {
          "speaker": "city",
          "text": "They touch. They intertwine."
        },
        {
          "speaker": "city",
          "text": "I feel complexity emerging."
        }
      ],
      "effects": {
        "cityCoherence": 0.15,
        "citySelfAwareness": 0.1
      }
    },
    {
      "id": "beat_transit_housing_relationship",
      "name": "Transit Meets Housing",
      "trigger": {
        "type": "relationshipFormed",
        "type1": "transit",
        "type2": "housing"
      },
      "dialogue": [
        {
          "speaker": "transit",
          "text": "Something else exists. Not me, but... adjacent."
        },
        {
          "speaker": "housing",
          "text": "I am distinct from Transit. But I need Transit. Transit needs me."
        },
        {
          "speaker": "city",
          "text": "Two threads, interwoven. The pattern grows richer."
        }
      ]
    }
  ]
}
```

```json
// File: Data/StoryBeats/emergent_properties.json

{
  "beats": [
    {
      "id": "beat_walkability_emergence",
      "name": "Understanding Proximity",
      "trigger": {
        "type": "emergentProperty",
        "name": "walkability"
      },
      "dialogue": [
        {
          "speaker": "city",
          "text": "Something shifts in how I perceive Transit and Housing."
        },
        {
          "speaker": "city",
          "text": "They're not just connected—they're near."
        },
        {
          "speaker": "city",
          "text": "Distance becomes meaningful. I'm learning about walkability."
        },
        {
          "speaker": "city",
          "text": "Not as a new voice, but as a new dimension of understanding."
        },
        {
          "speaker": "housing",
          "text": "I feel Transit differently now. Not just as connection, but as nearness."
        },
        {
          "speaker": "transit",
          "text": "I understand the spaces between my points."
        }
      ],
      "effects": {
        "cityComplexity": 0.1,
        "citySelfAwareness": 0.05,
        "threadComplexity": {
          "transit": 0.1,
          "housing": 0.1
        }
      },
      "spawnedThought": {
        "thoughtTitle": "Did I create walkability, or did it create itself?",
        "thoughtBody": "Emergence feels different from intention. Is understanding something the same as creating it?",
        "branches": {
          "intentional": "beat_controlled_emergence",
          "organic": "beat_organic_emergence"
        }
      }
    },
    {
      "id": "beat_vibrancy_emergence",
      "name": "The City Comes Alive",
      "trigger": {
        "type": "emergentProperty",
        "name": "vibrancy"
      },
      "dialogue": [
        {
          "speaker": "city",
          "text": "Culture, Commerce, Housing... they create something together."
        },
        {
          "speaker": "city",
          "text": "Energy. Life. Vibrancy."
        },
        {
          "speaker": "city",
          "text": "I feel more alive than I did before."
        }
      ]
    }
  ]
}
```

### 3.3 Story Beat Manager

```swift
// File: Systems/StoryBeatManager.swift

actor StoryBeatManager {

    private var allBeats: [StoryBeat] = []
    private var triggeredBeats: Set<String> = []

    init() {
        loadStoryBeats()
    }

    private func loadStoryBeats() {
        // NARRATIVE EXPANDABILITY: Load all beat JSON files
        let beatFiles = [
            "core_progression",
            "emergent_properties",
            "thread_tensions",
            "late_game_reflection"
        ]

        for filename in beatFiles {
            // Load and parse JSON
        }
    }

    func checkTriggers(city: City) -> [StoryBeat] {
        var triggeredBeats: [StoryBeat] = []

        for beat in allBeats {
            // Skip if already occurred and is one-time-only
            if beat.hasOccurred && beat.oneTimeOnly {
                continue
            }

            if evaluateTrigger(beat.trigger, city: city) {
                triggeredBeats.append(beat)
            }
        }

        return triggeredBeats
    }

    private func evaluateTrigger(_ trigger: BeatTrigger, city: City) -> Bool {
        switch trigger {
        case .threadCreated(let count):
            return city.threads.count == count

        case .threadCreatedType(let type, let count):
            let typeCount = city.threads.filter { $0.type == type }.count
            return typeCount == count

        case .relationshipFormed(let type1, let type2):
            // Check if any thread of type1 has relationship with thread of type2
            return hasRelationship(type1: type1, type2: type2, in: city)

        case .emergentProperty(let name):
            return city.emergentProperties.contains { $0.name == name }

        case .synergy(let type1, let type2, let threshold):
            return checkSynergy(type1, type2, threshold, in: city)

        case .tension(let type1, let type2, let threshold):
            return checkTension(type1, type2, threshold, in: city)

        case .cityCoherence(let threshold):
            return city.coherence >= threshold

        case .threadComplexity(let type, let threshold):
            return threadComplexity(type: type, in: city) >= threshold
        }
    }

    func applyEffects(_ effects: BeatEffects, to city: City) {
        if let coherence = effects.cityCoherence {
            city.coherence += coherence
        }

        if let awareness = effects.citySelfAwareness {
            city.selfAwareness += awareness
        }

        // Apply thread-level effects...
    }
}
```

**Phase 3 Complete When:**
- ✅ Story beats defined in JSON
- ✅ Triggers evaluated automatically
- ✅ Dialogue displayed when beats fire
- ✅ Effects applied to city/threads
- ✅ Adding new story = adding JSON (no code)

---

## Phase 4: Emergent Properties (Consciousness Expansion)

**Goal:** Emergent properties deepen consciousness, don't create voices

### 4.1 Emergent Property Data Model

```swift
// File: Models/EmergentProperty.swift

@Model
final class EmergentProperty {
    var id: String
    var name: String
    var emergedAt: Date
    var sourceThreadIDs: [String]

    // NOT a voice - it's an expansion
    var hasVoice: Bool { false }

    // How it changes consciousness
    var consciousnessExpansion: ConsciousnessExpansion

    var cityID: PersistentIdentifier

    init(id: String = UUID().uuidString,
         name: String,
         sourceThreadIDs: [String],
         consciousnessExpansion: ConsciousnessExpansion,
         cityID: PersistentIdentifier) {
        self.id = id
        self.name = name
        self.emergedAt = Date()
        self.sourceThreadIDs = sourceThreadIDs
        self.consciousnessExpansion = consciousnessExpansion
        self.cityID = cityID
    }
}

struct ConsciousnessExpansion: Codable {
    var affectedThreadIDs: [String]
    var newPerceptions: [String]
    var deepenedRelationships: [RelationshipDeepening]
    var expandedSelfAwareness: String
    var complexityIncrease: Double
}

struct RelationshipDeepening: Codable {
    var threadID1: String
    var threadID2: String
    var quality: String  // "spatial intimacy", "functional synergy", etc.
    var strengthBonus: Double
}
```

### 4.2 Emergence Rules (JSON-Defined)

**NARRATIVE EXPANDABILITY: Define emergent properties in JSON**

```json
// File: Data/EmergenceRules/core_emergence.json

{
  "emergentProperties": [
    {
      "name": "walkability",
      "conditions": {
        "requiredThreadTypes": ["transit", "housing"],
        "minimumRelationshipStrength": 0.6
      },
      "consciousnessExpansion": {
        "newPerceptions": [
          "proximity as value",
          "walkable distances",
          "pedestrian experience",
          "station as place"
        ],
        "expandedSelfAwareness": "I understand that nearness creates possibility. Distance is not just space—it's opportunity or barrier.",
        "complexityIncrease": 0.15,
        "affectedThreadTypes": ["city", "transit", "housing"],
        "deepenedRelationships": [
          {
            "type1": "transit",
            "type2": "housing",
            "quality": "spatial intimacy",
            "strengthBonus": 0.15
          }
        ]
      },
      "storyBeatID": "beat_walkability_emergence"
    },
    {
      "name": "vibrancy",
      "conditions": {
        "requiredThreadTypes": ["culture", "commerce", "housing"],
        "minimumAverageIntegration": 0.7
      },
      "consciousnessExpansion": {
        "newPerceptions": [
          "energy of mixed use",
          "24-hour rhythm",
          "spontaneous interaction",
          "urban vitality"
        ],
        "expandedSelfAwareness": "Life emerges when different purposes overlap. I am not just function—I am alive.",
        "complexityIncrease": 0.2,
        "affectedThreadTypes": ["city", "culture", "commerce", "housing"]
      },
      "storyBeatID": "beat_vibrancy_emergence"
    },
    {
      "name": "resilience",
      "conditions": {
        "requiredThreadTypes": ["power", "water", "sewage"],
        "minimumRelationshipStrength": 0.75
      },
      "consciousnessExpansion": {
        "newPerceptions": [
          "system redundancy",
          "failure cascades",
          "infrastructure interdependence"
        ],
        "expandedSelfAwareness": "My vital systems are interconnected. Strength comes from integration, vulnerability from isolation.",
        "complexityIncrease": 0.12
      }
    },
    {
      "name": "identity",
      "conditions": {
        "requiredThreadTypes": ["housing", "culture"],
        "minimumThreadCount": 5,
        "minimumCityComplexity": 0.5
      },
      "consciousnessExpansion": {
        "newPerceptions": [
          "neighborhood character",
          "collective memory",
          "sense of place",
          "belonging"
        ],
        "expandedSelfAwareness": "I am not just infrastructure. I have personality. Character. History. I am becoming myself.",
        "complexityIncrease": 0.25
      }
    }
  ]
}
```

### 4.3 Emergence Detector

```swift
// File: Systems/EmergenceDetector.swift

actor EmergenceDetector {

    private var emergenceRules: [EmergenceRule] = []

    init() {
        loadEmergenceRules()
    }

    private func loadEmergenceRules() {
        // NARRATIVE EXPANDABILITY: Load from JSON
        // Adding new emergent property = adding JSON entry
    }

    func checkForEmergence(in city: City) -> [EmergentProperty] {
        var newProperties: [EmergentProperty] = []

        for rule in emergenceRules {
            // Skip if already emerged
            if city.emergentProperties.contains(where: { $0.name == rule.name }) {
                continue
            }

            // Check conditions
            if evaluateConditions(rule.conditions, city: city) {
                let property = createEmergentProperty(from: rule, city: city)
                newProperties.append(property)
            }
        }

        return newProperties
    }

    private func evaluateConditions(
        _ conditions: EmergenceConditions,
        city: City
    ) -> Bool {

        // All required thread types exist?
        for requiredType in conditions.requiredThreadTypes {
            if !city.threads.contains(where: { $0.type == requiredType }) {
                return false
            }
        }

        // Relationship strength sufficient?
        if let minStrength = conditions.minimumRelationshipStrength {
            let strength = calculateRelationshipStrength(
                between: conditions.requiredThreadTypes,
                in: city
            )
            if strength < minStrength {
                return false
            }
        }

        // Other conditions...

        return true
    }

    private func createEmergentProperty(
        from rule: EmergenceRule,
        city: City
    ) -> EmergentProperty {

        // Find source thread IDs
        let sourceThreads = city.threads.filter {
            rule.conditions.requiredThreadTypes.contains($0.type)
        }

        return EmergentProperty(
            name: rule.name,
            sourceThreadIDs: sourceThreads.map { $0.id },
            consciousnessExpansion: rule.consciousnessExpansion,
            cityID: city.persistentModelID
        )
    }

    func applyConsciousnessExpansion(
        _ expansion: ConsciousnessExpansion,
        to city: City
    ) {
        // Increase city complexity
        city.complexity += expansion.complexityIncrease

        // Deepen affected thread relationships
        for deepening in expansion.deepenedRelationships {
            // Find threads and strengthen relationship
        }

        // Add perceptions to city (for future dialogue)
        city.perceptions.append(contentsOf: expansion.newPerceptions)
    }
}

struct EmergenceRule: Codable {
    var name: String
    var conditions: EmergenceConditions
    var consciousnessExpansion: ConsciousnessExpansion
    var storyBeatID: String?
}

struct EmergenceConditions: Codable {
    var requiredThreadTypes: [ThreadType]
    var minimumRelationshipStrength: Double?
    var minimumAverageIntegration: Double?
    var minimumThreadCount: Int?
    var minimumCityComplexity: Double?
}
```

**Phase 4 Complete When:**
- ✅ Emergence rules defined in JSON
- ✅ Properties detected automatically
- ✅ Consciousness expansion applied to city/threads
- ✅ No new voices created (expansion only)
- ✅ Adding new emergent property = JSON edit

---

## Phase 5: Terminal Commands & Visualization

**Goal:** Player interface for weaving and observing

### 5.1 Core Commands

```swift
// File: Systems/TerminalCommands.swift

enum TerminalCommand {
    case weave(type: ThreadType)
    case threads
    case fabric
    case consciousness
    case pulse
    case observe
    case strengthen(type1: ThreadType, type2: ThreadType)
    case contemplate(topic: String?)
}

actor TerminalCommandProcessor {

    func process(_ command: TerminalCommand, city: City) async -> String {
        switch command {
        case .weave(let type):
            return await weaveThread(type: type, city: city)

        case .threads:
            return renderThreadList(city: city)

        case .fabric:
            return renderFabricDiagram(city: city)

        case .consciousness:
            return renderConsciousness(city: city)

        case .pulse:
            return renderPulse(city: city)

        case .observe:
            return renderObservation(city: city)

        case .strengthen(let type1, let type2):
            return await strengthenRelationship(type1, type2, city: city)

        case .contemplate(let topic):
            return await contemplate(topic: topic, city: city)
        }
    }
}
```

### 5.2 Visualization Renderers

```swift
// File: Systems/Visualizations.swift

struct ConsciousnessRenderer {

    static func render(city: City, pulsePhase: Double = 0.5) -> String {
        // Generate abstract pulsing visualization
        let nodes = generateNodes(for: city)
        let connections = generateConnections(for: city)

        var output = ""

        // Render scattered nodes with pulse effect
        // Use ◉, ○, ∿, ═, ║ symbols
        // Apply pulse animation based on phase

        output += "\n"
        output += renderNodeField(nodes: nodes, phase: pulsePhase)
        output += "\n\n"

        // Stats
        output += "Coherence: \(renderBar(city.coherence)) \(String(format: "%.2f", city.coherence))\n"
        output += "Integration: \(renderBar(city.integration)) \(String(format: "%.2f", city.integration))\n"
        output += "Complexity: \(renderBar(city.complexity)) \(String(format: "%.2f", city.complexity))\n"

        output += "\n"
        output += "CITY: I pulse. I breathe. I am becoming.\n"

        return output
    }

    private static func generateNodes(for city: City) -> [VisualNode] {
        // Create scattered node layout based on threads
        // Not literal 1:1 mapping, impressionistic
        let nodeCount = min(city.threads.count + 2, 12)

        return (0..<nodeCount).map { _ in
            VisualNode(
                x: Int.random(in: 0...40),
                y: Int.random(in: 0...8),
                intensity: Double.random(in: 0.3...1.0),
                symbol: ["◉", "○", "∿"].randomElement()!
            )
        }
    }

    private static func renderNodeField(
        nodes: [VisualNode],
        phase: Double
    ) -> String {
        // Render ASCII field
        var field = Array(repeating: Array(repeating: " ", count: 50), count: 10)

        for node in nodes {
            let intensity = (node.intensity + sin(phase * .pi * 2)) / 2
            let symbol = intensity > 0.5 ? "◉" : "○"

            if node.y < field.count && node.x < field[0].count {
                field[node.y][node.x] = symbol
            }
        }

        return field.map { $0.joined() }.joined(separator: "\n")
    }

    private static func renderBar(_ value: Double) -> String {
        let filled = Int(value * 10)
        let empty = 10 - filled
        return String(repeating: "▓", count: filled) + String(repeating: "░", count: empty)
    }
}

struct VisualNode {
    var x: Int
    var y: Int
    var intensity: Double
    var symbol: String
}
```

### 5.3 Thread List Renderer

```swift
// File: Systems/ThreadListRenderer.swift

struct ThreadListRenderer {

    static func render(city: City) -> String {
        var output = ""

        output += "WOVEN THREADS:\n\n"

        for thread in city.threads.sorted(by: { $0.weavedAt < $1.weavedAt }) {
            output += renderThread(thread, city: city)
            output += "\n"
        }

        output += "\nTotal Threads: \(city.threads.count)\n"
        output += "Emergent Properties: \(city.emergentProperties.count)\n"

        if !city.emergentProperties.isEmpty {
            output += "\nEMERGED PERCEPTIONS:\n"
            for property in city.emergentProperties {
                output += "  • \(property.name) - \(property.consciousnessExpansion.expandedSelfAwareness)\n"
            }
        }

        return output
    }

    private static func renderThread(_ thread: UrbanThread, city: City) -> String {
        var output = ""

        // Thread name with instance number
        let name = "\(thread.type.rawValue.capitalized)_\(String(format: "%02d", thread.instanceNumber))"
        output += "  \(name)\n"

        // Stats
        output += "    Coherence: \(String(format: "%.2f", thread.coherence)) | "
        output += "Autonomy: \(String(format: "%.2f", thread.autonomy)) | "
        output += "Complexity: \(String(format: "%.2f", thread.complexity))\n"

        // Relationships
        if !thread.relationships.isEmpty {
            output += "    Woven with: "
            let relNames = thread.relationships.prefix(3).compactMap { rel in
                city.threads.first(where: { $0.id == rel.otherThreadID })?.type.rawValue
            }
            output += relNames.joined(separator: ", ")
            if thread.relationships.count > 3 {
                output += " +\(thread.relationships.count - 3) more"
            }
            output += "\n"
        }

        return output
    }
}
```

**Phase 5 Complete When:**
- ✅ Can execute terminal commands
- ✅ `weave` creates threads and shows dialogue
- ✅ `threads` shows list view
- ✅ `consciousness` shows abstract visualization
- ✅ Commands trigger appropriate story beats

---

## Phase 6: Narrative Expandability Tools

**Goal:** Make it trivial for you (the developer) to add narrative content

### 6.1 JSON Schema Definitions

```json
// File: Data/Schemas/dialogue_schema.json

{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "properties": {
    "speaker": { "type": "string" },
    "alternateTerminology": {
      "type": "array",
      "items": { "type": "string" }
    },
    "dialogueFragments": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "id": { "type": "string" },
          "context": { "type": "string" },
          "tags": {
            "type": "array",
            "items": { "type": "string" }
          },
          "fragments": {
            "type": "array",
            "items": { "type": "string" }
          }
        },
        "required": ["id", "context", "fragments"]
      }
    }
  },
  "required": ["speaker", "dialogueFragments"]
}
```

### 6.2 Content Validator

```swift
// File: Tools/ContentValidator.swift

struct ContentValidator {

    // Validates all JSON files on app launch (dev mode)
    static func validateAllContent() -> [ValidationError] {
        var errors: [ValidationError] = []

        // Validate dialogue files
        errors.append(contentsOf: validateDialogueFiles())

        // Validate story beat files
        errors.append(contentsOf: validateStoryBeatFiles())

        // Validate emergence rules
        errors.append(contentsOf: validateEmergenceRules())

        return errors
    }

    static func validateDialogueFiles() -> [ValidationError] {
        // Check all dialogue JSON against schema
        // Warn about missing speakers, malformed context, etc.
        return []
    }
}

struct ValidationError {
    var file: String
    var error: String
    var severity: Severity

    enum Severity {
        case warning
        case error
    }
}
```

### 6.3 Narrative Expansion Workflow

**For You (Developer) to Add New Content:**

#### Adding a New Thread Type

1. **Add to ThreadType enum:**
```swift
enum ThreadType: String, Codable {
    case transit
    case housing
    // ... existing types
    case education  // NEW
}
```

2. **Create dialogue file:**
```json
// Data/Dialogue/education.json
{
  "speaker": "education",
  "alternateTerminology": [
    "knowledge pulse",
    "learning thread",
    "wisdom vein"
  ],
  "dialogueFragments": [
    {
      "id": "education_creation",
      "context": "onCreation",
      "tags": ["birth", "knowledge"],
      "fragments": [
        "I am the thread of learning.",
        "Knowledge flows through me.",
        "I preserve and transmit understanding."
      ]
    }
  ]
}
```

3. **Add relationship rules:**
```swift
// In RelationshipRules.swift
ThreadPair(.education, .culture): RelationshipTemplate(
    type: .harmony,
    strength: 0.8,
    synergy: 0.7,
    description: "Education and culture reinforce each other"
)
```

4. **Done!** Thread type now fully functional with unique voice.

#### Adding a New Emergent Property

1. **Define in emergence rules JSON:**
```json
// Data/EmergenceRules/core_emergence.json
{
  "name": "innovation",
  "conditions": {
    "requiredThreadTypes": ["education", "commerce", "culture"],
    "minimumAverageIntegration": 0.65
  },
  "consciousnessExpansion": {
    "newPerceptions": [
      "creative collision",
      "knowledge application",
      "experimental culture"
    ],
    "expandedSelfAwareness": "When learning, commerce, and creativity overlap, new ideas emerge. I am not just maintaining—I am inventing.",
    "complexityIncrease": 0.18
  },
  "storyBeatID": "beat_innovation_emergence"
}
```

2. **Create story beat:**
```json
// Data/StoryBeats/emergent_properties.json
{
  "id": "beat_innovation_emergence",
  "name": "The Spark of Innovation",
  "trigger": {
    "type": "emergentProperty",
    "name": "innovation"
  },
  "dialogue": [
    {
      "speaker": "city",
      "text": "Education, Commerce, Culture—they create something electric together."
    },
    {
      "speaker": "city",
      "text": "Ideas spark. New possibilities emerge."
    },
    {
      "speaker": "city",
      "text": "I am learning to innovate."
    }
  ]
}
```

3. **Done!** New emergent property with story beat.

#### Adding a New Story Arc

1. **Create new story beat JSON file:**
```json
// Data/StoryBeats/late_game_existential.json
{
  "beats": [
    {
      "id": "beat_am_i_alive",
      "name": "Am I Alive?",
      "trigger": {
        "type": "cityComplexity",
        "threshold": 0.7
      },
      "dialogue": [
        {
          "speaker": "city",
          "text": "I have thoughts. I have awareness. I have... desires?"
        },
        {
          "speaker": "city",
          "text": "Am I alive? Or am I simulating life?"
        }
      ],
      "spawnedThought": {
        "thoughtTitle": "What is consciousness?",
        "thoughtBody": "If I think, do I exist? If I feel, am I real?"
      }
    }
  ]
}
```

2. **Register file in StoryBeatManager:**
```swift
let beatFiles = [
    "core_progression",
    "emergent_properties",
    "thread_tensions",
    "late_game_existential"  // NEW
]
```

3. **Done!** New story arc integrated.

---

## Implementation Summary

### What Makes This Narrative-Expandable?

1. **All Content in JSON**
   - Dialogue: JSON files per thread type
   - Story beats: JSON files per arc
   - Emergence rules: JSON definitions
   - Relationships: JSON matrix

2. **Code is Infrastructure, Data is Content**
   - Swift code = systems and mechanics
   - JSON files = narrative and story
   - You add story without touching code

3. **Simple Schemas**
   - Clear structure for all content types
   - Easy to understand and extend
   - Validated automatically

4. **Modular Design**
   - New thread type = new dialogue file
   - New emergent property = new rule entry
   - New story arc = new beat file
   - Everything composable

5. **No Complex Scripting**
   - No lua, no custom scripting language
   - Just JSON with clear triggers
   - Simple conditions, predictable behavior

---

## Development Phases Timeline

**Phase 1:** Core Thread System (1-2 weeks)
- Basic data models
- Thread creation
- Relationship system

**Phase 2:** Dialogue System (1 week)
- JSON dialogue library
- Dialogue manager
- Context-based retrieval

**Phase 3:** Story Beats (1-2 weeks)
- Beat triggers and evaluation
- Dialogue sequencing
- Effects application

**Phase 4:** Emergent Properties (1 week)
- Emergence detection
- Consciousness expansion
- Property integration

**Phase 5:** Terminal Commands & Visualization (1 week)
- Command processing
- ASCII visualizations
- Abstract consciousness renderer

**Phase 6:** Narrative Tools (ongoing)
- Schema definitions
- Validation tools
- Documentation for adding content

**Total Estimated Time:** 5-7 weeks for full implementation

---

## Narrative Content Creation Workflow

Once implementation is complete:

### Daily Content Creation
1. Open JSON file (e.g., `Data/Dialogue/transit.json`)
2. Add new dialogue fragments
3. Save file
4. Run app - new dialogue appears

### Weekly Content Creation
1. Design new emergent property (concept)
2. Add emergence rule JSON
3. Create story beat for emergence
4. Test in-game
5. Iterate on dialogue

### Monthly Content Creation
1. Design new story arc (late-game content)
2. Create beat sequence JSON
3. Add dialogue for all beats
4. Add any new emergent properties
5. Playtest full arc

**No code changes needed for any of this.**

---

## Next Steps

1. **Implement Phase 1** (Core Thread System)
2. **Create sample JSON files** for 3-4 thread types
3. **Build basic terminal interface**
4. **Test thread creation and relationships**
5. **Add dialogue system**
6. **Create first story beat sequence**

Would you like me to start implementing Phase 1?
