---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite, TaskOutput
description: End-to-end product-to-code pipeline — strategy, plan, execute, ship
---

# Ship Command

Orchestrates the full `/strategy` → `/plan` → `/execute` pipeline in a single session. Takes a product goal (or auto-detects the next priority) and produces shipped, tested code with PRD updated.

You still get a hard approval gate before any code is written. The mechanical handoffs between commands are eliminated.

## Usage

```
/ship [goal description]
/ship                     # auto-detect next priority from PRD
```

---

## Pipeline Overview

```
Phase 1: Analyze    (auto)           → .ship/1-analysis.md
Phase 2: Plan       (auto → STOP)    → PRD updated with spec
         ── USER APPROVAL GATE ──
Phase 3: Execute    (auto)           → .ship/2-execution.md
Phase 4: Ship       (auto)           → .ship/3-summary.md + PRD updated
```

Every phase produces an artifact or PRD update before the next phase starts. If any phase fails 3 times, stop and report rather than continuing.

---

## Phase 1: Analyze

**Goal:** Understand current state and identify what to build.

If `$ARGUMENTS` contains a goal description, use that. Otherwise:

### Auto-Detection
Analyze the PRD and codebase in parallel:
- Read `docs/product/PRD.md` — find the highest-priority unbuilt feature
- Scan the codebase — what's actually implemented vs. what the PRD claims
- Check recent git history — what was shipped last, any in-progress work

### Output: `.ship/1-analysis.md`

```markdown
# Ship Analysis

**Date**: [date]
**Goal**: [from user args or auto-detected]

## Current State
- Last shipped: [recent commit summary]
- PRD status: [X complete, Y in progress, Z not started]

## Target Feature
**Name**: [feature name]
**Priority**: [from PRD or inferred]
**JTBD**: [1-sentence job-to-be-done]

## Why This Feature Next
[2-3 sentences grounding the choice in PRD priorities, dependencies, or user input]

## Scope Assessment
- Key dependencies: [list]
- Risk areas: [anything that might complicate execution]
```

Present the analysis to the user briefly before continuing to Phase 2. If the auto-detected feature seems wrong, the user can redirect here.

---

## Phase 2: Plan

**Goal:** Write a feature spec into the PRD for user approval.

This phase follows the same methodology as `/plan`:

### Spec Generation

Produce and write into the PRD:
- **Jobs to be Done** — functional, emotional, success criteria
- **Design Spec** — layout, visual style, component hierarchy, state variations
- **UX Architecture** — user flow, entry/exit points, interactions, feedback patterns
- **Technical Architecture** — file structure, state management, data flow, integration points
- **Success Criteria** — checklist including `npm run build` passes

Write the spec as an `### In Progress:` section in the PRD's Implementation Status.

### HARD STOP — User Approval Gate

```
AskUserQuestion: "Here's the plan for [feature name]:

[Key specs and architectural decisions to highlight]

Approve to begin execution, or adjust the plan."

Options:
- Approved — start building
- Adjust — [describe changes needed]
- Cancel — stop here, keep the plan for later
```

**DO NOT proceed to Phase 3 until the user explicitly approves.** If they choose "Adjust," revise the spec and ask again. If they choose "Cancel," end the session with the PRD spec intact.

---

## Phase 3: Execute

**Goal:** Build the feature with build verification.

Follow the same methodology as `/execute`:

1. Create feature branch from main
2. Build the feature, verifying `npm run build` at meaningful checkpoints
3. Commit at meaningful milestones with descriptive messages
4. Fix build failures before continuing (3 attempts per failure, then stop)

### Output: `.ship/2-execution.md`

```markdown
# Execution Report

**Branch**: feature-[name]
**Commits**: [count]
**Build**: Pass

## What Was Built
- [Summary of key changes]

## Key Files
- [List of significant files added or modified]
```

---

## Phase 4: Ship

**Goal:** Update PRD and produce a ship summary.

### PRD Update
- Convert `### In Progress:` section to a Complete entry
- Add commit hashes and dates

### Output: `.ship/3-summary.md`

```markdown
# Ship Summary

**Feature**: [name]
**Date**: [date]
**Goal**: [original goal from Phase 1]
**Branch**: feature-[name]

## What Shipped
- [1-line summary of what was built]

## Key Files Changed
- [List of significant files added or modified]

## PRD Status
- [Feature name]: Complete (was In Progress)

## Next Recommended Action
[What naturally follows — next PRD priority]
```

### Final Report to User

```
Ship complete: [feature name]

Shipped: [summary]

PRD updated. Ship artifacts in .ship/ directory.
Next up per PRD: [next priority feature]
```

---

## Failure Modes

### Phase 1 fails (no PRD, empty codebase)
Report what's missing. Suggest running `/plan` manually with more context.

### Phase 2 rejected by user
End cleanly. PRD spec is preserved for reference. User can run `/plan` separately to revise.

### Phase 3 build failures
After 3 failed fix attempts, stop and report with full error context.

### Any phase fails 3 times
Stop immediately. Report what succeeded, what failed, and what artifacts exist. Do not attempt to continue past a triple failure.

---

## Artifact Cleanup

The `.ship/` directory accumulates across runs. Each run overwrites the numbered files. To preserve history:

```bash
mv .ship .ship-[feature-name]-[date]
```

---

## Integration

- PRD is the single source of truth — no intermediate plan files
- `.ship/` artifacts are session logs, not contracts
- Updates PRD with status markers (compatible with `/strategy` reads)
- User approval gate preserves human steering at the critical decision point
