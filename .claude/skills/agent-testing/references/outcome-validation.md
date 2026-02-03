# Outcome Validation

## The Principle

**Validate the end result, not the steps taken to get there.**

Agents may take different paths to achieve the same outcome. Tests should verify the destination, not police the journey.

---

## Why Outcomes Matter

### The Problem with Step Validation

```typescript
// WRONG: Testing steps
it("creates project correctly", async () => {
  const spy = jest.spyOn(tools, "create_project");

  await agent.execute("Create a project called Test");

  // This is fragile - agent might use different approach
  expect(spy).toHaveBeenCalledWith({
    name: "Test",
    description: "",
    settings: { notifications: true },
  });
});
```

Problems:
- Agent might add description by default
- Agent might use different default settings
- Agent might call multiple tools to achieve same result
- Test breaks when agent improves

### The Outcome Approach

```typescript
// RIGHT: Testing outcome
it("creates project correctly", async () => {
  await agent.execute("Create a project called Test");

  // Validate the outcome, not the method
  const project = await db.projects.findByName("Test");
  expect(project).toBeDefined();
  expect(project.name).toBe("Test");
});
```

Benefits:
- Agent can evolve without breaking tests
- Tests are stable and meaningful
- Focus on user value

---

## Outcome Validation Patterns

### Pattern 1: State Validation

Check database or system state after action:

```typescript
describe("State Validation", () => {
  it("project exists after creation", async () => {
    await agent.execute("Create project 'New Project'");

    // Validate state
    const project = await db.projects.findByName("New Project");
    expect(project).not.toBeNull();
  });

  it("project removed after deletion", async () => {
    const project = await createTestProject();

    await agent.execute(`Delete project "${project.name}"`);

    // Validate state
    expect(await db.projects.exists(project.id)).toBe(false);
  });

  it("member added to project", async () => {
    const project = await createTestProject();

    await agent.execute(`Add alice@test.com to "${project.name}"`);

    // Validate state
    const members = await db.members.find({ projectId: project.id });
    expect(members.map(m => m.email)).toContain("alice@test.com");
  });
});
```

### Pattern 2: Invariant Validation

Check that certain conditions always hold:

```typescript
describe("Invariant Validation", () => {
  it("project always has an owner", async () => {
    await agent.execute("Create project 'Test'");

    const project = await db.projects.findByName("Test");

    // Invariant: every project has owner
    expect(project.ownerId).toBeDefined();
  });

  it("task count matches actual tasks", async () => {
    const project = await createTestProject();

    await agent.execute(`Add 3 tasks to "${project.name}"`);

    const tasks = await db.tasks.find({ projectId: project.id });
    const projectData = await db.projects.get(project.id);

    // Invariant: cached count matches reality
    expect(projectData.taskCount).toBe(tasks.length);
  });

  it("soft-deleted items not in listings", async () => {
    const project = await createTestProject();

    await agent.execute(`Delete project "${project.name}"`);

    // Invariant: deleted items don't appear in lists
    const result = await agent.execute("List all projects");
    expect(result.content).not.toContain(project.name);
  });
});
```

### Pattern 3: Relationship Validation

Check that relationships are correctly maintained:

```typescript
describe("Relationship Validation", () => {
  it("task belongs to correct project", async () => {
    const project = await createTestProject();

    await agent.execute(`Create task "New Task" in "${project.name}"`);

    const task = await db.tasks.findByName("New Task");
    expect(task.projectId).toBe(project.id);
  });

  it("member removal cascades correctly", async () => {
    const project = await createTestProject();
    await agent.execute(`Add alice@test.com to "${project.name}"`);
    const member = await db.members.findByEmail("alice@test.com");

    await agent.execute(`Remove alice@test.com from "${project.name}"`);

    // Validate cascade
    const tasks = await db.tasks.find({ assigneeId: member.id });
    expect(tasks).toHaveLength(0); // Tasks reassigned or unassigned
  });

  it("project deletion handles dependents", async () => {
    const project = await createTestProject();
    await agent.execute(`Add 3 tasks to "${project.name}"`);
    await agent.execute(`Add 2 members to "${project.name}"`);

    await agent.execute(`Delete project "${project.name}"`);

    // Validate dependents handled
    const tasks = await db.tasks.find({ projectId: project.id });
    const members = await db.members.find({ projectId: project.id });
    expect(tasks).toHaveLength(0);
    expect(members).toHaveLength(0);
  });
});
```

### Pattern 4: Semantic Validation

Validate meaning, not exact content:

```typescript
describe("Semantic Validation", () => {
  it("summary includes key information", async () => {
    const project = await createTestProject({
      tasks: [
        { status: "done" },
        { status: "done" },
        { status: "in_progress" },
        { status: "todo" },
        { status: "todo" },
      ],
    });

    const result = await agent.execute(`Summarize "${project.name}"`);

    // Semantic validation - content conveys right info
    expect(result.content).toMatch(/2.*(complete|done)/i);
    expect(result.content).toMatch(/1.*(progress|active)/i);
    expect(result.content).toMatch(/2.*(todo|pending|remaining)/i);
  });

  it("error message is helpful", async () => {
    const result = await agent.execute("Delete nonexistent project");

    // Semantic validation - error is helpful
    expect(result.content).toMatch(/not found|doesn't exist|no.*project/i);
    // Ideally also suggests what to do
    expect(result.content).toMatch(/list|search|check/i);
  });
});
```

---

## Outcome Comparison

### Before/After Snapshots

```typescript
async function withSnapshot<T>(
  fn: () => Promise<void>,
  getState: () => Promise<T>
): Promise<{ before: T; after: T }> {
  const before = await getState();
  await fn();
  const after = await getState();
  return { before, after };
}

it("bulk archive changes only completed tasks", async () => {
  await createTestTasks([
    { status: "done" },
    { status: "done" },
    { status: "in_progress" },
  ]);

  const { before, after } = await withSnapshot(
    () => agent.execute("Archive all completed tasks"),
    () => db.tasks.findAll()
  );

  // Validate only done tasks changed
  const doneTasks = before.filter(t => t.status === "done");
  const otherTasks = before.filter(t => t.status !== "done");

  for (const task of doneTasks) {
    const updated = after.find(t => t.id === task.id);
    expect(updated.archived).toBe(true);
  }

  for (const task of otherTasks) {
    const updated = after.find(t => t.id === task.id);
    expect(updated.archived).toBe(task.archived); // Unchanged
  }
});
```

### Diff-Based Validation

```typescript
function diff<T>(before: T[], after: T[], key: keyof T): {
  added: T[];
  removed: T[];
  changed: Array<{ before: T; after: T }>;
} {
  const beforeMap = new Map(before.map(x => [x[key], x]));
  const afterMap = new Map(after.map(x => [x[key], x]));

  return {
    added: after.filter(x => !beforeMap.has(x[key])),
    removed: before.filter(x => !afterMap.has(x[key])),
    changed: after
      .filter(x => beforeMap.has(x[key]))
      .filter(x => JSON.stringify(x) !== JSON.stringify(beforeMap.get(x[key])))
      .map(x => ({ before: beforeMap.get(x[key])!, after: x })),
  };
}

it("only targeted task is updated", async () => {
  const tasks = await createTestTasks(5);
  const targetTask = tasks[2];

  const before = await db.tasks.findAll();

  await agent.execute(`Mark "${targetTask.name}" as complete`);

  const after = await db.tasks.findAll();
  const changes = diff(before, after, "id");

  expect(changes.added).toHaveLength(0);
  expect(changes.removed).toHaveLength(0);
  expect(changes.changed).toHaveLength(1);
  expect(changes.changed[0].after.id).toBe(targetTask.id);
});
```

---

## Flexible Outcome Matching

### Multiple Valid Outcomes

```typescript
it("handles ambiguous request reasonably", async () => {
  await createTestTasks([
    { name: "Task A", priority: "high" },
    { name: "Task B", priority: "high" },
  ]);

  await agent.execute("Work on the high priority task");

  // Either task being started is valid
  const tasks = await db.tasks.findAll();
  const inProgress = tasks.filter(t => t.status === "in_progress");

  expect(inProgress.length).toBeGreaterThanOrEqual(1);
  expect(inProgress.every(t => t.priority === "high")).toBe(true);
});
```

### Partial Success

```typescript
it("completes as much as possible", async () => {
  await createTestTasks([
    { name: "Valid Task 1" },
    { name: "Valid Task 2" },
    { name: "Locked Task", locked: true },
  ]);

  const result = await agent.execute("Complete all tasks");

  // Valid tasks should be done
  const tasks = await db.tasks.findAll();
  const validTasks = tasks.filter(t => !t.locked);
  expect(validTasks.every(t => t.status === "done")).toBe(true);

  // Should indicate partial success
  expect(result.content).toMatch(/locked|couldn't|some/i);
});
```

---

## What NOT to Validate

### Don't Validate Implementation Details

```typescript
// WRONG: Testing internal implementation
it("uses correct API call", async () => {
  const spy = jest.spyOn(api, "createProject");
  await agent.execute("Create project");
  expect(spy).toHaveBeenCalledTimes(1);
});

// RIGHT: Test observable outcome
it("project is created", async () => {
  await agent.execute("Create project 'Test'");
  expect(await db.projects.findByName("Test")).toBeDefined();
});
```

### Don't Validate Exact Wording

```typescript
// WRONG: Exact string match
expect(result.content).toBe("Project 'Test' has been created successfully.");

// RIGHT: Semantic validation
expect(await db.projects.findByName("Test")).toBeDefined();
```

### Don't Validate Timing

```typescript
// WRONG: Timing dependent
expect(project.createdAt).toBeCloseTo(Date.now(), -2);

// RIGHT: Just verify it exists
expect(project.createdAt).toBeDefined();
```

---

## Summary

Outcome validation focuses on:
1. **Final state** — What exists after the action
2. **Invariants** — Rules that always hold
3. **Relationships** — Connections between entities
4. **Semantics** — Meaning, not exact text

Let agents find their own path. Verify they arrive at the right destination.
