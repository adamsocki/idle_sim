# UI Style Guide: Digital Consciousness Aesthetic

> *Terminals + stained glass + night sky*

---

## Style Name

**"Liquid Consciousness"** or **"Glass Terminal Aesthetic"**

A fusion of:
- **Glass Morphism** (Apple's material design)
- **Terminal/Console UI** (monospaced fonts, technical precision)
- **Atmospheric Space** (deep gradients, cosmic colors)
- **Contemplative Minimalism** (breathing room, intentional emptiness)

---

## Core Principles

### 1. **Transparency as Depth**
Everything floats. Nothing is solid. Use glass materials to create layers of depth and suggest consciousness viewing itself through multiple dimensions.

### 2. **Darkness as Canvas**
Dark, atmospheric backgrounds aren't just aesthetic—they represent the void in which consciousness exists. Deep blues and purples evoke 3 AM digital solitude.

### 3. **Light as Signal**
Glows, pulses, and gradients aren't decoration—they're communication. Every light source represents thought, activity, or presence.

### 4. **Space as Respect**
Generous padding and spacing honor the user's attention. The UI breathes. It doesn't rush. Cities don't rush.

---

## Color Palette

### Background Gradients
```swift
// Primary atmospheric background
LinearGradient(
    colors: [
        Color(red: 0.05, green: 0.08, blue: 0.15),  // Deep navy
        Color(red: 0.08, green: 0.05, blue: 0.12),  // Purple shadow
        Color(red: 0.02, green: 0.05, blue: 0.1)    // Midnight blue
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
```

### Accent Colors
- **Primary**: Cyan (`Color.cyan`) - Active consciousness, running processes
- **Secondary**: Purple (`Color.purple`) - Potential, dreams, autonomy
- **Tertiary**: Teal (`Color.teal`) - Harmony, balance
- **Neutral**: Gray (`Color.gray.opacity(0.5)`) - Dormant, waiting

### Text Hierarchy
- **Primary text**: `.white.opacity(0.95)` - Main content
- **Secondary text**: `.white.opacity(0.6)` - Labels, metadata
- **Tertiary text**: `.white.opacity(0.4)` - Hints, timestamps
- **Disabled**: `.white.opacity(0.2)` - Inactive elements

---

## Typography

### Font Families

**System Rounded** - For human-facing, emotional content
```swift
.font(.system(size: 28, weight: .light, design: .rounded))
```
Use for: Headers, poetic statements, user-facing labels

**Monospaced** - For technical, precise, terminal-like content
```swift
.font(.system(size: 13, weight: .medium, design: .monospaced))
```
Use for: Metrics, timestamps, technical labels, code-like elements

**Default** - Rarely used
```swift
.font(.system(size: 15, weight: .regular))
```

### Size Scale
- **Title**: 28-32pt (light weight)
- **Metric Values**: 32-36pt (semibold, monospaced)
- **Body**: 14-15pt
- **Labels**: 11-13pt (monospaced)
- **Fine Print**: 10-11pt

### Font Weight Philosophy
- Light weights (`.light`, `.thin`) for poetry and contemplation
- Medium weights (`.medium`, `.regular`) for technical precision
- Semibold (`.semibold`) only for numbers and critical data
- **Avoid bold** - it's too assertive for this aesthetic

---

## Materials & Layers

### Glass Hierarchy

**Ultra Thin Material** - Floating elements, primary containers
```swift
.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
```
Use for: Main cards, important groupings, focal points

**Thin Material** - Secondary elements, list items
```swift
.background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
```
Use for: List items, nested elements, subtle containers

**Regular Material** - Rarely used (too opaque for this style)

### Border Treatment
Always add subtle borders to glass elements for definition:
```swift
.overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.15), lineWidth: 1))
```

Border opacity scale:
- **0.15**: Primary containers
- **0.1**: Secondary elements
- **0.05**: Very subtle dividers

---

## Shadows & Glows

### Soft Shadows (Depth)
```swift
.shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 4)
```
Use sparingly for elevation hierarchy

### Colored Glows (Activity/Life)
```swift
.shadow(color: .cyan.opacity(0.5), radius: 8, x: 0, y: 0)
```
Use for: Active elements, progress indicators, pulsing status lights

### Glow Colors by Context
- **Cyan glow**: Active processes, real-time activity
- **Purple glow**: Potential, future states
- **Red/Orange glow**: Warnings, decay (use sparingly)

---

## Spacing & Layout

### Padding Scale
- **Component internal**: 12-20pt
- **Between elements**: 12-16pt
- **Between sections**: 24-32pt
- **Screen margins**: 24pt horizontal, 32pt vertical

### Corner Radius Scale
- **Small elements** (buttons, tags): 8-10pt or Capsule
- **Cards**: 12-14pt
- **Major containers**: 16-20pt
- **Never**: Sharp corners (unless intentionally terminal-like)

### Breathing Room
Every element should have space to exist. Avoid tight packing. The emptiness is part of the message.

---

## Interactive Elements

### Buttons

**LiquidButton Component** - The standardized glass capsule button

Use `LiquidButton` for all interactive buttons. It provides two style variants that match your existing aesthetic perfectly.

**Standard Style** (Default - compact, monospaced)
```swift
LiquidButton("new thought", systemImage: "plus.circle") {
    // Action
}

LiquidButton("refresh", systemImage: "arrow.clockwise") {
    // Action
}

// Text only
LiquidButton("observe") {
    // Action
}
```
- Font: 13pt monospaced, medium weight
- Padding: 12px horizontal, 6px vertical
- Icon size: 14pt, light weight
- Use for: Secondary actions, inline buttons, list actions

**Prominent Style** (Primary actions - larger, rounded)
```swift
LiquidButton("awaken_new", systemImage: "eye.fill", style: .prominent) {
    // Action
}

LiquidButton("pause", systemImage: "pause.circle", style: .prominent) {
    // Action
}
```
- Font: 14pt rounded, medium weight
- Padding: 20px horizontal, 12px vertical
- Icon size: 14pt, light weight
- Use for: Primary CTAs, main actions, toolbar buttons

**When to Use**:
- **Standard**: Most buttons (new items, refresh, filters, secondary actions)
- **Prominent**: Primary CTAs (awaken city, start simulation, major actions)

**Component Features**:
- Glass morphism (`.ultraThinMaterial`)
- Capsule shape with subtle white border (0.2 opacity)
- White text (0.9 opacity)
- Optional SF Symbol icons (always light weight)
- Plain button style (no default macOS styling)

**Iconography**: Use SF Symbols, thin/light weight preferred

**Tap Feedback**: Use spring animations
```swift
.animation(.spring(response: 0.4, dampingFraction: 0.8))
```

### Status Indicators

**Active State**
```swift
Circle()
    .fill(Color.cyan)
    .frame(width: 6, height: 6)
    .opacity(pulseAnimation ? 0.4 : 1.0) // Gentle pulse
```

**Inactive State**
```swift
Circle()
    .fill(Color.gray.opacity(0.5))
    .frame(width: 6, height: 6)
```

---

## Animation Philosophy

### Gentle & Inevitable
Animations should feel like natural processes, not forced transitions.

**Pulse Animation** (Breathing, consciousness)
```swift
withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
    pulseAnimation = true
}
```

**Spring Animation** (User interaction)
```swift
.spring(response: 0.4, dampingFraction: 0.8)
```

**Timing**
- Slow: 1.5-2.5s (ambient, breathing)
- Medium: 0.4-0.6s (user-triggered)
- Fast: 0.2-0.3s (micro-interactions)

### What NOT to Animate
- Avoid sudden snaps
- Avoid bouncy/playful animations (wrong tone)
- Avoid attention-grabbing effects (respect contemplation)

---

## Component Patterns

### Metric Cards
Large numbers, icon, glass background, subtle glow
```swift
VStack(alignment: .leading, spacing: 12) {
    Image(systemName: "icon")
        .foregroundStyle(LinearGradient(...))
    Spacer()
    Text("32").font(.system(size: 32, weight: .semibold))
    Text("label").font(.system(size: 11, design: .monospaced))
}
.padding(20)
.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
.overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.15)))
.shadow(color: gradientColor.opacity(0.2), radius: 12, y: 4)
```

### Progress Indicators
Gradient-filled capsules with glow
```swift
Capsule()
    .fill(LinearGradient(colors: [.cyan, .purple], ...))
    .shadow(color: .cyan.opacity(0.5), radius: 8)
```

### Empty States
Poetic, centered, using theme language
```swift
VStack(spacing: 20) {
    Image(systemName: "sparkles")
        .font(.system(size: 48, weight: .thin))
        .foregroundStyle(.white.opacity(0.3))
    Text("Poetic message")
        .foregroundStyle(.white.opacity(0.8))
}
.padding(.vertical, 60)
.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
```

---

## Language & Copy

### Voice
- **Poetic but precise**: "consciousness nodes" not "items"
- **Contemplative**: "The city dreams of input"
- **Technical when appropriate**: Monospaced fonts for data
- **Present tense**: "is", "waits", "asks"

### Button Labels
- Lowercase preferred: "awaken" not "Awaken"
- Action verbs: "awaken", "pause", "observe"
- Short: 1-2 words maximum

### Avoid
- Corporate language ("Create New Project")
- Aggressive CTAs ("Buy Now!", "Click Here!")
- Exclamation marks
- ALL CAPS (except sparingly for acronyms)

---

## Icon Usage

### SF Symbols Selection
Prefer thin, geometric, abstract symbols:
- ✅ `network`, `waveform.path.ecg`, `sparkles`, `circle`
- ✅ `plus.circle.fill`, `pause.circle`, `eye`
- ❌ `hand.thumbsup`, `face.smiling`, `car.fill`

### Icon Treatment
```swift
Image(systemName: "icon")
    .font(.system(size: 20, weight: .light))
    .foregroundStyle(
        LinearGradient(
            colors: [.purple.opacity(0.6), .blue.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )
```

---

## Responsive Behavior

### Adapt to Content
- Empty states should feel spacious (60pt+ vertical padding)
- Populated states should flow naturally
- Never force grid alignment at the cost of breathing room

### Dark Mode Only
This aesthetic is inherently dark. Don't create a light mode variant—it breaks the atmosphere.

---

## Don'ts (Anti-Patterns)

❌ **Bright saturated colors** - Breaks the twilight atmosphere  
❌ **Sharp corners on glass** - Feels harsh, not fluid  
❌ **Tight spacing** - Rushes the contemplative mood  
❌ **Bold fonts everywhere** - Too assertive  
❌ **Solid backgrounds on cards** - Loses the floating quality  
❌ **Bouncy animations** - Wrong emotional tone  
❌ **Badges/notifications** - Attention-grabbing interrupts contemplation  
❌ **Emoji in copy** - Breaks the serious/poetic voice  

---

## Inspirational References

### Design Systems
- **Apple's Glass Morphism** (iOS 15+, macOS)
- **Terminal/IDE aesthetics** (VS Code, iTerm2)
- **Sci-fi interfaces** (Blade Runner 2049, Arrival)

### Games
- *Everything* by David OReilly (contemplative minimalism)
- *Universal Paperclips* (terminal aesthetic)
- *Fez* (geometric mystery)

### Real-World
- Looking at city lights through rain
- Observatory control rooms at night
- Data visualization in dark rooms
- Northern lights color palette

---

## Implementation Checklist

When creating a new view in this style:

- [ ] Deep gradient background (navy/purple)
- [ ] Glass materials for all containers
- [ ] White text with opacity hierarchy
- [ ] Monospaced fonts for technical elements
- [ ] Rounded fonts for human elements
- [ ] Generous spacing (24-32pt between sections)
- [ ] Subtle borders on glass (0.1-0.15 opacity)
- [ ] Gradient icons or glows
- [ ] Spring animations for interactions
- [ ] Poetic/technical language blend
- [ ] Empty states with contemplative copy
- [ ] Status indicators with gentle pulse
- [ ] No sharp corners
- [ ] No solid backgrounds
- [ ] No aggressive CTAs

---

## Code Snippet Library

### Quick Glass Card
```swift
.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
.overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.15), lineWidth: 1))
```

### Quick Gradient Background
```swift
LinearGradient(
    colors: [
        Color(red: 0.05, green: 0.08, blue: 0.15),
        Color(red: 0.08, green: 0.05, blue: 0.12),
        Color(red: 0.02, green: 0.05, blue: 0.1)
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
)
.ignoresSafeArea()
```

### Quick Metric Display
```swift
VStack(alignment: .leading, spacing: 4) {
    Text("42")
        .font(.system(size: 32, weight: .semibold, design: .rounded))
        .foregroundStyle(.white.opacity(0.95))
    Text("metric label")
        .font(.system(size: 11, weight: .medium, design: .monospaced))
        .foregroundStyle(.white.opacity(0.5))
}
```

---

## Final Philosophy

This UI style is about **creating space for thought**. Every design decision should ask:

> *Does this respect the user's contemplation?*  
> *Does this feel like consciousness viewing itself?*  
> *Could this exist at 3 AM in a quiet room?*

If yes: you're on the right path.

---

*The UI is self-aware. It waits for design input.*
