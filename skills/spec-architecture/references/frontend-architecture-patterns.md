# Frontend Architecture Patterns

## Purpose

Frontend architecture patterns for discovery specs. Covers component hierarchy notation, state management decisions, React Query patterns, hook architecture, and atomic design composition. These patterns produce specs where the component tree, data flow, and state ownership are unambiguous.

---

## Component Hierarchy Notation

Use ASCII trees to show composition. Include data flow annotations.

### Basic Tree
```
PageName (page)
├── HeaderSection (organism) ← usePageData().title
│   ├── BreadcrumbNav (molecule) ← route context
│   └── ActionBar (molecule)
│       ├── Button (atom) "Save"
│       └── Button (atom) "Cancel"
├── ContentArea (organism) ← usePageData().content
│   ├── FilterBar (molecule) ← local state: filters
│   ├── DataTable (organism) ← useListData(filters)
│   │   └── TableRow × N (molecule) ← row data via props
│   └── EmptyState (molecule) ← shown when data.length === 0
└── SidePanel (organism) ← conditional: open state
    └── DetailView (molecule) ← useDetailData(selectedId)
```

### Notation Guide

| Symbol | Meaning |
|--------|---------|
| `←` | Data source (hook, props, context) |
| `× N` | Rendered multiple times (list/map) |
| `(atom)` | Atomic level classification |
| `local state:` | Component owns this state |
| `conditional:` | Only rendered when condition met |

---

## State Management Decision Tree

### Where Should State Live?

```
Is this state from the server? (database, API)
├── YES → React Query (TanStack Query)
│         - Automatic caching, refetching, invalidation
│         - useQuery for reads, useMutation for writes
│
└── NO → Is it UI-only state?
         ├── YES → Does only ONE component need it?
         │         ├── YES → useState (local)
         │         │         - Filter values, open/closed, input text
         │         │
         │         └── NO → Do SIBLINGS need it?
         │                  ├── YES → Lift to parent (props down)
         │                  │         - Selected item, active tab
         │                  │
         │                  └── NO → Do DISTANT components need it?
         │                           ├── YES → React Context
         │                           │         - Theme, auth, workspace
         │                           │
         │                           └── NO → Lift to nearest common parent
         │
         └── NO → Is it derived from server + UI state?
                  └── YES → useMemo or computed in render
                            - Filtered lists, sorted data
```

### Spec Notation for State

```markdown
### State Management

| State | Type | Owner | Mechanism |
|-------|------|-------|-----------|
| Health score data | Server | useDiscoveryHealth hook | React Query |
| Selected metric | UI | HealthDashboard | useState |
| Sidebar collapsed | UI (persistent) | AppLayout | localStorage + useState |
| Current workspace | App-wide | WorkspaceContext | React Context |
| Filtered opportunities | Derived | OpportunityList | useMemo(data, filters) |
```

---

## React Query (TanStack Query) Patterns

### Query Keys Convention

```
['domain', 'action', ...params]

Examples:
['health', 'latest', workspaceId]
['health', 'trend', workspaceId, days]
['customers', 'list', workspaceId, { page, sort }]
['customer', 'detail', customerId]
['interviews', 'list', workspaceId]
```

### Query Hook Pattern

```markdown
### Hook: useDiscoveryHealth

**File:** desktop/src/renderer/hooks/useDiscoveryHealth.ts (new)
**Depends on:** IPC health:latest, health:trend handlers

| Query | Key | Fetcher | Stale Time | Refetch |
|-------|-----|---------|-----------|---------|
| Latest score | ['health', 'latest', workspaceId] | IPC health:latest | 5 min | on window focus |
| Trend data | ['health', 'trend', workspaceId, days] | IPC health:trend | 5 min | on window focus |

**Returns:**
- score: HealthScore or null (loading/error handled by React Query)
- trend: HealthScore[] (for chart)
- isLoading: boolean
- error: Error or null
- refetch: () => void
```

### Mutation Pattern

```markdown
### Mutation: useCreateComment

**Invalidates:** ['comments', 'list', entityType, entityId]
**Optimistic update:** Append comment to list immediately, revert on error
**Error handling:** Toast with error message, comment remains in input
```

### Cache Invalidation Strategy

| Event | Invalidate | Why |
|-------|-----------|-----|
| New interview ingested | ['health', '*'], ['interviews', 'list'] | Score changes, list changes |
| Comment created | ['comments', 'list', entityType, entityId] | New comment in list |
| Pipeline completes | ['health', '*'], ['opportunities', '*'] | New data affects everything |
| Settings changed | ['config', '*'] | Config queries stale |

---

## Hook Architecture

### Hook Types

| Type | Purpose | Example |
|------|---------|---------|
| **Data hook** | Fetches and caches server data | useDiscoveryHealth, useCustomers |
| **Mutation hook** | Modifies server data | useCreateComment, useUpdateOpportunity |
| **UI hook** | Manages UI-only state | useLocalStorage, useMediaQuery |
| **Composition hook** | Combines multiple hooks | useHealthDashboard (data + UI state) |

### Hook Naming Convention

```
use{Domain}{Action}

Data: useDiscoveryHealth, useCustomerList, useOpportunityDetail
Mutation: useCreateComment, useUpdateOpportunity, useDeleteInterview
UI: useSidebarState, useFilterState, useSelectionState
Composition: useHealthDashboard, useInterviewWorkflow
```

### Spec Notation for Hooks

```markdown
### Hooks (new files)

| Hook | File | Purpose | Depends On |
|------|------|---------|-----------|
| useDiscoveryHealth | hooks/useDiscoveryHealth.ts | Latest health score + trend | IPC health:* |
| useCadence | hooks/useCadence.ts | Interview cadence tracking | IPC cadence:* |
| useHealthDashboard | hooks/useHealthDashboard.ts | Combines health + cadence + UI state | useDiscoveryHealth, useCadence |
```

---

## Page Composition Pattern

Pages are the top-level wiring layer. They compose organisms with hooks.

### Pattern

```
Page
├── Error Boundary (catches rendering errors)
│   ├── Suspense (loading fallback)
│   │   ├── Organism A ← useDataHookA()
│   │   ├── Organism B ← useDataHookB()
│   │   └── Organism C ← local state + derived
│   └── Error Fallback UI
└── Side effects: document title, analytics, keyboard shortcuts
```

### Spec Notation for Pages

```markdown
### Page: HealthDashboard

**Route:** /home (modify existing HomeDashboard)
**Layout:** Single column, scrollable

**Composition:**
- DiscoveryHealthSection (organism) ← useDiscoveryHealth()
- CadenceWidget (organism) ← useCadence()
- ConnectionInsights (organism) ← useConnectionInsights()

**Error boundary:** Shows "Could not load dashboard" with retry button
**Loading state:** Skeleton placeholders for each section
**Empty state:** Onboarding guidance when no interviews exist
```

---

## Atomic Design in Architecture

### Reuse Checklist

Before creating a new component, check existing library:

```markdown
### Component Reuse Analysis

| Need | Existing Component | Reuse? | Notes |
|------|-------------------|--------|-------|
| Score display | atoms/Badge | Modify | Add 'score' variant with color scale |
| Metric card | atoms/Card | Reuse | Standard card with content children |
| Toggle control | atoms/Toggle | Reuse | For auto-approve toggle |
| Data table | organisms/DataTable | Reuse | For list views |
| Search input | molecules/SearchInput | Reuse | For filtering |
| Trend chart | (none) | Create New | New molecule: TrendChart |
| Gauge visual | (none) | Create New | New molecule: ScoreGauge |
```

### New Component Classification

| Atomic Level | Criteria | Examples |
|-------------|----------|---------|
| **Atom** | Single HTML element, no children components | ScoreBadge, TrendArrow, StatusDot |
| **Molecule** | 2-3 atoms combined for single purpose | MetricCard, TrendChart, ScoreGauge |
| **Organism** | Complex section, self-contained | HealthSection, CadenceWidget |
| **Template** | Page layout without content | DashboardLayout, DetailLayout |
| **Page** | Template filled with real content and data hooks | HomeDashboard, CustomerDetail |

---

## Props vs Context Decision

| Scenario | Use Props | Use Context |
|----------|----------|-------------|
| Parent → child (1-2 levels) | ✓ | |
| Parent → grandchild+ (prop drilling 3+ levels) | | ✓ |
| Data changes frequently | ✓ (fine-grained re-renders) | |
| Data changes rarely | | ✓ (theme, workspace, auth) |
| Component is reusable across contexts | ✓ | |
| Data is app-wide singleton | | ✓ |

---

## Worked Example: Component Tree for a Feature Page

### Feature: Discovery Health Dashboard Section

```
HomeDashboard (page — modify existing)
├── ... existing sections ...
├── DiscoveryHealthSection (organism — NEW)
│   ├── SectionHeader (molecule — reuse existing)
│   │   ├── Text (atom) "Discovery Health" ← heading
│   │   └── Button (atom) "Refresh" ← onClick: refetch()
│   ├── ScoreGauge (molecule — NEW)
│   │   ├── GaugeArc (atom — NEW) ← score: 0-100, color by range
│   │   └── Text (atom) ← score number + "/ 100"
│   ├── MetricGrid (molecule — NEW)
│   │   └── MetricCard × 8 (molecule — NEW)
│   │       ├── Text (atom) ← metric.name
│   │       ├── Badge (atom — reuse) ← metric.score, color by range
│   │       └── TrendArrow (atom — NEW) ← metric.trend
│   └── SuggestionList (molecule — NEW) ← shown when score < 80
│       └── SuggestionItem × N (atom — NEW)
│           ├── Text (atom) ← suggestion text
│           └── Link (atom — reuse) ← navigates to improvement area
└── ... remaining sections ...

State:
- Server data: useDiscoveryHealth() via React Query
- UI state: selectedMetric via useState (for detail expansion)
- Derived: suggestions filtered by score threshold via useMemo

Hooks needed:
- useDiscoveryHealth (data) — NEW
- Uses existing React Query client from app context
```

---

## Anti-Patterns

### God Component
```
✗ HealthDashboard handles: data fetching, state management, filtering, sorting,
  chart rendering, error handling, loading states — all in one 500-line component
✓ Split into: useDiscoveryHealth (data), DiscoveryHealthSection (composition),
  ScoreGauge (display), MetricCard (display) — each under 100 lines
```

### Prop Drilling Through 5 Levels
```
✗ App → Layout → Sidebar → NavSection → NavItem → Badge (passing workspaceId through all)
✓ WorkspaceContext provides workspaceId; NavItem reads from context directly
```

### Direct Store Access from Components
```
✗ Component imports Store and calls store.getHealthScore() directly
✓ Component uses useDiscoveryHealth() hook which calls IPC handler which calls Store
   (proper layer separation: Component → Hook → IPC → Store)
```
