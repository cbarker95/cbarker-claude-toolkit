---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite, EnterPlanMode, ExitPlanMode
description: Strategic planning with detailed feature specs for parallel development
---

# Plan Command

Strategic planning phase that evaluates the codebase, clarifies requirements, generates detailed feature specifications, updates the PRD, and outputs a slice plan with skill recommendations.

## Usage

```
/plan [--prd=docs/product/PRD.md]
```

## Purpose

This command handles the **thinking** part of parallel development:
- Understand what's already built
- Clarify what needs to be built next
- Create detailed specs (JTBD, design, UX, architecture)
- Update PRD with completion markers
- Plan vertical slices with skill recommendations

The output is `.parallel-plan.md` — a reviewable plan ready for `/execute`.

---

## IMPORTANT: Enter Plan Mode First

**Before doing any evaluation or analysis, you MUST enter plan mode.**

```
1. Call EnterPlanMode tool immediately
2. Wait for user approval to enter plan mode
3. Only then proceed with discovery and analysis
4. Write your plan to the plan file
5. Exit plan mode with ExitPlanMode when ready for user approval
6. After approval, execute: update PRD and write .parallel-plan.md
```

This ensures:
- User approves the approach before any changes are made
- Discovery happens without side effects
- PRD updates only happen after explicit approval
- Clear separation between planning and execution

---

## Workflow

### Step 0: Enter Plan Mode

```
EnterPlanMode()
```

Wait for user approval before proceeding.

---

### Phase 1: Discovery (Parallel Agents)

Launch parallel exploration to understand current state:

```
# Agent 1: PRD Analysis
Task(subagent_type="Explore", prompt="
Read the PRD at docs/product/PRD.md (or user-specified path).
Extract:
1. Product vision and goals
2. Feature list with current status markers
3. User flows and success metrics
4. Technical constraints or requirements
Return: Structured summary of PRD state
")

# Agent 2: Codebase Analysis
Task(subagent_type="Explore", prompt="
Analyze the codebase to understand:
1. What features are actually implemented (match against PRD)
2. Existing patterns (component structure, state management, styling)
3. Directory organization and naming conventions
4. Integration points (APIs, shared state, config)
Return: Implementation status and patterns found
")
```

### Phase 2: Clarification

Use `AskUserQuestion` to gather context:

```
AskUserQuestion: "Based on the PRD and codebase analysis:

**Currently Complete:**
- [List features with commits]

**In Progress:**
- [List partially implemented features]

**Not Started:**
- [List pending features]

What's the focus for this session?"

Options:
- [Feature A] (highest priority per PRD)
- [Feature B]
- [Feature C]
- Custom selection
```

Follow up as needed:

```
AskUserQuestion: "For [selected feature], I need to clarify the job-to-be-done:

What problem does this solve for the user?

Options:
- [JTBD option 1]
- [JTBD option 2]
- [JTBD option 3]
- Let me explain..."
```

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

### Phase 4: Write Plan to Plan File

Write all specifications and proposed PRD updates to the plan file (not directly to PRD yet):

```markdown
# Parallel Development Plan

## Proposed PRD Updates

[Show what will be added/changed in the PRD]

## Feature Specifications

[All JTBD, Design, UX, Technical specs]

## Slice Definitions

[Slice plan with skill recommendations]
```

### Phase 5: Exit Plan Mode

```
ExitPlanMode()
```

Wait for user approval of the plan.

---

### Phase 6: Execute Plan (After Approval)

Only after user approves the plan:

1. **Update PRD** with completion markers
2. **Write `.parallel-plan.md`** with slice definitions

#### PRD Completion Markers

```markdown
## Implementation Status

### ✅ Complete
| Feature | Commit | Date |
|---------|--------|------|
| [Feature name] | [hash] | [date] |

### 🔄 In Progress
| Feature | Branch | Owner | Notes |
|---------|--------|-------|-------|
| [Feature name] | [branch] | [agent] | [status] |

### 📋 Next Up
| Feature | Priority | Dependencies | Estimated Slices |
|---------|----------|--------------|------------------|
| [Feature name] | P[0-3] | [deps] | [count] |

### ⏸️ Deferred
| Feature | Reason |
|---------|--------|
| [Feature name] | [why deferred] |
```

#### .parallel-plan.md Format

```markdown
# Parallel Development Plan

**Generated**: [date]
**PRD Version**: [version]
**Session Focus**: [description]

## Slices

### Slice 1: [Slice Name]

**Branch**: feature-[name]

**Recommended Skills**:
- `[skill-1]` — [Why this skill is relevant]
- `[skill-2]` — [Why this skill is relevant]

#### Jobs to be Done
[Copy from feature spec]

#### Design Spec
[Copy from feature spec]

#### UX Architecture
[Copy from feature spec]

#### Technical Architecture
[Copy from feature spec]

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

## Example Session

```
User: /plan

Claude: [Calls EnterPlanMode, waits for approval]

User: [Approves plan mode]

Claude: [Launches discovery agents in parallel]

Claude: "Discovery complete. Here's what I found:

**PRD Status:**
- Vision: Design verification tool for PRs
- 8 features defined, 3 complete, 2 in progress, 3 not started

**Codebase Status:**
- Next.js 14 with App Router
- Tailwind CSS for styling
- Workspace shell implemented
- Chat interface implemented
- Canvas graph not started

What's the focus for this session?"

User: "Canvas graph and parsing engine"

Claude: "For the Canvas Graph, what's the primary job-to-be-done?

1. Debug design debt (find pollution paths)
2. Explore architecture (understand dependencies)
3. Plan refactors (see blast radius)
4. All of the above"

User: "All of the above, starting with exploration"

Claude: [Writes detailed plan to plan file]

Claude: [Calls ExitPlanMode]

"I've written the plan with detailed specifications:

**Slice 1: Canvas Graph Core**
- JTBD: Visualize component dependencies at a glance
- Design: Full-viewport graph, node-edge visualization
- UX: Hover for tooltips, click for selection, drag to pan
- Skills: frontend-design, atomic-design-system

**Slice 2: Parsing Engine**
- JTBD: Extract import relationships from source files
- Technical: ts-morph AST parsing
- Skills: agent-native-architecture

Please review and approve the plan."

User: [Approves plan]

Claude: [Updates PRD with markers, writes .parallel-plan.md]

"Plan approved. Updated:
- PRD now shows 🔄 markers for Canvas Graph and Parsing Engine
- .parallel-plan.md written with full specifications

Ready to execute with `/execute`"
```

---

## Integration

- Outputs feed into `/execute` command
- Uses `parallel-development` skill patterns
- References project-specific PRD location
- Creates audit trail via PRD history
