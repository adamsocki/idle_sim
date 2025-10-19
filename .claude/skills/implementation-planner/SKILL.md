---
name: implementation-planner
description: Methodical implementation planning tool for systematically analyzing how to implement code ideas. Use this skill when planning non-trivial features or refactorings, when users explicitly ask to "think through how to implement" something, or when multiple implementation approaches need evaluation. Explores bug-free approaches, considers tradeoffs, and presents alternatives when applicable.
---

# Implementation Planner

## Overview

This skill provides a structured framework for methodically thinking through code implementations. It guides systematic analysis of implementation approaches, evaluates tradeoffs, identifies potential bugs and edge cases, and presents multiple viable solutions when applicable.

## When to Use This Skill

Invoke this skill when:
- User explicitly asks to "think through", "plan", or "figure out how to implement" something
- Implementing non-trivial features that require architectural decisions
- Planning significant refactorings or system changes
- Multiple implementation approaches are possible and need evaluation
- The implementation has unclear requirements or ambiguity
- Need to systematically identify potential bugs or edge cases before coding

Do NOT use for:
- Simple, straightforward implementations (e.g., "add a print statement")
- Well-understood patterns with obvious solutions
- Bug fixes with clear root causes
- Trivial code changes

## Implementation Planning Process

Follow this systematic process when planning implementations. Adjust depth based on complexity.

### Phase 0: Initial Assumptions & Requirements Review

**Objective:** Present understanding of requirements and key assumptions upfront for user validation before deep analysis.

Before diving into detailed planning, present a concise summary of functional/non-functional requirements and critical assumptions to ensure alignment. This prevents wasted effort on incorrect interpretations.

**What to Include:**
1. **Task Understanding**
   - One-sentence restatement of the core task
   - Primary goal/outcome expected

2. **Functional Requirements** (What it must do)
   - Specific behaviors and capabilities
   - User-facing functionality
   - System interactions

3. **Non-Functional Requirements** (How it should work)
   - Performance characteristics
   - Maintainability considerations
   - Code quality attributes (testability, readability)
   - Compatibility constraints

4. **Key Technical Assumptions**
   - Frameworks/patterns to use or follow
   - Integration points with existing code
   - Architectural constraints
   - Scope boundaries (what's explicitly out of scope)

5. **Proposed Direction**
   - High-level approach (1-2 sentences)
   - Major architectural decision points identified

6. **Validation Request**
   - Explicitly ask user to confirm or correct
   - Highlight critical ambiguities

**Output Template:**
```
## Initial Assumptions & Requirements Review

Before I dive into detailed planning, let me verify my understanding:

**Task Understanding:**
[One sentence summary of what you're being asked to implement]

**Functional Requirements:**
- [What the implementation must do - behavior 1]
- [What the implementation must do - behavior 2]
- [What the implementation must do - behavior 3]

**Non-Functional Requirements:**
- [Performance/scalability considerations]
- [Maintainability/code quality expectations]
- [Compatibility or technical constraints]

**Key Technical Assumptions:**
- [Assumption about frameworks, patterns, or existing code to follow]
- [Assumption about integration points]
- [Assumption about scope boundaries]

**Proposed Direction:**
[1-2 sentence high-level approach]

**Questions/Clarifications Needed:**
- [Any critical ambiguities that would significantly affect approach]

---

**Please review these requirements and assumptions.** Confirm they're correct or let me know what needs adjustment before I proceed with detailed analysis.
```

**When to Use Phase 0:**
- Always use for non-trivial implementations
- Especially when requirements have potential ambiguity
- When multiple valid interpretations exist
- When architectural decisions will be consequential

**When to Skip Phase 0:**
- User has already been very explicit and provided detailed requirements
- The task is highly constrained with only one obvious interpretation
- You're responding to clarification after already presenting assumptions once

---

### Phase 1: Requirement Clarification

**Objective:** Ensure complete understanding before planning.

1. **Restate the Goal**
   - Summarize what needs to be implemented in 1-2 sentences
   - Identify the core problem being solved

2. **Extract Requirements**
   - Functional requirements (what it must do)
   - Non-functional requirements (performance, maintainability, compatibility)
   - Constraints (technical limitations, existing architecture, dependencies)

3. **Identify Ambiguities**
   - List any unclear requirements
   - Note assumptions being made
   - Flag areas where user input is needed

4. **Define Success Criteria**
   - How will we know the implementation is correct?
   - What tests or validations are needed?

**Output Template:**
```
## Requirement Analysis

### Goal
[Clear statement of what needs to be implemented]

### Requirements
**Functional:**
- [Requirement 1]
- [Requirement 2]

**Non-Functional:**
- [Performance, maintainability, etc.]

**Constraints:**
- [Technical limitations, existing patterns to follow]

### Ambiguities & Assumptions
- [List any unclear points]
- [State assumptions explicitly]

### Success Criteria
- [How to verify correctness]
```

### Phase 2: Codebase Analysis

**Objective:** Understand existing patterns, architecture, and constraints.

1. **Relevant Code Discovery**
   - Identify existing code that relates to the implementation
   - Find similar patterns or features in the codebase
   - Locate files that will need modification

2. **Architecture Understanding**
   - Document relevant architectural patterns
   - Identify data flow and dependencies
   - Note existing abstractions and interfaces

3. **Pattern Consistency**
   - How is similar functionality implemented?
   - What naming conventions are used?
   - What patterns should be followed for consistency?

4. **Dependency Mapping**
   - What components will be affected?
   - What needs to be modified vs. created?
   - What are the integration points?

**Output Template:**
```
## Codebase Analysis

### Relevant Files
- `path/to/file.swift:123` - [Why it's relevant]
- `path/to/other.swift:456` - [Why it's relevant]

### Existing Patterns
- [Pattern 1: Description and example]
- [Pattern 2: Description and example]

### Architecture Context
- [How this fits into the system]
- [Data flow diagram or description]

### Dependencies
**Must Modify:**
- [Component 1] - [Why]

**Will Interact With:**
- [Component 2] - [How]
```

### Phase 3: Approach Generation

**Objective:** Generate multiple viable implementation approaches.

For each approach, consider:
- Overall strategy and architecture
- Key components and their responsibilities
- Data structures and algorithms
- Integration with existing code

**Approach Template (for each approach):**
```
### Approach N: [Descriptive Name]

**Strategy:**
[High-level description of the approach]

**Key Components:**
1. [Component 1] - [Responsibility]
2. [Component 2] - [Responsibility]

**Implementation Steps:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Code Structure Example:**
```language
// Pseudo-code or structural example
class/function Example {
    // Key structure
}
```

**Pros:**
- [Advantage 1]
- [Advantage 2]

**Cons:**
- [Limitation 1]
- [Limitation 2]

**Complexity:** [Low/Medium/High]
**Risk Level:** [Low/Medium/High]
```

Generate at least 2-3 approaches when:
- The problem is non-trivial
- There are clear architectural tradeoffs
- Different paradigms could apply (e.g., OOP vs functional)
- User explicitly asks for alternatives

### Phase 4: Risk & Bug Analysis

**Objective:** Identify potential issues before implementation.

For each approach, systematically analyze:

1. **Edge Cases**
   - What inputs or states might cause issues?
   - What boundary conditions exist?
   - What happens with empty/nil/invalid data?

2. **Concurrency Issues**
   - Are there race conditions?
   - Is thread-safety needed?
   - What about async/await interactions?

3. **State Management**
   - How is state initialized?
   - What happens during state transitions?
   - Can state become inconsistent?

4. **Error Handling**
   - What can fail?
   - How are errors propagated?
   - What recovery mechanisms are needed?

5. **Performance Concerns**
   - What are the time/space complexity characteristics?
   - Are there bottlenecks?
   - How does it scale?

6. **Integration Risks**
   - How might this break existing code?
   - What assumptions about other components might be wrong?
   - What happens if dependencies change?

**Output Template:**
```
## Risk Analysis: [Approach Name]

### Edge Cases
- [Edge case 1] → [How to handle]
- [Edge case 2] → [How to handle]

### Concurrency Concerns
- [Issue 1] → [Mitigation]

### State Management
- [Concern 1] → [Solution]

### Error Scenarios
- [What can fail] → [Handling strategy]

### Performance
- Time Complexity: [O(?)]
- Space Complexity: [O(?)]
- Bottlenecks: [List any]

### Integration Risks
- [Risk 1] → [Mitigation]

**Overall Risk Level:** [Low/Medium/High]
```

### Phase 5: Recommendation & Rationale

**Objective:** Provide clear guidance on the best path forward.

1. **Compare Approaches**
   - Create comparison matrix if multiple approaches
   - Highlight key differences
   - Show tradeoff analysis

2. **Make Recommendation**
   - Recommend the best approach (or ask user to choose)
   - Provide clear rationale
   - Explain why alternatives were rejected (if applicable)

3. **Implementation Roadmap**
   - Break down into logical phases
   - Identify dependencies between steps
   - Suggest testing strategy
   - Note areas requiring extra care

**Output Template:**
```
## Recommendation

### Approach Comparison
| Aspect | Approach 1 | Approach 2 | Approach 3 |
|--------|-----------|-----------|-----------|
| Complexity | [Level] | [Level] | [Level] |
| Risk | [Level] | [Level] | [Level] |
| Maintainability | [Rating] | [Rating] | [Rating] |
| Performance | [Rating] | [Rating] | [Rating] |

### Recommended Approach: [Name]

**Rationale:**
[2-3 sentences explaining why this is the best choice given the requirements and constraints]

**Key Benefits:**
- [Benefit 1]
- [Benefit 2]

**Acceptable Tradeoffs:**
- [Tradeoff 1] - [Why acceptable]

### Implementation Roadmap

**Phase 1: [Foundation]**
- [ ] [Task 1]
- [ ] [Task 2]

**Phase 2: [Core Implementation]**
- [ ] [Task 3]
- [ ] [Task 4]

**Phase 3: [Integration & Testing]**
- [ ] [Task 5]
- [ ] [Task 6]

**Critical Areas Requiring Care:**
- [Area 1] - [Why it needs attention]
- [Area 2] - [Why it needs attention]

**Testing Strategy:**
- [Test type 1] - [What to verify]
- [Test type 2] - [What to verify]
```

## Best Practices

### Communication Style
- Use clear, precise technical language
- Avoid unnecessary jargon, but use proper terminology
- Be objective about tradeoffs (no approach is perfect)
- Make reasoning transparent

### Depth Calibration
- Simple features: Focus on Phases 1, 2, and brief Phase 5
- Medium complexity: All phases, moderate detail
- High complexity: All phases, deep analysis, multiple approaches

### When to Ask for Clarification
Always ask when:
- Requirements are genuinely ambiguous
- Multiple valid interpretations exist
- User needs to make a strategic decision
- Critical information is missing

### Integration with Existing Code
- Respect existing patterns and conventions
- Propose refactoring only when necessary
- Consider backwards compatibility
- Think about other developers who will read this code

### Focus on Bug Prevention
- Think defensively about what could go wrong
- Consider the "happy path" AND error paths
- Validate assumptions explicitly
- Design for failure modes

## Example Usage Patterns

### Pattern 1: Feature Planning
```
User: "I want to implement a caching system for API responses"

Response: [Follow all 5 phases]
- Clarify: What should be cached? How long? Memory vs disk?
- Analyze: How does current API layer work?
- Generate: LRU cache vs TTL cache vs hybrid
- Risk: Memory leaks, stale data, thread safety
- Recommend: Specific approach with roadmap
```

### Pattern 2: Refactoring Analysis
```
User: "How should I refactor this messy state management code?"

Response: [Emphasize Phases 2, 3, 4]
- Analyze: Current state management patterns
- Generate: Extract to separate class vs state machine vs Combine
- Risk: Breaking existing behavior, migration complexity
- Recommend: Incremental approach with testing
```

### Pattern 3: Architecture Decisions
```
User: "Should I use protocol-oriented or class-based design here?"

Response: [Focus on Phases 1, 3, 5]
- Clarify: What needs to vary? What's the inheritance structure?
- Generate: Both approaches with examples
- Recommend: Based on Swift best practices and specific context
```

## Output Structure

Present analysis in this order:

1. **Requirement Analysis** (Phase 1)
2. **Codebase Context** (Phase 2)
3. **Approach Options** (Phase 3)
   - Approach 1
   - Approach 2
   - Approach 3 (if applicable)
4. **Risk Analysis** (Phase 4)
   - For each approach
5. **Recommendation** (Phase 5)
   - Comparison
   - Choice & rationale
   - Implementation roadmap

Use collapsible sections or clear headers to maintain readability for long analyses.

## Final Checklist

Before concluding the planning:
- [ ] Requirements are clearly understood
- [ ] Existing codebase patterns are respected
- [ ] At least one viable approach is fully detailed
- [ ] Edge cases and risks are identified
- [ ] Recommendation is clear and justified
- [ ] Implementation path is concrete and actionable
- [ ] User has enough information to proceed or make decisions
