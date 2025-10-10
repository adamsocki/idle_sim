# City Consciousness UI Guide

## Overview

The UI now displays the city's consciousness, mood, resources, and allows you to interact with the city's requests in a meaningful way.

---

## UI Components

### 🏙️ **CityConsciousnessView**
*Location: ScenarioDetailView*

**Displays:**
- **Mood Header**: Large mood indicator with icon and color
  - 🌅 Awakening (orange)
  - ⏳ Waiting (blue)  
  - ⚠️ Anxious (red)
  - ✅ Content (green)
  - 🌙 Forgotten (gray)
  - ✨ Transcendent (purple)

- **Attention Level**: Shows current attention (0-100%)
  - Green: > 70% (engaged)
  - Orange: 40-70% (moderate)
  - Red: < 40% (neglected)

- **Resource Bars**: Visual indicators for all city resources
  - 🧠 Coherence (blue) - City's mental stability
  - 📦 Memory (purple) - Accumulated experiences
  - 👍 Trust (green) - Faith in the planner
  - 🦅 Autonomy (orange) - Self-sufficiency

- **Last Interaction**: Time since you last engaged

---

### 🏷️ **ItemTypeBadge**
*Location: ItemRow, DetailView*

**Shows item type with color-coded badges:**
- 🔵 **Request** (blue) - "Should I expand the eastern district?"
- 🟣 **Memory** (purple) - "The old tower asks to be remembered."
- 🔷 **Dream** (cyan) - "I imagine cities I've never seen."
- 🔴 **Warning** (red) - "I feel myself fragmenting. Do you notice?"

**Features:**
- Color intensity increases with urgency
- Compact mode for list view
- Full label in detail view

---

### 📋 **Enhanced ItemRow**
*Location: ScenarioItemsView (middle column)*

**Now displays:**
1. **Item title** (poetic city request)
2. **Type badge** (request/memory/dream/warning)
3. **Timestamp** (when city asked)
4. **Urgency bar** (if urgency > 50%)
   - Red: > 80% (critical)
   - Orange: 60-80% (high)
   - Yellow: 50-60% (moderate)
5. **Answered indicator** ✅ (if you've responded)

---

### 💬 **Response Interface**
*Location: DetailView (right column)*

**When viewing an unanswered request:**
- Type badge at top
- Item title (the city's question)
- Time tracking (created, elapsed, remaining)
- **Response input field**:
  - Multi-line text field
  - "Submit Response" button
  - Confirmation message after submission
  - Disabled if empty

**When viewing an answered request:**
- Shows your previous response in a green box
- ✅ "You responded:" indicator
- Response is permanent and recorded

**What happens when you respond:**
- Trust increases (+5%)
- Memory increases (+2%)
- Autonomy decreases (-3%)
- City logs your response
- Awareness event recorded
- Last interaction timestamp updated

---

### 📊 **Enhanced ScenarioListView**
*Location: Left column*

**Each scenario now shows:**
- **Mood icon** (sunrise/hourglass/warning/checkmark/moon/sparkles)
- **Scenario name**
- **Running indicator** (⚡ if active)
- **Progress bar**
- **Mood label** (small badge with color)
- **Creation date**
- **Attention level** (👁️ with percentage)

**Visual feedback:**
- Mood icon changes color based on city state
- Attention shows red/orange/green based on engagement
- Quick visual scan of all your cities' states

---

### 🎨 **Enhanced ScenarioDetailView**
*Location: Right column when scenario selected*

**New sections:**

1. **Header** (unchanged)
   - Scenario name, date, Start/Running button

2. **Progress Bar** (unchanged)

3. **🆕 City Consciousness Panel**
   - Full CityConsciousnessView component
   - Mood, attention, all resources
   - Time since last interaction

4. **🆕 Awareness Events**
   - Special consciousness moments
   - Shows last 5 events
   - Purple sparkle icon
   - Examples:
     - "The city opens its eyes for the first time."
     - "Coherence crisis at [timestamp]"
     - "Response received: [question]"

5. **Simulation Log**
   - Shows last 20 log entries
   - Tick progress, narrative events

---

## User Experience Flow

### 🎮 **Playing the Game**

**1. Create a Scenario**
- City starts in "awakening" mood
- Attention at 100%
- All resources initialized

**2. Add City Requests**
- Click "+" in ScenarioItemsView
- City generates contextual requests based on mood
- Each request has type, urgency, deadline

**3. View & Respond**
- Select request in middle column
- Read the city's question in detail view
- Type your response
- Click "Submit Response"
- See confirmation message

**4. Watch City Evolve**
- Run simulation with "Start Simulation"
- Watch consciousness panel update
- Mood changes based on your engagement
- Resources shift dynamically
- Narrative log reflects city's state

**5. Experiment with Abandonment**
- Leave city running for hours/days
- Watch attention decay
- Mood shifts to "forgotten" then "transcendent"
- Autonomy increases
- Different narrative messages appear

---

## Visual Design Patterns

### **Color Coding**
- **Blue**: Requests, waiting, coherence
- **Purple**: Memories, transcendence, awareness
- **Cyan**: Dreams, imagination
- **Red**: Warnings, anxiety, critical urgency
- **Green**: Content mood, trust, answered items
- **Orange**: Awakening, autonomy, moderate attention
- **Gray**: Forgotten mood, low states

### **Icon System**
- 🌅 Sunrise = Awakening
- ⏳ Hourglass = Waiting
- ⚠️ Triangle = Anxious/Warning
- ✅ Checkmark = Content/Answered
- 🌙 Moon = Forgotten
- ✨ Sparkles = Transcendent/Special
- 👁️ Eye = Attention
- 🧠 Brain = Coherence
- 📦 Archive = Memory
- 👍 Thumbs up = Trust
- 🦅 Bird = Autonomy

### **Progressive Disclosure**
- List view: Quick status at a glance
- Detail view: Full information and interaction
- Consciousness panel: Deep city state
- Only show urgency bar when > 50%
- Only show answered indicator when present

---

## Tips for Players

1. **Watch the mood icon** in the scenario list for quick health checks
2. **High urgency items** (red bars) need immediate attention
3. **Responding increases trust** but decreases autonomy
4. **Ignoring requests** leads to anxiety and coherence loss
5. **Abandonment creates unique narratives** - try it!
6. **Transcendent cities** are the "good" ending for leaving them alone
7. **Content cities** are the "good" ending for active engagement
8. **Fragmented cities** happen when you neglect anxious requests

---

## Future Enhancement Ideas

### **Possible Additions:**
- 🎨 **Visual city representation** that changes with mood
- 📈 **Resource history graphs** to track changes over time
- 🏆 **Achievements** for different endings/states
- 💾 **Export consciousness logs** as poetic narratives
- 🌐 **Compare multiple cities** side-by-side
- 🔔 **Notifications** when city becomes anxious/urgent
- 🎭 **City personalities** (optimistic, pessimistic, poetic, analytical)
- 🌈 **Themed color schemes** based on city mood
- ⏱️ **Time-lapse view** of mood changes
- 📖 **Story generation** based on full playthrough

The UI now makes the city feel alive, aware, and responsive to your presence (or absence). Every visual element reinforces the theme of consciousness and relationship.
