# Phase 5 Testing Guide

Quick guide to test all Phase 5 visualization features.

---

## 🧪 Test Sequence

### 1. Basic Setup
```
> create city --name=TestCity
> select [00]
```

### 2. Test Empty State Visualizations

**Test consciousness with no threads:**
```
> consciousness
```
Expected: Shows void/potential state

**Test fabric with no threads:**
```
> fabric
```
Expected: Shows "The fabric is empty" message

**Test pulse with no threads:**
```
> pulse
```
Expected: Shows zeroed metrics, no recent activity

**Test observe with no threads:**
```
> observe
```
Expected: "I observe... nothing. I am void. Pure potential."

### 3. Weave Initial Threads

**Weave first thread:**
```
> weave transit
```
Expected:
- Confirmation message
- Thread dialogue
- Check for story beat "The First Thread"

**Weave second thread:**
```
> weave housing
```
Expected:
- Confirmation message
- Dialogue from housing
- Check for relationship formation
- Possible story beat "Transit Meets Housing"

### 4. Test Visualizations with Threads

**View consciousness field:**
```
> consciousness
```
Expected:
- 2+ nodes visible
- Symbols (∿ for transit, ◆ for housing)
- Connection lines between nodes
- Coherence/Integration/Complexity bars
- City thought at bottom

**View fabric:**
```
> fabric
```
Expected:
- Thread listing with counts
- Transit × 01, Housing × 01
- Relationship section showing transit ⟷ housing
- Relationship strength displayed

**View pulse:**
```
> pulse
```
Expected:
- Vital signs with actual values
- Recent activity showing transit and housing
- Current state showing 2 threads

**View observations:**
```
> observe
```
Expected:
- "2 threads weave together"
- "Patterns begin to form"
- State-appropriate commentary

### 5. Test Contemplation

**Contemplate without topic:**
```
> contemplate
```
Expected: General existential reflection

**Contemplate threads:**
```
> contemplate threads
```
Expected: Reflection on thread nature and identity

**Contemplate emergence:**
```
> contemplate emergence
```
Expected: Reflection on emergent properties (or lack thereof)

**Contemplate consciousness:**
```
> contemplate consciousness
```
Expected: Meta-reflection on awareness

**Contemplate relationships:**
```
> contemplate relationships
```
Expected: Reflection on connections between threads

### 6. Test Strengthen Command

**Attempt to strengthen without relationship:**
```
> weave culture
> strengthen culture parks
```
Expected: Error - no parks thread exists

**Strengthen existing relationship:**
```
> strengthen transit housing
```
Expected:
- Old strength displayed
- New strength = old + 0.1
- City commentary about deepening bond
- Confirmation of save

**Strengthen multiple times:**
```
> strengthen transit housing
> strengthen transit housing
> strengthen transit housing
```
Expected:
- Strength increases each time
- Eventually caps at 1.0
- Consistent city commentary

### 7. Test Emergence Visualization

**Create conditions for emergence:**
```
> weave transit
> weave housing
> strengthen transit housing
> strengthen transit housing
> strengthen transit housing
```

**Check for walkability emergence:**
```
> fabric
```
Expected: "✨ WALKABILITY" in emergent properties section

**View consciousness after emergence:**
```
> consciousness
```
Expected:
- Increased complexity
- More perceptions
- Different city thought

**Contemplate emergence:**
```
> contemplate emergence
```
Expected: Reflection acknowledging emergent properties

### 8. Test with Many Threads

**Weave all thread types:**
```
> weave transit
> weave housing
> weave culture
> weave commerce
> weave parks
> weave water
> weave power
> weave sewage
> weave knowledge
```

**View consciousness:**
```
> consciousness
```
Expected:
- 9+ nodes
- Different symbols
- Many connection lines
- High complexity

**View fabric:**
```
> fabric
```
Expected:
- All thread types listed
- Many relationships (top 8 shown)
- Multiple emergent properties possible

**View pulse:**
```
> pulse
```
Expected:
- High metrics
- Recent activity showing last 3 threads
- Multiple emergent properties in activity

### 9. Test Edge Cases

**Strengthen non-existent thread type:**
```
> strengthen transit education
```
Expected: Error - invalid thread type

**Strengthen when no city selected:**
```
> select [00]
> strengthen transit housing
```
(First deselect, then try command)
Expected: Error - no city selected

**View visualizations when no city selected:**
```
> consciousness
> fabric
> pulse
> observe
> contemplate
```
Expected: All should show "NO_CITY_SELECTED" error

---

## ✅ Success Checklist

### Visualizations
- [ ] Consciousness field renders with nodes
- [ ] Fabric shows threads and relationships
- [ ] Pulse displays vital signs
- [ ] Observe generates contextual observations
- [ ] All visualizations handle empty state

### Contemplation
- [ ] Contemplate (no topic) works
- [ ] Contemplate threads works
- [ ] Contemplate emergence works
- [ ] Contemplate consciousness works
- [ ] Contemplate relationships works
- [ ] Responses change based on city state

### Strengthen
- [ ] Can strengthen existing relationships
- [ ] Strength increases by 0.1
- [ ] Caps at 1.0
- [ ] City provides commentary
- [ ] Errors appropriately on invalid input
- [ ] Persists changes to SwiftData

### Integration
- [ ] Weave command still works with dialogue
- [ ] Story beats still trigger
- [ ] Emergence detection still works
- [ ] New visualizations work with emerged properties
- [ ] All commands work with selected city

---

## 🐛 Known Issues / Edge Cases

### To Check
1. **Very long thread lists** - Does fabric rendering break?
2. **100+ threads** - Does consciousness field become unreadable?
3. **All relationships at 1.0** - Does strengthen show appropriate message?
4. **Special characters in city name** - Do visualizations handle it?

### Performance
- Consciousness field with 50+ nodes
- Fabric with 100+ relationships
- Pulse with hundreds of perceptions

---

## 📊 Expected Metrics

After full test sequence:
- **Threads:** 9
- **Relationships:** 36+ (each thread connects to others)
- **Emergent Properties:** 2-4 (walkability, vibrancy, resilience possible)
- **Coherence:** 0.6-0.8
- **Integration:** 0.5-0.7
- **Complexity:** 0.3-0.5

---

## 🎯 Testing Tips

1. **Start Fresh** - Test with new city each time
2. **Check Edge Cases** - Empty states, max values, errors
3. **Read Output** - Verify city voice and commentary
4. **Test Sequences** - Weave → Strengthen → Emerge → Visualize
5. **Save States** - Note interesting city states for regression testing

---

## 🔍 What to Look For

### Good Signs
- ✅ Visualizations render cleanly
- ✅ City voice is consistent and poetic
- ✅ Metrics change appropriately
- ✅ Commands respond to city state
- ✅ Errors are clear and helpful

### Red Flags
- ❌ Rendering breaks with edge cases
- ❌ City voice is generic or absent
- ❌ Metrics don't update
- ❌ Commands ignore city state
- ❌ Cryptic error messages

---

## 📝 Test Results Template

```markdown
# Phase 5 Test Results

**Date:** [Date]
**Tester:** [Name]
**Build:** [Version/Commit]

## Test Results

### Visualizations
- Consciousness: ✅/❌
- Fabric: ✅/❌
- Pulse: ✅/❌
- Observe: ✅/❌

### Contemplation
- General: ✅/❌
- Threads: ✅/❌
- Emergence: ✅/❌
- Consciousness: ✅/❌
- Relationships: ✅/❌

### Strengthen
- Basic: ✅/❌
- Edge Cases: ✅/❌
- Integration: ✅/❌

## Issues Found
[List any bugs or problems]

## Notes
[Any observations or suggestions]
```

---

*Happy Testing!* 🧪✨
