---
allowed-tools: Read, Write, Edit, Glob, Grep, Task, AskUserQuestion, TodoWrite
description: Audit action parity between UI and agent capabilities
---

# Parity Audit Command

Audit that agents can do everything users can do through the UI.

## Phase 1: UI Action Discovery

Launch these sub-agents **in parallel** using the Task tool:

### Agent 1: Component Analysis
```
subagent_type: Explore
prompt: "Scan React/Vue components for user actions:
- Find onClick, onSubmit, onChange handlers
- Identify forms and their submissions
- List buttons, links, and interactive elements
- Note what API calls they trigger

Return a list of UI actions with:
- Component file
- Action trigger (button, form, etc.)
- Handler function
- API endpoint called (if any)"
```

### Agent 2: API Route Analysis
```
subagent_type: Explore
prompt: "Scan API routes for available operations:
- List all API endpoints
- Identify CRUD operations
- Note which endpoints are called from UI

Return a list of API operations that represent user actions."
```

### Agent 3: Agent Tool Inventory
```
subagent_type: Explore
prompt: "List all agent tools available:
- Check MCP server definitions
- Check tool registrations
- Note tool names and descriptions

Return a complete tool inventory."
```

Wait for all agents, then synthesize.

## Phase 2: Parity Mapping

Create a mapping between UI actions and agent tools:

```markdown
## Parity Map

| # | UI Action | Location | Agent Tool | Status |
|---|-----------|----------|------------|--------|
| 1 | Create project | Dashboard.tsx | create_project | ✅ |
| 2 | Delete project | Settings.tsx | delete_project | ✅ |
| 3 | Export data | Settings.tsx | - | ❌ GAP |
```

## Phase 3: Gap Analysis

For gaps, analyze impact and priority:

```markdown
## Parity Gaps

### Critical (Blocks Common Tasks)
| Gap | Location | User Impact | Suggested Tool |
|-----|----------|-------------|----------------|
| [Action] | [File] | [Impact] | [Tool spec] |

### Important (Reduces Agent Value)
| Gap | Location | User Impact | Suggested Tool |
|-----|----------|-------------|----------------|

### Nice-to-Have (Edge Cases)
| Gap | Location | User Impact | Suggested Tool |
|-----|----------|-------------|----------------|
```

## Phase 4: Test Generation

Ask user what to generate using AskUserQuestion:

```
"Found [X] parity gaps across [Y] feature areas.

What would you like to do?
- Generate parity tests for covered actions
- Generate gap report with tool recommendations
- Generate both tests and gap report
- Focus on specific feature area"
```

### Generate Tests

For covered actions, generate parity tests:

```typescript
// tests/parity/[feature].test.ts
describe("Action Parity: [Feature]", () => {
  /**
   * @ui [Location in UI]
   * @handler [Handler function]
   * @api [API endpoint]
   */
  it("[action description]", async () => {
    // Setup
    // Agent action
    // Verify outcome matches UI result
  });
});
```

### Generate Gap Report

Write gap analysis to file:

```
docs/parity/gap-report.md
```

## Phase 5: Output

### Parity Audit Report

Write comprehensive report:

```markdown
# Parity Audit Report

**Date**: [Date]
**Scope**: [What was audited]

## Summary

| Metric | Value |
|--------|-------|
| Total UI Actions | [X] |
| Covered by Tools | [Y] |
| Parity Score | [Z]% |
| Critical Gaps | [N] |

## Coverage by Feature

| Feature | Actions | Covered | Score |
|---------|---------|---------|-------|
| Projects | 10 | 8 | 80% |
| Members | 5 | 5 | 100% |
| Settings | 8 | 4 | 50% |

## Full Parity Map

[Complete action-to-tool mapping]

## Gap Analysis

[Prioritized gaps with recommendations]

## Generated Tests

[List of generated test files]

## Recommendations

1. [Priority 1 recommendation]
2. [Priority 2 recommendation]
...
```

Save to: `docs/parity/audit-[date].md`

## Scoring

Calculate parity score:

```
Parity Score = (Actions with Tools) / (Total Actions) × 100

Targets:
- 100%: Full parity (ideal)
- 90%+: Good (acceptable for v1)
- 80-90%: Moderate gaps (prioritize fixes)
- <80%: Significant gaps (agents feel limited)
```

## When to Run

- Before releasing agent features
- After adding new UI functionality
- After implementing new tools
- As part of regular quality checks

## Related Commands

- `/generate-tests` — Generate capability tests
- `/mcp-design` — Design tools for identified gaps
