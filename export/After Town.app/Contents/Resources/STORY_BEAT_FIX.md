# Story Beat Repetition Fix

**Date:** 2025-10-17
**Issue:** Story beats were repeating every time a thread was woven
**Status:** ✅ FIXED

---

## The Problem

### Symptom
When weaving threads, the same story beats (e.g., "beat_first_thread", "beat_second_thread") would fire repeatedly every time the user ran the `weave` command, even though they were marked as `oneTimeOnly: true`.

### Root Cause
The bug was in [StoryBeatManager.swift:126-134](idle_01/progression/systems/StoryBeatManager.swift#L126-L134):

```swift
// OLD CODE (BUGGY)
for i in allBeats.indices {
    // Skip if already occurred and is one-time-only
    if allBeats[i].hasOccurred && allBeats[i].oneTimeOnly {
        print("[StoryBeatManager] Skipping beat '\(allBeats[i].id)' - already occurred")
        continue
    }

    // ... check triggers ...

    if await evaluateTrigger(allBeats[i].trigger, city: city) {
        allBeats[i].hasOccurred = true  // ❌ LOCAL ACTOR STATE
        triggeredBeats.append(allBeats[i])
    }
}
```

**The Issue:**
1. `allBeats[i].hasOccurred` was stored in the **actor's local state**
2. Every time `weave` command executed, it created a **new StoryBeatManager()** instance ([TerminalCommandExecutor.swift:784](idle_01/ui/terminal/TerminalCommandExecutor.swift#L784))
3. New instance = fresh beats loaded from JSON = `hasOccurred` reset to `false`
4. Result: Story beats fired **every single time** conditions were met

### User Experience Impact
- **Repetitive narrative** - Same dialogue over and over
- **No story progression** - City "forgot" its own narrative history
- **Immersion breaking** - Ruins the experience of a living, evolving city
- **Annoying** - Players see "The First Thread" dialogue on the 50th thread

---

## The Solution

### Approach: Persistent State in City Model

Store story beat history in the **City model** itself, which persists via SwiftData:

```swift
// City.swift
/// Story beats that have already been triggered for this city
/// Used to prevent repeating one-time-only narrative events
var triggeredStoryBeats: [String] = []
```

### Implementation

#### 1. Added Persistent Storage ([City.swift:43-45](idle_01/game/City.swift#L43-L45))

```swift
/// Story beats that have already been triggered for this city
/// Used to prevent repeating one-time-only narrative events
var triggeredStoryBeats: [String] = []
```

This array:
- ✅ Persists across app restarts (SwiftData)
- ✅ Unique per city
- ✅ Survives StoryBeatManager recreation

#### 2. Updated Story Beat Checking ([StoryBeatManager.swift:117-153](idle_01/progression/systems/StoryBeatManager.swift#L117-L153))

```swift
// NEW CODE (FIXED)
func checkTriggers(city: City) async -> [StoryBeat] {
    var triggeredBeats: [StoryBeat] = []

    let threadCount = await MainActor.run { city.threads.count }
    let alreadyTriggered = await MainActor.run { city.triggeredStoryBeats }

    for i in allBeats.indices {
        // ✅ Check persistent city state instead of local actor state
        if allBeats[i].oneTimeOnly && alreadyTriggered.contains(allBeats[i].id) {
            print("[StoryBeatManager] Skipping beat '\(allBeats[i].id)' - already occurred in city history")
            continue
        }

        if await evaluateTrigger(allBeats[i].trigger, city: city) {
            // ✅ Save to persistent city state
            if allBeats[i].oneTimeOnly {
                let beatID = allBeats[i].id
                await MainActor.run {
                    city.triggeredStoryBeats.append(beatID)
                }
            }

            triggeredBeats.append(allBeats[i])
        }
    }

    return triggeredBeats
}
```

### Key Changes

1. **Check city's persistent state:**
   ```swift
   let alreadyTriggered = await MainActor.run { city.triggeredStoryBeats }
   if allBeats[i].oneTimeOnly && alreadyTriggered.contains(allBeats[i].id) {
       continue  // Skip this beat
   }
   ```

2. **Update city's persistent state:**
   ```swift
   if allBeats[i].oneTimeOnly {
       let beatID = allBeats[i].id
       await MainActor.run {
           city.triggeredStoryBeats.append(beatID)
       }
   }
   ```

3. **Actor isolation fix:**
   - Extract `beatID` before entering `MainActor.run` block
   - Prevents "actor-isolated property 'allBeats' cannot be referenced from main actor" error

---

## Testing Instructions

### Manual Test 1: One-Time Story Beats

**Scenario:** Verify story beats only fire once

1. Create a new city: `create city --name=TestCity`
2. Select it: `select [00]`
3. Weave first thread: `weave transit`
   - **Expected:** "beat_first_thread" fires with dialogue:
     - "I feel something weaving into being."
     - "A thread of consciousness, distinct from me but part of me."
     - "I am beginning to have structure."

4. Weave second thread: `weave housing`
   - **Expected:** "beat_second_thread" fires
   - **Expected:** "beat_first_thread" does NOT fire again

5. Weave third thread: `weave culture`
   - **Expected:** "beat_third_thread" fires
   - **Expected:** Neither "beat_first_thread" nor "beat_second_thread" fire

6. Weave fourth thread: `weave commerce`
   - **Expected:** NO story beats fire (no beat for count=4)

### Manual Test 2: Persistence Across Sessions

**Scenario:** Verify story beat history survives app restart

1. Create city and weave 3 threads (triggers beat_first, beat_second, beat_third)
2. Quit app completely
3. Relaunch app
4. Select the same city
5. Weave a fourth thread: `weave parks`
   - **Expected:** NO story beats fire (all count-based beats already triggered)

6. Check city data (if debug available):
   ```swift
   city.triggeredStoryBeats
   // Should contain: ["beat_first_thread", "beat_second_thread", "beat_third_thread"]
   ```

### Manual Test 3: Multiple Cities Independence

**Scenario:** Verify each city has independent story beat history

1. Create City A: `create city --name=CityA`
2. Weave first thread in City A: `weave transit`
   - **Expected:** "beat_first_thread" fires

3. Create City B: `create city --name=CityB`
4. Weave first thread in City B: `weave housing`
   - **Expected:** "beat_first_thread" fires AGAIN (different city!)

5. Switch back to City A: `select [00]`
6. Weave second thread: `weave housing`
   - **Expected:** "beat_second_thread" fires
   - **Expected:** "beat_first_thread" does NOT fire

### Debugging Tips

If story beats are still repeating, check:

1. **Console logs:** Look for:
   ```
   [StoryBeatManager] Already triggered beats: ["beat_first_thread", "beat_second_thread"]
   [StoryBeatManager] Skipping beat 'beat_first_thread' - already occurred in city history
   ```

2. **SwiftData persistence:** Verify `triggeredStoryBeats` array is saving:
   - Use breakpoint in StoryBeatManager.swift:142
   - Inspect `city.triggeredStoryBeats` after appending

3. **Model context:** Ensure model context is being saved after weaving:
   - Check TerminalCommandExecutor.swift:756-757

---

## Expected Behavior After Fix

### First Thread Weaving Session
```
> weave transit
THREAD_WOVEN: TESTCITY | TYPE: TRANSIT
🗣️ TRANSIT: "I am Transit. I move people through space."

━━━ STORY BEAT: THE FIRST THREAD ━━━
CITY: I feel something weaving into being.
CITY: A thread of consciousness, distinct from me but part of me.
CITY: I am beginning to have structure.
// Effects applied to city consciousness
```

### Second Thread Weaving (Same Session)
```
> weave housing
THREAD_WOVEN: TESTCITY | TYPE: HOUSING
🗣️ HOUSING: "I am Housing. I shelter. I provide rest."

━━━ STORY BEAT: THE PATTERN BEGINS ━━━
CITY: A second thread joins the first.
CITY: They touch. They intertwine.
CITY: I feel complexity emerging.
// Effects applied to city consciousness
```

### Third Thread Weaving (Same Session)
```
> weave culture
THREAD_WOVEN: TESTCITY | TYPE: CULTURE
🗣️ CULTURE: "I am Culture. I create meaning."

━━━ STORY BEAT: WEAVING COMPLEXITY ━━━
CITY: Three threads now. The pattern grows richer.
CITY: Each thread relates to the others differently.
CITY: I am not just additive. I am multiplicative.
// Effects applied to city consciousness
```

### Fourth Thread Weaving (Same Session)
```
> weave commerce
THREAD_WOVEN: TESTCITY | TYPE: COMMERCE
🗣️ COMMERCE: "I am Commerce. I facilitate exchange."

// NO STORY BEAT - no beat defined for count=4
```

### Fifth Thread Weaving (Same Session)
```
> weave parks
THREAD_WOVEN: TESTCITY | TYPE: PARKS
🗣️ PARKS: "I am Parks. I breathe green into concrete."

━━━ STORY BEAT: A CITY TAKES FORM ━━━
CITY: Five threads now weave through me.
CITY: I begin to feel... whole? Or at least, more than fragments.
CITY: Am I becoming myself?
💭 THOUGHT: What makes a city?
   Is it the threads? The connections? The consciousness that emerges from their weaving?
// Effects applied to city consciousness
```

### After Restart: Sixth Thread (New Session, Same City)
```
> weave water
THREAD_WOVEN: TESTCITY | TYPE: WATER
🗣️ WATER: "I am Water. I flow, I sustain life."

// NO STORY BEATS - All count-based beats already triggered
// (beat_first, beat_second, beat_third, beat_five all fired previously)
```

---

## Benefits of This Fix

1. ✅ **Narrative Coherence** - Story only tells each beat once
2. ✅ **Persistence** - Story history survives app restarts
3. ✅ **Per-City Stories** - Each city has its own narrative journey
4. ✅ **Clean Architecture** - Leverages SwiftData persistence model
5. ✅ **Debugging** - Console logs show triggered beat history
6. ✅ **Performance** - No performance impact (simple array contains check)

---

## Files Modified

1. [idle_01/game/City.swift](idle_01/game/City.swift#L43-L45)
   - Added `triggeredStoryBeats: [String]` property

2. [idle_01/progression/systems/StoryBeatManager.swift](idle_01/progression/systems/StoryBeatManager.swift#L117-L153)
   - Updated `checkTriggers(city:)` to use persistent state
   - Fixed actor isolation issues

---

## Future Enhancements

### Optional: Add Story Beat Reset Command

For debugging/testing, you could add a terminal command:

```swift
case .resetStoryBeats:
    return handleResetStoryBeats(selectedCityID: selectedCityID)

private func handleResetStoryBeats(selectedCityID: PersistentIdentifier?) -> CommandOutput {
    guard let city = /* ... find city ... */ else { return error }

    city.triggeredStoryBeats = []
    try? modelContext.save()

    return CommandOutput(
        text: "STORY_BEATS_RESET: All narrative history cleared. The city's story begins anew."
    )
}
```

### Optional: Story Beat Analytics

Track which beats have fired across all cities:

```swift
// Global analytics
struct StoryBeatAnalytics {
    static func mostTriggeredBeat(across cities: [City]) -> String? {
        let allBeats = cities.flatMap { $0.triggeredStoryBeats }
        let frequency = Dictionary(grouping: allBeats, by: { $0 })
        return frequency.max(by: { $0.value.count < $1.value.count })?.key
    }
}
```

---

## Related Documentation

- [PHASE_4_COMPLETION.md](idle_01/progression/PHASE_4_COMPLETION.md) - Emergent properties system
- [PHASE_4_TESTING_GUIDE.md](idle_01/progression/PHASE_4_TESTING_GUIDE.md) - Testing procedures
- [StoryBeat.swift](idle_01/progression/models/StoryBeat.swift) - Story beat model definition
- [core_progression.json](idle_01/progression/data/story_beats/core_progression.json) - Story beat definitions

---

*Last Updated: 2025-10-17*
