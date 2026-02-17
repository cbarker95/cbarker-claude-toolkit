---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite, EnterPlanMode, ExitPlanMode
description: Strategic planning with feature specs and execution strategy recommendation
---

# Plan Command

Strategic planning phase that evaluates the codebase, clarifies requirements, and generates detailed feature specifications with success criteria.

**Boundary:** This command produces `.dev-plan.md` and updates the PRD. It does NOT start implementation, install dependencies, create todos, or write code. Wait for the user to explicitly run `/execute`.

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
## Jobs to be Done

| Job Type | Description |
|----------|-------------|
| **Functional** | [What the user needs to accomplish] |
| **Emotional** | [How the user wants to feel] |
| **Social** | [How the user wants to be perceived] |
| **Success Criteria** | [Measurable outcome from user perspective] |
```

#### 3.2 Design Spec

```markdown
## Design Spec

**Layout**: [Full description of spatial arrangement]

**Visual Style**:
- Colors: [Palette with semantic meaning]
- Typography: [Font choices and hierarchy]
- Spacing: [Grid system and margins]
- Effects: [Shadows, borders, animations]

**Component Hierarchy**:
```
[Organism Name] (organism)
├── [Molecule Name] (molecule)
│   ├── [Atom Name] (atom)
│   └── [Atom Name] (atom)
├── [Molecule Name] (molecule)
└── [Atom Name] (atom)
```

**State Variations**:
- Loading: [Description]
- Empty: [Description]
- Error: [Description]
- Success: [Description]
- [Other relevant states]
```

#### 3.3 UX Architecture

```markdown
## UX Architecture

**User Flow**:
1. [Entry point and initial state]
2. [User action → System response]
3. [User action → System response]
4. [Completion/exit state]

**Entry Points**: [How users get here]
**Exit Points**: [Where users go next]

**Interactions**:
| Element | Click | Hover | Drag | Keyboard |
|---------|-------|-------|------|----------|
| [Element 1] | [Action] | [Action] | [Action] | [Action] |
| [Element 2] | [Action] | [Action] | [Action] | [Action] |

**Feedback Patterns**:
- Loading: [How loading is communicated]
- Success: [How success is communicated]
- Error: [How errors are communicated]
```

#### 3.4 Technical Architecture

```markdown
## Technical Architecture

**File Structure**:
```
src/[feature]/
├── [Component].tsx
├── [Component].module.css
├── [hooks/]
│   └── use[Feature].ts
├── [lib/]
│   └── [utility].ts
└── types.ts
```

**State Management**: [Approach - React state, context, external store]

**Data Flow**: [Source] → [Transform] → [Render]

**Integration Points**:
- [How this connects to existing code]
- [APIs or services consumed]
- [Events emitted or listened to]
```

### Phase 4: Outputs

After user approves the plan, produce two artifacts:

#### PRD Update

Update the PRD Implementation Status section:

```markdown
## Implementation Status

### Complete
| Feature | Commit | Date |
|---------|--------|------|
| [Feature name] | [hash] | [date] |

### In Progress
| Feature | Branch | Notes |
|---------|--------|-------|
| [Feature name] | [branch] | [status] |

### Next Up
| Feature | Priority | Dependencies |
|---------|----------|--------------|
| [Feature name] | P[0-3] | [deps] |

### Deferred
| Feature | Reason |
|---------|--------|
| [Feature name] | [why deferred] |
```

#### .dev-plan.md

```markdown
# Development Plan

**Generated**: [date]
**Session Focus**: [description]
**Branch**: feature-[name]
**Status**: not started

---

## Spec

### Jobs to be Done
[From Phase 3]

### Design Spec
[From Phase 3]

### UX Architecture
[From Phase 3]

### Technical Architecture
[From Phase 3]

---

## Success Criteria
- [ ] [Criterion 1 — from JTBD success criteria]
- [ ] [Criterion 2]
- [ ] `npm run build` passes
- [ ] PRD updated with completion markers
```

---

## Output Files

1. **Updated PRD**: `docs/product/PRD.md` (or user-specified path)
   - Implementation Status section updated with markers

2. **Development Plan**: `.dev-plan.md`
   - Feature specs + success criteria
   - Ready for `/execute`

---

## Integration

- Outputs feed into `/execute` command
- References project-specific PRD location
- Creates audit trail via PRD history
