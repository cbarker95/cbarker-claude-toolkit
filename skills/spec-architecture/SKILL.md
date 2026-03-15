---
name: spec-architecture
description: Write technically detailed discovery specifications with implementation-depth backend and frontend architecture. Covers data modeling, API/IPC design, dependency analysis, component composition, state management, integration patterns, and per-feature testing strategy. Use when writing or reviewing specs for technical completeness.
---

<why_now>
## Why Spec Architecture Now

The gap between "spec written" and "feature built correctly" almost always comes down to missing technical architecture. A spec that says "Add health dashboard to Home page" without specifying the data model, IPC handlers, component tree, and state management creates a feature that works differently than intended — or requires constant developer questions during implementation.

For autonomous build systems like go-commando, this gap is fatal. There's no developer to ask clarifying questions. The spec IS the developer's entire understanding of what to build. Missing architecture means missing functionality.

Spec architecture gives you "lead dev experience" in document form:
- **Data model** tells you what tables/columns to create and what queries to write
- **API contracts** tell you the exact channel names, request/response types, and error shapes
- **Component trees** tell you what composes what and where state lives
- **Dependency graphs** tell you what order to build things in
- **Test strategy** tells you what to verify at each step

If a developer can implement a 🟪 feature without asking "how does this connect to the rest of the system?" — the spec architecture is complete.
</why_now>

<core_principles>
## Core Principles

### 1. Data Model First

Every feature starts with its data. What entities exist? What are their relationships? What columns do they need? What queries will the UI require? Schema design constrains everything downstream — get it wrong and you're refactoring everything.

**Test:** Can you describe the exact database tables, columns, types, and relationships this feature needs? Can you write the CREATE TABLE statement?

Anti-pattern: Implementing UI components before defining the data model. You end up bending the data to fit the UI instead of the UI reflecting the data.

### 2. Dependency Graph Awareness

Every feature touches existing code. A new dashboard section needs store methods, IPC handlers, React hooks, and UI components — each depending on the previous layer. Map what exists, what needs modification, and what needs creation. This determines build order.

**Test:** Can you draw a dependency graph showing what imports what, what depends on what, and what order to build?

Anti-pattern: Building features without analyzing impact on existing code. "Just add a button" becomes a 10-file change when you discover missing store methods, untyped IPC channels, and absent query patterns.

### 3. API Contract Specification

Define the contract between layers before implementation. In Electron apps, this means IPC channel names with typed request/response shapes. In web apps, REST/GraphQL endpoints with payloads. Contracts enable parallel work — frontend and backend can be built simultaneously.

**Test:** Could a frontend developer and a backend developer work in parallel from this spec, meeting at defined contracts?

Anti-pattern: Implementing backend and frontend sequentially because contracts aren't defined upfront. One side guesses what the other needs.

### 4. Component Composition Architecture

Components compose into trees. The spec must define which component contains which, how data flows through props, where state lives (local, lifted, React Query, context), and which existing components to reuse vs create new.

**Test:** Can you draw the component tree with data flow arrows showing which component owns which state?

Anti-pattern: Flat component lists ("we need ComponentA, ComponentB, ComponentC") without showing how they compose together or how data flows between them.

### 5. Error Handling Strategy

Errors are architecture, not afterthought. Define error categories (validation, network, permission, system), where each is caught, how each surfaces to the user, and what recovery paths exist. Every data fetch needs an error state. Every mutation needs a failure path.

**Test:** For every async operation in the spec, can you describe what happens when it fails?

Anti-pattern: Adding try/catch blocks at the end as cleanup. Error handling should be part of the initial design, not a retrofit.

### 6. Test-Alongside Strategy

Every 🟪 feature in a spec includes its test files. Tests are not a separate phase. The Docs/Specifications/CLAUDE.md explicitly says: "DO NOT write the plan so all the tests are written in the final phase!" Testing is part of building, not a step after building.

**Test:** Does every 🟪 feature in the spec list test files alongside implementation files?

Anti-pattern: A spec with 10 🟪 features where none mention tests, followed by a final "🟪 11. Add tests for all features" — this always produces incomplete test coverage.
</core_principles>

<intake>
## What spec architecture work do you need help with?

1. **Backend architecture** — Data model, API/IPC design, store methods, migrations, error handling
2. **Frontend architecture** — Component hierarchy, state management, data fetching patterns, hooks
3. **Dependency analysis** — Trace what's affected, identify build order, map shared code
4. **Integration patterns** — IPC contracts, API boundaries, event systems, type sharing
5. **Testing strategy** — Per-feature test planning, test types per layer, test-alongside patterns
6. **Full architecture review** — Comprehensive backend + frontend + integration review
7. **Add architecture to a spec** — Enhance an existing discovery spec with technical detail

**Wait for response before proceeding.**
</intake>

<routing>
| Response | Action |
|----------|--------|
| 1, "backend", "data model", "API", "database", "store", "SQLite" | Read [backend-architecture-patterns.md](./references/backend-architecture-patterns.md) |
| 2, "frontend", "component", "state", "React", "hook", "UI" | Read [frontend-architecture-patterns.md](./references/frontend-architecture-patterns.md) |
| 3, "dependency", "build order", "affected", "impact", "order" | Read [dependency-analysis.md](./references/dependency-analysis.md) |
| 4, "IPC", "integration", "contract", "event", "API boundary" | Read [integration-patterns.md](./references/integration-patterns.md) |
| 5, "test", "testing", "coverage", "verify" | Read [testing-strategy.md](./references/testing-strategy.md) |
| 6, "full", "comprehensive", "review", "all" | Read all references in parallel, synthesize findings |
| 7, "spec", "enhance", "add to", "improve" | Read all references, apply to existing spec document |

**After reading references, apply patterns to the user's specific context.**
</routing>

<parallel_agents>
## Parallelized Sub-Agents

For comprehensive architecture work, launch these agents **in parallel**:

### Analysis Phase (Parallel)
```
┌─────────────────────────┐  ┌─────────────────────────┐  ┌─────────────────────────┐
│ Backend Analyzer        │  │ Frontend Analyzer       │  │ Dependency Tracer       │
│ → Reads store.ts,       │  │ → Reads component dirs, │  │ → Maps imports/exports, │
│   types.ts, db schema   │  │   hooks, pages          │  │   identifies affected   │
│ → Designs data model,   │  │ → Designs component     │  │   modules, determines   │
│   store methods, IPC    │  │   tree, state, hooks    │  │   build order           │
└───────────┬─────────────┘  └───────────┬─────────────┘  └───────────┬─────────────┘
            │                            │                            │
            └────────────────┬───────────┘────────────────────────────┘
                             ▼
              ┌─────────────────────────┐
              │ Integration Synthesizer │
              │ → Reconciles backend +  │
              │   frontend contracts,   │
              │   defines IPC channels, │
              │   assigns test strategy │
              └─────────────────────────┘
```

### Integration with Spec Generation
```
spec-architecture ──────┐
                        ├──→ /discover (spec generation with technical depth)
ux-ui-architecture ─────┤
                        ├──→ /review-spec (architecture quality audit)
atomic-design-system ───┘
```
</parallel_agents>

<reference_index>
## Reference Files

All references in `references/`:

**Backend:**
- [backend-architecture-patterns.md](./references/backend-architecture-patterns.md) — Data modeling, SQLite patterns, store methods, IPC handlers, migrations, error handling

**Frontend:**
- [frontend-architecture-patterns.md](./references/frontend-architecture-patterns.md) — Component trees, state management, React Query patterns, hook architecture, atomic design composition

**Integration:**
- [dependency-analysis.md](./references/dependency-analysis.md) — Dependency graphs, build order algorithm, impact analysis, shared code identification
- [integration-patterns.md](./references/integration-patterns.md) — IPC contracts, API boundaries, event systems, type sharing

**Quality:**
- [testing-strategy.md](./references/testing-strategy.md) — Test-alongside pattern, test pyramid, per-layer testing, test types
</reference_index>

<commands>
## Available Commands

- `/discover` — Generate discovery specs (uses this skill for technical architecture sections)
- `/review-spec` — Review existing specs for architecture completeness
- `/implement` — Build specs autonomously (benefits from detailed architecture)
</commands>

<anti_patterns>
## Anti-Patterns

### Backend Anti-Patterns

**UI before data model** — Building components without knowing what data they display
```
✗ "Create HealthDashboard component" (what data? what format? where from?)
✓ "Add health_scores table (id, workspace_id, computed_at, composite_score, metrics JSON)
   → Store.getLatestHealthScore() method → IPC health:latest handler → useDiscoveryHealth hook
   → HealthDashboard component consuming hook data"
```

**No migration plan** — Adding tables without considering existing databases
```
✗ "Add new table" (what about existing databases? data migration?)
✓ "Migration: ALTER TABLE ADD COLUMN with default value. Existing rows get default.
   Migration runs on store initialization, version tracked in _migrations table."
```

### Frontend Anti-Patterns

**Flat component lists** — No composition relationships
```
✗ "Build: HealthGauge, MetricCard, TrendChart, ActionButton"
✓ "HealthDashboard (organism)
   ├── HealthGauge (molecule) ← useDiscoveryHealth().compositeScore
   ├── MetricCardGrid (molecule)
   │   └── MetricCard × 8 (atom) ← useDiscoveryHealth().metrics
   └── SuggestionList (molecule) ← useDiscoveryHealth().suggestions"
```

**God components** — Single component handling display, state, data fetching, and business logic
```
✗ HealthDashboard fetches data, manages filter state, computes trends, renders charts, handles errors
✓ useDiscoveryHealth (data fetching) → HealthDashboard (composition) → HealthGauge (display only)
   Each layer has one job.
```

### Testing Anti-Patterns

**Tests at the end** — Separate testing phase after all features built
```
✗ "🟪 10. Write tests for features 1-9"
✓ Every 🟪 feature lists its test files alongside implementation files:
   🟪 1. Health scorer
   Files: src/core/discovery-health.ts (new), src/core/discovery-health.test.ts (new)
```

### Dependency Anti-Patterns

**No build order** — Features listed without dependency analysis
```
✗ "🟪 1. Dashboard UI, 🟪 2. Database tables, 🟪 3. IPC handlers"
   (UI depends on IPC, IPC depends on DB — wrong order!)
✓ "🟪 1. Types + DB tables, 🟪 2. Store methods + IPC, 🟪 3. Hooks, 🟪 4. Dashboard UI"
   (each depends only on previous items)
```
</anti_patterns>

<success_criteria>
## Success Criteria

You've built proper spec architecture when:

### Data Model
- [ ] Every feature's data entities are defined (tables, columns, types, constraints)
- [ ] Relationships between entities are explicit (foreign keys, join tables)
- [ ] Queries needed by the UI are listed (not just tables)
- [ ] Migration strategy defined for schema changes

### API Contracts
- [ ] IPC channels named with types (e.g., `health:latest` → `HealthScore`)
- [ ] Request and response shapes defined (TypeScript types)
- [ ] Error response shapes defined
- [ ] Handler registration pattern documented

### Component Architecture
- [ ] Component tree shows composition (what contains what)
- [ ] Data flow arrows show which component owns state
- [ ] Existing components identified for reuse (with atomic level)
- [ ] New components classified by atomic level
- [ ] State management approach defined per component (local, Query, context)

### Dependencies
- [ ] Dependency graph drawn (what imports what)
- [ ] Build order follows topological sort (no-dependency items first)
- [ ] Shared code (types, utils) identified and built first
- [ ] Impact analysis shows existing files affected

### Error Handling
- [ ] Error categories defined (validation, network, permission, system)
- [ ] Each async operation has a failure path
- [ ] Error messages are user-facing (not developer jargon)
- [ ] Recovery paths defined (retry, fallback, escalate)

### Testing
- [ ] Every 🟪 feature lists test files alongside implementation files
- [ ] Test types appropriate per layer (unit for store, component for UI)
- [ ] No final "testing phase" exists
- [ ] Error cases have test coverage

### The Ultimate Test

**Can a developer implement any 🟪 feature without asking "how does this connect to the rest of the system?"**
**Can they build it in isolation and have it integrate correctly?**

If yes, you've written thorough spec architecture.
</success_criteria>
