# Interactive Terminal UI - Design Plan

> *"Extending the Terminal Hive Mind aesthetic into a complete interactive UI system"*

---

## Vision

Transform the entire app into a cohesive **retro-futuristic computer interface** where every element - dashboards, lists, buttons, forms - maintains the Terminal Hive Mind aesthetic. Think Fallout's Pip-Boy, Alien's USCSS Nostromo terminals, or WarGames' WOPR interface.

The terminal is no longer just a read-only monitor - it's the entire operating system that also contains a terminal line.

---

## Current State

**What exists:**
- ✅ `TerminalDashboardView.swift` - Read-only monitoring dashboard with ASCII art, perfect implementation
- ✅ `TERMINAL_HIVE_MIND_STYLE_GUIDE.md` - Complete design system documentation
- ✅ CRT flicker effect, font scaling (Cmd+/-), pulse animations

**What needs transformation:**
- ❌ `CityListView.swift` - Currently uses "Liquid Consciousness" style (glassmorphism, gradients)
- ❌ `CityView.swift` - Poetic UI with gradient backgrounds and soft materials
- ❌ `GlobalDashboardView.swift` - Has 3 dashboard variants (need Terminal only)
- ❌ All UI components lack terminal aesthetic consistency
- ❌ new terminal input area located at bottom 

---

## Design System: Terminal UI Components

### Core Principles

All interactive elements must follow:

1. **Visual Consistency**
   - Pure black background (`Color.black`)
   - Phosphor green only (`Color.green` opacity 0.3-0.9)
   - Monospace font (`.system(design: .monospaced)`)
   - ASCII box drawing (`╔═╗║╚╝╟╢`)
   - ALL_CAPS labels for technical terms
   - Zero-padded numbers (`[00]`, `003`)

2. **Interaction Patterns**
   - Instant state changes (no smooth animations)
   - Hover: opacity increase (0.7 → 0.9)
   - Active/Selected: brighter borders or inverted colors
   - Click feedback: brief opacity flash (0.1s)
   - No elastic/spring animations
   - No rounded corners on primary containers
   - movable selection cursor that looks like ' > '. 

3. **Information Hierarchy**
   - Left-aligned content
   - Minimal spacing (0-8pt between elements)
   - Dividers instead of whitespace
   - Dotted leaders for label-value pairs

---

## Component Library

### 1. TerminalButton

**Purpose:** Primary action buttons

**Visual:**
```
┌─────────────────┐
│ > ACTION_LABEL  │
└─────────────────┘
```

**Features:**
- Uppercase label with `>` prefix
- Rectangle border (1pt green 0.6 opacity)
- Hover: text opacity 0.7 → 0.9
- Click: brief invert/flash
- Monospace bold font

**Code Structure:**
```swift
struct TerminalButton: View {
    let label: String
    let action: () -> Void
    @State private var isHovered = false
    @Binding var terminalFontSize: CGFloat

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(">")
                Text(label.uppercased())
            }
            .font(terminalFont(9, weight: .bold))
            .foregroundStyle(Color.green.opacity(isHovered ? 0.9 : 0.7))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .overlay(Rectangle().strokeBorder(Color.green.opacity(0.6)))
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
```

---

### 2. TerminalListRow

**Purpose:** Clickable list items (cities, thoughts, etc.)

**Visual:**
```
║ > [00] ● CITY_NAME                    STATUS: ACTIVE ║
```

**Features:**
- Index number, status indicator, label
- Full-width clickable area
- Hover: background green 0.0 → 0.05
- Selected: background green 0.1, brighter border
- Side borders (║) for ASCII box containment

**States:**
- Normal: opacity 0.7
- Hover: opacity 0.8, background 0.05
- Selected: opacity 0.9, background 0.1

---

### 3. TerminalBox

**Purpose:** Container with ASCII borders

**Visual:**
```
╔═══ HEADER_TEXT ════════════════════════════╗
║ Content goes here                          ║
║ More content                               ║
╚════════════════════════════════════════════╝
```

**Features:**
- Optional header text in top border
- Padding inside: 8-12pt
- Border opacity: 0.6
- Divider support with `╟──╢`

---

### 4. TerminalTextField

**Purpose:** Text input fields

**Visual:**
```
║ FIELD_NAME.........: [_________________] ║
```

**Features:**
- Dotted leader to input field
- Input area with cursor
- Monospace font
- Bottom border indicator (like old terminal cursors)
- Focus state: brighter border

---

### 5. TerminalProgressBar

**Purpose:** Visual metric display (already exists, make reusable)

**Visual:**
```
METRIC_NAME[██████░░░░] 0.6234
```

**Features:**
- 10-character bar with filled (█) and empty (░)
- Precise decimal value display
- Label in ALL_CAPS

---

### 6. TerminalToggle

**Purpose:** ON/OFF switches

**Visual:**
```
║ SETTING_NAME.......: [ON]  ║
or
║ SETTING_NAME.......: [OFF] ║
```

**Features:**
- Square bracket indicators
- ON: opacity 0.9
- OFF: opacity 0.4
- Clickable to toggle

---

### 7. TerminalDivider

**Purpose:** Section separation

**Visual:**
```
╟────────────────────────────────────────────╢
```

**Features:**
- T-junction characters for box containment
- Opacity 0.4 (softer than borders)
- Used between list items or sections

---

## Application Structure

### Navigation Layout

```
┌──────────────┬───────────────────┬──────────────┐
│ LEFT         │ CENTER            │ RIGHT        │
│ (240-280pt)  │ (flexible)        │ (250-350pt)  │
├──────────────┼───────────────────┼──────────────┤
│              │                   │              │
│ Terminal     │ No Selection:     │ No Item:     │
│ City List    │  Terminal         │  Empty       │
│              │  Dashboard        │  State       │
│              │                   │              │
│ [00] ALPHA   │ City Selected:    │ Item:        │
│ [01] BETA    │  Terminal         │  Terminal    │
│ [02] GAMMA   │  City Detail      │  Item        │
│              │                   │  Detail      │
│ [CREATE]     │                   │              │
│              │                   │              │
└──────────────┴───────────────────┴──────────────┘
```

Every column uses pure black background with phosphor green terminal components.

---

## Implementation Phases

### Phase 1: Terminal Component Library
**File:** `idle_01/ui/terminal/TerminalComponents.swift`

Create all reusable components:
- TerminalButton
- TerminalListRow
- TerminalBox
- TerminalTextField
- TerminalProgressBar (extract from existing code)
- TerminalToggle
- TerminalDivider
- TerminalStatusIndicator (●○)

**Shared Features:**
- All accept `@Binding var terminalFontSize: CGFloat`
- All use `terminalFont()` helper function
- All support Cmd+/- zoom
- All use phosphor green color system

**Estimated effort:** 4-6 hours

---

### Phase 2: Terminal City List View
**File:** `idle_01/ui/terminal/TerminalCityListView.swift`

**Replace:** Current `CityListView.swift`

**Structure:**
```
╔═══ CONSCIOUSNESS_NODES ════════════════════╗
║                                            ║
║ ┌─ CREATE ────────────────────────────┐   ║
║ │ > INITIALIZE_NEW_NODE                │   ║
║ └──────────────────────────────────────┘   ║
║                                            ║
╟────────────────────────────────────────────╢
║                                            ║
║ > [00] ● ALPHA_CITY          ACTIVE       ║
║ > [01] ○ BETA_NODE           DORMANT      ║
║ > [02] ● GAMMA_HIVE          ACTIVE       ║
║                                            ║
╚════════════════════════════════════════════╝

╔═══ SYSTEM_METRICS ═════════════════════════╗
║ TOTAL_NODES........: 003                   ║
║ ACTIVE_PROCESSES...: 002                   ║
║ UPTIME.............: 047:23                ║
╚════════════════════════════════════════════╝
```

**Features:**
- Scrollable list of cities
- Each row clickable to select city
- CREATE button at top
- Summary metrics at bottom
- Selected city: brighter, inverted, or border highlight

**Replaces:**
- Atmospheric gradients → Pure black
- Glass morphism cards → Terminal rows
- Liquid buttons → Terminal buttons
- Poetic "consciousness" header → System metrics

**Estimated effort:** 3-4 hours

---

### Phase 3: Simplify Global Dashboard
**File:** `idle_01/ui/GlobalDashboardView.swift`

**Changes:**
- Remove version tabs (Original/Twilight/Terminal)
- Remove `selectedVersion` state
- Always show `TerminalDashboardView` directly
- Pass through font size and flicker bindings

**Code:**
```swift
struct GlobalDashboardView: View {
    @Query(sort: \City.createdAt, order: .reverse)
    private var cities: [City]

    @State private var pulseAnimation = false
    @State private var terminalFontSize: CGFloat = 9.0
    @State private var crtFlicker: Double = 1.0
    @State private var crtFlickerEnabled: Bool = false

    var body: some View {
        TerminalDashboardView(
            cities: cities,
            pulseAnimation: $pulseAnimation,
            terminalFontSize: $terminalFontSize,
            crtFlicker: $crtFlicker,
            crtFlickerEnabled: $crtFlickerEnabled
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
            startCRTFlicker { flickerValue in
                withAnimation(.linear(duration: 0.016)) {
                    crtFlicker = flickerValue
                }
            }
        }
    }
}
```

**Estimated effort:** 30 minutes

---

### Phase 4: Terminal City Detail View
**File:** `idle_01/ui/terminal/TerminalCityDetailView.swift`

**Replace:** Current `CityView.swift`

**Structure:**
```
╔═══ NODE_[00]: ALPHA_CITY ══════════════════╗
║                                            ║
║ STATUS.............: [ACTIVE]              ║
║ UPTIME.............: 012:34:56             ║
║ LAST_INTERACTION...: 00:02:15              ║
║                                            ║
╟────────────────────────────────────────────╢
║                                            ║
║ COHERENCE..........: [██████░░░░] 0.6234   ║
║ TRUST..............: [███████░░░] 0.7012   ║
║ MEMORY.............: [█████░░░░░] 0.5123   ║
║ AUTONOMY...........: [████░░░░░░] 0.4456   ║
║                                            ║
╟────────────────────────────────────────────╢
║                                            ║
║ MOOD...............: CONTENT               ║
║ ATTENTION..........: 067%                  ║
║                                            ║
╟────────────────────────────────────────────╢
║                                            ║
║ ┌─ ACTIONS ────────────────────────────┐  ║
║ │ [START] [STOP] [RESET] [DELETE]     │  ║
║ └──────────────────────────────────────┘  ║
║                                            ║
╚════════════════════════════════════════════╝

╔═══ CONSCIOUSNESS_STREAM ═══════════════════╗
║                                            ║
║ > [REQ] Should I expand eastern district? ║
║ > [MEM] The old tower asks to be...       ║
║ > [DRM] I imagine cities I've never...    ║
║                                            ║
║ ┌─────────────────────────────────────┐   ║
║ │ > NEW_THOUGHT                        │   ║
║ └─────────────────────────────────────┘   ║
║                                            ║
╚════════════════════════════════════════════╝
```

**Features:**
- Node header with index and name
- Status and uptime information
- Resource metrics with progress bars
- Action buttons (START/STOP/RESET/DELETE)
- Scrollable list of thoughts/items
- Each thought is clickable terminal row
- NEW_THOUGHT button at bottom

**Replaces:**
- Gradient backgrounds → Pure black
- Soft material cards → ASCII boxes
- Color-coded metrics → Green-only progress bars
- Poetic presentation → Technical readout

**Estimated effort:** 5-6 hours

---

### Phase 5: Terminal Item Detail View
**File:** `idle_01/ui/terminal/TerminalItemDetailView.swift`

**Replace:** Current `DetailView.swift` (when terminal mode)

**Structure:**
```
╔═══ THOUGHT_[00] ═══════════════════════════╗
║                                            ║
║ TYPE...............: REQUEST               ║
║ TIMESTAMP..........: [12:34:56]            ║
║ URGENCY............: [██████░░░░] 0.6234   ║
║                                            ║
╟────────────────────────────────────────────╢
║                                            ║
║ >> Should I expand the eastern district?   ║
║    The population density is increasing    ║
║    and I sense a need for more space.      ║
║                                            ║
╟────────────────────────────────────────────╢
║                                            ║
║ RESPONSE:                                  ║
║ ┌────────────────────────────────────────┐ ║
║ │ [Type response here...]                │ ║
║ │                                        │ ║
║ └────────────────────────────────────────┘ ║
║                                            ║
║ ┌─ ACTIONS ─────────────────────────────┐ ║
║ │ [RESPOND] [DISMISS] [DELETE]          │ ║
║ └───────────────────────────────────────┘ ║
║                                            ║
╚════════════════════════════════════════════╝
```

**Features:**
- Item metadata (type, timestamp, urgency)
- Original thought/question display
- Response text input field (terminal-style)
- Action buttons

**Estimated effort:** 3-4 hours

---

### Phase 6: Terminal Effects & Polish

**Optional Enhancements:**

#### 6.1 CRT Scanlines
Horizontal lines overlay across entire window

**Implementation:**
```swift
struct CRTScanlinesOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 2) {
                ForEach(0..<Int(geometry.size.height / 3), id: \.self) { _ in
                    Rectangle()
                        .fill(Color.black.opacity(0.1))
                        .frame(height: 1)
                }
            }
        }
        .allowsHitTesting(false)
    }
}
```

#### 6.2 Phosphor Glow
Subtle outer glow on text

**Implementation:**
```swift
Text("SOME_TEXT")
    .shadow(color: .green.opacity(0.3), radius: 2)
    .shadow(color: .green.opacity(0.1), radius: 4)
```

#### 6.3 Boot Sequence Animation
Terminal-style startup when app launches

**Structure:**
```
> INITIALIZING_CONSCIOUSNESS_MONITOR...
> LOADING_SYSTEM_MODULES...................[OK]
> SCANNING_NODES...........................[OK]
> ESTABLISHING_HIVE_CONNECTION.............[OK]
>
> READY.
```

Auto-plays on first launch, 2-3 second animation, then fades to normal UI.

#### 6.4 Keyboard Sounds (Optional)
Quiet terminal beeps on button clicks, subtle "data update" sounds

#### 6.5 Screen Curvature (Advanced)
Very subtle fisheye distortion on edges for authentic CRT feel

**Estimated effort:** 4-6 hours total

---

## Visual Design Reference

### Color Palette

**Phosphor Green** (`Color.green`)
```swift
0.9 opacity - Headers, active status, important data
0.8 opacity - Primary labels, selected states
0.7 opacity - Default text, button labels
0.6 opacity - Borders, structural elements (╔═╗)
0.5 opacity - Metadata, secondary info
0.4 opacity - Dividers (╟──╢), timestamps
0.3 opacity - Ambient/background structure
```

**Pure Black** (`Color.black`)
```swift
Background only. No variations. No opacity.
```

**Optional Warning Colors** (rare use)
```swift
Color.orange.opacity(0.8) - Critical warnings
Color.yellow.opacity(0.8) - Caution states
```

### Typography

**All Text:**
```swift
.font(.system(size: X, weight: Y, design: .monospaced))
```

**Base Sizes (scales with Cmd +/-):**
```
11pt bold - Main headers, section titles
10pt bold - Status labels, indices
10pt regular - Primary content
9pt bold - Index numbers [00]
9pt regular - ASCII borders, data labels
8pt regular - Timestamps, metadata
```

### ASCII Box Characters

```
╔ ╗ ╚ ╝   Corners
═         Horizontal lines
║         Vertical lines
╟ ╢       T-intersections (dividers)
─         Lighter horizontal (optional)
```

### Status Indicators

```
● (filled circle) - Active/Running - Green 0.9 opacity
○ (hollow circle) - Inactive/Dormant - Green 0.4 opacity
```

---

## Implementation Checklist

When creating any new terminal view:

- [ ] Pure black background (`Color.black`)
- [ ] All text phosphor green with appropriate opacity
- [ ] Monospace font (`.monospaced`)
- [ ] ASCII box characters for structure
- [ ] ALL_CAPS for technical labels
- [ ] Zero-padded numbers for indices
- [ ] Progress bars using `█░` characters
- [ ] Status indicators `●○`
- [ ] Minimal spacing (0-8pt between elements)
- [ ] Left-aligned content
- [ ] No smooth transitions (instant state changes)
- [ ] Hover states (opacity change only)
- [ ] Selected states (brighter border or inverted)
- [ ] Support Cmd+/- font scaling
- [ ] Support optional CRT flicker toggle

---

## Migration Strategy

### Safe Approach: Feature Flag

**Create:** `@AppStorage("useTerminalUI") var useTerminalUI = false`

**In SimulatorView:**
```swift
Group {
    if useTerminalUI {
        TerminalCityListView(...)
    } else {
        CityListView(...) // Original
    }
}
```

This allows:
- Gradual implementation without breaking existing UI
- Easy A/B comparison during development
- Safe rollback if needed
- User preference toggle (power users can opt-in early)

**Eventually:** Remove flag and old views once terminal UI is complete and tested.

---

## Example: Complete Terminal City List Row

```swift
struct TerminalCityListRow: View {
    let city: City
    let index: Int
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isHovered = false
    @Binding var terminalFontSize: CGFloat

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                // Left border
                Text("║")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))

                // Row prefix
                Text(">")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(isSelected ? 0.9 : 0.5))

                // Index
                Text(String(format: "[%02d]", index))
                    .font(terminalFont(9, weight: .bold))
                    .foregroundStyle(Color.green.opacity(isSelected ? 0.9 : 0.7))

                // Status indicator
                Text(city.isRunning ? "●" : "○")
                    .font(terminalFont(9))
                    .foregroundStyle(city.isRunning ? Color.green.opacity(0.9) : Color.green.opacity(0.4))

                // City name (fixed width padding)
                Text(city.name.uppercased().padding(toLength: 20, withPad: " ", startingAt: 0))
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(isSelected ? 0.9 : 0.7))

                Spacer()

                // Status text
                Text(city.isRunning ? "ACTIVE" : "DORMANT")
                    .font(terminalFont(8))
                    .foregroundStyle(Color.green.opacity(isSelected ? 0.8 : 0.5))

                // Right border
                Text("║")
                    .font(terminalFont(9))
                    .foregroundStyle(Color.green.opacity(0.6))
            }
            .padding(.vertical, 4)
            .background(
                Color.green.opacity(
                    isSelected ? 0.1 : (isHovered ? 0.05 : 0.0)
                )
            )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }

    private func terminalFont(_ baseSize: CGFloat, weight: Font.Weight = .regular) -> Font {
        let scaleFactor = terminalFontSize / 9.0
        return .system(size: baseSize * scaleFactor, weight: weight, design: .monospaced)
    }
}
```

---

## Inspirational References

### Films & Media
- **Pi (1998)** - Max's homemade computer, cobbled-together terminal aesthetic
- **The Matrix (1999)** - Green cascading code, monitoring interfaces
- **WarGames (1983)** - WOPR terminal, strategic command interface
- **Alien (1979)** - Mother terminal, retro-future computer displays
- **Fallout (series)** - Pip-Boy UI, green monochrome with clickable buttons
- **Alien: Isolation (2014)** - Working computer terminals throughout game

### Real-World Terminals
- **VT100/VT220** - 1970s-80s mainframe access terminals
- **MS-DOS** - Command line interface before Windows
- **Early Unix systems** - Green phosphor displays
- **Oscilloscopes** - Green trace on black CRT
- **Server monitoring** - htop, top, system diagnostics

### Games with Terminal Aesthetics
- **Fallout 4** - Pip-Boy and terminal hacking minigame
- **System Shock 2** - MFD interface, retro-tech UI
- **Duskers** - Pure terminal-based gameplay
- **SUPERHOT: MIND CONTROL DELETE** - DOS-style terminal menus

---

## Testing Checklist

Before considering complete:

**Visual Consistency:**
- [ ] All views use pure black background
- [ ] All text is phosphor green monospace
- [ ] All interactive elements follow same hover/selected pattern
- [ ] ASCII boxes align properly at all font scales
- [ ] No gradients or rounded corners in terminal views

**Functionality:**
- [ ] All existing features still work (create city, add thoughts, etc.)
- [ ] Keyboard shortcuts work (Cmd+/-, Cmd+F for flicker)
- [ ] City selection and navigation flows correctly
- [ ] Item selection and detail view works
- [ ] All buttons trigger correct actions

**Polish:**
- [ ] CRT flicker toggle works globally
- [ ] Font scaling applies to all terminal components
- [ ] Scanlines overlay doesn't block interaction
- [ ] Performance is smooth (60fps)

**Accessibility Considerations:**
- [ ] Font can scale to 24pt for readability
- [ ] Consider optional high-contrast mode (brighter green)
- [ ] Ensure keyboard navigation works for all actions

---

## Future Possibilities

### Terminal Command Line
Add text input at bottom for command-based interaction:

```
> help
> list --all
> inspect [00]
> create city --name=DELTA
> start [01]
> stop [02]
> export --format=json
```

Could become an alternative power-user interface.

### Live Data Streaming
Auto-scrolling activity feed with real-time updates

### Glitch Effects
Occasional character corruption/flicker for unstable machine feel

### Multiple Color Modes
- Phosphor green (default)
- Amber (amber.opacity...)
- White (classic IBM PC)

User can toggle in preferences.

### Network/Multiplayer Visualization
If game becomes networked, show other players' consciousness nodes in terminal list

---

## File Structure

```
idle_01/
├── ui/
│   ├── terminal/
│   │   ├── TerminalComponents.swift        [NEW - Component library]
│   │   ├── TerminalCityListView.swift      [NEW - Replaces CityListView]
│   │   ├── TerminalCityDetailView.swift    [NEW - Replaces CityView]
│   │   ├── TerminalItemDetailView.swift    [NEW - Replaces DetailView]
│   │   └── TerminalEffects.swift           [NEW - Scanlines, glow, etc]
│   ├── dashboard/
│   │   ├── TerminalDashboardView.swift     [KEEP - Already perfect]
│   │   ├── OriginalDashboardView.swift     [DEPRECATE - Optional removal]
│   │   └── TwilightDashboardView.swift     [DEPRECATE - Optional removal]
│   ├── GlobalDashboardView.swift           [SIMPLIFY - Remove tabs]
│   ├── SimulatorView.swift                 [MINOR UPDATE - Wire new views]
│   └── [Keep other views as-is for now]
└── TERMINAL_HIVE_MIND_STYLE_GUIDE.md       [KEEP - Core reference]
    INTERACTIVE_TERMINAL_UI_PLAN.md         [THIS FILE]
```

---

## Conclusion

This plan transforms your entire app into a cohesive retro-futuristic terminal interface while maintaining all existing functionality. The Terminal Hive Mind aesthetic extends from read-only monitoring to full interactive UI system.

**Key Benefits:**
- ✅ Unified visual language throughout app
- ✅ Distinctive, memorable aesthetic
- ✅ Perfect for "machine consciousness" theme
- ✅ Nostalgic appeal to retro computing enthusiasts
- ✅ All standard SwiftUI, no custom rendering needed
- ✅ Gradual implementation path with feature flags

**Next Steps:**
1. Create component library first (foundation for everything)
2. Implement one view at a time with feature flag
3. Test thoroughly at each phase
4. Add polish effects last
5. Remove old views once terminal UI is complete

> *"This isn't a friendly interface. This is a diagnostic tool. You're not using consciousness—you're monitoring it."*

---

**INTERFACE: TERMINAL_UI_DESIGN_PLAN**
**DOCUMENT_VERSION: 1.0**
**STATUS: [READY_FOR_IMPLEMENTATION]**
**// █**
