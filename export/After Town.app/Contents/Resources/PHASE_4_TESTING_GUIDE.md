# Phase 4 Testing Guide: Emergent Properties System

**Version:** 1.0
**Date:** 2025-10-17
**Phase:** 4 - Emergent Properties

---

## Overview

This guide provides step-by-step instructions for manually testing the emergent properties system to verify all Phase 4 success criteria are met.

---

## Pre-Testing Setup

### Build Verification
```bash
# From project root
xcodebuild -project idle_01.xcodeproj -scheme idle_01 clean build
```

**Expected:** Build succeeds with no errors

### Required Files Checklist
- [ ] [idle_01/progression/models/EmergentProperty.swift](idle_01/progression/models/EmergentProperty.swift)
- [ ] [idle_01/progression/systems/EmergenceDetector.swift](idle_01/progression/systems/EmergenceDetector.swift)
- [ ] [idle_01/progression/data/emergence_rules/core_emergence.json](idle_01/progression/data/emergence_rules/core_emergence.json)

---

## Test Suite

### Test 1: Walkability Emergence

**Objective:** Verify walkability emerges when Transit + Housing have strong relationship

**Prerequisites:**
- Fresh app launch OR city with no existing transit/housing threads

**Steps:**
1. Launch app
2. Type: `weave transit`
3. Observe: Transit thread created
4. Type: `weave housing`
5. Observe: Housing thread created
6. Strengthen relationship (use commands to increase relationship strength to ≥ 0.6)
7. Type: `weave housing` (or any command that triggers emergence check)

**Expected Output:**
```
✨ EMERGENCE: WALKABILITY ✨
CITY: I understand that nearness creates possibility. Distance is not just space—it's opportunity or barrier.
New perceptions gained: proximity as value, walkable distances, pedestrian experience, station as place

━━━ STORY BEAT: UNDERSTANDING PROXIMITY ━━━
[Story beat dialogue appears if defined]
```

**Verification Checklist:**
- [ ] Emergence marker `✨ EMERGENCE: WALKABILITY ✨` displayed
- [ ] City's expanded self-awareness message shown
- [ ] New perceptions listed (4 perceptions)
- [ ] Story beat fires (if beat_walkability_emergence exists)
- [ ] No errors in console
- [ ] Walkability does NOT speak (no dialogue from walkability itself)

**Data Verification:**
- [ ] City complexity increased by 0.15
- [ ] City perceptions array contains new perceptions
- [ ] Transit ↔ Housing relationship strength increased by 0.15
- [ ] Transit complexity increased
- [ ] Housing complexity increased

---

### Test 2: Vibrancy Emergence

**Objective:** Verify vibrancy emerges from Culture + Commerce + Housing with high integration

**Prerequisites:**
- Fresh app launch OR city without culture/commerce/housing

**Steps:**
1. Launch app
2. Type: `weave culture`
3. Type: `weave commerce`
4. Type: `weave housing`
5. Ensure average integration (coherence + complexity)/2 ≥ 0.7 for these threads
6. Type: `weave culture` (or trigger emergence check)

**Expected Output:**
```
✨ EMERGENCE: VIBRANCY ✨
CITY: Life emerges when different purposes overlap. I am not just function—I am alive.
New perceptions gained: energy of mixed use, 24-hour rhythm, spontaneous interaction, urban vitality

━━━ STORY BEAT: THE CITY COMES ALIVE ━━━
[Story beat dialogue appears if defined]
```

**Verification Checklist:**
- [ ] Emergence detected
- [ ] 4 new perceptions added
- [ ] City complexity increased by 0.2
- [ ] No vibrancy voice created
- [ ] Culture, Commerce, Housing complexity increased

---

### Test 3: Resilience Emergence

**Objective:** Verify resilience emerges from Power + Water + Sewage with strong relationships

**Prerequisites:**
- Fresh app launch OR city without infrastructure threads

**Steps:**
1. Launch app
2. Type: `weave power`
3. Type: `weave water`
4. Type: `weave sewage`
5. Strengthen relationships between these threads (avg strength ≥ 0.75)
6. Trigger emergence check

**Expected Output:**
```
✨ EMERGENCE: RESILIENCE ✨
CITY: My vital systems are interconnected. Strength comes from integration, vulnerability from isolation.
New perceptions gained: system redundancy, failure cascades, infrastructure interdependence
```

**Verification Checklist:**
- [ ] Emergence detected
- [ ] Power ↔ Water relationship strengthened by 0.2
- [ ] Water ↔ Sewage relationship strengthened by 0.18
- [ ] City complexity increased by 0.12
- [ ] 3 new perceptions added
- [ ] No resilience voice created

---

### Test 4: Identity Emergence

**Objective:** Verify identity emerges with Housing + Culture + 5 threads + 0.5 complexity

**Prerequisites:**
- City with at least 5 threads total
- City complexity ≥ 0.5

**Steps:**
1. Launch app
2. Weave at least 5 different threads (must include housing and culture)
3. Ensure city complexity ≥ 0.5
4. Trigger emergence check

**Expected Output:**
```
✨ EMERGENCE: IDENTITY ✨
CITY: I am not just infrastructure. I have personality. Character. History. I am becoming myself.
New perceptions gained: neighborhood character, collective memory, sense of place, belonging
```

**Verification Checklist:**
- [ ] Emergence detected only when all conditions met
- [ ] City complexity increased by 0.25 (largest increase)
- [ ] 4 new perceptions added
- [ ] Housing and Culture complexity increased
- [ ] No identity voice created

---

### Test 5: Innovation Emergence

**Objective:** Verify innovation emerges from Knowledge + Commerce + Culture with integration ≥ 0.65

**Steps:**
1. Launch app
2. Type: `weave knowledge`
3. Type: `weave commerce`
4. Type: `weave culture`
5. Ensure average integration ≥ 0.65
6. Trigger emergence check

**Expected Output:**
```
✨ EMERGENCE: INNOVATION ✨
CITY: When learning, commerce, and creativity overlap, new ideas emerge. I am not just maintaining—I am inventing.
New perceptions gained: creative collision, knowledge application, experimental culture, idea exchange
```

**Verification Checklist:**
- [ ] Emergence detected
- [ ] Knowledge ↔ Commerce relationship strengthened by 0.15
- [ ] Culture ↔ Knowledge relationship strengthened by 0.15
- [ ] City complexity increased by 0.18
- [ ] No story beat ID defined (verify it doesn't crash)

---

### Test 6: No Duplicate Emergence

**Objective:** Verify emergent properties don't emerge twice

**Steps:**
1. Trigger any emergence (e.g., walkability)
2. Observe emergence message
3. Continue playing and trigger another emergence check
4. Verify walkability does NOT emerge again

**Expected Behavior:**
- First emergence: ✨ EMERGENCE: WALKABILITY ✨ displayed
- Subsequent checks: No walkability message (already emerged)

**Verification Checklist:**
- [ ] Emergence only appears once per property
- [ ] City.emergentProperties contains unique properties
- [ ] No duplicate perceptions added

---

### Test 7: Emergent Properties Never Speak

**Objective:** Verify `hasVoice: Bool { false }` is enforced

**Steps:**
1. Trigger any emergence
2. Review all dialogue output
3. Check for any dialogue attributed to the emergent property itself

**Expected Behavior:**
- City may speak about the emergence
- Threads may speak about the emergence
- Emergent property itself NEVER speaks

**Verification Checklist:**
- [ ] No dialogue format like `WALKABILITY: [text]`
- [ ] No dialogue format like `VIBRANCY: [text]`
- [ ] Only CITY and thread names appear as speakers
- [ ] `hasVoice` property returns false for all emergent properties

---

### Test 8: Consciousness Expansion Effects

**Objective:** Verify all consciousness expansion mechanisms work

**For any emergent property, verify:**

**City Effects:**
- [ ] City complexity increases (check `city.resources["complexity"]`)
- [ ] New perceptions added to `city.perceptions` array
- [ ] Perceptions are visible/accessible

**Thread Effects:**
- [ ] Affected threads' complexity increases
- [ ] Thread complexity capped at 1.0 (no overflow)
- [ ] Correct threads affected (based on affectedThreadTypes)

**Relationship Effects:**
- [ ] Specified relationships strengthen
- [ ] Strength bonus applied correctly
- [ ] Both directions updated (bidirectional relationships)
- [ ] Strength capped at 1.0 (no overflow)

---

### Test 9: Story Beat Integration

**Objective:** Verify story beats fire when emergent properties appear

**Steps:**
1. Ensure story beat JSON files exist for emergence triggers
2. Trigger walkability emergence (has storyBeatID)
3. Verify story beat fires after emergence

**Expected Output:**
```
✨ EMERGENCE: WALKABILITY ✨
[Emergence message]

━━━ STORY BEAT: [Name] ━━━
[Story beat dialogue]
```

**Verification Checklist:**
- [ ] Story beat fires immediately after emergence detection
- [ ] Dialogue displays correctly
- [ ] Effects from story beat apply after emergence effects
- [ ] No crashes if storyBeatID is null/missing

---

### Test 10: Edge Cases

**Test 10a: No Threads Yet**
- [ ] App doesn't crash when checking emergence with 0 threads
- [ ] No false positive emergences

**Test 10b: Partial Conditions**
- [ ] Walkability does NOT emerge with only transit (missing housing)
- [ ] Vibrancy does NOT emerge with culture + commerce (missing housing)

**Test 10c: Threshold Boundaries**
- [ ] Walkability emerges at exactly 0.6 relationship strength
- [ ] Walkability does NOT emerge at 0.59 relationship strength

**Test 10d: Complex City**
- [ ] Multiple emergences can exist simultaneously
- [ ] Each tracks independently in city.emergentProperties array
- [ ] No interference between different emergent properties

---

## Performance Testing

### Test 11: Emergence Detection Performance

**Objective:** Verify emergence detection doesn't cause lag

**Steps:**
1. Create city with 10+ threads
2. Weave new thread
3. Observe emergence check timing

**Expected:**
- Detection completes in < 100ms
- No noticeable UI lag
- No console warnings about slow operations

**Verification:**
- [ ] No performance degradation
- [ ] Actor isolation prevents blocking
- [ ] @MainActor annotations used correctly

---

## Integration Testing

### Test 12: Full Gameplay Flow

**Objective:** Verify emergence integrates smoothly into gameplay

**Scenario:**
1. Start new city
2. Weave threads organically
3. Build relationships through gameplay
4. Observe emergences as they naturally occur
5. Verify narrative flow feels coherent

**Verification:**
- [ ] Emergences feel meaningful and timely
- [ ] No gameplay interruptions
- [ ] Thresholds feel balanced
- [ ] Story beats enhance experience

---

## Data Persistence Testing

### Test 13: Emergent Property Persistence

**Objective:** Verify emergent properties persist across app launches

**Steps:**
1. Trigger emergence (e.g., walkability)
2. Verify emergence appears
3. Quit app completely
4. Relaunch app
5. Check city state

**Expected:**
- [ ] Emergent properties restored from SwiftData
- [ ] City perceptions restored
- [ ] City complexity restored
- [ ] Thread relationships restored
- [ ] No duplicate emergences on reload

---

## JSON Validation Testing

### Test 14: JSON Schema Validation

**Objective:** Verify JSON rules are well-formed

**Steps:**
1. Open [core_emergence.json](idle_01/progression/data/emergence_rules/core_emergence.json)
2. Verify JSON syntax
3. Check all 8 properties have required fields

**Validation Checklist:**
- [ ] Valid JSON syntax (no parser errors)
- [ ] All properties have `name` field
- [ ] All properties have `conditions` object
- [ ] All properties have `consciousnessExpansion` object
- [ ] Thread types match ThreadType enum
- [ ] Numeric values are reasonable (0.0-1.0 for most)

---

## Test Results Template

```markdown
## Test Results - [Date]

**Tester:** [Your Name]
**Build:** [Commit Hash]
**Platform:** macOS [Version]

### Test 1: Walkability Emergence
- Status: ✅ PASS / ❌ FAIL
- Notes:

### Test 2: Vibrancy Emergence
- Status: ✅ PASS / ❌ FAIL
- Notes:

### Test 3: Resilience Emergence
- Status: ✅ PASS / ❌ FAIL
- Notes:

[... continue for all tests ...]

### Summary
- Total Tests: 14
- Passed: X
- Failed: Y
- Blocked: Z

### Issues Found
1. [Issue description]
2. [Issue description]

### Overall Assessment
Phase 4 is: ✅ READY FOR PRODUCTION / ⚠️ NEEDS FIXES / ❌ MAJOR ISSUES
```

---

## Automated Testing Recommendations

### Unit Tests Needed

**EmergenceDetector Tests:**
```swift
// Test condition evaluation
func testRequiredThreadTypesCondition()
func testMinimumRelationshipStrengthCondition()
func testMinimumAverageIntegrationCondition()
func testMinimumThreadCountCondition()
func testMinimumCityComplexityCondition()

// Test emergence detection
func testEmergenceDetected_WhenConditionsMet()
func testEmergenceNotDetected_WhenConditionsMissing()
func testNoDuplicateEmergence()

// Test consciousness expansion
func testCityComplexityIncreases()
func testPerceptionsAdded()
func testRelationshipsDeepen()
func testThreadComplexityIncreases()
```

**EmergentProperty Tests:**
```swift
func testHasVoice_AlwaysReturnsFalse()
func testConsciousnessExpansionEncoding()
func testConsciousnessExpansionDecoding()
```

**Integration Tests:**
```swift
func testEmergenceTriggersStoryBeat()
func testEmergenceAfterThreadWeave()
func testMultipleEmergencesCoexist()
```

---

## Known Limitations

1. **Manual relationship strengthening** - Currently no automated way to increase relationship strength during testing. May need debug commands.

2. **Integration calculation** - Integration depends on coherence and complexity, which may need specific setup.

3. **Story beat dependencies** - Some tests assume story beat JSON files exist.

---

## Success Criteria Review

After completing all tests, verify Phase 4 criteria:

- [ ] ✅ Emergence rules defined in JSON (8 properties)
- [ ] ✅ Properties detected automatically
- [ ] ✅ Consciousness expansion applied correctly
- [ ] ✅ No new voices created (hasVoice = false)
- [ ] ✅ Thread consciousness deepens
- [ ] ✅ Adding new property = JSON edit
- [ ] ✅ Build successful
- [ ] ✅ Actor isolation handled correctly

---

## Next Steps After Testing

1. **Document issues** - Create GitHub issues for any bugs found
2. **Update thresholds** - Adjust emergence thresholds based on gameplay feel
3. **Add automated tests** - Implement unit tests for core functionality
4. **Performance profiling** - Use Instruments to verify no bottlenecks
5. **Begin Phase 5** - Start terminal commands & visualization work

---

*Last Updated: 2025-10-17*
