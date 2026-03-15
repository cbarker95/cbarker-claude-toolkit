# Testing Strategy

## Purpose

Tests belong alongside features, not in a separate phase. The CLAUDE.md for habitatd specs explicitly states: "DO NOT write the plan so all the tests are written in the final phase!" This reference covers the test-alongside pattern, test types per layer, and how to specify testing in discovery specs.

---

## Test-Alongside Pattern

### The Rule

**Every 🟪 feature in a spec lists test files alongside implementation files.**

```markdown
🟪 ### 3. Core: Health computation logic

**Files:**
- src/core/discovery-health.ts (new)
- src/core/discovery-health.test.ts (new)   ← TEST FILE WITH THE FEATURE
```

### Why Not Tests-At-End?

| Tests at the end | Tests alongside |
|-----------------|-----------------|
| Features built without verification | Each feature verified immediately |
| Test writer must re-learn the code | Test writer understands the code (just wrote it) |
| Untestable code discovered too late | Untestable patterns caught early |
| Partial coverage (time pressure) | Complete coverage (built incrementally) |
| go-commando builds features that may be broken | go-commando verifies each feature before moving on |

---

## Test Pyramid for Specs

```
         ╱ ╲
        ╱ E2E╲           Few, slow, high-confidence
       ╱───────╲
      ╱Integr-  ╲        Moderate count, test contracts
     ╱  ation    ╲
    ╱─────────────╲
   ╱    Unit       ╲     Many, fast, test logic
  ╱─────────────────╲
```

### Layer-Specific Test Types

| Layer | Test Type | What to Test | Example |
|-------|-----------|-------------|---------|
| **Types** | Type checks | Compile-time only | TypeScript strict mode |
| **Store methods** | Unit | CRUD operations, edge cases, constraints | createHealthScore with valid/invalid data |
| **Business logic** | Unit | Pure computation, transformation | Health score calculation with known inputs |
| **IPC handlers** | Integration | Request/response contract, error handling | health:latest returns correct shape |
| **React hooks** | Hook test | Data fetching, caching, error states | useDiscoveryHealth loading/success/error |
| **Components** | Component | Renders correctly, interactions work | ScoreGauge displays score, click handlers fire |
| **Pages** | Integration | Components wired correctly, data flows | HealthDashboard loads data and renders sections |

---

## What to Test Per Layer

### Store Methods

| Test Case | Example |
|-----------|---------|
| Create with valid data | createHealthScore({...valid}) succeeds |
| Create with missing required field | createHealthScore({...missing}) throws |
| Read existing record | getLatestHealthScore returns correct record |
| Read non-existent record | getLatestHealthScore returns null |
| List with results | listHealthScores returns array in correct order |
| List with no results | listHealthScores returns empty array |
| Update existing record | updateHealthScore modifies correct fields |
| Delete existing record | deleteHealthScore removes record |
| Foreign key constraint | Creating child without parent throws |
| Concurrent access | Two operations on same record don't corrupt |

### Business Logic (Pure Functions)

| Test Case | Example |
|-----------|---------|
| Normal input | computeHealthScore with balanced data returns expected range |
| Edge: no data | computeHealthScore with empty corpus returns 0 or default |
| Edge: maximum data | computeHealthScore with large corpus returns capped at 100 |
| Edge: partial data | computeHealthScore with some metrics missing handles gracefully |
| Metric calculation | Individual metric (interview cadence) with known inputs returns expected value |

### IPC Handlers

| Test Case | Example |
|-----------|---------|
| Valid request | health:latest with valid workspaceId returns HealthScore |
| Missing parameter | health:latest without workspaceId returns error |
| Invalid parameter | health:latest with non-existent workspace returns null |
| Error propagation | health:compute with network failure returns structured error |

### React Hooks

| Test Case | Example |
|-----------|---------|
| Loading state | useDiscoveryHealth initially returns isLoading: true |
| Success state | useDiscoveryHealth after fetch returns data |
| Error state | useDiscoveryHealth on failure returns error |
| Refetch | useDiscoveryHealth.refetch() triggers new fetch |
| Cache | Second call uses cached data (no new fetch) |
| Invalidation | After mutation, related queries refetch |

### Components

| Test Case | Example |
|-----------|---------|
| Renders with data | ScoreGauge({score: 75}) renders "75 / 100" |
| Renders empty state | MetricCard({metric: null}) renders placeholder |
| Renders error state | DiscoveryHealthSection with error shows error message |
| Click interaction | MetricCard click handler fires with correct metric |
| Keyboard interaction | Button activates on Enter/Space |
| Accessibility | Component has correct ARIA attributes |

### Pages

| Test Case | Example |
|-----------|---------|
| Loads and renders sections | HealthDashboard shows health section + cadence widget |
| Handles loading state | HealthDashboard shows skeletons while loading |
| Handles empty state | HealthDashboard with no data shows onboarding guidance |
| Handles error state | HealthDashboard with error shows retry option |

---

## Spec Notation for Tests

### Inline with Feature Files

```markdown
🟪 ### 2. Core: Health computation logic

Implements DiscoveryHealthScorer — pure calculation module that computes 8 CDH
sub-metrics into a 0-100 composite health score.

**Files:**
- `src/core/discovery-health.ts` (new)
- `src/core/discovery-health.test.ts` (new)

**Test cases:**
- Balanced corpus → score in 60-80 range
- No interviews → score 0, all metrics flagged
- Recent interviews only → cadence high, other metrics may be low
- Single customer → breadth metric flagged
```

### Separate Test Section (for complex features)

```markdown
🟪 ### 5. Page: Health Dashboard

**Files:**
- desktop/src/renderer/components/home/DiscoveryHealthSection.tsx (new)
- desktop/src/renderer/components/home/DiscoveryHealthSection.test.tsx (new)
- desktop/src/renderer/pages/HomeDashboard.tsx (modify)

**Test plan:**
| Scenario | Setup | Expected |
|----------|-------|----------|
| Loading state | Mock hook returns isLoading | Skeleton placeholders shown |
| Data loaded | Mock hook returns score + metrics | Gauge shows score, 8 metric cards |
| Empty corpus | Mock hook returns null | Onboarding guidance shown |
| Error | Mock hook returns error | Error message + retry button |
| Metric click | Click metric card | Detail expansion or navigation |
```

---

## Testing Patterns for React

### Component Test Structure

```
describe('ComponentName', () => {
  it('renders with required props')
  it('renders empty state when no data')
  it('renders loading state')
  it('renders error state')
  it('handles user interaction (click, type, etc.)')
  it('has correct accessibility attributes')
})
```

### Hook Test Structure

```
describe('useHookName', () => {
  it('returns loading state initially')
  it('returns data after successful fetch')
  it('returns error on fetch failure')
  it('refetches when dependencies change')
  it('uses cached data on repeat access')
})
```

### Mocking IPC in Tests

```
Mock window.api.{domain}.{method} to return test data
- Success: returns typed response
- Error: throws structured error
- Loading: delay resolution
```

---

## Testing Patterns for Electron

### IPC Handler Tests

```
Test ipcMain handlers in isolation:
1. Create test Store with in-memory SQLite
2. Seed test data
3. Call handler function directly (not via IPC)
4. Assert response matches expected shape
5. Assert Store was modified correctly (for mutations)
```

### Main Process Tests

```
Test main process modules:
- Store methods with test database
- Business logic with known inputs
- File watchers with temp directories
- Pipeline orchestrator with mock steps
```

---

## Snapshot vs Behavior Tests

| Use Snapshots When | Use Behavior Tests When |
|-------------------|------------------------|
| Component structure is stable | Component behavior matters more than structure |
| Catching unintended changes | Testing specific user interactions |
| Large, static components | Dynamic, interactive components |
| Initial implementation | Ongoing maintenance |

**Recommendation:** Prefer behavior tests. Snapshots break on every visual change and provide false negatives.

---

## Test File Naming Convention

| Source File | Test File |
|------------|-----------|
| discovery-health.ts | discovery-health.test.ts |
| DiscoveryHealthSection.tsx | DiscoveryHealthSection.test.tsx |
| useDiscoveryHealth.ts | useDiscoveryHealth.test.ts |
| store.ts | store.test.ts (or per-feature: store.health.test.ts) |

---

## Anti-Patterns

### Tests Deferred to Final Phase
```
✗ "🟪 10. Write tests for all features"
✓ Every 🟪 feature lists its .test.ts files alongside implementation files
```

### Only Happy Path Tests
```
✗ Tests only cover: create with valid data, fetch existing record
✓ Tests also cover: create with invalid data, fetch non-existent, concurrent access,
  empty state, error state, boundary values
```

### Testing Implementation Details
```
✗ Test checks that useState was called with specific initial value
  (brittle — breaks on any refactor)
✓ Test checks that component renders correctly and responds to interaction
  (stable — survives refactors)
```

### Missing Error Case Tests
```
✗ Only test successful operations
✓ Test error cases for every async operation:
  - Network failure → error state rendered
  - Invalid input → validation error shown
  - Permission denied → upgrade prompt shown
```
