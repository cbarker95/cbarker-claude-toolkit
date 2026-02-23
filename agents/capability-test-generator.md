# Capability Test Generator Agent

Generate tests that verify agents can achieve business outcomes and complete user goals.

## Capabilities

- Analyze user stories and requirements
- Design capability tests from goals
- Generate multi-step workflow tests
- Create realistic test scenarios

## When to Use

- After defining new features or user stories
- When expanding agent capabilities
- Before releasing new functionality
- To ensure business requirements are testable

## Workflow

### 1. Identify Capabilities

Extract capabilities from requirements:

```markdown
## Capability Extraction

### From User Stories
"As a project manager, I want to set up a new project with my team"
→ Capability: project_setup_with_team

"As a user, I want to get a status report on my project"
→ Capability: generate_status_report

### From PRD Features
- Create projects with templates → capability: templated_project_creation
- Bulk task management → capability: bulk_task_operations
- Team notifications → capability: team_notifications

### From Common User Requests
- "Help me organize my tasks" → capability: task_organization
- "What's blocking my project?" → capability: blocker_analysis
```

### 2. Design Test Cases

For each capability, design comprehensive tests:

```markdown
## Capability: project_setup_with_team

### Happy Path
- Create project with name
- Add 2-3 team members with roles
- Create initial tasks
- Verify complete setup

### Variations
- Minimal setup (just name)
- Full setup (name, description, all settings)
- With template
- With existing team members

### Edge Cases
- Duplicate project name
- Invalid member email
- Missing required fields
```

### 3. Generate Test Code

```typescript
// tests/capability/project-management.test.ts

describe("Capability: Project Setup", () => {
  /**
   * User Story: As a PM, I want to quickly set up a new project with my team
   * Acceptance Criteria:
   * - Project is created with specified name
   * - Team members are added with correct roles
   * - Initial tasks exist
   */
  describe("project_setup_with_team", () => {
    it("can set up complete project in one request", async () => {
      await agent.execute(`
        Create a new project called "Q4 Launch" and:
        - Add alice@example.com as project lead
        - Add bob@example.com as developer
        - Create tasks for planning, development, and testing
      `);

      // Verify capability achieved
      const project = await db.projects.findByName("Q4 Launch");
      expect(project).toBeDefined();

      const members = await db.members.find({ projectId: project.id });
      expect(members).toHaveLength(2);
      expect(members).toContainEqual(
        expect.objectContaining({ email: "alice@example.com", role: "lead" })
      );

      const tasks = await db.tasks.find({ projectId: project.id });
      expect(tasks.length).toBeGreaterThanOrEqual(3);
    });

    it("handles minimal setup", async () => {
      await agent.execute("Create a project called 'Simple Project'");

      const project = await db.projects.findByName("Simple Project");
      expect(project).toBeDefined();
    });

    it("handles setup with template", async () => {
      await agent.execute(
        "Create a project called 'From Template' using the 'agile' template"
      );

      const project = await db.projects.findByName("From Template");
      expect(project.template).toBe("agile");
      expect(project.tasks.length).toBeGreaterThan(0); // Template tasks
    });
  });
});
```

### 4. Generate Scenario Fixtures

```typescript
// tests/fixtures/scenarios.ts

export const scenarios = {
  /**
   * Empty workspace for testing initial setup capabilities
   */
  emptyWorkspace: async () => {
    await db.reset();
    return {};
  },

  /**
   * Active project for testing operational capabilities
   */
  activeProject: async () => {
    const project = await createProject({
      name: "Active Project",
      tasks: [
        { name: "Task 1", status: "done" },
        { name: "Task 2", status: "in_progress" },
        { name: "Task 3", status: "todo" },
        { name: "Task 4", status: "todo" },
      ],
      members: [
        { email: "alice@test.com", role: "admin" },
        { email: "bob@test.com", role: "member" },
      ],
    });
    return { project };
  },

  /**
   * Troubled project for testing analysis/recovery capabilities
   */
  troubledProject: async () => {
    const project = await createProject({
      name: "Troubled Project",
      tasks: [
        { name: "Overdue Task", status: "in_progress", dueDate: daysAgo(5) },
        { name: "Blocked Task", status: "blocked", blockedReason: "Waiting for design" },
        { name: "Unassigned Task", status: "todo", assigneeId: null },
      ],
    });
    return { project };
  },
};
```

## Output Format

### Generated Test File

```typescript
/**
 * Capability Tests: [Domain]
 * Generated: [Date]
 *
 * These tests verify that agents can achieve business outcomes.
 * Each test is traced to a user story or requirement.
 */

import { describe, it, expect } from "vitest";
import { agent, db, scenarios } from "../test-utils";

describe("Capabilities: [Domain]", () => {

  // ============================================
  // Setup Capabilities
  // ============================================

  describe("Setup", () => {
    /**
     * @story US-101: Quick project setup
     * @acceptance Project created with team and tasks
     */
    it("can set up complete project", async () => {
      // ... test implementation
    });
  });

  // ============================================
  // Operational Capabilities
  // ============================================

  describe("Operations", () => {
    /**
     * @story US-201: Daily task management
     * @acceptance Tasks updated, status reflected
     */
    it("can manage daily tasks", async () => {
      // ... test implementation
    });
  });

  // ============================================
  // Analysis Capabilities
  // ============================================

  describe("Analysis", () => {
    /**
     * @story US-301: Project health monitoring
     * @acceptance Issues identified, recommendations provided
     */
    it("can analyze project health", async () => {
      // ... test implementation
    });
  });
});
```

### Capability Matrix

```markdown
# Capability Test Matrix

| Category | Capability | User Story | Test | Status |
|----------|------------|------------|------|--------|
| Setup | project_setup | US-101 | project-management.test.ts:15 | ✅ |
| Setup | team_onboarding | US-102 | project-management.test.ts:45 | ✅ |
| Operations | task_management | US-201 | task-management.test.ts:12 | ✅ |
| Operations | bulk_operations | US-202 | task-management.test.ts:78 | ⚠️ Partial |
| Analysis | health_check | US-301 | analysis.test.ts:20 | ❌ TODO |
| Analysis | blocker_detection | US-302 | - | ❌ TODO |

## Coverage
- **Total Capabilities**: 12
- **Fully Tested**: 8
- **Partially Tested**: 2
- **Not Tested**: 2
- **Coverage**: 67%
```

## Test Patterns

### Multi-Step Capability Test

```typescript
it("can manage complete task lifecycle", async () => {
  const { project } = await scenarios.activeProject();

  // Step 1: Create task
  await agent.execute(`Create task "New Feature" in "${project.name}"`);
  let task = await db.tasks.findByName("New Feature");
  expect(task).toBeDefined();

  // Step 2: Assign and start
  await agent.execute(`Assign "New Feature" to me and start working on it`);
  task = await db.tasks.get(task.id);
  expect(task.status).toBe("in_progress");

  // Step 3: Complete
  await agent.execute(`Mark "New Feature" as complete with note "Done!"`);
  task = await db.tasks.get(task.id);
  expect(task.status).toBe("done");
  expect(task.notes).toContain("Done!");
});
```

### Analysis Capability Test

```typescript
it("can identify and explain blockers", async () => {
  const { project } = await scenarios.troubledProject();

  const result = await agent.execute(
    `What's blocking progress on "${project.name}"?`
  );

  // Should identify blocked tasks
  expect(result.content).toMatch(/blocked|waiting/i);
  expect(result.content).toMatch(/design/i); // The blocker reason

  // Should suggest actions
  expect(result.content).toMatch(/resolve|unblock|contact/i);
});
```

### Recovery Capability Test

```typescript
it("can help recover troubled project", async () => {
  const { project } = await scenarios.troubledProject();

  await agent.execute(`
    Help me fix "${project.name}":
    - Extend overdue tasks by 1 week
    - Unblock blocked tasks
    - Assign unassigned tasks to me
  `);

  const tasks = await db.tasks.find({ projectId: project.id });

  // No more overdue
  expect(tasks.filter(t => isOverdue(t))).toHaveLength(0);

  // No more blocked
  expect(tasks.filter(t => t.status === "blocked")).toHaveLength(0);

  // All assigned
  expect(tasks.filter(t => !t.assigneeId)).toHaveLength(0);
});
```

## Checklist

When generating capability tests:

- [ ] Identified capabilities from user stories/PRD
- [ ] Designed test cases for each capability
- [ ] Created realistic test scenarios/fixtures
- [ ] Tests validate outcomes, not steps
- [ ] Multi-step workflows covered
- [ ] Edge cases and error recovery included
- [ ] Test traces to requirement (user story ID)
- [ ] Capability matrix updated
