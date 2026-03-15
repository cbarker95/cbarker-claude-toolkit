# Integration Patterns

## Purpose

Integration patterns define how layers communicate: IPC channels between Electron main and renderer, API contracts between frontend and backend, event systems for decoupled components. Specs that don't define these contracts force developers to invent interfaces at implementation time — leading to inconsistent naming, missing error handling, and type mismatches.

---

## IPC Pattern for Electron

### Architecture Overview

```
Renderer Process          Preload Bridge          Main Process
(React components)        (contextBridge)         (Node.js + Store)

useHook() ──────→ window.api.method() ──→ ipcMain.handle() ──→ store.method()
    ↑                                          │
    └──────────────── result ──────────────────┘
```

### Channel Naming Convention

```
{domain}:{action}

domain  = lowercase noun (health, comments, pipeline, customers)
action  = lowercase verb or noun (list, create, delete, status, latest)
```

| Pattern | Example | Use |
|---------|---------|-----|
| `{domain}:list` | `comments:list` | Fetch collection with filters |
| `{domain}:get` | `customer:get` | Fetch single by ID |
| `{domain}:create` | `comments:create` | Create new entity |
| `{domain}:update` | `opportunity:update` | Update existing entity |
| `{domain}:delete` | `comment:delete` | Delete entity |
| `{domain}:{special}` | `health:compute` | Domain-specific action |
| `{domain}:status` | `pipeline:status` | Status/state query |

### Type-Safe IPC Contract

Define the contract in types that both sides import:

```markdown
### IPC Contract: health domain

| Channel | Request | Response | Errors |
|---------|---------|----------|--------|
| health:latest | { workspaceId: string } | HealthScore or null | — |
| health:compute | { workspaceId: string } | HealthScore | NetworkError, CreditError |
| health:trend | { workspaceId: string, days: number } | HealthScore[] | — |
```

### Handler Registration Pattern

Handlers in ipc.ts follow a consistent pattern:

```markdown
For each IPC channel:
1. Register handler with ipcMain.handle(channel, handler)
2. Handler receives (event, args) with typed args
3. Handler calls Store method
4. Handler returns typed response
5. Errors caught and re-thrown as structured error objects
```

### Preload Bridge Pattern

The preload script exposes a type-safe API to the renderer:

```markdown
### Preload API Additions

window.api.health = {
  getLatest: (workspaceId) => ipcRenderer.invoke('health:latest', { workspaceId }),
  compute: (workspaceId) => ipcRenderer.invoke('health:compute', { workspaceId }),
  getTrend: (workspaceId, days) => ipcRenderer.invoke('health:trend', { workspaceId, days }),
};
```

---

## API Contract Format

For backend API routes (Fastify, Express):

### REST Contract Template

```markdown
### Endpoint: GET /api/health/latest

**Auth:** Required (Bearer token)
**Params:** ?workspace_id={id}

**Success Response (200):**
{ score: HealthScore }

**Error Responses:**
| Status | Body | When |
|--------|------|------|
| 401 | { error: "unauthorized" } | Missing/invalid token |
| 404 | { error: "workspace_not_found" } | Invalid workspace_id |
| 500 | { error: "internal_error", message: string } | Unexpected failure |
```

### Contract Versioning

For evolving APIs:
- **Additive changes** (new fields, new endpoints): No version bump needed
- **Breaking changes** (removed fields, changed types): Version bump required
- **Version in URL**: `/api/v1/health` vs `/api/v2/health`
- **Prefer additive**: Add optional fields rather than breaking existing consumers

---

## Event System Patterns

### When to Use Events vs Direct Calls

| Scenario | Use Direct Call | Use Events |
|----------|---------------|-----------|
| One sender, one receiver | ✓ | |
| One sender, multiple receivers | | ✓ |
| Tight coupling is acceptable | ✓ | |
| Loose coupling needed | | ✓ |
| Response needed | ✓ | |
| Fire-and-forget | | ✓ |
| Synchronous flow | ✓ | |
| Asynchronous notifications | | ✓ |

### Event Naming Convention

```
{domain}:{past-tense-verb}

Examples:
  pipeline:file-detected    — New file found in vault
  pipeline:step-completed   — Pipeline step finished
  pipeline:paused           — Pipeline waiting for approval
  interview:ingested        — Interview processed into vault
  health:computed           — New health score available
```

### Event Payload Pattern

```markdown
### Event: pipeline:step-completed

**Emitter:** PipelineOrchestrator
**Listeners:** PipelineStatusIndicator (UI badge), Toast system, Health recomputation

**Payload:**
{
  fileId: string,
  stepName: string,
  stepIndex: number,
  totalSteps: number,
  result: 'success' | 'error' | 'skipped',
  error?: string
}
```

### Pub/Sub for Decoupled Systems

```
Publisher ──→ EventBus ──→ Subscriber A
                       ──→ Subscriber B
                       ──→ Subscriber C
```

Use when:
- Pipeline completion triggers multiple unrelated updates (health score, UI badges, toasts)
- File watcher events need to reach multiple consumers
- Background operations need to notify UI without tight coupling

---

## Type Sharing Between Layers

### Shared Types Strategy

```
src/types.ts
├── Data entities (HealthScore, Customer, Opportunity)
├── Enum types (OpportunityType, ProposalStatus)
├── IPC request/response types (HealthLatestRequest, HealthLatestResponse)
└── Event payload types (PipelineStepEvent)

Imported by:
├── src/core/store.ts (data entities)
├── src/core/discovery-health.ts (data entities)
├── desktop/src/main/ipc.ts (IPC types)
├── desktop/src/renderer/hooks/*.ts (data entities, IPC response types)
└── desktop/src/renderer/components/*.tsx (data entities for props)
```

### Avoiding Type Duplication

```
✗ Define HealthScore in types.ts AND in the renderer
  (types drift apart, runtime errors)

✓ Define HealthScore once in types.ts
  Import from the same file in every layer
```

### IPC Type Safety Pattern

```markdown
### Type-Safe IPC Definition

Define channel map type in shared types:

type IPCChannels = {
  'health:latest': { request: { workspaceId: string }, response: HealthScore | null },
  'health:compute': { request: { workspaceId: string }, response: HealthScore },
  'health:trend': { request: { workspaceId: string, days: number }, response: HealthScore[] },
}

Both ipcMain.handle and ipcRenderer.invoke reference these types.
```

---

## Contract Testing

### Testing Both Sides Independently

```markdown
### IPC Contract Tests

**Main process side (handler tests):**
- health:latest with valid workspace → returns HealthScore
- health:latest with empty workspace → returns null
- health:compute with valid workspace → computes and returns score
- health:compute with network error → throws structured error

**Renderer side (hook tests):**
- useDiscoveryHealth renders loading state initially
- useDiscoveryHealth renders data after fetch
- useDiscoveryHealth renders error state on failure
- useDiscoveryHealth refetches on window focus
```

### Integration Test Pattern

```markdown
### Integration Test: Health IPC Round-Trip

1. Create Store with test database
2. Seed test data (interviews, opportunities)
3. Call health:compute handler directly
4. Verify HealthScore structure matches type
5. Call health:latest handler
6. Verify returns the computed score
7. Call health:trend handler with days=7
8. Verify returns array of scores
```

---

## Worked Example: habitatd IPC Pattern

### Adding Health Score IPC

**Step 1: Types (src/types.ts)**
```
Add HealthScore and HealthMetric interfaces
```

**Step 2: Store (src/core/store.ts)**
```
Add health_scores table
Add createHealthScore, getLatestHealthScore, getHealthTrend methods
```

**Step 3: IPC Handler (desktop/src/main/ipc.ts)**
```
Register handler: ipcMain.handle('health:latest', async (event, args) => {
  const store = getStore();
  return store.getLatestHealthScore(args.workspaceId);
});

Register handler: ipcMain.handle('health:trend', async (event, args) => {
  const store = getStore();
  return store.getHealthTrend(args.workspaceId, args.days);
});
```

**Step 4: Preload (desktop/src/preload/index.ts)**
```
Add health methods to window.api:
  health: {
    getLatest: (workspaceId) => ipcRenderer.invoke('health:latest', { workspaceId }),
    getTrend: (workspaceId, days) => ipcRenderer.invoke('health:trend', { workspaceId, days }),
  }
```

**Step 5: Hook (desktop/src/renderer/hooks/useDiscoveryHealth.ts)**
```
useQuery(['health', 'latest', workspaceId], () => window.api.health.getLatest(workspaceId))
useQuery(['health', 'trend', workspaceId, days], () => window.api.health.getTrend(workspaceId, days))
```

This is the complete contract: Types → Store → Handler → Preload → Hook.

---

## Anti-Patterns

### Untyped IPC
```
✗ ipcRenderer.invoke('some-channel', { arbitrary: data })
  (no type checking, runtime errors when shapes mismatch)
✓ Typed channel map ensuring request/response types match
```

### Direct Store Access from Renderer
```
✗ Component imports Store directly (bypasses IPC, breaks process isolation)
✓ Component → Hook → IPC → Store (proper layer separation)
```

### Inconsistent Channel Naming
```
✗ 'getHealth', 'fetch_customers', 'PIPELINE-START', 'commentsList'
✓ 'health:latest', 'customers:list', 'pipeline:start', 'comments:list'
```
