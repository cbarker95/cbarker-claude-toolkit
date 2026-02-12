---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite, TaskOutput
description: End-to-end product-to-code pipeline — strategy, plan, execute, merge, ship
---

# Ship Command

Orchestrates the full `/strategy` → `/plan` → `/execute` → merge pipeline in a single session. Takes a product goal (or auto-detects the next priority) and produces shipped, tested code with PRD updated.

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
Phase 2: Plan       (auto → STOP)    → .ship/2-plan.md + .parallel-plan.md
         ── USER APPROVAL GATE ──
Phase 3: Execute    (auto)           → .ship/3-execution.md
Phase 4: Integrate  (auto)           → .ship/4-integration.md
Phase 5: Ship       (auto)           → .ship/5-summary.md + PRD updated
```

Every phase produces an artifact file before the next phase starts. If any phase fails 3 times, stop and report rather than continuing.

---

## Phase 1: Analyze

**Goal:** Understand current state and identify what to build.

If `$ARGUMENTS` contains a goal description, use that. Otherwise:

### Auto-Detection
Analyze the PRD and codebase in parallel:
- Read `docs/product/PRD.md` — find the highest-priority unbuilt feature (check Priority Assessment if it exists, otherwise use feature status markers)
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
- Estimated slices: [count]
- Key dependencies: [list]
- Risk areas: [anything that might complicate execution]
```

Present the analysis to the user briefly before continuing to Phase 2. If the auto-detected feature seems wrong, the user can redirect here.

---

## Phase 2: Plan

**Goal:** Produce a detailed parallel plan for user approval.

This phase follows the same methodology as `/plan`:

### Spec Generation

For each slice, produce:
- **Jobs to be Done** — functional, emotional, success criteria
- **Design Spec** — layout, visual style, component hierarchy, state variations
- **UX Architecture** — user flow, entry/exit points, interactions, feedback patterns
- **Technical Architecture** — file structure, state management, data flow, integration points

### Slice Decomposition

Break the feature into 2-4 parallel slices with:
- Non-overlapping file ownership
- Clear frozen files list
- Success criteria per slice
- Skill recommendations per slice

### Output: `.ship/2-plan.md` + `.parallel-plan.md`

`.ship/2-plan.md` is a human-readable summary. `.parallel-plan.md` is the machine-readable contract for Phase 3 (same format as `/plan` output).

Also update the PRD with In Progress markers for the planned feature.

### HARD STOP — User Approval Gate

```
AskUserQuestion: "Here's the plan for [feature name]:

Slice 1: [name] — [1-line summary]
Slice 2: [name] — [1-line summary]
[Slice 3 if applicable]

[Key architectural decision or trade-off to highlight]

Approve to begin execution, or adjust the plan."

Options:
- Approved — start building
- Adjust — [describe changes needed]
- Cancel — stop here, keep the plan for later
```

**DO NOT proceed to Phase 3 until the user explicitly approves.** If they choose "Adjust," revise the plan and ask again. If they choose "Cancel," end the session with the plan artifacts intact.

---

## Phase 3: Execute

**Goal:** Build all slices in parallel with build verification.

### Worktree Setup

```bash
PROJECT=$(basename $(pwd))
git checkout main && git pull origin main

# Create worktree per slice
git worktree add ../${PROJECT}-[slice-name] -b feature-[slice-name]
```

### Task Prompts

Write `.claude-task.md` in each worktree:

```markdown
# Task: [Slice Name]

Worktree: [path]
Branch: [branch-name]

## Skills
Read before starting: [skill paths]

## Spec
[JTBD, Design, UX, Technical specs from .parallel-plan.md]

## Files You Own
- [list]

## Frozen Files (DO NOT MODIFY)
- [list]

## Done Criteria
- [ ] [criteria from plan]
- [ ] TypeScript build passes (`npm run build`)
- [ ] No runtime errors on dev server
- Commit when done: "COMPLETE: [description]"
```

### Spawn Agents

```bash
cd ../${PROJECT}-[slice-1] && claude --dangerously-skip-permissions -p "$(cat .claude-task.md)" &
cd ../${PROJECT}-[slice-2] && claude --dangerously-skip-permissions -p "$(cat .claude-task.md)" &
cd ../${PROJECT}
```

### Monitor

Poll worktrees for `COMPLETE:` commits. Report progress as agents finish.

### Output: `.ship/3-execution.md`

```markdown
# Execution Report

| Slice | Branch | Status | Build | Commits |
|-------|--------|--------|-------|---------|
| [name] | feature-[name] | Complete | Pass | [count] |
| [name] | feature-[name] | Complete | Pass | [count] |

**Duration**: [time from spawn to all complete]
```

Wait for all agents to complete before proceeding. If an agent appears stalled (no commits for extended period), report and ask the user whether to wait, check on it, or proceed without it.

---

## Phase 4: Integrate

**Goal:** Merge all slices and verify the integrated build.

### Sequential Merge

```bash
git checkout main
git pull origin main

# Merge each completed branch (order from .parallel-plan.md)
git merge --no-ff feature-[slice-1] -m "Merge feature-[slice-1]: [description]

Co-Authored-By: Claude <noreply@anthropic.com>"

# Run build after EACH merge to catch integration issues early
npm run build
```

If a merge introduces build failures:
1. Attempt to fix the integration issue (type errors, import conflicts)
2. If not fixable in 3 attempts, revert that merge and note it as held back
3. Continue with remaining slices

### Output: `.ship/4-integration.md`

```markdown
# Integration Report

## Merged Successfully
| Slice | Merge Commit | Build After Merge |
|-------|-------------|-------------------|
| [name] | [hash] | Pass |

## Held Back (if any)
| Slice | Reason | Fix Needed |
|-------|--------|------------|
| [name] | [build error] | [what needs fixing] |

## Final Build
- TypeScript: Pass/Fail
- Dev server: Starts cleanly / Issues noted
```

---

## Phase 5: Ship

**Goal:** Update all tracking artifacts and produce a ship summary.

### PRD Update
- Change In Progress → Complete for merged features
- Add commit hashes and dates
- If any slices were held back, note them as still In Progress

### Cleanup

```bash
# Remove worktrees
git worktree remove ../${PROJECT}-[slice] --force  # for each slice

# Delete merged feature branches
git branch -d feature-[slice-1] feature-[slice-2]

# Remove tracking files
rm -f .parallel-plan.md .parallel-agents.md

# Prune
git worktree prune
```

### Output: `.ship/5-summary.md`

```markdown
# Ship Summary

**Feature**: [name]
**Date**: [date]
**Goal**: [original goal from Phase 1]

## What Shipped
- [Slice 1]: [1-line summary of what was built]
- [Slice 2]: [1-line summary of what was built]

## What Was Held Back
- [Slice or sub-feature]: [reason, what's needed to unblock]
(or "Nothing — all slices shipped cleanly")

## Key Files Changed
- [List of significant files added or modified]

## PRD Status
- [Feature name]: Complete (was Not Started)

## Next Recommended Action
[What naturally follows — next PRD priority, or fixing held-back slices]
```

### Final Report to User

```
Ship complete: [feature name]

Shipped:
- [Slice 1] — [summary]
- [Slice 2] — [summary]

[Held back: [slice] — [reason] (if applicable)]

PRD updated. Ship artifacts in .ship/ directory.
Next up per PRD: [next priority feature]
```

---

## Failure Modes

### Phase 1 fails (no PRD, empty codebase)
Report what's missing. Suggest running `/plan` manually with more context.

### Phase 2 rejected by user
End cleanly. Artifacts in `.ship/` are preserved for reference. User can run `/plan` separately to revise.

### Phase 3 agent stalls
After reporting, offer options: wait longer, manually check the worktree, or proceed with completed slices only.

### Phase 4 merge conflicts
Resolve in feature branch, not main. If unresolvable, hold back that slice and continue.

### Any phase fails 3 times
Stop immediately. Report what succeeded, what failed, and what artifacts exist. Do not attempt to continue past a triple failure.

---

## Artifact Cleanup

The `.ship/` directory accumulates across runs. Each run overwrites the numbered files (1-analysis through 5-summary). To preserve history, the user can rename the directory before running again:

```bash
mv .ship .ship-[feature-name]-[date]
```

---

## Integration

- Combines the workflows of `/strategy` (analysis), `/plan` (spec), and `/execute` (build + merge)
- Produces `.parallel-plan.md` (compatible with standalone `/execute`)
- Updates PRD with status markers (compatible with `/strategy` reads)
- User approval gate preserves human steering at the critical decision point
