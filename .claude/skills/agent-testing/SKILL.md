# Agent Testing Skill

Test that agents can actually do what they're supposed to do.

## Purpose

Agent-native applications need different testing approaches than traditional software. This skill covers:

- **Parity testing** — Verify agents can do what users can do
- **Capability testing** — Test agent can achieve specific outcomes
- **Outcome validation** — Verify results, not steps
- **Behavior validation** — Ensure agents follow prompt guidelines

## Core Principles

### Test Outcomes, Not Steps

```typescript
// WRONG: Testing implementation
expect(agent).toHaveCalledTool("create_project");
expect(agent).toHaveCalledTool("add_member");

// RIGHT: Testing outcome
const result = await agent.execute("Create a project with Alice as admin");
expect(result.project).toBeDefined();
expect(result.project.members).toContainEqual({ name: "Alice", role: "admin" });
```

### Test Capabilities, Not Tools

```typescript
// WRONG: Testing tool exists
expect(tools).toContain("delete_project");

// RIGHT: Testing capability works
const result = await agent.execute("Delete the test project");
expect(await db.projects.exists("test-project")).toBe(false);
```

### Test Parity Continuously

```typescript
// For every UI action, verify agent equivalent
for (const uiAction of extractUIActions()) {
  it(`agent can ${uiAction.description}`, async () => {
    const result = await agent.execute(uiAction.naturalLanguage);
    expect(result.outcome).toEqual(uiAction.expectedOutcome);
  });
}
```

## When to Use This Skill

- After implementing new agent tools
- After adding new UI capabilities
- Before releasing agent-native features
- When debugging agent capability issues
- During code review of agent-related changes

## Key Concepts

### Parity Testing

Ensures agents can do everything users can do through the UI. See [parity-testing.md](references/parity-testing.md).

### Capability Testing

Tests that agents can achieve specific outcomes regardless of how. See [capability-testing.md](references/capability-testing.md).

### Outcome Validation

Validates the end result, not the path taken. See [outcome-validation.md](references/outcome-validation.md).

### Agent-Native Testing Patterns

Testing patterns specific to agent-native applications. See [agent-native-testing.md](references/agent-native-testing.md).

## Testing Pyramid for Agents

```
                 ╱╲
                ╱  ╲
               ╱ E2E╲          End-to-end: Full agent conversations
              ╱──────╲
             ╱        ╲
            ╱ Capability╲      Capability: Agent achieves outcomes
           ╱────────────╲
          ╱              ╲
         ╱    Parity      ╲    Parity: Agent matches UI capabilities
        ╱──────────────────╲
       ╱                    ╲
      ╱      Tool Unit       ╲  Unit: Individual tools work correctly
     ╱────────────────────────╲
```

### Layer Descriptions

1. **Tool Unit Tests**: Each tool returns correct results for inputs
2. **Parity Tests**: Every UI action has working agent equivalent
3. **Capability Tests**: Agent can achieve business outcomes
4. **E2E Tests**: Full conversations produce expected results

## Agents

- **parity-test-generator** — Generates tests verifying action parity
- **capability-test-generator** — Generates tests for agent capabilities
- **agent-behavior-validator** — Validates agent follows guidelines

## Commands

- `/parity-audit` — Audit and test action parity
- `/generate-tests` — Generate agent capability tests

## Quick Reference

### Test File Structure

```
tests/
├── unit/
│   └── tools/           # Tool unit tests
│       ├── create_project.test.ts
│       └── list_projects.test.ts
├── parity/
│   └── actions.test.ts  # UI action parity tests
├── capability/
│   └── workflows.test.ts # Business capability tests
└── e2e/
    └── conversations.test.ts # Full conversation tests
```

### Test Naming Convention

```typescript
// Parity tests
describe("Action Parity", () => {
  it("can create project (matches: Dashboard > New Project)", ...);
  it("can delete project (matches: Settings > Delete)", ...);
});

// Capability tests
describe("Project Management Capabilities", () => {
  it("can set up a new project with team", ...);
  it("can archive completed projects", ...);
});
```

## References

- [parity-testing.md](references/parity-testing.md) — Parity test patterns
- [capability-testing.md](references/capability-testing.md) — Capability test patterns
- [outcome-validation.md](references/outcome-validation.md) — Outcome validation
- [agent-native-testing.md](references/agent-native-testing.md) — Agent-native patterns
