---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite, TaskOutput
description: Execute parallel development - spawn agents, monitor, merge, cleanup
---

# Execute Command

Mechanical execution phase for parallel development. Reads the plan, creates worktrees, spawns agents, monitors progress, merges completed work, and cleans up.

## Usage

```
/execute [subcommand]
```

**Subcommands:**
- `(default)` - Spawn agents from `.parallel-plan.md`
- `status` - Check progress of running agents
- `merge` - Merge all completed branches and cleanup
- `sync` - Sync current worktree with main
- `clean` - Remove a specific worktree

---

## Prerequisites

Run `/plan` first to generate `.parallel-plan.md` with:
- Slice definitions (branches, file ownership)
- Feature specs (JTBD, design, UX, architecture)
- Skill recommendations per slice
- Frozen files list

---

## Safety Model

Worktree isolation + PR review makes `--dangerously-skip-permissions` safe here. Each agent can only affect its own feature branch. Worst case is a bad branch you delete and re-run.

---

## Default: Spawn Agents

When run without subcommand, reads `.parallel-plan.md` and spawns agents.

### Workflow

#### 1. Validate Plan

```bash
# Check plan file exists
if [ ! -f .parallel-plan.md ]; then
  echo "No plan found. Run /plan first."
  exit 1
fi
```

Verify:
- [ ] Plan file exists and is valid
- [ ] Slices are defined with branches
- [ ] File ownership is non-overlapping
- [ ] Frozen files are identified

#### 2. Create Worktrees

```bash
PROJECT=$(basename $(pwd))

# Ensure main is up to date
git checkout main
git pull origin main

# Create worktree for each slice (from plan)
git worktree add ../${PROJECT}-[slice-1] -b feature-[slice-1]
git worktree add ../${PROJECT}-[slice-2] -b feature-[slice-2]

# Verify
git worktree list
```

#### 3. Generate Task Prompts

Write `.claude-task.md` in each worktree. The spawned agent reads the full specs from the plan — keep the task prompt focused on context and boundaries:

```markdown
# Task: [Slice Name]

You are working in worktree: [path]
Branch: [branch-name]

## Skills
Read these before starting: [list skill paths]

## Spec
[Copy the slice's JTBD, Design, UX, and Technical specs from .parallel-plan.md]

## Files You Own (modify freely)
- [List from plan]

## Frozen Files (DO NOT MODIFY)
- [List from plan]

## Done Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- Commit when done: "COMPLETE: [description]"
```

#### 4. Spawn Background Agents

```bash
# Spawn agent for each worktree
cd ../${PROJECT}-[slice-1] && claude --dangerously-skip-permissions -p "$(cat .claude-task.md)" &
cd ../${PROJECT}-[slice-2] && claude --dangerously-skip-permissions -p "$(cat .claude-task.md)" &

# Return to main worktree
cd ../${PROJECT}
```

#### 5. Create Tracking File

Write `.parallel-agents.md` in main worktree:

```markdown
# Parallel Development Tracking

**Started**: [timestamp]
**Plan**: .parallel-plan.md
**Session Focus**: [from plan]

## Active Worktrees

| Worktree | Branch | Task | Status |
|----------|--------|------|--------|
| ../${PROJECT}-[slice-1] | feature-[slice-1] | [description] | Running |
| ../${PROJECT}-[slice-2] | feature-[slice-2] | [description] | Running |

## Check Progress

Run: `/execute status`

## When All Complete

Run: `/execute merge`
```

#### 6. Report

```markdown
## Agents Spawned

| Slice | Branch | Status |
|-------|--------|--------|
| [slice-1] | feature-[slice-1] | Running |
| [slice-2] | feature-[slice-2] | Running |

**Check progress:** `/execute status`
**When all complete:** `/execute merge`
```

---

## Subcommand: status

Shows status of all worktrees and agent completion.

### Workflow

```bash
# For each worktree, check completion status
for worktree in $(git worktree list --porcelain | grep "^worktree" | awk '{print $2}'); do
  if [ "$worktree" = "$(pwd)" ]; then continue; fi
  branch=$(cd $worktree && git branch --show-current)
  last_commit=$(cd $worktree && git log -1 --oneline)
  status=$(cd $worktree && git status --short | wc -l | tr -d ' ')

  if echo "$last_commit" | grep -q "COMPLETE:"; then
    echo "DONE  [$branch] $worktree: $last_commit"
  elif [ "$status" -gt 0 ]; then
    echo "WIP   [$branch] $worktree: $status uncommitted changes"
  else
    echo "WIP   [$branch] $worktree: $last_commit"
  fi
done
```

### Output

```markdown
## Parallel Development Status

| Worktree | Branch | Last Commit | Status |
|----------|--------|-------------|--------|
| ../project-slice-1 | feature-slice-1 | COMPLETE: Canvas graph | Done |
| ../project-slice-2 | feature-slice-2 | Add parser utils | WIP |

### Actions

- All done? Run `/execute merge`
- Stuck agent? Delete branch and re-run: `/execute clean [branch]`
- Check work: `cd [worktree] && git log --oneline`
```

---

## Subcommand: merge

Merges all completed branches to main and cleans up.

### Workflow

#### 1. Verify All Complete

```bash
# Check each non-main worktree for COMPLETE: commit
for worktree in $(git worktree list --porcelain | grep "^worktree" | awk '{print $2}'); do
  if [ "$worktree" = "$(pwd)" ]; then continue; fi
  last=$(cd $worktree && git log -1 --oneline)
  if ! echo "$last" | grep -q "COMPLETE:"; then
    echo "NOT READY: $worktree — $last"
  fi
done
```

If not all complete, show status and wait.

#### 2. Merge Each Branch

```bash
git checkout main
git pull origin main

# Merge each feature branch (--no-ff preserves history)
git merge --no-ff feature-slice-1 -m "Merge feature-slice-1: [description]

Co-Authored-By: Claude <noreply@anthropic.com>"

git merge --no-ff feature-slice-2 -m "Merge feature-slice-2: [description]

Co-Authored-By: Claude <noreply@anthropic.com>"

# Validate
npm test || npm run build
```

#### 3. Update PRD

Update PRD completion markers:
- Change In Progress to Complete for merged features
- Add commit hashes and dates

#### 4. Clean Up

```bash
# Remove worktrees
git worktree remove ../project-slice-1 --force
git worktree remove ../project-slice-2 --force

# Delete feature branches
git branch -d feature-slice-1 feature-slice-2

# Delete tracking files
rm -f .parallel-agents.md
rm -f .parallel-plan.md

# Prune
git worktree prune
```

#### 5. Report

```markdown
## Parallel Merge Complete!

### Merged Branches
- feature-slice-1: [hash] - COMPLETE: [message]
- feature-slice-2: [hash] - COMPLETE: [message]

### Validation
- Tests: Passing
- Build: Success

### PRD Updated
- [Feature 1]: Complete (was In Progress)
- [Feature 2]: Complete (was In Progress)

### Cleanup
- Worktrees removed: 2
- Branches deleted: 2
- Tracking files removed

### Next Up (per PRD)
- [Next feature 1]
- [Next feature 2]
```

---

## Subcommand: sync

Syncs current worktree with latest main.

### Workflow

```bash
# Save current work
git stash --include-untracked

# Fetch and rebase
git fetch origin
git rebase origin/main

# Handle conflicts if any (pause and help user)

# Run tests
npm test || npm run test || yarn test

# Restore work
git stash pop
```

### Conflict Handling

If rebase conflicts occur, use `AskUserQuestion` to present options:
- Help resolve conflicts (walk through each file)
- Abort rebase (return to previous state)
- Skip problematic commit

---

## Subcommand: clean

Removes a specific worktree and optionally its branch.

### Workflow

```bash
# Check worktree status
cd [worktree-path] && git status
```

Use `AskUserQuestion` to confirm:
- Worktree path, branch name, clean/dirty status, merged-to-main status
- Options: Remove worktree only / Remove worktree and branch / Cancel

```bash
# Remove worktree
git worktree remove [path] --force

# Optionally delete branch
git branch -D [branch]

# Prune
git worktree prune
```

---

## Error Handling

### Plan File Missing
```
No plan found. Run /plan first to analyze the codebase, clarify requirements,
generate feature specs, and create the parallel plan. Then run /execute again.
```

### Branch Already Exists
Options: Delete existing branch, clean up existing worktree, or use different branch name.

### Merge Conflicts
Resolve in feature branch, not main:
1. `cd [feature-worktree]`
2. `git fetch origin && git rebase origin/main`
3. Resolve conflicts
4. `git add . && git rebase --continue`
5. Return and merge again

---

## Full Workflow

```
User: /plan
[Strategic planning, PRD updates, generates .parallel-plan.md]

User: /execute
[Creates worktrees, spawns agents]

User: /execute status
[Shows agent progress]

User: /execute merge
[Merges all, updates PRD, cleans up]
```

---

## Integration

- Reads from `.parallel-plan.md` (output of `/plan`)
- Creates `.parallel-agents.md` for tracking
- Updates PRD with completion markers on merge
- Uses `COMPLETE:` commit prefix for completion detection
