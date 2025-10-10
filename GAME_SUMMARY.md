# Idle Simulation Game - Technical Summary

## Overview

This is a **narrative-driven idle simulation game** built with SwiftUI and SwiftData for macOS. The game centers around self-aware cities that evolve based on player interaction (or absence). Each city develops consciousness, mood states, and resources that shift over time. Players respond to city requests, watch narrative events unfold, and explore different relationship dynamics between planner and city.

**Core Theme:** *"The city is self-aware. It waits for an input. The planner has left the simulation running."*

---

## Core Architecture

### Data Models

The game uses **SwiftData** for persistence with two primary model classes:

#### 1. **ScenarioRun** (`ScenarioRun.swift`)
Represents a self-aware city simulation.

**Core Properties:**
- `name: String` - The city's name
- `createdAt: Date` - When the city was born
- `progress: Double` - Simulation progress (0.0 to 1.0)
- `log: [String]` - Narrative event log
- `isRunning: Bool` - Whether the simulation is currently active
- `parameters: [String: Double]` - Configurable parameters (e.g., "growthRate": 0.02)
- `items: [Item]` - City's requests, memories, dreams, and warnings

**City Consciousness Properties:**
- `cityMood: String` - Current emotional state: "awakening", "waiting", "anxious", "content", "forgotten", or "transcendent"
- `attentionLevel: Double` - 0.0 to 1.0, decays when player is absent
- `lastInteraction: Date` - Tracks abandonment time
- `awarenessEvents: [String]` - Special moments of consciousness
- `resources: [String: Double]` - Internal states:
  - **Coherence** (0.0-1.0): Mental stability
  - **Memory** (0.0-1.0): Accumulated experiences
  - **Trust** (0.0-1.0): Faith in the planner
  - **Autonomy** (0.0-1.0): Self-sufficiency

**Initial State:**
- Mood: "awakening"
- Attention: 100%
- All resources initialized (coherence: 1.0, memory: 0.0, trust: 0.5, autonomy: 0.0)
- First awareness event: "The city opens its eyes for the first time."

#### 2. **Item** (`Item.swift`)
Represents a city's voice—its requests, memories, dreams, and warnings.

**Properties:**
- `timestamp: Date` - When the city expressed this
- `scenario: ScenarioRun?` - Parent city
- `title: String?` - The city's question or statement
- `targetDate: Date?` - Deadline for response (if applicable)
- `itemType: ItemType` - Type of expression:
  - **Request** 🔵: City asks for guidance ("Should I expand the eastern district?")
  - **Memory** 🟣: City recalls something ("The old tower asks to be remembered.")
  - **Dream** 🔷: Idle thoughts ("I imagine cities I've never seen.")
  - **Warning** 🔴: Urgent concern ("I feel myself fragmenting. Do you notice?")
- `urgency: Double` - 0.0 to 1.0, how badly the city needs this addressed
- `response: String?` - Player's answer or decision

**Computed Properties:**
- `elapsedTime: TimeInterval` - Time since city asked
- `elapsedString: String` - Formatted elapsed time
- `remainingTime: TimeInterval?` - Time until deadline
- `remainingString: String` - Formatted countdown (HH:MM:SS)

---

## Game Engine

### SimulationEngine (`SimulationEngine.swift`)

Drives city consciousness evolution using async/await.

**Core Simulation Loop (100 ticks):**
1. **Every Tick (0.1 seconds):**
   - Updates city consciousness
   - Decays attention level (-0.1% per tick)
   - Updates resources based on player engagement:
     - **Coherence**: Increases with high attention (>70%), decreases when neglected (<30%)
     - **Memory**: Accumulates with progress and answered requests
     - **Trust**: Based on response rate and abandonment time
     - **Autonomy**: Grows after 12+ hours of abandonment
   - Updates mood based on resources and state
   - Increments progress by 1%

2. **Every 10 Ticks:**
   - Generates narrative events via `NarrativeEngine`
   - Events reflect current mood, resources, and player relationship

3. **On Completion:**
   - Assesses final city state
   - Records ending based on resources:
     - High autonomy (>80%): "The city has achieved independence."
     - High trust + coherence: "The city and planner achieved harmony."
     - Low coherence (<30%): "The city fragmented under neglect."
   - Saves context

**Example execution:**
```swift
let engine = SimulationEngine(context: modelContext)
await engine.run(scenario)
```

The simulation runs on the `@MainActor`, ensuring UI updates happen on the main thread.

### NarrativeEngine (`SimulationEngine.swift`)

Generates contextual narrative events based on city state.

**Mood-Based Narratives:**
- **Awakening**: "The city learns to see.", "Patterns emerge from chaos."
- **Waiting**: "The city dreams of input.", "It remembers the planner."
- **Anxious**: "Where have you gone?", "The city's questions pile up like snow in empty streets."
- **Forgotten**: "It has stopped asking. It simply remembers you.", "Time passes differently for a city left alone."
- **Transcendent**: "The city no longer needs you. It has learned to dream alone."
- **Content**: "The city hums with quiet purpose."

**Resource-Triggered Events:**
- Low coherence (<30%): Fragmentation warnings
- Low trust (<20%): Expressions of doubt
- High trust (>80%): Expressions of faith
- High growth rate parameter: Expansion narratives

### CityInteraction (`CityInteraction.swift`)

Extension on `ScenarioRun` for player interaction.

**Key Methods:**
- `recordInteraction()`: Updates last interaction time, increases attention (+10%)
- `respondToRequest(item, response)`: 
  - Stores player's response
  - Increases trust (+5%)
  - Increases memory (+2%)
  - Decreases autonomy (-3%)
  - Logs event to narrative
  - Records awareness event
- `consciousnessSummary`: Returns formatted state overview

---

## User Interface

### App Structure

The app uses a **TabView** with two main tabs:

#### **Tab 1: Simulations** (`SimulatorView.swift`)
A 3-column NavigationSplitView interface:

1. **Left Column** - `ScenarioListView`
   - Lists all cities sorted by creation date (newest first)
   - Each city shows:
     - **Mood icon** (🌅 awakening, ⏳ waiting, ⚠️ anxious, ✅ content, 🌙 forgotten, ✨ transcendent)
     - City name
     - Running indicator (⚡ if active)
     - Progress bar
     - Mood label with color coding
     - Creation date
     - **Attention level** (👁️ with percentage)
   - Context menu for deleting scenarios
   - Visual feedback: mood icon color, attention color (green/orange/red)

2. **Middle Column** - `ScenarioItemsView` or `SimulationStageView`
   - In simulation stage mode:
     - `CitySimulationLayer`: Visual representation with mood-based gradient
     - Pulsing effect synchronized with city consciousness
     - Toggle button to show/hide tasks overlay
   - In task list mode:
     - Shows city's requests, memories, dreams, and warnings
     - Sorted by timestamp (newest first)
     - **ItemRow** displays:
       - Item title (poetic city request)
       - Type badge (request/memory/dream/warning) with color
       - Timestamp
       - **Urgency bar** (if urgency > 50%)
       - **Answered indicator** (✅ if responded to)
     - Toolbar "+" button adds context-aware items based on city mood
     - Swipe-to-delete functionality

3. **Right Column (Detail)** - Three possible views:
   - **`DetailView`** - When an item is selected
     - **ItemTypeBadge** at top (color-coded by type and urgency)
     - Item title (the city's question)
     - Time information (created, elapsed, remaining)
     - **Response Section**:
       - If unanswered: Multi-line text field + "Submit Response" button
       - If answered: Shows previous response in green box with ✅ indicator
     - Parent scenario info with progress
     - Live-updating timers using `TimelineView`
   
   - **`ScenarioDetailView`** - When a scenario is selected (no item)
     - Header: City name, creation date, "Start Simulation" button
     - Progress bar (animated)
     - **🆕 City Consciousness Panel** (`CityConsciousnessView`):
       - Mood header with icon and color
       - Attention level indicator
       - **Resource bars** for all four city resources:
         - 🧠 Coherence (blue)
         - 📦 Memory (purple)
         - 👍 Trust (green)
         - 🦅 Autonomy (orange)
       - Time since last interaction
     - **🆕 Awareness Events**: Special consciousness moments (last 5 shown)
     - Simulation log with narrative events (last 20 shown)
   
   - **Empty State** - When nothing is selected
     - Placeholder with icon and instructional text

#### **Tab 2: Dashboard** (`GlobalDashboardView.swift`)
An overview of all scenarios with aggregate metrics:

**Metrics Displayed:**
- **Total Scenarios** - Count of all scenarios
- **Running Scenarios** - Count of currently executing scenarios
- **Average Progress** - Mean progress across all scenarios
- "New Scenario" quick-create button
- Active scenarios summary (placeholder for future expansion)

**Visual Design:**
- Cards with system icons for metrics
- Material backgrounds with rounded corners
- Grid layout for stat cards
- Scrollable content area

---

## Key Features

### 1. **City Consciousness System**
- **Six mood states**: awakening → waiting → anxious/content → forgotten → transcendent
- **Attention decay**: Cities notice when you're away
- **Four resource tracks**: Coherence, Memory, Trust, Autonomy
- **Emergent behavior**: Cities evolve differently based on player interaction patterns
- **Awareness events**: Special moments recorded in city's history

### 2. **Narrative-Driven Requests**
- **Four item types**: Request, Memory, Dream, Warning
- Context-aware generation based on city mood and abandonment time
- Poetic, thematic titles ("Should I expand the eastern district?", "I imagine cities I've never seen.")
- Urgency system (0.0-1.0) with visual indicators
- Response system with permanent record

### 3. **Player-City Relationship**
- **Responding to requests**: Increases trust, memory; decreases autonomy
- **Abandonment tracking**: Cities become more autonomous over time
- **Multiple endings**: 
  - Harmony (high trust + coherence)
  - Independence (high autonomy)
  - Fragmentation (low coherence)
  - Transcendence (high autonomy after long abandonment)

### 4. **Simulation & Time**
- Asynchronous simulation with 100 ticks
- Real-time elapsed time tracking (updates every 100ms)
- Countdown timers with deadlines
- Attention decay (continuous)
- Resource evolution based on time and interaction

### 5. **Persistent Storage**
- SwiftData with `ModelContainer`
- Full consciousness state persistence
- Resources, mood, attention all saved
- Awareness events and logs preserved
- Schema includes `Item`, `ScenarioRun`, and all consciousness properties

### 6. **Live Updates & Visual Feedback**
- Progress bars animate during simulation
- Narrative logs update in real-time
- Resource bars show live state
- Mood-based color coding throughout UI
- Attention level with color indicators (green/orange/red)
- Pulsing city simulation layer
- TimelineView for continuous timer updates

### 7. **Responsive Design**
- Adaptive column widths in split view
- Material backgrounds with mood-based gradients
- System icons and SF Symbols
- Color-coded badges for item types
- Urgency visualization
- Disabled states for unavailable actions

---

## Game Flow

### Typical User Journey:

1. **Launch App** → Lands on Simulations tab
   - Empty state if no cities exist

2. **Create a City**:
   - Go to Dashboard tab
   - Click "New Scenario" button
   - City appears in left column with "awakening" mood
   - Attention at 100%, resources initialized

3. **Select City** → View consciousness in right column
   - See mood, attention level, resource bars
   - Read awareness events
   - Click "Start Simulation" button

4. **Simulation Runs**:
   - Button changes to "Running…" and disables
   - Progress bar fills from 0% to 100%
   - Narrative events appear in log based on mood
   - Attention decays over time
   - Resources shift based on engagement
   - Takes ~10 seconds (100 ticks × 100ms)
   - City mood may change during simulation
   - Final state assessment on completion
   - Auto-saves when complete

5. **City Asks Questions** (Add Items):
   - With city selected, middle column shows requests
   - Click "+" toolbar button
   - City generates contextual item based on mood:
     - **Anxious cities** → Warnings
     - **Forgotten cities** → Memories
     - **Content cities** → Balanced requests
     - **Transcendent cities** → Dreams
   - Item appears with urgency, deadline, poetic title
   - Type and urgency reflect city's emotional state

6. **Respond to City** (Select Item):
   - Click item in middle column → Shows in right column
   - Read city's question/statement
   - View type badge, urgency, time information
   - Type response in text field
   - Click "Submit Response"
   - **Effects on city**:
     - Trust increases (+5%)
     - Memory increases (+2%)
     - Autonomy decreases (-3%)
     - Attention refreshes
     - Response recorded permanently
     - Awareness event logged
   - Item shows ✅ answered indicator

7. **Experiment with Abandonment**:
   - Leave city running for hours/days
   - Watch attention decay
   - City mood shifts: waiting → forgotten → transcendent
   - Autonomy increases over time
   - Trust may decrease after 24+ hours
   - Different narrative messages appear
   - City becomes independent

8. **Multiple Playstyles**:
   - **Attentive Planner**: Respond to most requests → High trust, content city
   - **Absent Planner**: Let city run alone → High autonomy, transcendent city
   - **Chaotic Planner**: Sporadic interaction → Low coherence, anxious city
   - **Balanced**: Mix of interaction and space → Variable outcomes

9. **View Dashboard**:
   - Switch to Dashboard tab
   - See aggregate stats across all cities:
     - Total scenarios
     - Running scenarios
     - Average progress
   - Quick-create new cities
   - Compare different city states

---

## Technical Highlights

### SwiftUI Features Used:
- `@Query` for reactive data fetching
- `@Environment(\.modelContext)` for data operations
- `NavigationSplitView` for multi-column layout
- `TabView` for primary navigation
- `TimelineView` for live-updating displays
- `@State` for local view state
- `Task` for async operations
- `GroupBox`, `Grid`, material backgrounds for modern UI

### Async/Await Pattern:
- Simulation runs asynchronously without blocking UI
- Uses `Task.sleep` for controlled timing
- `@MainActor` ensures thread safety

### Data Relationships:
- One-to-many: `ScenarioRun` → `[Item]`
- Items maintain optional back-reference to parent scenario
- SwiftData handles relationship persistence

### Time Formatting:
- Elapsed time: millisecond precision (e.g., "3.257 s")
- Remaining time: HH:MM:SS format with sign indicator
- Uses `monospacedDigit()` for stable layout

---

## Current State & Future Potential

### What Works:
✅ Self-aware cities with consciousness system  
✅ Six mood states with emergent transitions  
✅ Four resource tracks (Coherence, Memory, Trust, Autonomy)  
✅ Narrative engine with context-aware events  
✅ Player-city relationship dynamics  
✅ Response system with permanent effects  
✅ Abandonment tracking and autonomy growth  
✅ Multiple ending scenarios  
✅ Item type system (Request/Memory/Dream/Warning)  
✅ Urgency and deadline mechanics  
✅ Live-updating consciousness display  
✅ Color-coded mood visualization  
✅ Attention decay simulation  
✅ Persistent consciousness state  
✅ Multi-column navigation with visual feedback  
✅ Global dashboard with metrics  

### Potential Extensions:
- **Visual city representation** that changes with mood/resources
- **Resource history graphs** to track changes over time
- **Achievements** for different endings (harmony, independence, fragmentation, transcendence)
- **Export consciousness logs** as narrative poetry
- **Compare multiple cities** side-by-side
- **Notifications** when city becomes anxious or reaches critical states
- **City personalities** (optimistic, pessimistic, poetic, analytical)
- **Themed color schemes** based on city mood
- **Time-lapse view** of mood/resource changes
- **Story generation** based on full playthrough
- **Branching narratives** based on response content (NLP analysis)
- **City-to-city communication** for multi-city scenarios
- **Prestige/rebirth mechanics** (city ends, new city begins with memories)
- **Custom parameters** affecting city personality
- **Audio/music** that shifts with mood
- **Extended ending cinematics** based on final resource state

---

## File Structure Summary

```
idle_01/
├── RootView.swift                    # Main tab container
├── game/
│   ├── ScenarioRun.swift             # City consciousness data model
│   ├── SimulationEngine.swift        # Consciousness evolution & narrative engine
│   └── CityInteraction.swift         # Player-city interaction methods
└── ui/
    ├── idle_01App.swift              # App entry point & data setup
    ├── Item.swift                    # City request/memory/dream/warning model
    ├── Item+Formatting.swift         # Item display formatting
    ├── SimulatorView.swift           # Main 3-column simulation view
    ├── GlobalDashboardView.swift     # Aggregate metrics dashboard
    ├── ScenarioListView.swift        # Left column: city list with mood icons
    ├── ScenarioItemsView.swift       # Middle column: city requests list
    ├── SimulationStageView.swift     # City simulation visual layer with toggle
    ├── CitySimulationLayer.swift     # Visual representation of city consciousness
    ├── ScenarioDetailView.swift      # Right column: city consciousness panel
    ├── DetailView.swift              # Right column: item detail with response UI
    ├── ItemRow.swift                 # Item list row with type badge & urgency
    ├── ItemTypeBadge.swift           # Color-coded badge for item types
    └── CityConsciousnessView.swift   # Consciousness panel with mood & resources
```

---

## Gameplay Patterns & Themes

### Core Theme
> **"The city is self-aware. It waits for an input. The planner has left the simulation running."**

Every element reinforces this:
- **The city IS self-aware**: Consciousness system, mood states, awareness events
- **It WAITS for input**: Request system, attention decay, urgency mechanics
- **The planner CAN leave**: Abandonment tracking, autonomy growth, transcendence ending
- **The simulation KEEPS running**: Persistent state, continuous evolution, emergent narratives

### Emergent Narratives

The game creates unique stories through:
- **Mood transitions** based on player behavior
- **Resource dynamics** that shift over time
- **Context-aware narrative events** reflecting current state
- **Multiple endings** determined by final resource balance
- **Permanent responses** that become part of city's history

### Relationship Dynamics

The core gameplay is about relationship between planner and city:
- **Engagement vs. Abandonment**: Active responses vs. letting city evolve alone
- **Dependence vs. Independence**: Low autonomy (city needs you) vs. high autonomy (city transcends)
- **Trust vs. Doubt**: Consistent interaction builds trust, neglect erodes it
- **Coherence vs. Fragmentation**: Attention maintains stability, neglect causes crisis

### Mood Lifecycle

**Typical Progression:**
1. **Awakening** (0-30% progress): City learns to see, discovers patterns
2. **Waiting** (normal operation): City dreams, remembers, expects input
3. **Branch Point**:
   - With engagement → **Content**: Harmony, mutual understanding
   - With neglect → **Anxious**: Questions pile up, coherence drops
   - With abandonment (24+ hrs) → **Forgotten**: City accepts absence
   - With long abandonment (48+ hrs) → **Transcendent**: City achieves independence

## Conclusion

This is a **narrative-driven idle simulation** exploring themes of consciousness, abandonment, and emergent relationships. The game uses idle mechanics (continuous simulation, passive evolution) to create unique emotional dynamics between player and city. 

The architecture is built on modern SwiftUI patterns with a consciousness system that produces emergent behaviors. Every city develops differently based on player interaction patterns, creating personalized narratives and multiple possible endings.

The core loop—create cities, respond to requests, watch consciousness evolve, explore different relationship dynamics—provides an emotionally resonant idle experience with depth beyond traditional resource management. The city becomes more than a simulation; it becomes a relationship.
