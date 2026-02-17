---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite, EnterPlanMode, ExitPlanMode
description: Strategic planning with feature specs and success criteria
---

# Plan Command

Evaluates the codebase, clarifies requirements, generates feature specs, and writes them directly into the PRD.

**Boundary:** This command updates the PRD only. It does NOT start implementation, install dependencies, create todos, or write code. Wait for the user to explicitly run `/execute`.

## Usage

```
/plan [--prd=docs/product/PRD.md]
```

---

## Workflow

### Phase 1: Discovery

Work in plan mode. Understand current state by analyzing the PRD (`docs/product/PRD.md` or user-specified path) and the codebase in parallel. Identify:
- Feature status: what's complete, in progress, not started
- Existing patterns: component structure, state management, styling approach
- Integration points: APIs, shared state, config
- Gaps between PRD intent and implementation reality

### Phase 2: Clarification

Present the user with current status (complete / in progress / not started) and ask them to choose the session focus. Follow up on JTBD clarification as needed — what problem does the selected feature solve for the user?

### Phase 3: Feature Spec Generation

For each feature in scope, generate detailed specifications:

#### 3.1 Jobs to be Done

```markdown
| Job Type | Description |
|----------|-------------|
| **Functional** | [What the user needs to accomplish] |
| **Emotional** | [How the user wants to feel] |
| **Social** | [How the user wants to be perceived] |
| **Success Criteria** | [Measurable outcome from user perspective] |
```

#### 3.2 Design Spec

```markdown
**Layout**: [Full description of spatial arrangement]

**Visual Style**:
- Colors: [Palette with semantic meaning]
- Typography: [Font choices and hierarchy]
- Spacing: [Grid system and margins]
- Effects: [Shadows, borders, animations]

**Component Hierarchy**:
[Organism Name] (organism)
├── [Molecule Name] (molecule)
│   ├── [Atom Name] (atom)
│   └── [Atom Name] (atom)
├── [Molecule Name] (molecule)
└── [Atom Name] (atom)

**State Variations**:
- Loading / Empty / Error / Success / [Other]
```

#### 3.3 UX Architecture

```markdown
**User Flow**:
1. [Entry point and initial state]
2. [User action → System response]
3. [Completion/exit state]

**Entry Points**: [How users get here]
**Exit Points**: [Where users go next]

**Interactions**:
| Element | Click | Hover | Keyboard |
|---------|-------|-------|----------|
| [Element] | [Action] | [Action] | [Action] |

**Feedback Patterns**: Loading / Success / Error
```

#### 3.4 Technical Architecture

```markdown
**File Structure**:
src/[feature]/
├── [Component].tsx
├── [Component].module.css
├── [hooks/] → use[Feature].ts
├── [lib/] → [utility].ts
└── types.ts

**State Management**: [Approach]
**Data Flow**: [Source] → [Transform] → [Render]
**Integration Points**: [How this connects to existing code]
```

### Phase 4: Write to PRD

Write the feature spec directly into the PRD under a new section:

```markdown
### In Progress: [Feature Name]

**Branch**: feature-[name]
**Started**: [date]

#### Jobs to be Done
[From Phase 3]

#### Design Spec
[From Phase 3]

#### UX Architecture
[From Phase 3]

#### Technical Architecture
[From Phase 3]

#### Success Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] `npm run build` passes
```

Place this in the Implementation Status section, after "Complete" entries and before "Not Started."

When the feature ships, `/execute` converts this to a "Complete" entry with commit hash and date.

---

## Output

**Updated PRD**: `docs/product/PRD.md` (or user-specified path)
- Feature spec written into Implementation Status
- Ready for `/execute`

---

## Integration

- PRD is the single source of truth — no intermediate plan files
- `/execute` reads the In Progress spec from the PRD
- `/strategy` reads/writes the same PRD
