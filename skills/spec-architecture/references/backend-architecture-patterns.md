# Backend Architecture Patterns

## Purpose

Backend architecture patterns for discovery specs. Covers data modeling, SQLite patterns, store methods, IPC handler design, migration planning, and error handling. These patterns produce specs detailed enough for autonomous implementation without developer Q&A.

---

## Data Model Specification

### How to Define Entities in a Spec

Every data entity needs:

```markdown
### Entity: {EntityName}

**Table:** `{table_name}`
**Purpose:** {what this stores and why}

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | TEXT | PRIMARY KEY | UUID, generated on creation |
| workspace_id | TEXT | NOT NULL, FK workspaces(id) | Scope to workspace |
| {column} | {type} | {constraints} | {description} |
| created_at | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | ISO 8601 |
| updated_at | TEXT | NOT NULL, DEFAULT CURRENT_TIMESTAMP | ISO 8601, trigger-updated |

**Indices:**
- `idx_{table}_workspace` ON (workspace_id)
- `idx_{table}_{common_query_col}` ON ({column}) — for {query purpose}

**Relationships:**
- belongs_to: workspaces (via workspace_id)
- has_many: {related_table} (via {foreign_key})
```

### Column Type Reference (SQLite)

| Use Case | SQLite Type | Notes |
|----------|------------|-------|
| Identifiers | TEXT | UUIDs as text |
| Short strings | TEXT | No VARCHAR in SQLite |
| Long content | TEXT | No length limit in SQLite |
| Integers | INTEGER | Counts, scores, indices |
| Floating point | REAL | Ratios, percentages |
| Booleans | INTEGER | 0 = false, 1 = true |
| Timestamps | TEXT | ISO 8601 strings (sortable) |
| JSON data | TEXT | JSON.stringify/parse, use json_extract() for queries |
| Enums | TEXT | CHECK constraint with valid values |

### Relationship Patterns

**One-to-Many:**
```sql
-- Parent table
CREATE TABLE customers (id TEXT PRIMARY KEY, ...);

-- Child table with FK
CREATE TABLE interviews (
  id TEXT PRIMARY KEY,
  customer_id TEXT NOT NULL REFERENCES customers(id),
  ...
);
CREATE INDEX idx_interviews_customer ON interviews(customer_id);
```

**Many-to-Many:**
```sql
-- Junction table
CREATE TABLE opportunity_interviews (
  opportunity_id TEXT NOT NULL REFERENCES opportunities(id),
  interview_id TEXT NOT NULL REFERENCES interviews(id),
  PRIMARY KEY (opportunity_id, interview_id)
);
```

**Polymorphic (Entity-Type Pattern):**
```sql
-- Comments on any entity type
CREATE TABLE comments (
  id TEXT PRIMARY KEY,
  entity_type TEXT NOT NULL CHECK(entity_type IN ('opportunity', 'solution', 'proposal')),
  entity_id TEXT NOT NULL,
  content TEXT NOT NULL,
  ...
);
CREATE INDEX idx_comments_entity ON comments(entity_type, entity_id);
```

---

## SQLite-Specific Patterns

### WAL Mode and Foreign Keys
```sql
-- Enable on every connection (in Store constructor)
PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;
```

### Migration Pattern
```
In store initialization:
- Define versioned migrations array
- Each migration has a version number and SQL
- Check current version against migration list
- Run pending migrations in order
- Update version tracker
```

### Spec Notation for Migrations
```markdown
### Migration: Add health_scores table

**Version:** N+1 (auto-determined from current max)

SQL:
- CREATE TABLE IF NOT EXISTS health_scores with columns
- CREATE INDEX for common query patterns

**Existing DB impact:** None — new table, additive only.
```

---

## Store Method Design

### Method Naming Conventions

| Operation | Naming Pattern | Example |
|-----------|---------------|---------|
| Create | `create{Entity}` | `createHealthScore(score: HealthScore): void` |
| Read one | `get{Entity}` | `getHealthScore(id: string): HealthScore or null` |
| Read latest | `getLatest{Entity}` | `getLatestHealthScore(workspaceId: string): HealthScore or null` |
| List all | `list{Entities}` | `listHealthScores(workspaceId: string): HealthScore[]` |
| List filtered | `list{Entities}By{Filter}` | `listHealthScoresByDateRange(start, end): HealthScore[]` |
| Update | `update{Entity}` | `updateHealthScore(id: string, data: Partial<HealthScore>): void` |
| Delete | `delete{Entity}` | `deleteHealthScore(id: string): void` |
| Count | `count{Entities}` | `countInterviews(workspaceId: string): number` |
| Aggregate | `get{Aggregate}` | `getAverageScore(workspaceId: string): number` |

### Spec Notation for Store Methods

```markdown
### Store Methods (modify: src/core/store.ts)

| Method | Signature | Query Description |
|--------|-----------|-------------------|
| createHealthScore | (score: HealthScore) -> void | INSERT INTO health_scores |
| getLatestHealthScore | (workspaceId: string) -> HealthScore or null | SELECT ... ORDER BY computed_at DESC LIMIT 1 |
| listHealthScores | (workspaceId: string, limit?: number) -> HealthScore[] | SELECT ... ORDER BY computed_at DESC |
| getHealthTrend | (workspaceId: string, days: number) -> HealthScore[] | SELECT ... WHERE computed_at > date threshold |
```

---

## IPC Handler Design

### Channel Naming Convention

```
{domain}:{action}

Examples:
  health:latest       — GET latest health score
  health:compute      — POST trigger computation
  health:trend        — GET trend data (with params)
  pipeline:start      — POST start pipeline
  pipeline:status     — GET current status
  comments:create     — POST new comment
  comments:list       — GET comments for entity
```

### Handler Registration Pattern

```markdown
### IPC Handlers (modify: desktop/src/main/ipc.ts)

| Channel | Direction | Request Type | Response Type |
|---------|-----------|-------------|---------------|
| health:latest | renderer to main | { workspaceId: string } | HealthScore or null |
| health:compute | renderer to main | { workspaceId: string } | HealthScore |
| health:trend | renderer to main | { workspaceId: string, days: number } | HealthScore[] |
```

---

## Error Handling Taxonomy

### Error Categories

| Category | Source | User Surface | Recovery |
|----------|--------|-------------|----------|
| **Validation** | User input | Inline field errors | Fix input, resubmit |
| **Not Found** | Database query | "Not found" message with suggestions | Navigate to search/list |
| **Permission** | Auth/tier check | Upgrade prompt or access request | Upgrade or request access |
| **Network** | API calls, AI ops | "Connection lost" banner | Auto-retry, manual retry button |
| **Rate Limit** | API throttling | "Too many requests" with countdown | Auto-retry after cooldown |
| **Credit** | Usage metering | "Credits depleted" with upgrade CTA | Upgrade or wait for reset |
| **System** | Unexpected failures | "Something went wrong" with retry | Retry, fallback, support link |

### Spec Notation for Error Handling

```markdown
### Error Handling

| Operation | Error Type | User Sees | Recovery |
|-----------|-----------|-----------|----------|
| Health computation | Network error | Toast: "Could not compute health score" | Auto-retry in 30s |
| Health computation | No data | Dashboard: "Add interviews to see your health score" | CTA: Import interview |
| Store query | Not found | null returned, UI shows empty state | Contextual empty state |
```

---

## Worked Example: Adding a Feature to a Store.ts-Style App

### Feature: Discovery Health Scores

**Step 1: Types (src/types.ts)**

Define HealthMetricName (union of 8 metric names), HealthMetric (name, score, trend, details), and HealthScore (id, workspaceId, computedAt, compositeScore, metrics array).

**Step 2: Store (src/core/store.ts — modify)**

Add health_scores table to schema. Add methods: createHealthScore, getLatestHealthScore, listHealthScores, getHealthTrend.

**Step 3: IPC (desktop/src/main/ipc.ts — modify)**

Register handlers: health:latest, health:compute, health:trend. Each calls corresponding Store method.

**Step 4: Hook (desktop/src/renderer/hooks/useDiscoveryHealth.ts — new)**

React Query: useQuery for latest health score and trend data. Query keys scoped to workspace.

**Step 5: Component (desktop/src/renderer/components/home/DiscoveryHealthSection.tsx — new)**

Consumes useDiscoveryHealth hook. Renders HealthGauge + MetricCards + Suggestions.

**This is the build order: Types -> Store -> IPC -> Hook -> Component.**

---

## Query Design Patterns

Don't just specify tables — specify the queries the UI needs:

| UI Need | Query Pattern | Index Needed |
|---------|--------------|-------------|
| Latest score on dashboard | ORDER BY computed_at DESC LIMIT 1 | (workspace_id, computed_at) |
| Score trend chart | WHERE computed_at > threshold ORDER BY computed_at | (workspace_id, computed_at) |
| Customer interview count | COUNT(*) GROUP BY customer_id | (customer_id) |
| Opportunity by evidence weight | ORDER BY evidence_count DESC | (evidence_count) |
| Orphaned items (no connections) | LEFT JOIN WHERE connection IS NULL | FK columns |
| Full-text search | FTS5 virtual table or LIKE pattern | Consider FTS5 |

---

## Anti-Patterns

### Schema Without Queries
```
✗ "Add health_scores table" (what queries will the UI run against it?)
✓ "Add health_scores table. UI needs: latest score per workspace, trend over N days,
   average score for comparison. Index on (workspace_id, computed_at)."
```

### Missing Migration Strategy
```
✗ "Add column" (what about existing databases with data?)
✓ "ALTER TABLE ADD COLUMN with DEFAULT value. Existing rows get default.
   No data migration needed — new column populated on next computation."
```

### Store Method Without Type Safety
```
✗ "Add method to get health data" (what types? what parameters?)
✓ "getLatestHealthScore(workspaceId: string): HealthScore | null
   Returns null if no scores computed yet (empty state in UI)."
```
