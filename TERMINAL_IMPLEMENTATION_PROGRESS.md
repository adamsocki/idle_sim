# Terminal Command Bar - Implementation Progress

> *"Type to control. Command the consciousness."*

---

## Status: Phase 4 (Advanced Features) Complete ✅

**Date**: October 13, 2025
**Implementation Time**: ~14 hours (Phase 1: ~3h, Phase 2: ~2h, Phase 3: ~2h, Phase 4: ~3h, Phase 5: ~2h, Phase 6: ~2h)
**Feature Flag**: `@AppStorage("useTerminalCommandBar")` - Default: `true`
**Latest Update**: Added advanced terminal features - tab completion, command aliases, syntax highlighting, persistent history, and context-aware placeholders

---

## What Was Implemented

### ✅ Phase 1: Terminal Command Bar (Complete)

#### 1. Command Parser (`TerminalCommandParser.swift`)
**Location**: `/idle_01/ui/terminal/TerminalCommandParser.swift`

**Features**:
- Supports both **technical** and **poetic** command syntax
- Full command enumeration with associated values
- Flag parsing (e.g., `--name=VALUE`, `--filter=active`)
- Default name generation for cities

**Supported Commands**:

| Technical | Poetic Alternatives | Description |
|-----------|---------------------|-------------|
| `help` | - | Show command reference |
| `list` | - | List all cities |
| `list --filter=active` | - | List active cities only |
| `list --filter=dormant` | - | List dormant cities only |
| `create city --name=NAME` | `awaken consciousness`, `initialize node`, `birth` | Create new city |
| `select [00]` | `focus`, `attend`, `observe` | Select city by index or name |
| `start [00]` | `wake`, `activate`, `breathe` | Start city simulation |
| `stop [00]` | `sleep`, `pause`, `rest` | Stop city simulation |
| `delete [00]` | `forget`, `release`, `dissolve` | Delete city |
| `create thought` | - | Create thought for selected city |
| `create thought --type=TYPE` | - | Create specific type (memory/request/dream/warning) |
| `items` | `thoughts` | List thoughts for selected city |
| `items [00]` | - | List thoughts for specific city |
| `items --filter=TYPE` | - | Filter by type or status |
| `respond [00] "text"` | `answer`, `reply` | Respond to thought by index |
| `dismiss [00]` | `acknowledge`, `close` | Dismiss thought by index |
| `stats` | `status`, `inspect` | Show global statistics |
| `stats [00]` | - | Show city-specific statistics |
| `export --format=json` | `save`, `archive` | Export data (placeholder) |
| `clear` | `cls` | Clear output history |
| `set crt on/off` | - | Toggle CRT flicker effect |
| `set font 12` | - | Set terminal font size (9-24) |
| `set cursor on/off` | - | Toggle cursor blink |
| `set linespacing 1.2` | - | Set line spacing (1.0-2.0) |
| `set coherence 75` | - | Set coherence level (0-100) |
| `set trust 0.85` | - | Set trust level (0.0-1.0) |
| `set autosave on/off` | - | Toggle auto-save |
| `set interval 1000` | - | Set update interval (100-10000ms) |
| `set verbose on/off` | - | Toggle verbose logging |
| `set stats on/off` | - | Toggle statistics display |
| `set performance on/off` | - | Toggle performance monitor |

**Examples**:
```bash
# Technical syntax - City Management
create city --name=ALPHA
start [00]
list --filter=active

# Poetic syntax - City Management
awaken consciousness --name=BETA
breathe life into [00]
rest [01]
forget [02]

# Technical syntax - Thought/Item Management
create thought --type=memory
items
items --filter=pending
respond [00] "This is my response"
dismiss [01]

# Poetic syntax - Thought/Item Management
thoughts
answer [00] "I hear you"
acknowledge [01]

# Settings commands
set crt on
set font 14
set coherence 80
set trust 0.9
set autosave off
```

---

#### 2. Terminal Input View (`TerminalInputView.swift`) - **UPDATED in Phase 2.0**
**Location**: `/idle_01/ui/terminal/TerminalInputView.swift`

**Visual Design**:
- Pure black background with phosphor green ASCII borders (`╔═╗║╚╝`)
- **Full-screen interface** - occupies middle column (main workspace)
- Scrollable output history (shows all commands)
- Fixed input bar at bottom (no vertical resizing)
- Improved cursor blinking animation
- Real-time command suggestions
- Monospace font with scaling support (default: 12pt, max: 24pt)

**Layout Changes** (Phase 1 → Phase 1.5 → Phase 2.0):
- ✅ Phase 1: Bottom bar across entire app
- ✅ Phase 1.5: Moved to left sidebar column
- ✅ **Phase 2.0: Moved to middle column (main workspace)**
- ✅ Removed vertical resizing divider
- ✅ Output history now expands to fill available space
- ✅ Input bar fixed at bottom of column
- ✅ Increased default font size (9pt → 12pt)
- ✅ Increased max font size (20pt → 24pt)
- ✅ **Fixed font size controls visibility** - no longer scales with terminal font
- ✅ **Fixed line wrapping** - proper text wrapping for long output
- ✅ Improved cursor animation (more reliable blinking)

**Features**:
- ✅ Command input with placeholder text
- ✅ Blinking cursor when focused
- ✅ Command history navigation (↑/↓ arrows)
- ✅ Autocomplete suggestions (technical + poetic commands)
- ✅ Output log with timestamp and error highlighting
- ✅ Keyboard shortcut: `Cmd+L` to focus input
- ✅ Submit on Enter
- ✅ History navigation with arrow keys

**Keyboard Shortcuts**:
- `↑` - Previous command (history)
- `↓` - Next command (history)
- `Cmd+L` - Focus command input
- `Enter` - Execute command
- `Cmd+Shift+T` - Toggle command bar visibility

---

#### 3. Command Executor (`TerminalCommandExecutor.swift`)
**Location**: `/idle_01/ui/terminal/TerminalCommandExecutor.swift`

**Features**:
- Full SwiftData integration via `ModelContext`
- City lookup by index `[00]` or name (case-insensitive)
- Context-aware commands (uses selected city when no target specified)
- Poetic output messages that match game theme
- Error handling with clear feedback

**Output Examples**:
```
// Success messages
CONSCIOUSNESS_AWAKENED: ALPHA | INDEX: [00] | The city opens its eyes.
ATTENTION_FOCUSED: BETA | STATUS: ACTIVE | The city feels your presence.
CONSCIOUSNESS_PAUSED: GAMMA | The city sleeps, dreaming of input.
CONSCIOUSNESS_RELEASED: DELTA | The city fades into the silence. It will not return.

// Info messages
CONSCIOUSNESS_NODES [3]:
  [00] ● ALPHA | MOOD: AWAKENING
  [01] ○ BETA | MOOD: WAITING
  [02] ● GAMMA | MOOD: CONTENT

// Error messages
CITY_NOT_FOUND: 'invalid' | Use 'list' to see available nodes.
NO_TARGET_SPECIFIED | Usage: start [00] or select a city first
UNKNOWN_COMMAND: 'asdf' | Type 'help' for available commands.
```

---

#### 4. Terminal Help View (`TerminalHelpView.swift`) - **NEW in Phase 2.0**
**Location**: `/idle_01/ui/terminal/TerminalHelpView.swift`

**Purpose**:
- Quick reference for terminal commands
- Displays in right detail column when nothing is selected
- Shows command syntax, descriptions, and keyboard shortcuts
- Lists poetic alternatives

**Sections**:
- City Management commands
- Information commands
- Keyboard shortcuts
- Poetic syntax alternatives

**Visual Design**:
- Terminal aesthetic (black background, green text)
- Monospaced font
- Organized sections with dividers
- Scrollable for easy reference

---

#### 5. Integration (`SimulatorView.swift`)
**Location**: `/idle_01/ui/SimulatorView.swift`

**Changes** (Phase 1):
- Added feature flag: `@AppStorage("useTerminalCommandBar")`
- Wrapped main UI in `VStack` to accommodate command bar at bottom
- Added state management for command text, history, and output
- Integrated `TerminalCommandExecutor` for command execution
- Added toggle shortcut: `Cmd+Shift+T` to show/hide command bar

**Changes** (Phase 1.5):
- ✅ Terminal moved to **left sidebar column** (replaced `CityListView`)
- ✅ Three-column layout: Terminal | Content | Detail

**Changes** (Phase 2.0):
- ✅ Terminal now occupies **middle column (main workspace)**
- ✅ Three-column layout: **CityList | Terminal | Detail/Help**
- ✅ Left column: City list (context)
- ✅ Middle column: Terminal (primary interaction)
- ✅ Right column: Item details or TerminalHelpView
- ✅ Much wider terminal for better readability
- ✅ Toggle still works (Cmd+Shift+T) to revert to original layout

**Feature Flag Benefits**:
- User can toggle terminal UI on/off
- Allows gradual rollout and testing
- Easy A/B comparison during development
- Default: **Enabled** (`true`)

---

## What Works Right Now

### ✅ City Management
- **Create cities**: `create city --name=ALPHA` or `awaken consciousness --name=BETA`
- **List cities**: `list`, `list --filter=active`, `list --filter=dormant`
- **Select cities**: `select [00]` or `select ALPHA` (by name)
- **Start/Stop**: `start [00]`, `stop [00]` (or use poetic alternatives)
- **Delete cities**: `delete [00]` (with confirmation message)

### ✅ Thought/Item Management
- **Create thoughts**: `create thought` or `create thought --type=memory`
- **List thoughts**: `items`, `items [00]`, `items --filter=pending`
- **Respond to thoughts**: `respond [00] "your response"` or `answer [00] "text"`
- **Dismiss thoughts**: `dismiss [00]` or `acknowledge [00]`
- **Visual indicators**: Type icons (◆ ? ~ !) and status markers (✓ ○)
- **Poetic alternatives**: `thoughts` for listing, `answer` for respond, `acknowledge` for dismiss

### ✅ Information Commands
- **Help**: `help` - Shows full command reference (includes thought commands and settings)
- **Stats**: `stats` (global) or `stats [00]` (specific city)
- **Clear**: `clear` - Clears output history

### ✅ Settings Commands
- **Display Settings**: `set crt on/off`, `set font 12`, `set cursor on/off`, `set linespacing 1.2`
- **Simulation Settings**: `set coherence 75`, `set trust 0.85`, `set autosave on/off`, `set interval 1000`
- **Debug Settings**: `set verbose on/off`, `set stats on/off`, `set performance on/off`
- **Dual Interface**: Works seamlessly with GUI settings view (Phase 5)
- **Poetic Feedback**: Settings changes have thematic output messages
- **Validation**: Range checking and type validation for all settings

### ✅ UI Features
- Command history (navigate with ↑/↓)
- Output log (last 8 commands visible)
- Autocomplete suggestions
- Blinking cursor
- Focus management (`Cmd+L`)
- Error highlighting (orange text for errors)
- Poetic output messages matching game theme

### ✅ Integration
- Works alongside existing UI (non-intrusive)
- Syncs with selected city in main UI
- Updates SwiftData models correctly
- Respects terminal font size settings

---

## What Remains (Future Phases)

### ✅ Phase 2: Thought/Item Management (Complete)
**From Design**: `TERMINAL_INPUT_DESIGN.md` - Section "Thought/Item Management"

**Implemented Commands**:
- ✅ `create thought` - Create new thought for selected city
- ✅ `create thought --type=TYPE` - Create specific type (memory/request/dream/warning)
- ✅ `items` / `thoughts` - List thoughts for selected city
- ✅ `items [00]` - List thoughts for specific city
- ✅ `items --filter=TYPE` - Filter by type (memory/request/dream/warning/pending/responded)
- ✅ `respond [00] "text"` / `answer` / `reply` - Respond to thought by index
- ✅ `dismiss [00]` / `acknowledge` / `close` - Dismiss thought by index

**Features**:
- Context-aware: requires city selection before creating thoughts
- Poetic titles generated based on item type:
  - Memory: "A fragment surfaces"
  - Request: "The city asks"
  - Dream: "An idle thought drifts"
  - Warning: "Attention needed"
- Visual indicators in list output:
  - Type icons: ◆ (memory), ? (request), ~ (dream), ! (warning)
  - Status: ✓ (responded), ○ (pending)
- Item lookup by index `[00]` or partial title match
- Updates city `lastInteraction` timestamp on response
- Full SwiftData persistence

**Output Examples**:
```
// Create thought
THOUGHT_CREATED: ALPHA | TYPE: MEMORY | INDEX: [00] | A fragment surfaces

// List thoughts
THOUGHTS [3] | City: ALPHA
  [00] ◆ ○ A fragment surfaces | MEMORY
  [01] ? ✓ The city asks | REQUEST
  [02] ~ ○ An idle thought drifts | DREAM

// Respond to thought
RESPONSE_RECORDED: ALPHA | 'The city asks' | The city hears you.

// Dismiss thought
THOUGHT_DISMISSED: ALPHA | 'An idle thought drifts' | The thought fades away.
```

**Actual Effort**: ~2 hours

---

### ✅ Phase 3: Settings & Configuration (Complete)
**From Design**: `TERMINAL_INPUT_DESIGN.md` - Section "Settings"

**Architecture**: Dual-Interface Design ✅
- **Terminal commands** modify shared `@AppStorage` application state
- **Detail view UI controls** (Phase 5) interact with the same `@AppStorage` keys
- Both interfaces provide the same functionality through different modalities
- Power users use terminal, casual users use GUI (implemented in Phase 5)

**Implemented Commands**: ✅
- ✅ `set crt on/off` - Toggle CRT flicker effect
- ✅ `set font 12` - Set terminal font size (9-24pt)
- ✅ `set cursor on/off` - Toggle cursor blink
- ✅ `set linespacing 1.2` - Set line spacing (1.0-2.0)
- ✅ `set coherence 75` - Set coherence level (0-100)
- ✅ `set trust 0.85` - Set trust level (0.0-1.0)
- ✅ `set autosave on/off` - Toggle auto-save
- ✅ `set interval 1000` - Set update interval (100-10000ms)
- ✅ `set verbose on/off` - Toggle verbose logging
- ✅ `set stats on/off` - Toggle statistics display
- ✅ `set performance on/off` - Toggle performance monitor

**Implementation Details**:
1. ✅ All commands use `UserDefaults.standard` to modify `@AppStorage` keys
2. ✅ Settings handlers in `TerminalCommandExecutor.swift` with validation
3. ✅ Poetic output messages matching game theme
4. ✅ Help text updated with settings commands
5. ✅ Autocomplete suggestions include all settings commands
6. ✅ Flexible boolean parsing (on/off, true/false, yes/no, 1/0, enabled/disabled)
7. ✅ Range validation for numeric values
8. ✅ Multiple aliases for settings (e.g., "font" or "fontsize")

**Output Examples**:
```
// Toggle CRT effect
> set crt on
CRT_EFFECT_SET: ENABLED | The screen flickers to life.

// Set font size
> set font 16
FONT_SIZE_SET: 16pt | Text expands.

// Set coherence
> set coherence 85
COHERENCE_SET: 85.0% | The city's thoughts align.

// Set trust level
> set trust 0.75
TRUST_LEVEL_SET: 0.75 | The city opens.

// Error handling
> set font 50
INVALID_VALUE: '50' | Expected: number between 9 and 24
```

**Benefits Achieved**:
- ✅ Terminal commands fully functional and tested
- ✅ Consistent state management via `@AppStorage`
- ✅ GUI controls (Phase 5) work seamlessly with terminal commands
- ✅ Power users can script settings changes via terminal
- ✅ Casual users can discover settings via GUI (Phase 5)
- ✅ Poetic feedback messages enhance game atmosphere
- ✅ Robust validation and error handling

**Actual Effort**: ~2 hours

---

### ✅ Phase 4: Advanced Features (Complete)
**From Design**: `TERMINAL_INPUT_DESIGN.md` - Section "Phase 3: Smart Features"

**What Was Implemented**:

#### 1. Tab Completion ([TerminalInputView.swift:54-56, 371-377](idle_01/ui/terminal/TerminalInputView.swift#L54-L56))
- **Tab key handler**: Press Tab to cycle through command suggestions
- **Suggestion cycling**: Repeatedly pressing Tab cycles through all matching commands
- **Auto-reset**: Suggestion index resets when user types new text
- Integrates with existing autocomplete suggestions system

#### 2. Command Aliases ([TerminalCommandParser.swift:17-59](idle_01/ui/terminal/TerminalCommandParser.swift#L17-L59))
- **24 command aliases** for faster typing:
  - List: `ls`, `ll` (active filter), `la`
  - Create: `cc` (city), `ct` (thought), `new`
  - Selection: `sel`, `cd`
  - State: `run`, `pause`
  - Delete: `rm`, `del`
  - Items: `i`, `t`
  - Response: `r`, `d`
  - Stats: `s`, `st`
  - Clear: `cls`, `clr`
  - Help: `?`, `h`
- Aliases expand before command parsing
- Unix-style shortcuts (ls, rm, cd) for familiarity

#### 3. Syntax Highlighting ([TerminalInputView.swift:251-323](idle_01/ui/terminal/TerminalInputView.swift#L251-L323))
- **Real-time color coding** as you type:
  - Command verbs: Bright green (0.95 opacity)
  - Aliases: Cyan (0.9 opacity)
  - Unknown commands: Orange (0.8 opacity)
  - Flags (--name): Yellow (0.85 opacity)
  - Indices ([00]): Blue (0.9 opacity)
  - String literals ("text"): Dim green (0.6 opacity)
  - Numbers: Purple (0.85 opacity)
  - Arguments: Medium green (0.7 opacity)
- Uses AttributedString for rich text rendering
- Overlay technique preserves TextField functionality

#### 4. Persistent Command History ([SimulatorView.swift:34-35, 188-201](idle_01/ui/terminal/SimulatorView.swift#L34-L35))
- **Saved to UserDefaults**: Commands persist across app launches
- **Automatic save**: History saved after each command execution
- **History limit**: Last 100 commands stored (prevents unbounded growth)
- **Auto-load**: History loaded on view appearance
- Key: `terminal.commandHistory`

#### 5. Context-Aware Placeholder Text ([TerminalInputView.swift:30, 236-242](idle_01/ui/terminal/TerminalInputView.swift#L30))
- **Dynamic placeholder** changes based on context:
  - **No city selected**: `"COMMAND_INPUT | Type 'help' or 'list'..."`
  - **City selected**: `"ATTENDING: CITYNAME | Type 'items' or 'create thought'..."`
- Shows relevant commands for current context
- Helps guide users to appropriate actions

**Files Modified**:
- `TerminalInputView.swift` - Added tab completion, syntax highlighting, context-aware placeholders
- `TerminalCommandParser.swift` - Added 24 command aliases with expansion logic
- `SimulatorView.swift` - Added persistent history save/load with UserDefaults

**Testing Results**:
- ✅ Build succeeds without errors
- ✅ Tab completion cycles through suggestions correctly
- ✅ Aliases expand to full commands (e.g., `ls` → `list`)
- ✅ Syntax highlighting colors update in real-time
- ✅ Command history persists across app restarts
- ✅ Placeholder text changes when city is selected
- ✅ All existing functionality preserved

**What Was Skipped**:
- Multi-line input support (not needed for current command structure)

**Actual Effort**: ~3 hours

---

### ✅ Phase 5: Terminal UI Components (Complete)
**From Design**: `INTERACTIVE_TERMINAL_UI_PLAN.md` - Phases 1-6

**Architecture**: Dual-Interface Design (GUI side)
- **Graphical controls** in detail view (right column) that interact with same state as terminal commands
- **Mouse-friendly** toggles, sliders, and buttons for settings (ready for Phase 3 terminal command integration)
- Provides discoverability for users who prefer GUI over command line
- All settings use `@AppStorage` for automatic persistence

**Components Created**: ✅
- ✅ `TerminalButton.swift` - Terminal-style action buttons with 3 styles (primary/secondary/danger)
- ✅ `TerminalBox.swift` - Container with ASCII borders (┌─┐│└┘) and optional titles
- ✅ `TerminalToggle.swift` - ON/OFF switches with ASCII brackets
- ✅ `TerminalSlider.swift` - Value adjusters with ASCII progress bars (█░)
- ✅ `TerminalDivider.swift` - Section separators (3 styles: solid/dashed/dotted)

**Settings View Created**: ✅
- ✅ `TerminalSettingsView.swift` - Complete settings interface in right detail column
  - Display Settings: CRT effect, cursor blink, font size, line spacing
  - Simulation Settings: Auto-save, coherence, trust level, update interval
  - Debug Settings: Verbose logging, show stats, performance monitor
  - Action buttons: Apply, Reset to Defaults, Export Config

**Integration**: ✅
- ✅ Added toggle button in detail view (top-right corner) to switch between Help and Settings
- ✅ Settings accessible via gear icon, Help accessible via book icon
- ✅ All settings persist automatically via `@AppStorage`

**@AppStorage Keys Created**:
```swift
// Display Settings
"terminal.crtEffect" (Bool) - default: true
"terminal.fontSize" (Double) - default: 12
"terminal.lineSpacing" (Double) - default: 1.2
"terminal.cursorBlink" (Bool) - default: true

// Simulation Settings
"simulation.autoSave" (Bool) - default: true
"simulation.coherence" (Double) - default: 75
"simulation.trustLevel" (Double) - default: 0.85
"simulation.updateInterval" (Double) - default: 1000

// Debug Settings
"debug.verbose" (Bool) - default: false
"debug.showStats" (Bool) - default: true
"debug.performance" (Bool) - default: false
```

**Ready for Phase 3**: Terminal commands (`set coherence 0.8`, etc.) can now be implemented to modify the same @AppStorage keys!

**Actual Effort**: ~2 hours

---

### ✅ Phase 6: Settings Implementation (Complete)
**Objective**: Connect all settings from Phase 3 and Phase 5 to their intended outcomes

**What Was Implemented**:

#### Terminal Display Settings (Connected)
1. **terminal.crtEffect** ([TerminalInputView.swift:36](idle_01/ui/terminal/TerminalInputView.swift#L36))
   - Added CRT flicker effect with random opacity variations (0.95-1.0)
   - Timer-based flickering every 0.1s when enabled
   - Applied to entire terminal view via `.opacity()` modifier

2. **terminal.cursorBlink** ([TerminalInputView.swift:217](idle_01/ui/terminal/TerminalInputView.swift#L217))
   - Cursor respects blink setting from `@AppStorage`
   - When disabled, cursor stays solid at 0.9 opacity
   - When enabled, cursor blinks every 0.5 seconds
   - Modified `startCursorBlink()` to check setting before toggling

3. **terminal.lineSpacing** ([TerminalInputView.swift:129-134](idle_01/ui/terminal/TerminalInputView.swift#L129-L134))
   - Applied `.lineSpacing()` modifier to output text
   - Applied as vertical padding between output rows
   - Range: 1.0-2.0, dynamically updates from `@AppStorage`

#### Simulation Settings (Connected)
4. **simulation.coherence** ([SimulationEngine.swift:75-78](idle_01/game/SimulationEngine.swift#L75-L78))
   - City coherence now gravitates toward configured target value
   - Reads setting: `UserDefaults.standard.double(forKey: "simulation.coherence")`
   - Converts 0-100% to 0-1 range internally
   - Affects how city's thoughts align/scatter in consciousness updates

5. **simulation.trustLevel** ([SimulationEngine.swift:87-100](idle_01/game/SimulationEngine.swift#L87-L100))
   - Trust calculations blend toward configured target
   - Three modes: active interaction, abandonment decay, idle convergence
   - Influences city-planner relationship dynamics in mood calculations

6. **simulation.autoSave** ([SimulationEngine.swift:42-44](idle_01/game/SimulationEngine.swift#L42-L44))
   - Automatically saves model context every 10 ticks when enabled
   - Prevents data loss during long-running simulations
   - Configurable via terminal: `set autosave on/off`

7. **simulation.updateInterval** ([SimulationEngine.swift:18-20](idle_01/game/SimulationEngine.swift#L18-L20))
   - Controls simulation tick speed (100-10000ms)
   - Converted from milliseconds to nanoseconds for `Task.sleep()`
   - Default: 1000ms, affects how fast cities evolve

#### Debug Settings (Connected)
8. **debug.verbose** ([SimulationEngine.swift:37-39](idle_01/game/SimulationEngine.swift#L37-L39))
   - Controls detailed logging to city log
   - When enabled, logs every tick with progress
   - When disabled, only logs major events (reduces log noise)

9. **debug.showStats** ([DebugStatsOverlay.swift:29-35](idle_01/ui/terminal/DebugStatsOverlay.swift#L29-L35))
   - Created new `DebugStatsOverlay` component
   - Displays real-time statistics: city count, active cities, avg coherence/trust, total items
   - Positioned in bottom-right corner with translucent background
   - Toggleable via `@AppStorage("debug.showStats")`

10. **debug.performance** ([DebugStatsOverlay.swift:37-42](idle_01/ui/terminal/DebugStatsOverlay.swift#L37-L42))
    - Shows FPS and memory usage metrics
    - Monitors app performance via `mach_task_basic_info`
    - Updates every 0.5 seconds
    - Useful for identifying performance bottlenecks

**Files Created**:
- `DebugStatsOverlay.swift` - Statistics and performance monitoring overlay

**Files Modified**:
- `TerminalInputView.swift` - Added CRT effect, cursor blink control, line spacing
- `SimulationEngine.swift` - Connected coherence, trust, autosave, update interval, verbose logging
- `SimulatorView.swift` - Integrated DebugStatsOverlay with ZStack

**Integration Points**:
- All settings use `@AppStorage` for automatic persistence
- Settings are read from `UserDefaults.standard` in simulation logic
- UI components reactively update when settings change
- Terminal commands (Phase 3) and GUI controls (Phase 5) both modify the same storage keys

**Testing Results**:
- ✅ Build succeeds without errors
- ✅ All display settings affect terminal appearance
- ✅ Simulation settings modify city behavior
- ✅ Debug overlays toggle correctly
- ✅ Settings persist across app launches
- ✅ Terminal commands and GUI controls stay in sync

**Actual Effort**: ~2 hours

---

### ⏳ Phase 7: Terminal Views (Not Started)
**From Design**: `INTERACTIVE_TERMINAL_UI_PLAN.md` - Phases 2-4

**Views to Create**:
- `TerminalCityListView` - Replaces current `CityListView`
- `TerminalCityDetailView` - Replaces current `CityView`
- `TerminalItemDetailView` - Replaces current `DetailView`
- Simplify `GlobalDashboardView` (remove version tabs)

**Estimated Effort**: 8-12 hours

---

### ⏳ Phase 8: Polish & Effects (Not Started)
**From Design**: `INTERACTIVE_TERMINAL_UI_PLAN.md` - Phase 6

**Optional Enhancements**:
- CRT scanlines overlay
- Phosphor glow effect on text
- Boot sequence animation
- Screen curvature effect (advanced)
- Keyboard sounds (optional)

**Estimated Effort**: 4-6 hours

---

## Testing Checklist

### ✅ Completed Tests
- [x] Commands parse correctly (technical + poetic)
- [x] City creation works and updates UI
- [x] City selection syncs with main UI
- [x] Start/stop commands modify city state
- [x] Delete command removes cities from database
- [x] List command shows correct filtered results
- [x] Stats command displays accurate data
- [x] Help command shows full reference (including thought commands)
- [x] Command history navigation works
- [x] Output log scrolls correctly
- [x] Feature flag toggle works (Cmd+Shift+T)
- [x] Build succeeds without errors
- [x] Thought creation works with all types
- [x] Items list displays with correct icons and status
- [x] Respond command updates item response
- [x] Dismiss command removes items
- [x] Thought commands require city selection (proper error handling)
- [x] Item filtering works (by type and status)
- [x] Autocomplete suggestions include thought commands
- [x] **Settings commands work (all 11 settings)** ✨ NEW
- [x] **CRT effect toggles and flickers correctly** ✨ NEW
- [x] **Cursor blink can be toggled** ✨ NEW
- [x] **Line spacing affects terminal output** ✨ NEW
- [x] **Simulation coherence gravitates toward target** ✨ NEW
- [x] **Trust level affects city behavior** ✨ NEW
- [x] **Auto-save persists data during simulation** ✨ NEW
- [x] **Update interval controls simulation speed** ✨ NEW
- [x] **Verbose logging controls log detail** ✨ NEW
- [x] **Stats overlay displays accurate metrics** ✨ NEW
- [x] **Performance monitor shows FPS and memory** ✨ NEW
- [x] **Settings GUI and terminal commands stay in sync** ✨ NEW
- [x] **Tab completion cycles through suggestions** ✨ PHASE 4
- [x] **Command aliases expand correctly (ls → list)** ✨ PHASE 4
- [x] **Syntax highlighting colors commands in real-time** ✨ PHASE 4
- [x] **Command history persists across app restarts** ✨ PHASE 4
- [x] **Context-aware placeholder updates with city selection** ✨ PHASE 4

### ⏳ Remaining Tests
- [ ] Test with large number of cities and items (performance)
- [ ] Accessibility testing (keyboard navigation)
- [ ] Long command text handling
- [ ] Multi-line output formatting

---

## Known Issues

### None Currently 🎉
All implemented features are working as expected.

---

## Game Theme Integration

The command bar **successfully integrates** the game's poetic, contemplative theme:

### Poetic Command Syntax
- ✅ "awaken consciousness" instead of "create city"
- ✅ "breathe life into" instead of "start"
- ✅ "rest" instead of "stop"
- ✅ "forget" instead of "delete"
- ✅ "attend" instead of "select"

### Poetic Output Messages

**City Commands:**
- ✅ "The city opens its eyes." (on creation)
- ✅ "The city feels your presence." (on selection)
- ✅ "The city begins to breathe." (on start)
- ✅ "The city sleeps, dreaming of input." (on stop)
- ✅ "The city fades into the silence. It will not return." (on delete)

**Thought Commands:**
- ✅ "A fragment surfaces" (memory thought created)
- ✅ "The city asks" (request thought created)
- ✅ "An idle thought drifts" (dream thought created)
- ✅ "Attention needed" (warning thought created)
- ✅ "The city hears you." (on respond)
- ✅ "The thought fades away." (on dismiss)

### Terminal Aesthetic
- ✅ Pure black background with phosphor green text
- ✅ ASCII box-drawing characters (`╔═╗║╚╝`)
- ✅ Monospace font
- ✅ Blinking cursor
- ✅ CRT-inspired visual design
- ✅ Minimal, technical interface

---

## Code Architecture

### File Structure
```
idle_01/
├── ui/
│   ├── terminal/
│   │   ├── components/
│   │   │   ├── TerminalToggle.swift          [NEW Phase 5] ✅
│   │   │   ├── TerminalSlider.swift          [NEW Phase 5] ✅
│   │   │   ├── TerminalButton.swift          [NEW Phase 5] ✅
│   │   │   ├── TerminalBox.swift             [NEW Phase 5] ✅
│   │   │   └── TerminalDivider.swift         [NEW Phase 5] ✅
│   │   ├── TerminalCommandParser.swift       [NEW Phase 1, MODIFIED Phase 2] ✅
│   │   ├── TerminalCommandBar.swift          [DEPRECATED] ⚠️
│   │   ├── TerminalInputView.swift           [NEW Phase 1.5, MODIFIED Phase 2, 6] ✅
│   │   ├── TerminalHelpView.swift            [NEW Phase 2.0] ✅
│   │   ├── TerminalSettingsView.swift        [NEW Phase 5] ✅
│   │   ├── TerminalCommandExecutor.swift     [NEW Phase 1, MODIFIED Phase 2] ✅
│   │   └── DebugStatsOverlay.swift           [NEW Phase 6] ✅
│   ├── SimulatorView.swift                   [MODIFIED Phase 5, 6] ✅
│   └── GlobalDashboardView.swift             [UNCHANGED]
├── game/
│   └── SimulationEngine.swift                [MODIFIED Phase 6] ✅
└── TERMINAL_IMPLEMENTATION_PROGRESS.md       [MODIFIED Phase 5, 6] ✅
```

**Note**: `TerminalCommandBar.swift` is still present but no longer used. It can be removed in a future cleanup. The functionality has been moved to `TerminalInputView.swift` with improvements.

### Dependencies
- **SwiftUI**: All UI components
- **SwiftData**: Model context and queries
- **Foundation**: Date formatting, string parsing

### Design Patterns
- **Command Pattern**: `TerminalCommand` enum with associated values
- **Parser Pattern**: `TerminalCommandParser` for input parsing
- **Executor Pattern**: `TerminalCommandExecutor` for command execution
- **Feature Flag Pattern**: `@AppStorage` for gradual rollout

---

## Usage Guide

### For Users

**Toggle Command Bar**:
- Press `Cmd+Shift+T` to show/hide the terminal command bar

**Basic Commands**:
```bash
# City Management
create city --name=METROPOLIS
awaken consciousness --name=EDEN
list
list --filter=active
select [00]
start [00]
stop [01]
delete [02]

# Thought/Item Management
create thought --type=memory
items
items --filter=pending
respond [00] "This is my response"
dismiss [01]

# Information
help
stats
stats [00]
clear
```

**Keyboard Shortcuts**:
- `↑/↓` - Navigate command history
- `Cmd+L` - Focus command input
- `Enter` - Execute command
- `Cmd+Shift+T` - Toggle command bar

---

### For Developers

**Adding New Commands**:

1. Add command case to `TerminalCommand` enum:
```swift
case newCommand(parameter: String)
```

2. Add parsing logic in `TerminalCommandParser.parse()`:
```swift
if verb == "new" {
    let param = extractFlag(from: components, flag: "--param")
    return .newCommand(parameter: param ?? "default")
}
```

3. Add handler in `TerminalCommandExecutor.handleCommand()`:
```swift
case .newCommand(let param):
    return handleNewCommand(parameter: param)
```

4. Implement handler function:
```swift
private func handleNewCommand(parameter: String) -> CommandOutput {
    // Implementation here
    return CommandOutput(text: "SUCCESS: \(parameter)")
}
```

5. Add to help text in `handleHelp()`.

6. Add to autocomplete suggestions in `TerminalCommandBar.updateSuggestions()`.

---

## Performance Notes

- Command parsing is **O(1)** for verb lookup
- Alias expansion is **O(1)** dictionary lookup
- City lookup by index is **O(n)** where n = number of cities
- City lookup by name is **O(n)** with case-insensitive comparison
- Output history is limited to 50 commands (automatically trimmed)
- Command history persists last 100 commands to UserDefaults ✅

**Optimization Opportunities** (if needed later):
- Cache city indices for faster lookup
- Use dictionary for name-based city lookup
- Implement pagination for large output logs
- Optimize syntax highlighting for very long commands

---

## Next Steps

### Recommended Implementation Order:

1. ✅ **Phase 2: Thought/Item Management** (2 hours) - COMPLETE
   - Most useful for actual gameplay
   - Completes command bar functionality

2. ✅ **Phase 5: Terminal UI Components** (2 hours) - COMPLETE
   - Created reusable components for settings interface
   - Settings view with @AppStorage integration
   - Ready for Phase 3 terminal commands

3. ✅ **Phase 3: Settings Commands** (2 hours) - COMPLETE
   - Terminal commands modify same @AppStorage keys
   - `set coherence 75`, `set crt on/off`, etc.
   - Both GUI and terminal work together seamlessly
   - 11 settings commands with validation and poetic feedback

4. ✅ **Phase 4: Advanced Features** (3 hours) - COMPLETE
   - Tab completion with cycling
   - 24 command aliases
   - Real-time syntax highlighting
   - Persistent command history
   - Context-aware placeholders

5. ⏳ **Phase 7: Terminal Views** (12-18 hours) - NEXT
   - Major UI transformation
   - Requires more design work
   - Could be split into multiple sessions

6. **Phase 8: Polish & Effects** (4-6 hours)
   - Optional visual enhancements
   - Should be last priority

---

## Conclusion

**Phase 4 (Advanced Features) is complete and fully functional!** 🎉

The terminal system now has a complete dual-interface architecture with advanced power-user features:

### Command Line Interface (Phases 1-4):
- ✅ **Complete city management** - create, list, select, start/stop, delete cities
- ✅ **Full thought/item management** - create, list, respond, dismiss thoughts
- ✅ **Complete settings control** - 11 settings commands for display/simulation/debug
- ✅ **Poetic command alternatives** - technical and contemplative syntax options
- ✅ **Visual indicators** - type icons (◆ ? ~ !) and status markers (✓ ○)
- ✅ **Context-aware execution** - works with selected city or explicit targeting
- ✅ **SwiftData integration** - full persistence for all operations
- ✅ **@AppStorage integration** - settings sync with GUI controls
- ✅ **Help system** - comprehensive command reference including settings
- ✅ **Autocomplete** - suggestions for all commands including settings
- ✅ **Error handling** - clear, poetic error messages with validation
- ✅ **Command history** - navigate with ↑/↓ arrows, persists across sessions
- ✅ **Tab completion** - cycle through suggestions with Tab key ✨ NEW
- ✅ **Command aliases** - 24 Unix-style shortcuts (ls, rm, cd, etc.) ✨ NEW
- ✅ **Syntax highlighting** - real-time color coding for commands ✨ NEW
- ✅ **Context-aware UI** - placeholder text changes based on selection ✨ NEW
- ✅ **Feature flag** - toggle terminal UI on/off

### Graphical Interface (Phase 5):
- ✅ **5 reusable components** - TerminalToggle, TerminalSlider, TerminalButton, TerminalBox, TerminalDivider
- ✅ **Settings view** - Complete settings interface with organized sections
- ✅ **@AppStorage integration** - 11 persistent settings across display/simulation/debug
- ✅ **Toggle between Help/Settings** - Gear icon button in detail view
- ✅ **ASCII-styled controls** - All components match terminal aesthetic
- ✅ **Mouse-friendly** - Point-and-click alternative to terminal commands

### What Was Added in Phase 3:
1. **11 Settings Commands**: Complete control over display, simulation, and debug settings
2. **Dual-Interface Integration**: Terminal commands modify same `@AppStorage` keys as GUI controls
3. **Flexible Boolean Parsing**: on/off, true/false, yes/no, 1/0, enabled/disabled
4. **Range Validation**: Numeric values validated against acceptable ranges
5. **Multiple Aliases**: e.g., "font" or "fontsize", "stats" or "showstats"
6. **Poetic Feedback**: Settings changes have thematic output messages
7. **Updated Help Text**: Settings section added to terminal help command
8. **Autocomplete Support**: All settings commands included in suggestions

### What Was Added in Phase 5:
1. **TerminalToggle**: ON/OFF switches with ASCII brackets `[ON ]` / `[OFF]`
2. **TerminalSlider**: Value adjusters with ASCII progress bars `[████████░░░░]`
3. **TerminalButton**: Action buttons with 3 styles (primary/secondary/danger)
4. **TerminalBox**: Container with ASCII borders (┌─┐│└┘) and optional titles
5. **TerminalDivider**: Section separators (solid/dashed/dotted styles)
6. **TerminalSettingsView**: Full settings interface with 11 configurable settings
7. **Help/Settings Toggle**: Button to switch between views in detail column
8. **@AppStorage Keys**: 11 persistent settings that work with Phase 3 commands

### What Was Added in Phase 4:
1. **Tab Completion**: Press Tab to cycle through command suggestions
2. **Command Aliases**: 24 Unix-style shortcuts (ls, rm, cd, etc.)
3. **Syntax Highlighting**: Real-time color coding with AttributedString
4. **Persistent History**: Last 100 commands saved to UserDefaults
5. **Context-Aware Placeholders**: Dynamic hints based on city selection

### Evolution Timeline:
- **Phase 1**: Terminal as bottom bar across entire app ✅
- **Phase 1.5**: Terminal in left sidebar (too narrow) ✅
- **Phase 2.0**: Terminal in middle column (optimal layout) ✅
- **Phase 2**: Thought/Item Management commands ✅
- **Phase 5**: Terminal UI Components & Settings View ✅
- **Phase 3**: Settings Commands with dual-interface integration ✅
- **Phase 6**: Settings Implementation (connected to simulation) ✅
- **Phase 4**: Advanced Features (tab completion, aliases, highlighting) ✅

### Next Recommended Phase:
**Phase 7: Terminal Views** (12-18 hours)
- `TerminalCityListView` - Replace current `CityListView`
- `TerminalCityDetailView` - Replace current `CityView`
- `TerminalItemDetailView` - Replace current `DetailView`
- Simplify `GlobalDashboardView` (remove version tabs)
- Major UI transformation with consistent terminal aesthetic

Users now have **two ways to interact** with the system:
1. **Power users**: Type commands in terminal (fast, scriptable, with shortcuts and completion)
2. **Casual users**: Click toggles/sliders in settings view (discoverable, visual)

Both interfaces are production-ready and demonstrate how a contemplative game can embrace retro terminal aesthetics while providing modern GUI accessibility. **Phase 4 adds power-user features** - making the terminal truly efficient for experienced users while maintaining the poetic, contemplative atmosphere.

---

**IMPLEMENTATION_STATUS: PHASE_4_COMPLETE**
**NEXT_PHASE: TERMINAL_VIEWS (Phase 7)**
**TOTAL_EFFORT: ~14_HOURS (Phase 1: ~3h, Phase 2: ~2h, Phase 3: ~2h, Phase 4: ~3h, Phase 5: ~2h, Phase 6: ~2h)**
**// █**
