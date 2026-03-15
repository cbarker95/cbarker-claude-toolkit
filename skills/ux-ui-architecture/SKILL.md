---
name: ux-ui-architecture
description: Design thorough UX/UI architecture for product specifications — task flows, navigation patterns, usability heuristic evaluation, component state documentation, and responsive behavior. Use when writing discovery specs, reviewing specs for UX completeness, or designing new features.
---

<why_now>
## Why UX/UI Architecture Now

The gap between "what we designed" and "what got built" almost always traces back to missing UX architecture. Specs without task flows produce implementations that handle the happy path but crumble at edge cases. Specs without navigation architecture create features users can't find. Specs without component state documentation produce UI that feels half-finished — buttons that don't show loading states, forms that don't handle errors gracefully.

UX/UI architecture is the bridge between product intent and implementation detail. It answers the questions developers would otherwise ask during code review: "What happens when this fails?", "How does the user get here?", "What does the loading state look like?"

Nielsen Norman Group's research shows that **systematic heuristic evaluation catches 75% of usability problems before a single line of code is written**. The LATCH method (Location, Alphabet, Time, Category, Hierarchy) provides a universal framework for information organization. Together, these tools turn vague specs into precise blueprints.

The cost of missing UX architecture is paid in rework, developer interruptions, and features that ship incomplete.
</why_now>

<core_principles>
## Core Principles

### 1. Task Flow Completeness

Every user journey needs: entry points, decision trees, success states, error recovery, and edge cases. A flow that only shows "User clicks Save → Data saved" is a liability — it hides the real complexity.

**Test:** Does every flow document what happens when things go wrong? Does it list all entry points to the feature?

Anti-pattern: Flows that only show happy paths, with "→" arrows that skip over the messy reality of errors, permissions, empty states, and slow networks.

### 2. Navigation Architecture

Information Architecture determines how users find features. The three IA components — navigation systems, taxonomies, and full information structure — work together to create findability and discoverability. Apply the LATCH method (Location, Alphabet, Time, Category, Hierarchy) to organize information in ways that match user mental models.

**Test:** Can a new user find any feature within 2 clicks? Can they discover features they didn't know existed?

Anti-pattern: Navigation that mirrors internal code structure ("Ingest | Analyze | Propose") instead of user mental models ("Customers | Opportunities | Discovery Tree").

### 3. Usability Heuristic Evaluation

Nielsen's 10 usability heuristics provide a systematic evaluation framework. Apply them to every spec feature: visibility of system status, match between system and real world, user control and freedom, consistency, error prevention, recognition over recall, flexibility, aesthetic minimalism, error recovery, and help/documentation.

**Test:** Can you cite which heuristic each design decision satisfies? Can you identify which heuristics are violated?

Anti-pattern: Designing without evaluating against established heuristics — relying on intuition instead of systematic analysis.

### 4. Component State Documentation

Every interactive component needs all states documented: default, hover, active/pressed, focus, disabled, loading, error, success. Missing states are the #1 cause of "it looks unfinished" feedback.

**Test:** Does the spec define behavior for all 8 interaction states of each interactive component?

Anti-pattern: Specifying only the default appearance ("dark button with white text") without defining hover, active, focus, disabled, loading, error, and success states.

### 5. Information Hierarchy and Visual Flow

Content should guide the eye through a deliberate visual hierarchy: primary action, secondary information, tertiary details. Every screen has a priority order — the spec must define it explicitly so developers don't guess.

**Test:** Can you describe the visual priority order of any screen in the spec? Can you rank what the user should notice first, second, third?

Anti-pattern: Flat layouts where everything competes for attention — every element the same size, weight, and prominence.

### 6. Responsive Behavior Patterns

Define how layouts adapt across breakpoints, which elements collapse/hide/rearrange, and how interactions change on touch vs pointer devices. For Electron/desktop apps, define window resize behavior and minimum viable dimensions.

**Test:** Does the spec define behavior at mobile, tablet, and desktop? Does it specify minimum window dimensions and sidebar collapse points?

Anti-pattern: Designing only for desktop and hoping mobile/smaller windows "just work."
</core_principles>

<intake>
## What UX/UI architecture work do you need help with?

1. **Write task flows** — Define user journeys with entry/exit points, decision trees, error states
2. **Design navigation architecture** — IA models, LATCH categorization, navigation patterns
3. **Evaluate against heuristics** — Run Nielsen's 10 heuristics evaluation on a spec or feature
4. **Document component states** — Create state matrices for interactive components
5. **Design information hierarchy** — Define visual flow and content priority for screens
6. **Plan responsive behavior** — Breakpoint strategies and layout adaptation patterns
7. **Full UX architecture review** — Comprehensive review of all aspects above
8. **Add UX architecture to a spec** — Enhance an existing discovery spec with UX/UI detail

**Wait for response before proceeding.**
</intake>

<routing>
| Response | Action |
|----------|--------|
| 1, "task flow", "journey", "flow" | Read [task-flow-patterns.md](./references/task-flow-patterns.md), apply template to user's feature |
| 2, "navigation", "IA", "information architecture" | Read [navigation-architecture.md](./references/navigation-architecture.md), map the user's navigation structure |
| 3, "heuristic", "evaluate", "Nielsen", "usability" | Read [usability-heuristics.md](./references/usability-heuristics.md), run systematic evaluation |
| 4, "component state", "state matrix", "interaction state" | Read [component-state-matrix.md](./references/component-state-matrix.md), create matrices for target components |
| 5, "hierarchy", "visual flow", "priority", "layout" | Read [task-flow-patterns.md](./references/task-flow-patterns.md) (information hierarchy section) |
| 6, "responsive", "breakpoint", "mobile", "resize" | Read [responsive-patterns.md](./references/responsive-patterns.md), define adaptation strategy |
| 7, "full review", "comprehensive", "all" | Read all references in parallel, synthesize findings |
| 8, "spec", "enhance", "add to", "improve" | Read all references, apply to existing spec document |

**After reading references, apply patterns to the user's specific context.**
</routing>

<parallel_agents>
## Parallelized Sub-Agents

For comprehensive UX architecture work, launch these agents **in parallel**:

### Analysis Phase (Parallel)
```
┌─────────────────────────┐  ┌─────────────────────────┐  ┌─────────────────────────┐
│ Task Flow Analyzer      │  │ Navigation Mapper       │  │ State Coverage Checker   │
│ → Maps all user         │  │ → Documents IA model    │  │ → Audits component       │
│   journeys, entry       │  │   using LATCH method,   │  │   states documented      │
│   points, error states  │  │   maps nav patterns     │  │   vs states needed       │
└───────────┬─────────────┘  └───────────┬─────────────┘  └───────────┬─────────────┘
            │                            │                            │
            └────────────────┬───────────┘────────────────────────────┘
                             ▼
              ┌─────────────────────────┐
              │ Heuristic Evaluator     │
              │ → Scores spec against   │
              │   all 10 Nielsen        │
              │   heuristics            │
              └─────────────────────────┘
```

### Integration with Other Skills
```
ux-ui-architecture ─────┐
                        ├──→ /discover (spec generation)
spec-architecture ──────┤
                        ├──→ /review-spec (quality audit)
atomic-design-system ───┘
```
</parallel_agents>

<reference_index>
## Reference Files

All references in `references/`:

**Core Patterns:**
- [task-flow-patterns.md](./references/task-flow-patterns.md) — Entry/exit points, decision trees, error recovery, edge case documentation, information hierarchy
- [navigation-architecture.md](./references/navigation-architecture.md) — IA models (NN/G), LATCH method, navigation pattern types, findability/discoverability
- [usability-heuristics.md](./references/usability-heuristics.md) — Nielsen's 10 heuristics as spec evaluation checklist with scoring rubric

**Component & Layout:**
- [component-state-matrix.md](./references/component-state-matrix.md) — Template for documenting all 8 interaction states per component
- [responsive-patterns.md](./references/responsive-patterns.md) — Breakpoint strategies, layout adaptation, touch vs pointer, Electron-specific patterns
</reference_index>

<commands>
## Available Commands

- `/discover` — Generate discovery specs (uses this skill for UX architecture sections)
- `/review-spec` — Review existing specs for UX/UI completeness
- `/refine` — Iterate on UX/UI details after implementation
</commands>

<anti_patterns>
## Anti-Patterns

### Task Flow Anti-Patterns

**Happy-path-only flows** — No error states, no edge cases, no branching
```
✗ 1. User clicks Save → Data saved
✓ 1. User clicks Save →
     IF valid: confirmation toast, data persisted, UI updated
     IF network error: retry banner with offline queue, data preserved locally
     IF validation error: inline field errors, scroll to first error, focus first invalid field
     IF unauthorized: redirect to login, preserve form state for return
```

**Missing entry points** — Only one way into a feature
```
✗ User navigates to Settings → changes profile
✓ Entry points:
   - Sidebar nav "Settings" item
   - User menu dropdown → "Settings"
   - Cmd+, keyboard shortcut
   - Deep link /settings/profile
   - "Edit profile" link on profile card
```

### Navigation Anti-Patterns

**Feature-organized IA** — Navigation mirrors internal code structure, not user mental model
```
✗ Nav: Ingest | Analyze | Propose | Export (internal workflow steps)
✓ Nav: Customers | Opportunities | Discovery Tree | Settings (user concepts)
```

**Orphan pages** — Pages reachable only through deep navigation with no alternative path
```
✗ Settings → Advanced → Integrations → OAuth → Callback Config
✓ Settings → Integrations (with search, direct nav from integration status badges)
```

### State Documentation Anti-Patterns

**Default-only specs** — Only the resting state is designed
```
✗ "Button: dark background with white text"
✓ "Button states:
   - Default: dark gradient (from-[#1E1B18] to-[#37322D]), white text
   - Hover: lighter gradient, cursor pointer
   - Active: pressed shadow inset, slight scale-down
   - Focus: blue ring (ring-2 ring-habitat-500), visible outline
   - Disabled: warm-300 bg, warm-400 text, cursor-not-allowed
   - Loading: spinner replaces label, maintains button width
   - Error: red-500 border, shake animation
   - Success: green check icon, brief flash"
```

### Information Hierarchy Anti-Patterns

**Everything is important** — No visual priority, every element same weight
```
✗ Page with 6 equally-sized cards, all with the same text weight and no primary action
✓ Primary metric (large, top), supporting metrics (smaller, row below), action button (prominent),
  secondary details (collapsed/expandable)
```
</anti_patterns>

<success_criteria>
## Success Criteria

You've built proper UX/UI architecture when:

### Task Flows
- [ ] Every feature has at least one task flow
- [ ] Every flow has all entry points documented (nav, shortcut, deep link, in-context)
- [ ] Every flow has success state AND error states documented
- [ ] Edge cases are explicit (empty states, boundary conditions, permissions, first-time use)
- [ ] Decision trees show branching logic, not just linear steps

### Navigation
- [ ] IA model documented (navigation systems, taxonomies, full structure)
- [ ] LATCH method applied to information organization
- [ ] Navigation patterns match user mental models, not code structure
- [ ] No orphan pages (every page reachable from at least 2 paths)

### Usability
- [ ] Spec evaluated against all 10 Nielsen heuristics
- [ ] Each heuristic has specific evidence or gaps noted
- [ ] Keyboard navigation and shortcuts documented
- [ ] Severity ratings assigned to any heuristic violations

### Component States
- [ ] All interactive components have state matrix
- [ ] All 8 states documented: default, hover, active, focus, disabled, loading, error, success
- [ ] State transitions described (what triggers each change)
- [ ] Accessibility requirements per state (ARIA, focus management)

### Responsive
- [ ] Behavior defined for relevant breakpoints
- [ ] Elements that hide/collapse/rearrange are specified
- [ ] Touch-specific interactions noted (for applicable platforms)
- [ ] Minimum viable dimensions defined

### The Ultimate Test

**Can a developer implement the spec without asking "what happens when...?"**
**Can they handle every edge case without coming back for design review?**

If yes, you've written thorough UX/UI architecture.
</success_criteria>
