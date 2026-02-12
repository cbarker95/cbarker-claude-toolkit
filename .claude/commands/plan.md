---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite, EnterPlanMode, ExitPlanMode
description: Strategic planning with detailed feature specs for parallel development
---

# Plan Command

Strategic planning phase that evaluates the codebase, clarifies requirements, generates detailed feature specifications, updates the PRD, and outputs a slice plan with skill recommendations.

**Boundary:** This command produces `.parallel-plan.md` and updates the PRD. It does NOT start implementation, install dependencies, create todos, or write code. Wait for the user to explicitly run `/execute`.

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

#### PRD Completion Markers

Update the PRD with:

```markdown
## Implementation Status

### Complete
| Feature | Commit | Date |
|---------|--------|------|
| [Feature name] | [hash] | [date] |

### In Progress
| Feature | Branch | Owner | Notes |
|---------|--------|-------|-------|
| [Feature name] | [branch] | [agent] | [status] |

### Next Up
| Feature | Priority | Dependencies | Estimated Slices |
|---------|----------|--------------|------------------|
| [Feature name] | P[0-3] | [deps] | [count] |

### Deferred
| Feature | Reason |
|---------|--------|
| [Feature name] | [why deferred] |
```

#### .parallel-plan.md

```markdown
# Parallel Development Plan

**Generated**: [date]
**PRD Version**: [version]
**Session Focus**: [description]

## Slices

### Slice 1: [Slice Name]

**Branch**: feature-[name]

**Recommended Skills**:
- `[skill-1]`
- `[skill-2]`

#### Jobs to be Done
[From feature spec]

#### Design Spec
[From feature spec]

#### UX Architecture
[From feature spec]

#### Technical Architecture
[From feature spec]

**Files Owned**:
- [List of files/directories this slice can modify]

**Do NOT Modify** (frozen):
- [List of shared/frozen files]

**Success Criteria**:
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- Commit: "COMPLETE: [description]"

---

### Slice 2: [Slice Name]
[Same structure as Slice 1]

---

## Merge Order
1. [Slice with no dependencies first]
2. [Dependent slices after]

## Frozen Files (all slices)
- package.json
- tsconfig.json
- [Other shared files]
```

---

## Skill Recommendations

Based on slice requirements, recommend appropriate skills:

| Slice Type | Recommended Skills |
|------------|-------------------|
| UI Components | `frontend-design`, `atomic-design-system` |
| Backend/Tools | `agent-native-architecture` |
| Full Feature | `frontend-design`, skill matching domain |
| Infrastructure | Domain-specific skills |

---

## Output Files

1. **Updated PRD**: `docs/product/PRD.md` (or user-specified path)
   - Implementation Status section updated with markers

2. **Parallel Plan**: `.parallel-plan.md`
   - Full slice definitions with specs
   - Ready for `/execute`

---

## Integration

- Outputs feed into `/execute` command
- References project-specific PRD location
- Creates audit trail via PRD history
