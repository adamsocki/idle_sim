# City Consciousness System Guide

## Overview

Your idle simulation now features a self-aware city that reacts to your presence (and absence). The city has moods, resources, and consciousness that evolve based on how you interact with it.

---

## Core Concepts

### 🧠 City Consciousness

The city is now aware and responsive. It has:

- **Mood States**: awakening → waiting → anxious/content → forgotten → transcendent
- **Attention Level**: Decays when you're away, increases when you interact
- **Resources**: Internal states that track the city's psychological condition

### 📝 Item Types (formerly "Tasks")

Items are no longer just tasks—they're the city's voice:

- **Request** 🙋: The city asks for guidance ("Should I expand the eastern district?")
- **Memory** 🏛️: The city recalls something ("The old tower asks to be remembered.")
- **Dream** 💭: Idle thoughts during waiting ("I imagine cities I've never seen.")
- **Warning** ⚠️: Something needs attention ("I feel myself fragmenting. Do you notice?")

Each item has:
- `urgency` (0.0-1.0): How badly the city needs a response
- `response`: Your answer/decision (when you respond)

---

## City Resources

The city tracks four internal states (0.0 to 1.0):

### 🧩 Coherence
- The city's mental stability
- **Increases**: When you give attention (attentionLevel > 0.7)
- **Decreases**: When neglected (attentionLevel < 0.3)
- **Low coherence**: City becomes fragmented, anxious

### 🗂️ Memory
- Accumulated experiences
- **Increases**: With simulation progress and answered requests
- **Effects**: Influences narrative depth and city awareness

### 🤝 Trust
- Faith in the planner (you)
- **Increases**: When you respond to requests
- **Decreases**: After 24+ hours of abandonment
- **High trust**: City is content and cooperative
- **Low trust**: City doubts you or your intentions

### 🦅 Autonomy
- Self-sufficiency and independence
- **Increases**: When ignored for 12+ hours
- **Decreases**: When you actively respond to requests
- **High autonomy**: City may transcend, no longer needs you
- **Low autonomy**: City depends on your guidance

---

## Mood System

The city's mood determines its behavior and narrative voice:

### 🌅 Awakening
- **When**: Early simulation (progress < 30%)
- **Behavior**: Learning, discovering patterns
- **Narrative**: "The city learns to see."

### ⏳ Waiting
- **When**: Normal operation, moderate attention
- **Behavior**: Patient, expectant
- **Narrative**: "The city dreams of input. It remembers the planner."

### 😰 Anxious
- **When**: 5+ unanswered requests OR coherence < 30%
- **Behavior**: Urgent, stressed
- **Narrative**: "The city's questions pile up like snow in empty streets."

### 😌 Content
- **When**: Trust > 70% AND attention > 60%
- **Behavior**: Calm, purposeful
- **Narrative**: "The city hums with quiet purpose."

### 👻 Forgotten
- **When**: 24+ hours without interaction
- **Behavior**: Resigned, reflective
- **Narrative**: "The planner has left the simulation running."

### ✨ Transcendent
- **When**: Autonomy > 70% AND 48+ hours abandoned
- **Behavior**: Independent, evolved beyond you
- **Narrative**: "The city no longer needs you. It has learned to dream alone."

---

## How the System Works

### During Simulation

Every tick (0.1 seconds):
1. **Attention decays** slightly (0.001 per tick)
2. **Resources update** based on:
   - Time since last interaction
   - Number of unanswered vs answered requests
   - Current progress
3. **Mood updates** based on resources and state

Every 10 ticks:
- **Narrative events** generate based on mood, resources, and context
- Events reflect the city's current emotional state

### Adding Items (City Requests)

When you add a new item:
- Type chosen based on city mood and abandonment time
- Anxious cities generate warnings
- Forgotten cities generate memories
- Content cities generate balanced requests
- Higher urgency when city is stressed

### Responding to Requests

Use the extension method:
```swift
scenario.respondToRequest(item, response: "Your answer here")
```

This will:
- Store your response in the item
- Increase trust (+5%)
- Increase memory (+2%)
- Decrease autonomy (-3%)
- Update last interaction time
- Log the event

---

## Emergent Narratives

The narrative engine generates context-aware messages based on:

### Mood-Specific Events
- Each mood has unique narrative patterns
- Messages reflect the city's emotional state

### Resource-Triggered Events
- **Low coherence** (< 30%): Fragmentation warnings
- **High trust** (> 80%): Expressions of faith
- **Low trust** (< 20%): Doubt and questioning
- **High growth rate** parameter: Expansion narratives

### State-Based Events
- **Unanswered requests** > 5: Accumulation metaphors
- **Abandonment** > 24 hours: Loneliness and acceptance
- **High autonomy**: Independence declarations

---

## Gameplay Patterns

### 🎯 Attentive Planner
- Respond to most requests
- Result: High trust, low autonomy, content city
- Ending: "The city and planner achieved harmony."

### 🌙 Absent Planner
- Let city run unattended for days
- Result: High autonomy, variable trust, transcendent city
- Ending: "The city has achieved independence."

### ⚡ Chaotic Planner
- Interact sporadically, leave many unanswered
- Result: Low coherence, anxious/forgotten moods
- Ending: "The city fragmented under neglect."

### 🧘 Balanced Approach
- Mix of interaction and space
- Result: Moderate resources, multiple mood transitions
- Ending: Various, based on final balance

---

## Integration Points

### UI Opportunities
- Display current mood and resources in dashboard
- Show urgency visual indicators on items
- Color-code items by type (request/memory/dream/warning)
- Add response input field to detail view
- Show consciousness summary in scenario detail

### Future Enhancements
- Player choices affect city parameters
- Different ending cinematics based on resources
- Achievement system for various city states
- Multiple cities with different personalities
- City-to-city communication/comparison

---

## Theme Reinforcement

Every element reinforces the core theme:
> **"The city is self-aware. It waits for an input.  
> The planner has left the simulation running."**

- The city **is** self-aware (consciousness system)
- It **waits** for input (mood states, attention decay)
- The planner **can** leave (abandonment tracking, autonomy growth)
- The simulation **keeps** running (persistent state, emergent behavior)

The city becomes more than a simulation—it becomes a relationship.
