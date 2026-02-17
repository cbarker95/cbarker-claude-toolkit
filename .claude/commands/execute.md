---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite, TaskOutput
description: Execute development plan — sequential or parallel, with progress tracking
---

# Execute Command

Reads the development plan and builds the feature. Handles branching, progress tracking, build verification, and PRD updates.

## Usage

```
/execute [subcommand]
```

**Subcommands:**
- `(default)` — Execute or resume the plan from `.dev-plan.md`
- `status` — Check progress against success criteria
- `sync` — Sync current branch with main

---

## Prerequisites

Run `/plan` first to generate `.dev-plan.md` with feature specs and success criteria.

---

## Default: Execute Plan

### 1. Read Plan

```bash
if [ ! -f .dev-plan.md ]; then
  echo "No plan found. Run /plan first."
  exit 1
fi
```

Read `.dev-plan.md`. Understand the spec (JTBD, Design, UX, Technical Architecture) and the success criteria.

### 2. Branch Setup

If starting fresh:
```bash
git checkout main && git pull origin main
git checkout -b feature-[name]
```

If resuming (branch already exists): verify you're on the correct branch and review what's already been built via `git log` and `git diff`.

### 3. Build

Execute the plan. Use your judgment on how to decompose and sequence the work — types first, then logic, then UI, then integration is a common pattern, but adapt to the feature.

**Quality gates (non-negotiable):**

- Run `npm run build` at meaningful checkpoints. If it breaks, fix before continuing.
- Build failures get 3 fix attempts. After 3 failures, stop and report the issue to the user.
- Commit at meaningful milestones with descriptive messages — not just at the end.
- If interrupted, commit WIP with a clear message so the next session can resume.

Use TodoWrite to track progress against the success criteria.

### 4. Complete

When all success criteria pass:

1. Run `npm run build` one final time to confirm
2. Update `.dev-plan.md` status to `complete`
3. Update PRD completion markers:
   - Change In Progress → Complete for the feature
   - Add commit hash and date
4. Report what was built, key files changed, and next recommended action per PRD

---

## Subcommand: status

Report progress against success criteria from `.dev-plan.md`.

Read the plan, check which success criteria are met, summarize what's been built and what remains. Reference specific commits and files.

---

## Subcommand: sync

Sync current branch with latest main.

```bash
git stash --include-untracked
git fetch origin
git rebase origin/main
npm run build
git stash pop
```

If rebase conflicts occur, use `AskUserQuestion` to present options:
- Help resolve conflicts (walk through each file)
- Abort rebase (return to previous state)
- Skip problematic commit

---

## Error Handling

### Plan File Missing
```
No plan found. Run /plan first to analyze the codebase, clarify requirements,
generate feature specs, and create the development plan. Then run /execute again.
```

### Branch Already Exists
Check if it contains prior work for this plan. If so, resume. If not, ask the user whether to use, rename, or delete it.

### Build Failures
Fix in place — do not skip or defer. After 3 attempts at the same failure, stop and report with full error context so the user can help unblock.

---

## Integration

- Reads from `.dev-plan.md` (output of `/plan`)
- Uses TodoWrite for progress tracking
- Updates PRD with completion markers
- Commits at meaningful milestones for resumability
