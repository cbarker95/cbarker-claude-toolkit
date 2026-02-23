# Agent-Native Testing Patterns

## The Principle

**Agent-native applications require testing patterns that account for agent behavior, not just code behavior.**

Traditional testing verifies code works. Agent testing verifies agents can accomplish goals.

---

## What Makes Agent Testing Different

| Traditional Testing | Agent Testing |
|---------------------|---------------|
| Deterministic inputs | Natural language inputs |
| Single execution path | Multiple valid paths |
| Exact output matching | Semantic outcome validation |
| Unit → Integration → E2E | Tool → Parity → Capability → E2E |
| Mock dependencies | Real tool execution |
| Fast, isolated | May need real AI calls |

---

## The Agent Testing Pyramid

```
                    ╱╲
                   ╱  ╲
                  ╱ E2E╲           Full conversations
                 ╱──────╲
                ╱        ╲
               ╱Capability╲        Business outcomes
              ╱────────────╲
             ╱              ╲
            ╱    Parity      ╲     UI action equivalence
           ╱──────────────────╲
          ╱                    ╲
         ╱     Tool Unit        ╲  Individual tools
        ╱────────────────────────╲
```

### Layer 1: Tool Unit Tests

Test each tool in isolation:

```typescript
describe("create_project tool", () => {
  it("creates project with valid input", async () => {
    const result = await tools.create_project({
      name: "Test Project",
      description: "A test",
    });

    expect(result.success).toBe(true);
    expect(await db.projects.findByName("Test Project")).toBeDefined();
  });

  it("returns error for duplicate name", async () => {
    await createTestProject({ name: "Existing" });

    const result = await tools.create_project({
      name: "Existing",
    });

    expect(result.isError).toBe(true);
    expect(result.text).toMatch(/already exists/i);
  });

  it("returns helpful error for missing name", async () => {
    const result = await tools.create_project({});

    expect(result.isError).toBe(true);
    expect(result.text).toMatch(/name.*required/i);
  });
});
```

### Layer 2: Parity Tests

Test UI action equivalence:

```typescript
describe("Action Parity", () => {
  it("create project (Dashboard > New Project)", async () => {
    await agent.execute("Create a new project called 'Test'");
    expect(await db.projects.findByName("Test")).toBeDefined();
  });

  it("delete project (Settings > Delete)", async () => {
    const project = await createTestProject();
    await agent.execute(`Delete "${project.name}"`);
    expect(await db.projects.exists(project.id)).toBe(false);
  });
});
```

### Layer 3: Capability Tests

Test business outcomes:

```typescript
describe("Capabilities", () => {
  it("can set up complete project", async () => {
    await agent.execute(`
      Create "Q4 Launch" with Alice as lead,
      add planning and development tasks
    `);

    const project = await db.projects.findByName("Q4 Launch");
    expect(project).toBeDefined();
    expect(project.members).toContainEqual(
      expect.objectContaining({ name: "Alice", role: "lead" })
    );
    expect(project.tasks.length).toBeGreaterThanOrEqual(2);
  });
});
```

### Layer 4: E2E Conversation Tests

Test full agent conversations:

```typescript
describe("E2E Conversations", () => {
  it("handles multi-turn project setup", async () => {
    const conversation = await startConversation();

    await conversation.send("I need to start a new project");
    // Agent might ask clarifying questions

    await conversation.send("Call it Product Launch");
    // Agent creates project

    await conversation.send("Add Alice and Bob to the team");
    // Agent adds members

    await conversation.send("What's the current status?");
    // Agent summarizes

    // Verify final state
    const project = await db.projects.findByName("Product Launch");
    expect(project.members).toHaveLength(2);
  });
});
```

---

## Testing Agent Behavior

### Testing Tool Selection

```typescript
describe("Tool Selection", () => {
  it("chooses list over read for multiple items", async () => {
    await createTestProjects(5);

    const trace = await agent.executeWithTrace("Show me all my projects");

    // Agent should use list_projects, not multiple read_project calls
    expect(trace.toolCalls).toContainEqual(
      expect.objectContaining({ name: "list_projects" })
    );
    expect(
      trace.toolCalls.filter(c => c.name === "read_project").length
    ).toBeLessThan(5);
  });
});
```

### Testing Error Recovery

```typescript
describe("Error Recovery", () => {
  it("retries with corrected input", async () => {
    // First call will fail, agent should correct
    const trace = await agent.executeWithTrace(
      "Create project with name: Test Project!!!"
    );

    // Agent might try invalid name, get error, then fix
    const createCalls = trace.toolCalls.filter(
      c => c.name === "create_project"
    );

    // Eventually succeeds
    expect(await db.projects.count()).toBe(1);
  });

  it("asks for clarification when ambiguous", async () => {
    await createTestProjects([
      { name: "Project Alpha" },
      { name: "Project Beta" },
    ]);

    const result = await agent.execute("Delete the project");

    // Should ask which one, not guess
    expect(result.content).toMatch(/which|specify|multiple/i);
  });
});
```

### Testing Confirmation Flows

```typescript
describe("Confirmation Flows", () => {
  it("confirms before destructive action", async () => {
    const project = await createTestProject();

    const result = await agent.execute(`Delete project "${project.name}"`);

    // Should ask for confirmation
    expect(result.requiresConfirmation).toBe(true);
    expect(await db.projects.exists(project.id)).toBe(true); // Not deleted yet

    // Confirm
    await agent.execute("Yes, delete it");
    expect(await db.projects.exists(project.id)).toBe(false);
  });

  it("respects cancellation", async () => {
    const project = await createTestProject();

    await agent.execute(`Delete project "${project.name}"`);
    await agent.execute("No, cancel that");

    expect(await db.projects.exists(project.id)).toBe(true);
  });
});
```

---

## Test Utilities

### Agent Test Harness

```typescript
// test/agent-harness.ts
export class AgentTestHarness {
  private messages: Message[] = [];
  private toolCalls: ToolCall[] = [];

  async execute(prompt: string): Promise<AgentResult> {
    // Record interaction
    this.messages.push({ role: "user", content: prompt });

    // Execute with tracing
    const result = await this.agent.run(prompt, {
      onToolCall: (call) => this.toolCalls.push(call),
    });

    this.messages.push({ role: "assistant", content: result.content });

    return result;
  }

  getTrace(): AgentTrace {
    return {
      messages: this.messages,
      toolCalls: this.toolCalls,
    };
  }

  reset(): void {
    this.messages = [];
    this.toolCalls = [];
  }
}
```

### Outcome Matchers

```typescript
// test/matchers.ts
expect.extend({
  async toHaveCreatedProject(agent, name) {
    const project = await db.projects.findByName(name);
    return {
      pass: project !== null,
      message: () => `Expected project "${name}" to exist`,
    };
  },

  async toHaveDeletedProject(agent, id) {
    const exists = await db.projects.exists(id);
    return {
      pass: !exists,
      message: () => `Expected project ${id} to be deleted`,
    };
  },

  toHaveMentioned(result, ...terms) {
    const content = result.content.toLowerCase();
    const missing = terms.filter(t => !content.includes(t.toLowerCase()));
    return {
      pass: missing.length === 0,
      message: () => `Expected response to mention: ${missing.join(", ")}`,
    };
  },
});

// Usage
await expect(agent).toHaveCreatedProject("Test");
expect(result).toHaveMentioned("created", "Test");
```

### Scenario Builders

```typescript
// test/scenarios.ts
export const scenarios = {
  emptyWorkspace: () => {
    // Fresh state
  },

  activeProject: async () => {
    const project = await createTestProject({
      name: "Active Project",
      tasks: generateTasks(10),
      members: generateMembers(3),
    });
    return { project };
  },

  multiProjectWorkspace: async () => {
    const projects = await Promise.all([
      createTestProject({ name: "Project A" }),
      createTestProject({ name: "Project B" }),
      createTestProject({ name: "Project C" }),
    ]);
    return { projects };
  },
};

// Usage
it("handles multiple projects", async () => {
  const { projects } = await scenarios.multiProjectWorkspace();
  // Test with realistic data
});
```

---

## Snapshot Testing for Agents

### Response Snapshots (Use Carefully)

```typescript
// Only for stable, structured responses
it("produces consistent status report format", async () => {
  await scenarios.activeProject();

  const result = await agent.execute("Generate status report");

  // Snapshot the structure, not exact content
  expect(extractStructure(result.content)).toMatchSnapshot();
});

function extractStructure(content: string): object {
  return {
    hasSummary: /summary/i.test(content),
    hasMetrics: /\d+.*tasks/i.test(content),
    hasSections: content.includes("##"),
  };
}
```

### State Snapshots

```typescript
it("produces consistent project state", async () => {
  await agent.execute(`
    Create "Test Project" with:
    - Task: Planning
    - Task: Development
    - Member: alice@test.com as admin
  `);

  const state = await getProjectState("Test Project");

  // Snapshot normalized state
  expect(normalizeState(state)).toMatchSnapshot();
});

function normalizeState(state: ProjectState): object {
  return {
    taskCount: state.tasks.length,
    taskStatuses: state.tasks.map(t => t.status).sort(),
    memberCount: state.members.length,
    memberRoles: state.members.map(m => m.role).sort(),
  };
}
```

---

## CI/CD Integration

### Test Configuration

```typescript
// vitest.config.ts
export default {
  projects: [
    {
      name: "unit",
      testMatch: ["tests/unit/**/*.test.ts"],
      // Fast, run on every commit
    },
    {
      name: "parity",
      testMatch: ["tests/parity/**/*.test.ts"],
      // Medium, run on PR
    },
    {
      name: "capability",
      testMatch: ["tests/capability/**/*.test.ts"],
      // Slower, run on PR
    },
    {
      name: "e2e",
      testMatch: ["tests/e2e/**/*.test.ts"],
      // Slowest, run before merge
    },
  ],
};
```

### GitHub Actions

```yaml
name: Agent Tests

on: [push, pull_request]

jobs:
  unit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npm run test:unit

  parity:
    runs-on: ubuntu-latest
    needs: unit
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npm run test:parity
      - run: npm run parity-coverage-check

  capability:
    runs-on: ubuntu-latest
    needs: parity
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npm run test:capability

  e2e:
    runs-on: ubuntu-latest
    needs: capability
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npm run test:e2e
```

---

## Summary

Agent-native testing requires:

1. **Tool unit tests** — Each tool works correctly
2. **Parity tests** — Agent matches UI capabilities
3. **Capability tests** — Agent achieves outcomes
4. **E2E tests** — Full conversations work
5. **Behavior tests** — Agent handles errors, confirms destructive actions
6. **Outcome focus** — Validate results, not steps

Build confidence that agents can actually help users accomplish their goals.
