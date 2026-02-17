---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite, TaskOutput
description: Execute development plan with build verification and progress tracking
---

# Execute Command

Reads the feature spec from the PRD and builds it. Handles branching, progress tracking, build verification, and PRD updates.

## Usage

```
/execute [subcommand]
```

**Subcommands:**
- `(default)` — Execute or resume the current In Progress feature from the PRD
- `status` — Check progress against success criteria
- `sync` — Sync current branch with main

---

## Prerequisites

Run `/plan` first to write a feature spec into the PRD with success criteria.

---

## Default: Execute

### 1. Read PRD

Read `docs/product/PRD.md`. Find the `### In Progress:` section with the feature spec, success criteria, and branch name.

If no In Progress feature exists, tell the user to run `/plan` first.

### 2. Branch Setup

If starting fresh:
```bash
git checkout main && git pull origin main
git checkout -b feature-[name]
```

If resuming (branch already exists): verify you're on the correct branch and review what's already been built via `git log` and `git diff`.

### 3. Build

Execute the spec. Use your judgment on how to decompose and sequence the work.

**Quality gates (non-negotiable):**

- Run `npm run build` at meaningful checkpoints. If it breaks, fix before continuing.
- Build failures get 3 fix attempts. After 3 failures, stop and report the issue to the user.
- Commit at meaningful milestones with descriptive messages — not just at the end.
- If interrupted, commit WIP with a clear message so the next session can resume.

Use TodoWrite to track progress against the success criteria.

### 4. Complete

When all success criteria pass:

1. Run `npm run build` one final time to confirm
2. Update the PRD:
   - Convert the `### In Progress:` section to a `### Complete` entry
   - Add commit hash and date
3. Report what was built, key files changed, and next recommended action per PRD

---

## Subcommand: status

Report progress against success criteria from the PRD's In Progress section.

Read the PRD, check which success criteria are met, summarize what's been built and what remains. Reference specific commits and files.

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

### No In Progress Feature
```
No In Progress feature found in PRD. Run /plan first to generate a feature spec.
```

### Branch Already Exists
Check if it contains prior work for this feature. If so, resume. If not, ask the user whether to use, rename, or delete it.

### Build Failures
Fix in place — do not skip or defer. After 3 attempts at the same failure, stop and report with full error context so the user can help unblock.

---

## Integration

- Reads feature spec from `docs/product/PRD.md` (output of `/plan`)
- Uses TodoWrite for progress tracking
- Updates PRD In Progress → Complete on finish
- Commits at meaningful milestones for resumability
