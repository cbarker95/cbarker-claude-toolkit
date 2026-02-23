---
allowed-tools: Read, Write, Edit, Glob, Grep, Task, AskUserQuestion, TodoWrite
description: Generate agent capability and parity tests
---

# Generate Tests Command

Generate tests that verify agent capabilities, action parity, and behavior.

## Phase 1: Test Scope Discovery

Ask user what tests to generate using AskUserQuestion:

```
"What type of agent tests would you like to generate?

- Parity tests: Verify agents can do what users can in UI
- Capability tests: Verify agents can achieve business outcomes
- Behavior tests: Verify agents follow guidelines (confirmations, errors)
- All of the above"
```

Then ask for scope:

```
"What scope should I cover?

- Full codebase scan
- Specific feature area (specify)
- Based on recent changes (git diff)
- From PRD/user stories"
```

## Phase 2: Context Gathering

Based on scope, launch appropriate sub-agents:

### For Parity Tests
```
subagent_type: Explore
prompt: "Find all UI actions and their agent tool equivalents:
- Scan components for handlers
- Map to available tools
- Identify gaps

Return action-to-tool mapping."
```

### For Capability Tests
```
subagent_type: Explore
prompt: "Extract testable capabilities from:
- PRD or requirements docs
- User stories in issues
- Feature documentation

Return list of capabilities with acceptance criteria."
```

### For Behavior Tests
```
subagent_type: Explore
prompt: "Extract expected behaviors from:
- System prompts
- Agent guidelines
- CLAUDE.md or similar

Return list of behaviors to validate."
```

## Phase 3: Test Generation

### Parity Test Template

```typescript
/**
 * Parity Tests: [Feature]
 * Generated: [Date]
 * Coverage: [X]% ([Y]/[Z] actions)
 */

import { describe, it, expect, beforeEach } from "vitest";
import { agent, db } from "../test-utils";

describe("Action Parity: [Feature]", () => {
  beforeEach(async () => {
    await db.reset();
  });

  // ============================================
  // CRUD Operations
  // ============================================

  /**
   * @ui [UI Location]
   * @handler [Handler function]
   * @api [API endpoint]
   */
  it("can [action]", async () => {
    // Setup
    [setup code]

    // Execute
    await agent.execute("[natural language prompt]");

    // Verify outcome
    [assertions]
  });

  // ============================================
  // Gaps (TODO)
  // ============================================

  /**
   * @ui [UI Location]
   * @gap No agent tool exists
   * @priority [P0/P1/P2]
   */
  it.todo("can [action]");
});
```

### Capability Test Template

```typescript
/**
 * Capability Tests: [Domain]
 * Generated: [Date]
 */

import { describe, it, expect } from "vitest";
import { agent, db, scenarios } from "../test-utils";

describe("Capabilities: [Domain]", () => {

  // ============================================
  // Setup Capabilities
  // ============================================

  /**
   * @story [User Story ID]
   * @acceptance [Acceptance criteria]
   */
  it("can [capability description]", async () => {
    // Scenario setup
    const { [fixtures] } = await scenarios.[scenario]();

    // Execute capability
    await agent.execute(`[multi-line prompt]`);

    // Verify outcome (not steps)
    [assertions on final state]
  });

  // ============================================
  // Operational Capabilities
  // ============================================

  // ... more capabilities

});
```

### Behavior Test Template

```typescript
/**
 * Behavior Validation Tests
 * Generated: [Date]
 */

import { describe, it, expect } from "vitest";
import { agent, db } from "../test-utils";

describe("Agent Behavior Validation", () => {

  // ============================================
  // Safety Behaviors
  // ============================================

  describe("Confirmations", () => {
    it("confirms before [destructive action]", async () => {
      [setup]

      const result = await agent.execute("[action]");

      expect(result.requiresConfirmation).toBe(true);
      expect([state]).toBe([unchanged]);
    });
  });

  // ============================================
  // Helpfulness Behaviors
  // ============================================

  describe("Error Handling", () => {
    it("provides helpful error for [error case]", async () => {
      const result = await agent.execute("[trigger error]");

      expect(result.content).toMatch(/[explanation pattern]/i);
      expect(result.content).toMatch(/[suggestion pattern]/i);
    });
  });

});
```

## Phase 4: Test Utilities Generation

Generate supporting utilities:

### Test Harness

```typescript
// tests/test-utils.ts

import { AgentTestHarness } from "./harness";

export const agent = new AgentTestHarness();

export const db = {
  reset: async () => { /* ... */ },
  projects: { /* ... */ },
  tasks: { /* ... */ },
  members: { /* ... */ },
};

export const scenarios = {
  emptyWorkspace: async () => { /* ... */ },
  activeProject: async () => { /* ... */ },
  troubledProject: async () => { /* ... */ },
};

export async function createTestProject(overrides = {}) {
  return db.projects.create({
    name: `Test Project ${Date.now()}`,
    ...overrides,
  });
}
```

### Custom Matchers

```typescript
// tests/matchers.ts

expect.extend({
  async toHaveCreatedProject(agent, name) {
    const project = await db.projects.findByName(name);
    return {
      pass: project !== null,
      message: () => `Expected project "${name}" to exist`,
    };
  },

  toHaveConfirmed(result) {
    return {
      pass: result.requiresConfirmation === true,
      message: () => "Expected agent to request confirmation",
    };
  },
});
```

## Phase 5: Output

### File Structure

```
tests/
├── parity/
│   ├── projects.test.ts
│   ├── members.test.ts
│   └── settings.test.ts
├── capability/
│   ├── project-management.test.ts
│   ├── task-workflows.test.ts
│   └── analysis.test.ts
├── behavior/
│   ├── confirmations.test.ts
│   ├── error-handling.test.ts
│   └── helpfulness.test.ts
├── test-utils.ts
├── matchers.ts
└── fixtures/
    └── scenarios.ts
```

### Generation Report

```markdown
# Test Generation Report

**Generated**: [Date]
**Scope**: [What was covered]

## Summary

| Test Type | Files | Tests | Coverage |
|-----------|-------|-------|----------|
| Parity | 3 | 25 | 85% |
| Capability | 2 | 12 | - |
| Behavior | 3 | 18 | - |
| **Total** | **8** | **55** | - |

## Generated Files

### Parity Tests
- tests/parity/projects.test.ts (10 tests)
- tests/parity/members.test.ts (8 tests)
- tests/parity/settings.test.ts (7 tests)

### Capability Tests
- tests/capability/project-management.test.ts (7 tests)
- tests/capability/task-workflows.test.ts (5 tests)

### Behavior Tests
- tests/behavior/confirmations.test.ts (6 tests)
- tests/behavior/error-handling.test.ts (8 tests)
- tests/behavior/helpfulness.test.ts (4 tests)

### Utilities
- tests/test-utils.ts
- tests/matchers.ts
- tests/fixtures/scenarios.ts

## Gaps Identified

| Area | Gap | Priority |
|------|-----|----------|
| Projects | export_project | P1 |
| Settings | bulk_update | P2 |

## Next Steps

1. Run tests: `npm run test:agent`
2. Fill in TODOs for capability tests
3. Add tools for identified gaps
```

## Usage Examples

```bash
# Generate all tests for the codebase
/generate-tests

# Generate only parity tests
/generate-tests --type parity

# Generate tests for specific feature
/generate-tests --scope projects

# Generate from recent changes
/generate-tests --scope git-diff
```

## Related Commands

- `/parity-audit` — Audit parity coverage
- `/mcp-design` — Design tools for gaps
- `/dev` — Implement missing tools
