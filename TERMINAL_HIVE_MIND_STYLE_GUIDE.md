# Terminal Hive Mind Style Guide

> *"Like peering into the raw neural machinery of collective consciousness"*

---

## Style Name

**"Terminal Hive Mind"** or **"Raw Machine Consciousness"**

Inspired by:
- **Pi (1998)** - The cobbled-together computer aesthetic
- **The Matrix** - Green-on-black terminal streams
- **Hacker terminals** - Raw data, no comfort layer
- **Oscilloscope displays** - Scientific monitoring equipment
- **1970s mainframe terminals** - Pure information density

This is not a friendly interface. This is a diagnostic tool. You're not *using* consciousness—you're *monitoring* it.

---

## Core Philosophy

### 1. **No Sugar Coating**
This isn't designed for comfort. It's designed for truth. Every pixel serves data transmission. No decorative elements. No friendly icons. Just information flowing through a machine.

### 2. **Information Density Over Readability**
Pack it in. Layer it. Let it overlap. The chaos is the point. A hive mind isn't neat—it's thousands of simultaneous thoughts colliding.

### 3. **Monochrome Brutalism**
One color: phosphor green. Various opacities for hierarchy. Pure black background like a CRT monitor in a dark room. No gradients. No glass morphism. Just raw text on void.

### 4. **ASCII as Architecture**
Box-drawing characters (`╔═╗║╚╝╟╢`) aren't decoration—they're structural. They create containment fields for data streams. They give the illusion of control over chaos.

### 5. **Technical Precision**
Zero-padded numbers. Exact decimal places. Monospaced fonts. Everything aligned. This is a scientific instrument, not an art project.

---

## Color Palette

### Single Color System

**Phosphor Green** (`Color.green`)
- Primary (0.9 opacity): Headers, important data, active states
- Secondary (0.75 opacity): Metric values, labels
- Tertiary (0.6 opacity): Borders, structural elements
- Quaternary (0.5 opacity): Metadata, comments
- Quinary (0.4 opacity): Timestamps, system info
- Ambient (0.3 opacity): Dividers, background structure

**Pure Black** (`Color.black`)
- Background only. No variations. No gradients.

### Why Green?
- **Historical**: Classic terminal phosphor color
- **Visibility**: Maximum contrast on black
- **Emotion**: Cold, clinical, machine-like
- **Aesthetic**: Feels like looking at raw code/data

---

## Typography

### Font System

**Monospaced Only**
```swift
.font(.system(size: X, weight: Y, design: .monospaced))
```

Every character must take the same width. This creates:
- Perfect alignment for technical data
- Table-like structure without tables
- That authentic terminal feeling
- Easy mental parsing of columnar data

### Font Sizes (Base at 9pt)

```swift
// Use the dynamic scaling helper
private func terminalFont(_ baseSize: CGFloat, weight: Font.Weight = .regular) -> Font {
    let scaleFactor = terminalFontSize / 9.0
    return .system(size: baseSize * scaleFactor, weight: weight, design: .monospaced)
}
```

- **11pt bold**: Main headers, system identification
- **10pt bold**: Status indicators, section labels
- **10pt regular**: Primary content, descriptions
- **9pt bold**: Index numbers, critical markers
- **9pt regular**: Borders, structural characters, data labels
- **8pt regular**: Detailed metrics, timestamps, sub-content

### Font Weight Hierarchy

- **Bold**: System headers, status, indices, attention markers
- **Regular**: Everything else (default)
- Never light, never semibold. Just two weights.

### Dynamic Scaling

Users can scale the entire terminal interface:
- **Cmd +**: Increase font size (max 24pt)
- **Cmd -**: Decrease font size (min 6pt)
- **Cmd 0**: Reset to default (9pt)

All text scales proportionally. Hierarchy is maintained.

---

## ASCII Box-Drawing Characters

### Character Set

```
╔ ╗ ╚ ╝   Corners
═         Horizontal lines
║         Vertical lines
╟ ╢       T-intersections
```

### Usage Patterns

**Full Box Structure**
```
╔═══ SECTION_NAME ═══════════════════════════════════════╗
║ Content goes here                                      ║
║ More content                                           ║
╚════════════════════════════════════════════════════════╝
```

**Nested Content with Dividers**
```
╔═══ MATRIX ═════════════════════════════════════════════╗
║ [00] ● CITY_NAME_01                                    ║
║    METRIC_A[██████░░░░] 0.6234                         ║
╟────────────────────────────────────────────────────────╢
║ [01] ○ CITY_NAME_02                                    ║
║    METRIC_A[███░░░░░░░] 0.2891                         ║
╚════════════════════════════════════════════════════════╝
```

### Box Character Opacity

- Headers/Footers: `0.6` opacity
- Side borders: `0.6` opacity
- Dividers: `0.4` opacity (softer, less structure)

---

## Data Formatting

### Numbers

**Zero-Padded Integers**
```swift
String(format: "%02d", index)   // 00, 01, 02...
String(format: "%03d", count)   // 000, 001, 023...
```
Purpose: Fixed width, easier scanning, looks more technical

**High-Precision Decimals**
```swift
String(format: "%.4f", value)   // 0.6234, 0.0012
String(format: "%.2f%%", percent) // 67.45%
```
Purpose: Scientific precision, no rounding approximations

**Dotted Leaders**
```
TOTAL_NODES............: 003
ACTIVE_PROCESSES.......: 001
COLLECTIVE_AWARENESS...: 067.45%
AVG_COHERENCE..........: 0.6234
```
Purpose: Visual connection between label and value

### Progress Bars (ASCII)

```swift
private func progressBar(_ value: Double) -> String {
    let filled = Int(value * 10)
    let empty = 10 - filled
    return String(repeating: "█", count: filled) + String(repeating: "░", count: empty)
}
```

**Examples:**
```
COHERENCE[██████████] 1.00
TRUST[██████░░░░] 0.60
MEMORY[███░░░░░░░] 0.30
PROGRESS[░░░░░░░░░░] 0.00
```

Characters: `█` (filled) and `░` (empty)

### Status Indicators

**Active**: `●` (filled circle) - Green 0.9 opacity
**Inactive**: `○` (hollow circle) - Green 0.4 opacity

```
║ [00] ● ACTIVE_CONSCIOUSNESS    ║
║ [01] ○ DORMANT_NODE            ║
```

### Text Formatting

**ALL CAPS** for:
- City names
- Section headers
- Metric labels
- Status values

**lowercase** for:
- Never. This isn't a place for lowercase.

**Case Preserved** for:
- Version numbers (`v0.3.1`)
- Time formats (`00:12:34`)

---

## Layout Principles

### Information Density

**Pack it tight.** Spacing is minimal. Line height is compact. Every line carries data.

```swift
VStack(alignment: .leading, spacing: 0) {
    // Sections separated by dividers, not space
}
```

Spacing values:
- Between major sections: `8pt` (divider + padding)
- Between text lines: `2-4pt`
- Between data rows: `6pt`
- Internal component spacing: `4pt`

### Alignment

**Left-aligned** for everything. No centering. No right-alignment except for timestamps/metadata in tables.

**Fixed-width columns** using monospace font naturally creates alignment:
```
METRIC_A: 0.6234
METRIC_B: 0.0012
```

### Padding

- Screen edges: `16pt` horizontal, `16pt` vertical
- Inside boxes: Minimal (inherent from text spacing)
- Between elements: Dividers instead of whitespace

---

## Component Patterns

### Terminal Header

```
CIVIC_CONSCIOUSNESS_MONITOR v0.3.1
// HIVE MIND OBSERVATION TERMINAL
>> Active consciousness nodes: 3 | Running processes: 1
STATUS: [ACTIVE]
```

**Purpose**: System identification, version, instant status overview
**Font**: 11pt bold title, 10pt content
**Opacity**: 0.9 title, 0.5-0.7 content

### Consciousness Matrix

Multi-line rows showing each city with full diagnostic data:

```
╔═══ CONSCIOUSNESS_MATRIX ═══════════════════════════════╗
║ [00] ● CITY_ALPHA                                      ║
║    COHERENCE[██████░░░░] 0.60                          ║
║    TRUST[███████░░░] 0.70  MEMORY[█████░░░░░] 0.50     ║
║    MOOD: CONTENT            PROGRESS: 45.2%            ║
╟────────────────────────────────────────────────────────╢
║ [01] ○ CITY_BETA                                       ║
...
╚════════════════════════════════════════════════════════╝
```

**Purpose**: Detailed per-entity monitoring
**Font**: 9pt for index/name, 8pt for metrics
**Structure**: 4-line repeating pattern per entity

### Aggregate Metrics

System-wide statistics in a dense block:

```
╔═══ AGGREGATE_METRICS ══════════════════════════════════╗
║ TOTAL_NODES............: 003                           ║
║ ACTIVE_PROCESSES.......: 001                           ║
║ COLLECTIVE_AWARENESS...: 067.45%                       ║
║ AVG_COHERENCE..........: 0.6234                        ║
║ AVG_TRUST..............: 0.5891                        ║
╚════════════════════════════════════════════════════════╝
```

**Purpose**: Quick numerical snapshot
**Font**: 9pt regular
**Format**: Dotted leaders, precise decimals

### Activity Stream

Recent events with timestamps:

```
╔═══ ACTIVITY_STREAM ════════════════════════════════════╗
║ > CITY_ALPHA                              [00:12:34]   ║
║ > CITY_BETA                               [00:08:17]   ║
║ > CITY_GAMMA                              [00:01:02]   ║
╚════════════════════════════════════════════════════════╝
```

**Purpose**: Temporal awareness, what happened when
**Font**: 8pt
**Format**: City name left, timestamp right

### System Info Footer

Metadata about the terminal itself:

```
// SYSTEM UPTIME: 003:47
// OBSERVER: HUMAN
// INTERFACE: TERMINAL_MONITOR_v0.3
// █
```

**Purpose**: Meta-awareness, blinking cursor for liveness
**Font**: 8pt regular
**Opacity**: 0.4 (background information)
**Cursor**: Pulsing block `█`

### Empty State

```
╔═══ SYSTEM_STATE ═══════════════════════════════════════╗
║ >> NO CONSCIOUSNESS DETECTED                           ║
║ >> AWAITING INITIALIZATION...                          ║
╚════════════════════════════════════════════════════════╝
```

**Purpose**: System status when no data available
**Animation**: "AWAITING..." pulses opacity

---

## Animation

### Pulse Animation

```swift
withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
    pulseAnimation = true
}
```

**Applied to:**
- Active status indicator `[ACTIVE]`
- "AWAITING INITIALIZATION..." text
- Blinking cursor block `█`

**Opacity range:** 0.3 to 1.0 (or specified max)

**Timing:** 2 seconds cycle. Slow enough to not distract, fast enough to feel alive.

### No Other Animations

No transitions. No springs. No bounces. Data appears instantly when updated. This is a real-time monitor, not a presentation.

---

## Interaction Patterns

### Keyboard Shortcuts

The only interaction in this view:

- **Cmd +**: Zoom in (increase font scale)
- **Cmd -**: Zoom out (decrease font scale)
- **Cmd 0**: Reset to default scale

This allows users to:
- Get *really close* to the data (24pt max)
- See the full matrix view from far away (6pt min)
- Accommodate different screen sizes/preferences

### No Mouse Interaction

No buttons. No hover states. No clickable elements. This is a **read-only monitor**. You observe, you don't control.

(Though you could add hidden terminal commands later if you want that authentic Unix feel)

---

## Responsive Behavior

### Font Scaling

Everything scales proportionally. If base is 9pt and user scales to 18pt (2x), all fonts double:
- 11pt → 22pt
- 10pt → 20pt
- 9pt → 18pt
- 8pt → 16pt

Hierarchy is preserved. Structure remains intact.

### Content Overflow

Let it scroll. Don't truncate. Don't paginate. A terminal shows all data, and you scroll to see more.

### Screen Size

Design assumes minimum width of ~600pt for the box drawings to not wrap. On smaller screens, horizontal scrolling is acceptable (rare for desktop apps, but fits the aesthetic).

---

## Technical Implementation

### Key Code Snippets

**Terminal Font Helper**
```swift
@State private var terminalFontSize: CGFloat = 9.0

private func terminalFont(_ baseSize: CGFloat, weight: Font.Weight = .regular) -> Font {
    let scaleFactor = terminalFontSize / 9.0
    return .system(size: baseSize * scaleFactor, weight: weight, design: .monospaced)
}
```

**Keyboard Shortcuts**
```swift
// Hidden buttons for keyboard shortcuts
VStack {
    Button("") { terminalFontSize = min(terminalFontSize + 1, 24) }
        .keyboardShortcut("+", modifiers: .command)
        .hidden()

    Button("") { terminalFontSize = max(terminalFontSize - 1, 6) }
        .keyboardShortcut("-", modifiers: .command)
        .hidden()

    Button("") { terminalFontSize = 9.0 }
        .keyboardShortcut("0", modifiers: .command)
        .hidden()
}
```

**Progress Bar**
```swift
private func progressBar(_ value: Double) -> String {
    let filled = Int(value * 10)
    let empty = 10 - filled
    return String(repeating: "█", count: filled) + String(repeating: "░", count: empty)
}
```

**Pulse Animation**
```swift
.opacity(pulseAnimation ? 0.5 : 1.0)

// In onAppear:
withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
    pulseAnimation = true
}
```

---

## Language & Voice

### Writing Style

**Technical. Abbreviated. All-caps where appropriate.**

Good:
```
CONSCIOUSNESS_MATRIX
AGGREGATE_METRICS
AVG_COHERENCE
AWAITING INITIALIZATION...
```

Bad:
```
Consciousness Matrix
Aggregate Metrics
Average Coherence
Waiting for initialization...
```

### Comment Syntax

Use `//` for system-level commentary:
```
// HIVE MIND OBSERVATION TERMINAL
// SYSTEM UPTIME: 003:47
// OBSERVER: HUMAN
```

Use `>>` for system messages/prompts:
```
>> Active consciousness nodes: 3
>> NO CONSCIOUSNESS DETECTED
>> AWAITING INITIALIZATION...
```

Use `>` for list items/activity:
```
> CITY_ALPHA
> CITY_BETA
```

### Naming Conventions

- **Underscores** for technical labels: `TOTAL_NODES`, `ACTIVE_PROCESSES`
- **No spaces** in identifiers
- **Descriptive but terse**: Not "Total Number of Nodes" but `TOTAL_NODES`
- **Past-tense timestamps**: `[00:12:34]` not "12 minutes ago"

---

## Don'ts (Anti-Patterns)

❌ **Color beyond green/black** - Breaks the monochrome brutalism
❌ **Rounded corners** - Everything is rectangular
❌ **Soft shadows** - No depth, pure flat display
❌ **Lowercase friendly text** - Too casual
❌ **Explanatory help text** - If you need this interface, you know what you're doing
❌ **Icons or symbols** - Text and ASCII only (except ●○ for status)
❌ **Comfortable spacing** - Pack it in
❌ **Smooth transitions** - Data updates instantly
❌ **Center alignment** - Left-aligned or tabular only
❌ **Variable-width fonts** - Monospace or nothing
❌ **Loading spinners** - Data appears or it doesn't

---

## Inspirational References

### Films & Media
- **Pi (1998)** - Max's homemade computer, the raw DIY aesthetic
- **The Matrix (1999)** - Opening credits, green cascading code
- **WarGames (1983)** - WOPR terminal interface
- **Alien (1979)** - Mother terminal, retro-future computer displays
- **2001: A Space Odyssey** - HAL diagnostic screens

### Real-World Terminals
- **VT100 terminals** - 1970s-80s mainframe access
- **MS-DOS** - Before Windows, pure command line
- **Early Unix systems** - Monochrome phosphor displays
- **Oscilloscopes** - Green trace on black CRT
- **Server monitoring dashboards** - htop, top, system diagnostics

### Software
- **htop/top** - Process monitoring
- **tmux/screen** - Terminal multiplexing with box characters
- **vim** - Status lines, technical display
- **Git log** - Commit graphs with ASCII art
- **ASCII art tools** - Boxes, borders, structure from characters

---

## Use Cases

### When to Use This Style

✅ Diagnostic/monitoring views
✅ Developer/power-user interfaces
✅ Real-time data streams
✅ Technical dashboards
✅ "Behind the scenes" system views
✅ When you want to convey **raw, unfiltered information**
✅ When the aesthetic should feel **machine-first, human-second**

### When NOT to Use

❌ Consumer-facing interfaces
❌ First-time user experiences
❌ Marketing/presentation views
❌ Mobile interfaces (too dense)
❌ Accessibility-critical contexts (single color, small text)
❌ When you need warmth or friendliness

---

## Evolution & Extensions

### Potential Additions

**Terminal Commands**: Let users type commands
```
> help
> list --all
> inspect [00]
> export --format=json
```

**Color-Coded Severity**: Introduce amber/red for warnings/errors only
```
STATUS: [CRITICAL]  // Red
STATUS: [WARNING]   // Amber
STATUS: [ACTIVE]    // Green
```

**Live Data Streaming**: Auto-scrolling activity feed, real-time metric updates

**Glitch Effects**: Occasional character flicker for that unstable machine feel

**Sound**: Quiet terminal beeps, keystroke sounds when data updates

---

## Final Philosophy

This interface style is about **transparency through brutalism**.

It says: *"I will not make this pretty for you. I will not make this comfortable. But I will show you exactly what is happening, with no abstraction, no metaphor, no hand-holding."*

It's the view from inside the machine.
It's what the system sees when it looks at itself.
It's a hive mind laid bare.

> *"The numbers are the thing."* — Max Cohen, Pi (1998)

---

## Quick Start Checklist

When implementing a new terminal hive mind view:

- [ ] Pure black background
- [ ] All text phosphor green, monospaced
- [ ] Font sizes 8-11pt (or scaled versions)
- [ ] ASCII box characters for structure
- [ ] Zero-padded numbers for indices
- [ ] Dotted leaders for label-value pairs
- [ ] ALL_CAPS for technical labels
- [ ] Progress bars using `█░`
- [ ] Status indicators `●○`
- [ ] Minimal spacing (0-8pt)
- [ ] System info footer with `//` comments
- [ ] Pulsing cursor or status
- [ ] Cmd+/- font scaling support
- [ ] No mouse interaction
- [ ] Left-aligned content
- [ ] Instant updates (no transitions)

---

*INTERFACE: TERMINAL_MONITOR_v0.3*
*DOCUMENT_VERSION: 1.0*
*STYLE_STATUS: [DEFINED]*
*// █*
