# Capability Testing

## The Principle

**Test that agents can achieve business outcomes, not just execute tools.**

Capability tests verify that an agent can accomplish real user goals. They're higher-level than parity tests and focus on what users actually want to achieve.

---

## Capability vs Parity

| Parity Tests | Capability Tests |
|--------------|------------------|
| "Can agent create a project?" | "Can agent set up a complete workspace?" |
| Tool-level verification | Goal-level verification |
| Maps to UI buttons | Maps to user stories |
| "Agent can do X" | "Agent can help user accomplish Y" |

---

## Capability Test Structure

### Basic Pattern

```typescript
describe("Project Management Capabilities", () => {
  it("can set up a new project with team", async () => {
    // User goal: Set up a complete project
    const result = await agent.execute(`
      Create a new project called "Q4 Launch" and:
      - Add Alice (alice@example.com) as project lead
      - Add Bob (bob@example.com) as developer
      - Set the deadline to end of quarter
      - Create initial tasks for planning, development, and launch
    `);

    // Verify the capability was achieved
    const project = await db.projects.findByName("Q4 Launch");
    expect(project).toBeDefined();

    const members = await db.members.find({ projectId: project.id });
    expect(members).toHaveLength(2);
    expect(members.map(m => m.email)).toContain("alice@example.com");

    const tasks = await db.tasks.find({ projectId: project.id });
    expect(tasks.length).toBeGreaterThanOrEqual(3);
  });
});
```

### With Capability Definition

```typescript
// Define capabilities as testable specifications
interface Capability {
  name: string;
  description: string;
  userStory: string;
  testPrompt: string;
  verify: (context: TestContext) => Promise<boolean>;
}

const capabilities: Capability[] = [
  {
    name: "project_setup",
    description: "Set up a complete project with team and tasks",
    userStory: "As a PM, I want to quickly set up a new project with my team",
    testPrompt: `Create project "Test Project" with:
      - Member: test@example.com as admin
      - Initial task: "Planning"`,
    verify: async (ctx) => {
      const project = await db.projects.findByName("Test Project");
      if (!project) return false;

      const members = await db.members.find({ projectId: project.id });
      if (!members.some(m => m.email === "test@example.com")) return false;

      const tasks = await db.tasks.find({ projectId: project.id });
      return tasks.some(t => t.name.includes("Planning"));
    },
  },
];

// Generate tests from capabilities
describe("Agent Capabilities", () => {
  for (const cap of capabilities) {
    it(cap.name, async () => {
      const ctx = await setupTestContext();
      await agent.execute(cap.testPrompt);
      const passed = await cap.verify(ctx);
      expect(passed).toBe(true);
    });
  }
});
```

---

## Capability Categories

### 1. Setup Capabilities

Things users do to get started:

```typescript
describe("Setup Capabilities", () => {
  it("can complete initial onboarding", async () => {
    await agent.execute("Help me get started with a new workspace");
    expect(await db.workspaces.count()).toBeGreaterThan(0);
  });

  it("can configure workspace settings", async () => {
    await agent.execute("Set up my workspace with dark mode and weekly digests");
    const settings = await db.settings.get(userId);
    expect(settings.theme).toBe("dark");
    expect(settings.digestFrequency).toBe("weekly");
  });

  it("can import existing data", async () => {
    await agent.execute("Import my projects from the CSV file at /data/projects.csv");
    expect(await db.projects.count()).toBeGreaterThan(0);
  });
});
```

### 2. Operational Capabilities

Day-to-day tasks:

```typescript
describe("Operational Capabilities", () => {
  it("can manage task workflow", async () => {
    const task = await createTestTask({ status: "todo" });

    await agent.execute(`
      Move task "${task.name}" to in-progress,
      add a note "Started working on this",
      and assign it to me
    `);

    const updated = await db.tasks.get(task.id);
    expect(updated.status).toBe("in_progress");
    expect(updated.notes).toContain("Started working");
    expect(updated.assigneeId).toBe(userId);
  });

  it("can generate status reports", async () => {
    await createTestTasks(10);

    const result = await agent.execute("Generate a status report for this week");

    expect(result.content).toContain("completed");
    expect(result.content).toContain("in progress");
    expect(result.content).toMatch(/\d+ tasks/);
  });

  it("can handle bulk operations", async () => {
    const tasks = await createTestTasks(5, { status: "done" });

    await agent.execute("Archive all completed tasks");

    for (const task of tasks) {
      const updated = await db.tasks.get(task.id);
      expect(updated.archived).toBe(true);
    }
  });
});
```

### 3. Analysis Capabilities

Insights and reporting:

```typescript
describe("Analysis Capabilities", () => {
  it("can analyze project health", async () => {
    await createTestProject({
      tasks: [
        { status: "done", completedAt: daysAgo(1) },
        { status: "done", completedAt: daysAgo(2) },
        { status: "overdue", dueAt: daysAgo(3) },
      ],
    });

    const result = await agent.execute("How healthy is my project?");

    expect(result.content).toMatch(/overdue|behind|risk/i);
  });

  it("can identify bottlenecks", async () => {
    await createTestProject({
      tasks: [
        { status: "blocked", blockedBy: "waiting for design" },
        { status: "blocked", blockedBy: "waiting for design" },
        { status: "in_progress" },
      ],
    });

    const result = await agent.execute("What's blocking progress?");

    expect(result.content).toMatch(/design|blocked/i);
  });

  it("can forecast completion", async () => {
    await createTestProjectWithVelocity();

    const result = await agent.execute("When will we finish at current pace?");

    expect(result.content).toMatch(/\d+ (days|weeks)/);
  });
});
```

### 4. Recovery Capabilities

Handling problems:

```typescript
describe("Recovery Capabilities", () => {
  it("can recover deleted items", async () => {
    const project = await createTestProject();
    await db.projects.softDelete(project.id);

    await agent.execute(`Restore the deleted project "${project.name}"`);

    const restored = await db.projects.get(project.id);
    expect(restored.deletedAt).toBeNull();
  });

  it("can resolve conflicts", async () => {
    const task = await createTestTask();
    // Simulate conflicting edits
    await db.tasks.update(task.id, { version: 2, name: "Version A" });

    const result = await agent.execute(`
      There's a conflict on task "${task.name}".
      Keep the version with "Version A" in the name.
    `);

    const resolved = await db.tasks.get(task.id);
    expect(resolved.name).toContain("Version A");
  });

  it("can rollback changes", async () => {
    const project = await createTestProject({ name: "Original" });
    await db.projects.update(project.id, { name: "Changed" });

    await agent.execute("Undo the last change to my project");

    const rolled = await db.projects.get(project.id);
    expect(rolled.name).toBe("Original");
  });
});
```

---

## Multi-Step Capability Tests

### Sequential Steps

```typescript
it("can manage complete project lifecycle", async () => {
  // Step 1: Create
  await agent.execute("Create a project called 'Product Launch'");
  let project = await db.projects.findByName("Product Launch");
  expect(project).toBeDefined();

  // Step 2: Build out
  await agent.execute(`
    Add these tasks to "Product Launch":
    - Design mockups
    - Implement features
    - Write documentation
  `);
  let tasks = await db.tasks.find({ projectId: project.id });
  expect(tasks.length).toBe(3);

  // Step 3: Progress
  await agent.execute('Mark "Design mockups" as complete');
  tasks = await db.tasks.find({ projectId: project.id, status: "done" });
  expect(tasks.length).toBe(1);

  // Step 4: Complete
  await agent.execute("Complete all remaining tasks and archive the project");
  project = await db.projects.get(project.id);
  expect(project.archived).toBe(true);
});
```

### Branching Paths

```typescript
it("handles different user decisions", async () => {
  const project = await createTestProject({
    tasks: [{ status: "overdue" }],
  });

  // Path A: User wants to extend deadline
  const resultA = await agent.execute("Extend the deadline by a week");
  // Verify deadline extended

  // Path B: User wants to reduce scope
  const resultB = await agent.execute("Remove the overdue task instead");
  // Verify task removed

  // Both paths should be valid capabilities
});
```

---

## Capability Test Fixtures

### Realistic Test Data

```typescript
// fixtures/projects.ts
export const testScenarios = {
  emptyWorkspace: async () => {
    // Fresh start, no data
  },

  activeProject: async () => {
    return createTestProject({
      name: "Active Project",
      tasks: [
        { name: "Task 1", status: "done" },
        { name: "Task 2", status: "in_progress" },
        { name: "Task 3", status: "todo" },
      ],
      members: [
        { email: "alice@test.com", role: "admin" },
        { email: "bob@test.com", role: "member" },
      ],
    });
  },

  troubledProject: async () => {
    return createTestProject({
      name: "Troubled Project",
      tasks: [
        { name: "Overdue task", status: "overdue", dueAt: daysAgo(5) },
        { name: "Blocked task", status: "blocked" },
        { name: "Unassigned task", assigneeId: null },
      ],
    });
  },
};
```

### Context-Rich Testing

```typescript
it("can help with troubled project", async () => {
  const project = await testScenarios.troubledProject();

  const result = await agent.execute(`
    My project "${project.name}" is in trouble. Help me:
    1. Deal with overdue tasks
    2. Unblock blocked tasks
    3. Assign remaining work
  `);

  // Verify agent addressed all issues
  const tasks = await db.tasks.find({ projectId: project.id });
  expect(tasks.filter(t => t.status === "overdue")).toHaveLength(0);
  expect(tasks.filter(t => t.status === "blocked")).toHaveLength(0);
  expect(tasks.filter(t => !t.assigneeId)).toHaveLength(0);
});
```

---

## Capability Matrix

Track which capabilities are tested:

```markdown
## Capability Test Matrix

| Category | Capability | Tested | Notes |
|----------|------------|--------|-------|
| Setup | Initial onboarding | ✅ | |
| Setup | Import data | ✅ | CSV only |
| Setup | Configure settings | ✅ | |
| Operations | Task management | ✅ | |
| Operations | Bulk operations | ⚠️ | Archive only |
| Operations | Status reports | ✅ | |
| Analysis | Project health | ✅ | |
| Analysis | Bottleneck detection | ❌ | TODO |
| Analysis | Forecasting | ❌ | TODO |
| Recovery | Restore deleted | ✅ | |
| Recovery | Conflict resolution | ❌ | Complex |
| Recovery | Rollback changes | ⚠️ | Single step only |

**Coverage**: 8/12 (67%)
```

---

## Summary

Capability testing verifies:
1. Agents can achieve real user goals
2. Multi-step workflows complete successfully
3. Edge cases and recovery paths work
4. Business value is delivered

Focus on what users want to accomplish, not what tools exist.
