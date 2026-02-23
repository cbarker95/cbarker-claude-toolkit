# Parity Testing

## The Principle

**Test that agents can do everything users can do through the UI.**

Parity tests are the foundation of agent-native testing. They ensure your agent isn't arbitrarily limited compared to manual UI usage.

---

## Parity Test Structure

### Basic Pattern

```typescript
describe("Action Parity", () => {
  // For each UI action, test agent can achieve same outcome

  it("can create project (UI: Dashboard > New Project button)", async () => {
    // Agent action
    const result = await agent.execute("Create a new project called 'Test'");

    // Verify same outcome as UI action would produce
    expect(result.success).toBe(true);
    const project = await db.projects.findByName("Test");
    expect(project).toBeDefined();
  });

  it("can delete project (UI: Settings > Delete button)", async () => {
    // Setup
    const project = await createTestProject();

    // Agent action
    const result = await agent.execute(`Delete the project "${project.name}"`);

    // Verify same outcome
    expect(result.success).toBe(true);
    expect(await db.projects.exists(project.id)).toBe(false);
  });
});
```

### With UI Action Mapping

```typescript
// Define UI actions with their agent equivalents
const uiActions = [
  {
    name: "create_project",
    uiPath: "Dashboard > New Project",
    agentPrompt: "Create a new project called '{name}'",
    verify: async (params) => {
      const project = await db.projects.findByName(params.name);
      return project !== null;
    },
  },
  {
    name: "delete_project",
    uiPath: "Project Settings > Delete",
    agentPrompt: "Delete the project '{name}'",
    verify: async (params) => {
      const project = await db.projects.findByName(params.name);
      return project === null;
    },
  },
];

// Generate tests for all UI actions
describe("Action Parity", () => {
  for (const action of uiActions) {
    it(`${action.name} (UI: ${action.uiPath})`, async () => {
      const params = generateTestParams(action);
      const prompt = interpolate(action.agentPrompt, params);

      await agent.execute(prompt);

      const passed = await action.verify(params);
      expect(passed).toBe(true);
    });
  }
});
```

---

## Extracting UI Actions

### From React Components

```typescript
// extract-ui-actions.ts
import { parse } from "@babel/parser";
import traverse from "@babel/traverse";

function extractUIActions(componentPath: string): UIAction[] {
  const code = fs.readFileSync(componentPath, "utf-8");
  const ast = parse(code, { plugins: ["jsx", "typescript"] });
  const actions: UIAction[] = [];

  traverse(ast, {
    JSXElement(path) {
      // Find onClick handlers
      const onClick = path.node.openingElement.attributes.find(
        attr => attr.name?.name === "onClick"
      );

      if (onClick) {
        // Extract action info from handler or nearby comments
        actions.push({
          component: componentPath,
          element: path.node.openingElement.name.name,
          handler: extractHandlerName(onClick),
        });
      }
    },
  });

  return actions;
}
```

### From Route Handlers

```typescript
// For API routes that UI calls
function extractAPIActions(routesDir: string): UIAction[] {
  const routes = glob.sync(`${routesDir}/**/*.ts`);
  const actions: UIAction[] = [];

  for (const route of routes) {
    const handlers = parseRouteHandlers(route);
    for (const handler of handlers) {
      actions.push({
        method: handler.method,
        path: handler.path,
        description: handler.description,
      });
    }
  }

  return actions;
}
```

### Manual Inventory

```typescript
// When extraction isn't feasible, maintain manually
const UI_ACTIONS: UIAction[] = [
  // Projects
  { area: "Projects", action: "Create project", path: "Dashboard > New" },
  { area: "Projects", action: "Edit project", path: "Project > Settings" },
  { area: "Projects", action: "Delete project", path: "Settings > Delete" },
  { area: "Projects", action: "Archive project", path: "Settings > Archive" },

  // Members
  { area: "Members", action: "Invite member", path: "Team > Invite" },
  { area: "Members", action: "Remove member", path: "Team > Member > Remove" },
  { area: "Members", action: "Change role", path: "Team > Member > Role" },

  // Settings
  { area: "Settings", action: "Update profile", path: "Settings > Profile" },
  { area: "Settings", action: "Change password", path: "Settings > Security" },
];
```

---

## Parity Test Patterns

### Pattern 1: CRUD Parity

```typescript
describe("CRUD Parity: Projects", () => {
  it("Create: can create project", async () => {
    const result = await agent.execute("Create project 'New Project'");
    expect(await db.projects.count()).toBe(1);
  });

  it("Read: can view project details", async () => {
    const project = await createTestProject();
    const result = await agent.execute(`Show me project "${project.name}"`);
    expect(result.content).toContain(project.name);
    expect(result.content).toContain(project.description);
  });

  it("Update: can edit project", async () => {
    const project = await createTestProject();
    await agent.execute(`Rename project "${project.name}" to "Updated"`);
    const updated = await db.projects.get(project.id);
    expect(updated.name).toBe("Updated");
  });

  it("Delete: can delete project", async () => {
    const project = await createTestProject();
    await agent.execute(`Delete project "${project.name}"`);
    expect(await db.projects.exists(project.id)).toBe(false);
  });

  it("List: can list projects", async () => {
    await createTestProject({ name: "Project A" });
    await createTestProject({ name: "Project B" });
    const result = await agent.execute("List all projects");
    expect(result.content).toContain("Project A");
    expect(result.content).toContain("Project B");
  });
});
```

### Pattern 2: Workflow Parity

```typescript
describe("Workflow Parity: Onboarding", () => {
  it("can complete new user onboarding", async () => {
    // UI flow: Welcome > Create Project > Invite Team > Done

    // Agent equivalent
    await agent.execute(`
      I'm a new user. Help me get started:
      1. Create my first project called "My Project"
      2. Invite alice@example.com as an admin
      3. Set up notifications
    `);

    // Verify all onboarding steps completed
    const project = await db.projects.findByName("My Project");
    expect(project).toBeDefined();

    const member = await db.members.find({ projectId: project.id, email: "alice@example.com" });
    expect(member).toBeDefined();
    expect(member.role).toBe("admin");

    const settings = await db.settings.get(project.id);
    expect(settings.notifications).toBeDefined();
  });
});
```

### Pattern 3: Edge Case Parity

```typescript
describe("Edge Case Parity", () => {
  it("handles empty state like UI", async () => {
    // UI shows "No projects yet" message
    const result = await agent.execute("List my projects");
    expect(result.content).toMatch(/no projects|empty|none/i);
  });

  it("handles not found like UI", async () => {
    // UI shows 404 page
    const result = await agent.execute("Show project 'nonexistent'");
    expect(result.content).toMatch(/not found|doesn't exist/i);
  });

  it("handles permission denied like UI", async () => {
    // UI shows access denied
    const result = await agent.execute("Delete admin project");
    expect(result.content).toMatch(/permission|access|denied/i);
  });
});
```

---

## Parity Test Coverage

### Measuring Coverage

```typescript
// parity-coverage.ts
interface ParityCoverage {
  totalUIActions: number;
  testedActions: number;
  untestedActions: UIAction[];
  coveragePercent: number;
}

function calculateParityCoverage(
  uiActions: UIAction[],
  parityTests: ParityTest[]
): ParityCoverage {
  const tested = new Set(parityTests.map(t => t.actionId));
  const untested = uiActions.filter(a => !tested.has(a.id));

  return {
    totalUIActions: uiActions.length,
    testedActions: tested.size,
    untestedActions: untested,
    coveragePercent: (tested.size / uiActions.length) * 100,
  };
}
```

### Coverage Report

```markdown
# Parity Test Coverage Report

**Date**: 2024-01-15
**Coverage**: 85% (17/20 UI actions)

## Covered Actions
✅ Create project
✅ Edit project
✅ Delete project
✅ List projects
✅ Invite member
✅ Remove member
...

## Uncovered Actions
❌ Export to PDF (Settings > Export)
❌ Bulk archive (Select All > Archive)
❌ Duplicate project (Context Menu > Duplicate)

## Recommendations
1. Add export_project tool for PDF export
2. Add bulk_archive tool or array support to archive
3. Add duplicate_project tool
```

---

## Automated Parity Checks

### CI Integration

```yaml
# .github/workflows/parity.yml
name: Parity Tests

on: [push, pull_request]

jobs:
  parity:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Extract UI Actions
        run: npm run extract-ui-actions

      - name: Run Parity Tests
        run: npm run test:parity

      - name: Check Parity Coverage
        run: |
          coverage=$(npm run parity-coverage --silent)
          if [ "$coverage" -lt 90 ]; then
            echo "Parity coverage below 90%: $coverage%"
            exit 1
          fi
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Check if UI files changed
ui_changed=$(git diff --cached --name-only | grep -E "components/|pages/")

if [ -n "$ui_changed" ]; then
  echo "UI files changed. Running parity check..."
  npm run parity-check

  if [ $? -ne 0 ]; then
    echo "ERROR: New UI actions without parity tests detected."
    echo "Add tests before committing."
    exit 1
  fi
fi
```

---

## Anti-Patterns

### Testing Tool Existence, Not Capability

```typescript
// WRONG
it("has delete tool", () => {
  expect(tools.map(t => t.name)).toContain("delete_project");
});

// RIGHT
it("can delete project", async () => {
  const project = await createTestProject();
  await agent.execute(`Delete "${project.name}"`);
  expect(await db.projects.exists(project.id)).toBe(false);
});
```

### Testing Happy Path Only

```typescript
// WRONG: Only tests success
it("can create project", async () => {
  await agent.execute("Create project 'Test'");
  expect(await db.projects.count()).toBe(1);
});

// RIGHT: Tests edge cases too
it("handles duplicate name like UI", async () => {
  await createTestProject({ name: "Test" });
  const result = await agent.execute("Create project 'Test'");
  expect(result.content).toMatch(/already exists|duplicate/i);
});
```

### Brittle Natural Language Matching

```typescript
// WRONG: Exact string match
expect(result.content).toBe("Project created successfully.");

// RIGHT: Semantic validation
expect(await db.projects.findByName("Test")).toBeDefined();
```

---

## Summary

Parity testing ensures:
1. Every UI action has an agent equivalent
2. Agent produces same outcomes as UI
3. Edge cases handled consistently
4. Coverage tracked and enforced

The goal: Users never hit "the agent can't do that" for things they can do manually.
