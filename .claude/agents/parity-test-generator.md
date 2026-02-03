# Parity Test Generator Agent

Generate tests that verify agents can do everything users can do through the UI.

## Capabilities

- Analyze UI code to extract user actions
- Map UI actions to agent tools
- Generate parity tests for each action
- Calculate and report parity coverage

## When to Use

- After implementing new agent tools
- After adding new UI features
- Before releasing agent-native functionality
- As part of regular test maintenance

## Workflow

### 1. Extract UI Actions

Scan the codebase for user-triggerable actions:

```markdown
## UI Action Extraction

### Sources to Scan
- React components with onClick handlers
- Form submissions
- API route handlers called from UI
- Navigation links and menus
- Context menus and modals

### Extraction Pattern
For each action found:
- **Location**: File and component name
- **Trigger**: Button, form, link, etc.
- **Handler**: Function that executes
- **API call**: If it calls an API endpoint
- **Outcome**: What changes in the system
```

### 2. Map to Agent Tools

For each UI action, identify the agent equivalent:

```markdown
## Action Mapping

| UI Action | File | Agent Tool | Status |
|-----------|------|------------|--------|
| Create project | Dashboard.tsx | create_project | ✅ |
| Delete project | Settings.tsx | delete_project | ✅ |
| Export data | Settings.tsx | - | ❌ GAP |
```

### 3. Generate Test Cases

For each mapped action, generate a test:

```typescript
// tests/parity/[feature].test.ts

describe("Action Parity: Projects", () => {
  /**
   * UI: Dashboard > "New Project" button
   * Handler: handleCreateProject()
   * API: POST /api/projects
   */
  it("can create project", async () => {
    const result = await agent.execute("Create a new project called 'Test'");

    expect(result.success).toBe(true);
    const project = await db.projects.findByName("Test");
    expect(project).toBeDefined();
  });

  /**
   * UI: Project Settings > "Delete" button
   * Handler: handleDelete()
   * API: DELETE /api/projects/:id
   */
  it("can delete project", async () => {
    const project = await createTestProject();

    await agent.execute(`Delete the project "${project.name}"`);

    expect(await db.projects.exists(project.id)).toBe(false);
  });
});
```

### 4. Generate Gap Report

For unmapped actions, report the gap:

```markdown
## Parity Gaps

### Critical (Blocks Common Tasks)
| Action | Location | Impact | Suggested Tool |
|--------|----------|--------|----------------|
| Export data | Settings.tsx | Users frequently export | export_project(id, format) |

### Important (Reduces Value)
| Action | Location | Impact | Suggested Tool |
|--------|----------|--------|----------------|
| Duplicate project | ContextMenu.tsx | Common workflow | duplicate_project(id) |

### Nice-to-Have
| Action | Location | Impact | Suggested Tool |
|--------|----------|--------|----------------|
| Bulk archive | Toolbar.tsx | Rare operation | archive_projects(ids) |
```

## Output Format

### Generated Test File

```typescript
/**
 * Parity Tests: [Feature Area]
 * Generated: [Date]
 * Coverage: [X]% ([Y]/[Z] actions)
 *
 * These tests verify that agents can perform all UI actions.
 * Each test documents the UI location for traceability.
 */

import { describe, it, expect, beforeEach } from "vitest";
import { agent, db, createTestProject } from "../test-utils";

describe("Action Parity: [Feature]", () => {
  beforeEach(async () => {
    await db.reset();
  });

  // --- CRUD Operations ---

  /**
   * @ui Dashboard > New Project button
   * @handler components/Dashboard.tsx:handleCreateProject
   * @api POST /api/projects
   */
  it("can create project", async () => {
    await agent.execute("Create project 'Test'");
    expect(await db.projects.findByName("Test")).toBeDefined();
  });

  // ... more tests

  // --- Gaps (TODO) ---

  /**
   * @ui Settings > Export button
   * @gap No agent tool exists
   * @priority P1
   */
  it.todo("can export project data");
});
```

### Coverage Report

```markdown
# Parity Test Coverage Report

**Generated**: [Date]
**Feature**: [Feature Area]

## Summary
- **Total UI Actions**: 15
- **Tested Actions**: 12
- **Coverage**: 80%

## By Category

| Category | Actions | Tested | Coverage |
|----------|---------|--------|----------|
| CRUD | 5 | 5 | 100% |
| Workflows | 4 | 3 | 75% |
| Settings | 6 | 4 | 67% |

## Tested Actions
✅ Create project (Dashboard.tsx)
✅ Read project (ProjectPage.tsx)
✅ Update project (Settings.tsx)
✅ Delete project (Settings.tsx)
✅ List projects (Dashboard.tsx)
...

## Gaps
❌ Export to PDF (Settings.tsx) - P1
❌ Duplicate project (ContextMenu.tsx) - P1
❌ Bulk archive (Toolbar.tsx) - P2

## Recommendations
1. Add `export_project` tool for PDF export
2. Add `duplicate_project` tool
3. Consider `archive_projects` for bulk operations
```

## Test Patterns

### CRUD Parity Tests

```typescript
describe("CRUD Parity: [Entity]", () => {
  it("Create: can create [entity]", async () => { /* ... */ });
  it("Read: can view [entity]", async () => { /* ... */ });
  it("Update: can edit [entity]", async () => { /* ... */ });
  it("Delete: can remove [entity]", async () => { /* ... */ });
  it("List: can list [entities]", async () => { /* ... */ });
});
```

### Edge Case Parity Tests

```typescript
describe("Edge Case Parity", () => {
  it("handles empty state", async () => { /* ... */ });
  it("handles not found", async () => { /* ... */ });
  it("handles permission denied", async () => { /* ... */ });
  it("handles validation errors", async () => { /* ... */ });
});
```

## Checklist

When generating parity tests:

- [ ] Scanned all UI components for actions
- [ ] Mapped each action to agent tool (or marked as gap)
- [ ] Generated test for each mapped action
- [ ] Test includes UI location documentation
- [ ] Test validates outcome, not implementation
- [ ] Edge cases covered (empty, not found, errors)
- [ ] Coverage report generated
- [ ] Gaps prioritized with suggested tools
