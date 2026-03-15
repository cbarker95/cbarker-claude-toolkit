# Dependency Analysis

## Purpose

Dependency analysis determines what order to build things. In a spec with 10 features, building them in the wrong order means constantly revisiting completed work. This reference covers how to trace dependencies, map affected modules, and derive build order using topological sort.

---

## The Foundation-First Principle

Build in this order — each layer depends only on layers above it:

```
Layer 1: Types and Interfaces
  └── Pure type definitions, no imports from other layers

Layer 2: Data Layer (Store, Database)
  └── Imports only from Layer 1 (types)

Layer 3: Business Logic (Agents, Processors)
  └── Imports from Layers 1-2 (types + store)

Layer 4: Integration (IPC Handlers, API Routes)
  └── Imports from Layers 1-3 (types + store + business logic)

Layer 5: Data Hooks
  └── Imports from Layer 1 (types) + calls Layer 4 (IPC/API)

Layer 6: UI Components
  └── Imports from Layer 1 (types) + Layer 5 (hooks) + other components

Layer 7: Pages
  └── Imports from Layers 5-6 (hooks + components)
```

### Spec Implication

🟪 features should be ordered following this layer sequence:
1. Types + database schema
2. Store methods
3. Business logic / agents
4. IPC handlers
5. React hooks
6. UI components (atoms → molecules → organisms)
7. Pages (wiring components + hooks)

---

## Dependency Graph Notation

### ASCII Diagram Convention

```
A ──→ B       A depends on B (A imports from B)
A ──→ B ──→ C A depends on B, B depends on C
A ─┬→ B      A depends on both B and C
   └→ C
```

### Example: Health Dashboard Dependencies

```
types.ts (HealthScore, HealthMetric types)
    │
    ├──→ store.ts (health_scores table, CRUD methods)
    │        │
    │        └──→ ipc.ts (health:latest, health:trend handlers)
    │                │
    │                └──→ useDiscoveryHealth.ts (React Query hook)
    │                        │
    │                        └──→ DiscoveryHealthSection.tsx (organism)
    │                                │
    │                                ├──→ ScoreGauge.tsx (molecule)
    │                                ├──→ MetricCard.tsx (molecule)
    │                                └──→ HomeDashboard.tsx (page — modify)
    │
    └──→ discovery-health.ts (computation logic)
             │
             └──→ ipc.ts (health:compute handler)
```

### Reading the Graph

- **Leaves** (no outgoing arrows) = build first (types.ts)
- **Roots** (no incoming arrows) = build last (HomeDashboard.tsx)
- **Topological order** = any ordering where dependencies come before dependents

---

## Build Order Algorithm

### Step 1: List All Files

For each 🟪 feature, list every file that needs creation or modification.

### Step 2: Map Dependencies

For each file, list what it imports from (within this feature).

### Step 3: Topological Sort

Files with no dependencies → build first. Then files whose dependencies are all built. Repeat.

### Example

| File | Depends On | Build Order |
|------|-----------|-------------|
| types.ts (modify) | nothing | 1st |
| store.ts (modify) | types.ts | 2nd |
| discovery-health.ts (new) | types.ts, store.ts | 3rd |
| ipc.ts (modify) | store.ts, discovery-health.ts | 4th |
| useDiscoveryHealth.ts (new) | types.ts (via IPC) | 5th |
| ScoreGauge.tsx (new) | types.ts | 5th (parallel) |
| MetricCard.tsx (new) | types.ts | 5th (parallel) |
| DiscoveryHealthSection.tsx (new) | useDiscoveryHealth, ScoreGauge, MetricCard | 6th |
| HomeDashboard.tsx (modify) | DiscoveryHealthSection | 7th |

### Grouping into 🟪 Features

Combine build-order-adjacent files into 🟪 features:

```markdown
🟪 1. Foundation: Types + database schema
Files: types.ts (modify), store.ts (modify)

🟪 2. Core: Health computation logic
Files: discovery-health.ts (new), discovery-health.test.ts (new)

🟪 3. Integration: IPC handlers
Files: ipc.ts (modify)

🟪 4. Data: React hooks
Files: useDiscoveryHealth.ts (new)

🟪 5. Components: Score display
Files: ScoreGauge.tsx (new), MetricCard.tsx (new)

🟪 6. Page: Health dashboard section
Files: DiscoveryHealthSection.tsx (new), HomeDashboard.tsx (modify)
```

Each 🟪 depends only on previously completed 🟪 items.

---

## Impact Analysis

### When Modifying an Existing File

Ask: "What other files import from this file?"

```markdown
### Impact Analysis: Modifying store.ts

**Adding:** health_scores table, 4 new methods

**Files that import store.ts:**
- src/core/analysis.ts — not affected (doesn't use health methods)
- src/core/ingestion.ts — not affected
- src/core/agents/customer-extraction.ts — not affected
- desktop/src/main/ipc.ts — AFFECTED (needs new handlers)
- src/commands/status.ts — AFFECTED (could show health in status)

**Risk:** Low — additive changes only, no existing API changes
```

### When Modifying Types

Type changes ripple through the entire dependency chain:

```markdown
### Impact Analysis: Adding HealthScore type to types.ts

**Direct dependents:**
- store.ts — will use new type
- discovery-health.ts — will produce this type
- ipc.ts — will transport this type

**Indirect dependents:**
- useDiscoveryHealth.ts — hook return type
- DiscoveryHealthSection.tsx — component props

**Risk:** None — purely additive (new type, no changes to existing types)
```

---

## Shared Code Identification

### Types Used by Multiple Features

If multiple 🟪 features need the same types, put types in the FIRST 🟪:

```markdown
🟪 1. Foundation: Types + shared infrastructure
  - HealthScore, HealthMetric types (used by features 2-6)
  - CadenceData type (used by features 3, 5)
  - Common utility functions
```

### Components Used by Multiple Features

If multiple 🟪 features need the same component, build the component BEFORE both:

```
🟪 3. Component: MetricCard (used by Health Dashboard AND Cadence Widget)
🟪 4. Page section: Health Dashboard (uses MetricCard)
🟪 5. Page section: Cadence Widget (uses MetricCard)
```

### Utilities and Helpers

Shared utilities go in foundation:

```
🟪 1. Foundation
  - Date formatting utility (used by health trend charts, cadence display, activity feed)
  - Score color mapping utility (used by health gauge, metric cards, badges)
```

---

## Circular Dependency Detection

### Red Flag Patterns

```
✗ ComponentA imports ComponentB, ComponentB imports ComponentA
  → Extract shared logic into a third module both import from

✗ Hook imports from component, component imports hook
  → Hook should only export data/functions, component only consumes

✗ Store imports from IPC handler, IPC handler imports from Store
  → IPC handler calls Store (one-way), never the reverse
```

### Resolution Pattern

```
Before (circular):
  A ←→ B

After (extracted shared dependency):
  A ──→ C ←── B
  (A and B both depend on C, not on each other)
```

---

## Spec Notation for Dependencies

Include a dependency section in each spec:

```markdown
## Build Order and Dependencies

### Dependency Graph
{ASCII diagram showing file relationships}

### Build Sequence
| Phase | 🟪 Feature | Depends On | Files |
|-------|-----------|-----------|-------|
| 1 | Foundation | — | types.ts, store.ts |
| 2 | Core logic | Phase 1 | discovery-health.ts |
| 3 | Integration | Phases 1-2 | ipc.ts |
| 4 | Hooks | Phases 1, 3 | useDiscoveryHealth.ts |
| 5 | Components | Phase 1 | ScoreGauge.tsx, MetricCard.tsx |
| 6 | Page | Phases 4-5 | DiscoveryHealthSection.tsx |

### Shared Resources
| Resource | Used By | Created In |
|----------|---------|-----------|
| HealthScore type | Phases 2-6 | Phase 1 |
| MetricCard component | Phases 5-6 | Phase 5 |
```

---

## Anti-Patterns

### No Build Order
```
✗ 🟪 features listed in random order without dependency analysis
✓ 🟪 features ordered by dependency graph — each depends only on prior items
```

### Circular Dependencies Between Features
```
✗ 🟪 3 depends on 🟪 5, and 🟪 5 depends on 🟪 3
✓ Extract shared dependency into 🟪 2, both 3 and 5 depend on 2
```

### Shared Code in Wrong Phase
```
✗ Shared MetricCard component defined in 🟪 6, but needed by 🟪 4
✓ Shared MetricCard in its own earlier 🟪, before all consumers
```
