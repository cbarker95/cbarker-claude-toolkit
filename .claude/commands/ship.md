---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite, TaskOutput, EnterPlanMode, ExitPlanMode, Skill
description: Ship a feature end-to-end — analyze, spec, approve, build, update PRD
---

# Ship Command

The primary development command. Takes a product goal (or auto-detects the next priority), specs it out, gets approval, builds it, and updates the PRD.

## Usage

```
/ship [goal description]
/ship                     # auto-detect next priority from PRD
```

---

## Understand

Read `docs/product/PRD.md` and the codebase in parallel. Identify:
- Feature status: what's complete, in progress, not started
- Existing patterns: component structure, state management, styling approach
- Integration points: APIs, shared state, config
- Recent git history: what shipped last, any in-progress work

If `$ARGUMENTS` contains a goal, use that. Otherwise, identify the highest-priority unbuilt feature from the PRD.

Present a brief analysis to the user: what you're going to build and why it's the right next thing. If the auto-detected feature seems wrong, the user can redirect.

---

## Spec

Enter plan mode. Generate detailed specifications for the feature:

### Jobs to be Done

| Job Type | Description |
|----------|-------------|
| **Functional** | [What the user needs to accomplish] |
| **Emotional** | [How the user wants to feel] |
| **Social** | [How the user wants to be perceived] |
| **Success Criteria** | [Measurable outcome from user perspective] |

### Design Spec

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

**State Variations**: Loading / Empty / Error / Success / [Other]

### UX Architecture

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

### Technical Architecture

**File Structure**:
```
src/[feature]/
├── [Component].tsx
├── [Component].module.css
├── [hooks/] → use[Feature].ts
├── [lib/] → [utility].ts
└── types.ts
```

**State Management**: [Approach]
**Data Flow**: [Source] → [Transform] → [Render]
**Integration Points**: [How this connects to existing code]

### Success Criteria

- [ ] [Criterion 1 — from JTBD]
- [ ] [Criterion 2]
- [ ] `npm run build` passes

Write the full spec into the PRD as an `### In Progress:` section under Implementation Status.

Exit plan mode to get user approval before writing any code.

---

## Build

Create a feature branch and build the feature:

```bash
git checkout main && git pull origin main
git checkout -b feature-[name]
```

If resuming (branch already exists): verify you're on the correct branch and review what's already been built via `git log` and `git diff`.

Invoke skills based on what the feature requires:

| Feature Type | Skill |
|-------------|-------|
| UI components, pages, visual interfaces | `frontend-design` — production-grade UI with high design quality |
| Design system work, component libraries, tokens | `atomic-design-system` — Brad Frost atomic methodology |
| Agent systems, MCP tools, autonomous features | `agent-native-architecture` — agent-first patterns |
| Marketing pages, landing pages | `b2b-one-pager` — conversion-optimized page structures |

Use your judgment on which skills to invoke. Multiple skills can apply to one feature.

**Quality gates (non-negotiable):**
- `npm run build` must pass at meaningful checkpoints and before completion
- Build failures get 3 fix attempts, then stop and report
- Commit at meaningful milestones with descriptive messages — not just at the end
- If interrupted, commit WIP with a clear message so the next session can resume

Use TodoWrite to track progress against the success criteria.

---

## Complete

When all success criteria pass:

1. Run `npm run build` one final time to confirm
2. Update the PRD: convert `### In Progress:` to a Complete entry with commit hash and date
3. Report what was built, key files changed, and next recommended action per PRD

---

## When It Fails

- **No PRD or empty codebase**: Report what's missing
- **User rejects spec**: End cleanly, PRD spec preserved for later
- **Build failures after 3 attempts**: Stop, report full error context
- **Any step fails 3 times**: Stop immediately, report what succeeded and what didn't
