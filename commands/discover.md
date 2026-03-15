---
allowed-tools: Read, Write, Edit, Glob, Grep, Task, AskUserQuestion, EnterPlanMode, ExitPlanMode
description: Research codebase and generate a discovery specification for go-commando to build
---

# Discover Command

Research the codebase, clarify requirements, and generate a discovery specification — a structured document with 🟪 markers that go-commando + `/implement` can build autonomously. This is the thinking step before building — it answers "what should we build and how should it be structured?" so that go-commando can build it.

## Usage

```
/discover [feature area or brief description]
/discover                    — asks what to discover
```

---

## Step 1: Understand the Discovery

If `$ARGUMENTS` is empty, **STOP HERE.** Ask the user:

```
What feature area should I research and spec out?

  - A new page or module (describe the user problem it solves)
  - An extension to an existing feature (which feature, what's missing)
  - A broad product area (describe)
  - Something else (describe)
```

**Do not proceed until the user has replied.**

If `$ARGUMENTS` is provided, confirm the scope. **STOP HERE** and present:

```
Discovering: [what was described]

I'll research the codebase and generate a discovery specification that go-commando can build.
The spec will include components, pages, data layers, and implementation details.

Proceed with research?
```

**Do not proceed until the user has confirmed.**

---

## Step 2: Enter Plan Mode

**Immediately call `EnterPlanMode`.** The entire discovery process — research, analysis, and spec drafting — happens inside plan mode. The discovery spec IS the plan. The user will review the complete spec before anything is saved to disk.

**This is mandatory. Do not skip this step.**

---

## Step 3: Check for Existing Specs and Template

Before researching, check what already exists:

1. Look for an existing spec at `Docs/Specifications/{Feature}/README.md`
2. Read the discovery spec template from `templates/discovery-spec-template.md` for the expected format. If not found, check `Docs/Specifications/_templates/discovery-spec-template.md` as a fallback.

If an existing spec is found, ask whether to update it or start fresh.

---

## Step 4: Parallel Discovery

Launch these sub-agents **in parallel** using the Task tool:

### Agent 1: Existing Documentation & Architecture

```
subagent_type: Explore
prompt: "Review the project architecture relevant to [feature area]:

1. Read CLAUDE.md for conventions, architecture, and build commands
2. Check for existing product context:
   - docs/product/PRD.md (if it exists — extract product area, personas, priorities)
   - Any existing specs in Docs/Specifications/ related to this area
3. Read README.md for product description and setup
4. Identify architectural patterns, conventions, and constraints

Return:
- Product context (if found)
- Target users for this feature
- Any existing specs or documentation
- Key architectural constraints or patterns to follow"
```

### Agent 2: Codebase Feature Analysis

```
subagent_type: Explore
prompt: "Analyze what's currently built in this repository relevant to [feature area]:

1. What pages/routes/endpoints exist?
2. What components/modules exist?
3. What patterns are established (state management, data flow, styling)?
4. What would be easy to extend vs. what requires new infrastructure?
5. Are there partially built features or stubs?

Create a feature inventory:
- BUILT: Fully functional
- PARTIAL: Started but incomplete
- MISSING: Referenced but not implemented

Return a feature map with classification, file locations, and reusable patterns."
```

### Agent 3: Design & UX Analysis

```
subagent_type: Explore
prompt: "Analyze the UI/UX patterns relevant to [feature area]:

1. Read docs/design/DESIGN_LANGUAGE.md if it exists
2. Examine existing components for visual patterns, layout conventions
3. Identify reusable components and design tokens
4. Look at user flows — how does navigation work?

Return:
- Design language constraints (if found)
- Reusable UI components
- Layout and navigation patterns
- Data display patterns (tables, cards, lists)"
```

### Agent 4: Technical Architecture Analysis

```
subagent_type: Explore
prompt: "Analyze the backend technical architecture relevant to [feature area]:

1. Read src/types.ts for existing type definitions and naming conventions
2. Read src/core/store.ts for data access patterns (SQLite, WAL mode, method signatures)
3. Read desktop/src/main/ipc.ts for IPC channel patterns and handler conventions
4. Identify what store methods, types, and IPC handlers already exist
5. Map the data flow: Store → IPC handler → preload bridge → React hook → Component

Return:
- Existing data model relevant to this feature (tables, types)
- IPC channel naming patterns to follow (domain:action format)
- Store method patterns to follow (create/get/list/update/delete)
- State management approach in use (React Query for server data, useState for UI)
- Hook patterns (TanStack Query keys, fetch patterns, invalidation)"
```

### Agent 5: Component Design System Analysis

```
subagent_type: Explore
prompt: "Analyze the component design system relevant to [feature area]:

1. List all components in desktop/src/renderer/components/:
   - atoms/ (primitive elements — Button, Input, Badge, Card, etc.)
   - molecules/ (composed units — SearchInput, SegmentedControl, TabBar, etc.)
   - organisms/ (complex sections — DataTable, Sidebar, OSTCanvas, etc.)
   - templates/ (page layouts — AppLayout, etc.)
2. Read docs/design/DESIGN_LANGUAGE.md for visual constraints
3. For components likely relevant to this feature, read their source to understand props and variants
4. Identify which existing components can be reused for this feature
5. Identify what new components would need to be created

Return:
- Full component inventory by atomic level with brief purpose
- Design language constraints (4px grid, warm colors, skeuomorphic buttons, etc.)
- Component reuse map: existing component → proposed use in this feature
- New components needed with suggested atomic level (atom/molecule/organism)
- Any design system anti-patterns to avoid (pure white bg, blue CTAs, custom fonts)"
```

---

## Step 5: Synthesize and Present Discovery Summary

After agents complete, synthesize findings into a summary. **STOP HERE** and present to the user:

```text
Discovery summary: [Feature Name]

  Existing code:
    - [BUILT items relevant to this feature]
    - [PARTIAL items that can be extended]
    - [MISSING items that need building]

  Proposed discovery spec:
    Components: [N] ([names])
    Pages/Views: [N] ([names])
    Data hooks/services: [N]

  Estimated 🟪 features: [N] items for go-commando to build

  Should I generate the full discovery specification?

Options:
  - Generate spec (I'll write it for your review before saving)
  - Adjust scope (describe changes)
  - Cancel
```

**Do not proceed until the user has confirmed.** Wait silently.

---

## Step 6: Draft the Spec to the Plan File

Write the full discovery spec to the plan file. Since you are already in plan mode (from Step 2), the user will see this spec for review when you call `ExitPlanMode`.

The spec will eventually go to `Docs/Specifications/{Feature}/README.md`, but only after the user approves the plan.

### Spec Structure

The spec must include ALL of the following sections. Use the `ux-ui-architecture` skill references for task flows/navigation and the `spec-architecture` skill references for backend/frontend architecture. Use the `atomic-design-system` skill for component classification.

```markdown
# {Feature Name} — Discovery Specification

> **Run**: `node scripts/go-commando.js implement {SpecFolderName}`
>
> This spec is designed for autonomous execution via go-commando.js + /implement.
> Each 🟪 section is a self-contained unit of work. /implement will pick the next
> unfinished 🟪, build it, mark it ✅, and commit. The loop continues until all
> features are complete.

## Overview

{What this feature does and why — 2-3 sentences focused on user problem}

Covers: {comma-separated list of capabilities this spec delivers}

## Task Flows

### Flow 1: {Primary user journey}
**User**: {persona — e.g., PM starting their Monday}
**Entry point**: {where — nav link, dashboard action, notification, keyboard shortcut}

1. User {action} → System {response}
   - IF {condition A}: {behavior}
   - IF {condition B}: {behavior}
2. User {action} → System {response}
3. ...

**Success**: {observable outcome for the user}
**Error states**: {network failure, validation error, permission denied — with recovery}
**Edge cases**: {empty state, first-time use, boundary conditions, concurrent access}

### Flow 2: {Secondary user journey}
{Repeat for each distinct user journey — typically 2-4 flows}

## Architecture

{ASCII tree diagram showing component composition, data flow, navigation}

## Backend Architecture

### Data Model
{Table definitions with columns, types, constraints, relationships, indices}

### Store Methods
{Method signatures following existing naming patterns: create/get/list/update/delete}

### IPC Handlers
{Channel names with request/response types following domain:action convention}

### Error Handling
{Error categories (validation, network, permission, system) with recovery strategies}

## Frontend Architecture

### Component Tree
{ASCII tree showing composition with data flow annotations:
 PageName (page)
 ├── Organism ← useHook().data
 │   ├── Molecule
 │   └── Atom
 └── ...}

### State Management
{Table: state item | type (server/UI/derived) | owner component | mechanism (Query/local/context)}

### Data Fetching
{Hook definitions with query keys, stale times, invalidation strategy}

## Component Usage

### Reused Components
{Table: UI need | existing component | atomic level | location}

### New Components
{Table: component name | atomic level (atom/molecule/organism) | purpose}

## Design System Compliance
{References to DESIGN_LANGUAGE.md tokens and patterns applied — colors, spacing, typography, component variants}

## Scope

- **Core**: {backend modules, business logic}
- **Desktop**: {pages, components, hooks}
- **Out of scope**: {what this spec explicitly does NOT cover}

---

## Features

🟪 ### 1. Foundation: {types, database schema, shared infrastructure}
{description — types and data model come first, everything depends on them}
**Files:**
- [type definitions with (new) or (modify)]
- [store modifications with (modify)]
- [test files with (new)]

🟪 ### 2. Integration: {IPC handlers, API routes}
{description — bridge between data layer and UI}
**Files:**
- [handler files with (modify)]
- [test files]

🟪 ### 3. Data hooks: {React Query hooks}
{description — data fetching layer consumed by components}
**Files:**
- [hook files with (new)]
- [test files]

🟪 ### 4. Component: {Name}
{description — UI component with atomic level classification}
**Files:**
- [component files with (new)]
- [test files]

🟪 ### 5. Page: {PageName}
{description — wires components together with hooks}
**Files:**
- [page files with (new) or (modify)]
- [test files]
```

### Rules for Spec Generation

- **Every 🟪 feature must be self-contained** — completable in a single go-commando iteration
- **Foundation always comes first** — types, database schema, shared infrastructure
- **Build order follows dependency graph** — types → store → IPC → hooks → components → pages
- **Components before pages** — build parts, then assemble
- **Data layer before UI** — hooks and store methods before components that consume them
- **Every 🟪 must include test files** — no separate testing phase at the end
- **File paths must follow project conventions** (read from CLAUDE.md)
- **Each feature lists its files** with (new) or (modify) annotations
- **Keep features small** — if a 🟪 item would take more than ~10 minutes, split it
- **Backend architecture must define data model** — tables, store methods, IPC channels
- **Frontend architecture must show component tree** — composition, data flow, state management
- **Component reuse is mandatory** — reference existing atomic design system components before creating new ones
- **Dependency analysis determines build order** — run topological sort on feature dependencies

### Skill References for Spec Quality

When writing the spec, consult these skill references for patterns and templates:

**UX/UI Architecture** (`skills/ux-ui-architecture/references/`):
- `task-flow-patterns.md` — Entry points, decision trees, error recovery, edge case checklist
- `navigation-architecture.md` — IA models, LATCH method, navigation patterns
- `usability-heuristics.md` — Nielsen's 10 heuristics as evaluation checklist
- `component-state-matrix.md` — 8 interaction states per component

**Spec Architecture** (`skills/spec-architecture/references/`):
- `backend-architecture-patterns.md` — Data model, store methods, IPC handlers, migrations
- `frontend-architecture-patterns.md` — Component trees, state management, React Query patterns
- `dependency-analysis.md` — Build order, impact analysis, shared code identification
- `integration-patterns.md` — IPC contracts, type sharing, event systems
- `testing-strategy.md` — Test-alongside pattern, test types per layer

---

## Step 6.5: Quality Checklist

Before presenting the spec for approval, verify ALL of these items. If any fail, revise the spec before proceeding.

### Task Flows
- [ ] Every feature has at least one task flow with entry points and error states
- [ ] Task flows include decision trees (IF/THEN/ELSE branching), not just linear steps
- [ ] Edge cases are documented (empty states, first-time use, boundary conditions)
- [ ] Multiple entry points listed per feature (nav, shortcut, deep link, in-context action)

### Backend Architecture
- [ ] Data model defines tables with columns, types, constraints, and indices
- [ ] Store methods listed with signatures matching existing codebase patterns
- [ ] IPC channels named with domain:action convention and typed request/response
- [ ] Error handling defined per operation (validation, network, permission, system)

### Frontend Architecture
- [ ] Component tree diagram shows composition hierarchy with data flow annotations
- [ ] State management specified per state item (React Query, useState, context)
- [ ] Data fetching hooks defined with query keys and invalidation strategy
- [ ] New components classified by atomic level (atom/molecule/organism)

### Component Usage
- [ ] Existing components from atoms/molecules/organisms identified for reuse
- [ ] New components created only when no existing component fits
- [ ] Reuse justification provided for each decision

### Design System
- [ ] DESIGN_LANGUAGE.md tokens referenced (colors, spacing, typography)
- [ ] 4px grid compliance (all dimensions multiples of 4px)
- [ ] No anti-patterns (pure white bg, blue CTAs, custom fonts)

### Build Order
- [ ] 🟪 features follow dependency graph (foundation → store → IPC → hooks → components → pages)
- [ ] Each 🟪 depends only on previously completed 🟪 items
- [ ] Shared code (types, utilities) appears in earliest possible 🟪
- [ ] Each 🟪 is self-contained (completable in single go-commando iteration)

### Testing
- [ ] Every 🟪 feature lists test files alongside implementation files
- [ ] No final "testing phase" 🟪 exists
- [ ] Test cases cover error/edge scenarios, not just happy paths

**If any checklist item fails, revise the spec before proceeding to ExitPlanMode.**

---

## Step 7: Exit Plan Mode for Approval

Once the spec is complete in the plan file, call `ExitPlanMode`. The user will see the full spec and can:
- **Approve** — proceed to save
- **Request changes** — iterate on the spec in plan mode
- **Reject** — stop without saving

**Do not write the spec to `Docs/Specifications/` until the user approves the plan.**

---

## Step 8: Save and Report

After the user approves the plan, write the spec to `Docs/Specifications/{Feature}/README.md`. Create the directory if needed. Then output:

```text
Discovery spec saved: Docs/Specifications/{Feature}/README.md

  Features: [N] items ready for go-commando
  Estimated build: [rough estimate based on feature count]

  To build autonomously:
    node scripts/go-commando.js implement {Feature}

  To refine after building:
    /refine [specific issue]
```

---

## Notes

- The discovery spec is the input to go-commando + `/implement` — it defines what gets built
- Each 🟪 item should be completable in one `/implement` session (typically 1 component, 1 hook group, or 1 page)
- Keep the spec focused on what to build — detailed enough for autonomous execution, not a novel
- Run `/discover` again to add features to an existing spec or create a new one
- After go-commando builds the spec, use `/refine` for polish
- Run `/review-spec` to evaluate an existing spec's quality and auto-improve it
- The spec uses patterns from `ux-ui-architecture`, `spec-architecture`, and `atomic-design-system` skills
- Specs describe the destination (living documents) — plans describe how to get there (temporary)
