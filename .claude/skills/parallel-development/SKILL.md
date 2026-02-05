---
name: parallel-development
description: Git worktrees, multi-agent coordination, vertical slicing. Use when setting up parallel development workflows, splitting work across Claude instances, or coordinating merges from multiple workstreams.
---

<why_now>
## Why Parallel Development Matters

Complex projects benefit from multiple agents working simultaneously on different features. Git worktrees enable this by creating separate working directories that share the same repository, allowing:

- **Parallel execution** — Multiple Claude instances work on different branches simultaneously
- **Clean isolation** — Each worktree has its own index and working tree
- **Shared history** — All worktrees share the same .git directory and commits
- **Conflict minimization** — Vertical slicing keeps worktrees independent

The key insight: Claude instances can work in parallel just like human developers, but they need the right coordination patterns to avoid stepping on each other.
</why_now>

<core_principles>
## Core Principles

### 1. Vertical Slicing

Split work by feature slice, not layer:

```
✗ Horizontal (conflicts guaranteed):
  Worktree A: All backend changes
  Worktree B: All frontend changes

✓ Vertical (minimal conflicts):
  Worktree A: User auth (frontend + backend + tests)
  Worktree B: Billing (frontend + backend + tests)
```

**Test:** Can both worktrees be merged independently without code conflicts?

### 2. Shared-Nothing Architecture

Each worktree should touch different files:

```
Phase 1 Files          Phase 2 Files          Phase 3 Files
─────────────         ─────────────         ─────────────
.claude/skills/       .claude/skills/       .claude/commands/
  mcp-tool-design/      agent-testing/        release.md
.claude/agents/       .claude/agents/         roadmap.md
  mcp-*.md              parity-*.md         .claude/skills/
                                              deployment-ops/
```

**Test:** Do file paths overlap between worktrees?

### 3. Main as Integration Point

Main branch is the integration target, never the work surface:

```
feature-auth ──┬──> main (integration) <──┬── feature-billing
               │                          │
               └─────── merge ────────────┘
```

**Test:** Is anyone coding directly on main?

### 4. Frequent, Small Merges

Merge to main often to avoid divergence:

```
✗ Big bang merge (risky):
  Week 1: Work → Week 2: Work → Week 3: Work → Week 4: Merge chaos

✓ Incremental merge (safe):
  Day 1: Work → Merge → Day 2: Work → Merge → Day 3: Work → Merge
```

**Test:** How long since the last merge to main?

### 5. Coordination Over Communication

Structure the work so coordination happens through the system, not conversation:

```
✗ "Hey, I'm about to edit utils.js, don't touch it"
✓ utils.js only exists in one worktree's slice
```

**Test:** Does parallel work require active coordination?
</core_principles>

<two_phase_workflow>
## Two-Phase Workflow

Parallel development is split into two distinct phases:

### Phase 1: `/plan` — Strategic Planning

```
/plan
```

Handles the **thinking** part:
- Enters plan mode for safe exploration
- Evaluates codebase and existing patterns
- Clarifies requirements via `AskUserQuestion`
- Generates detailed feature specs (JTBD, design, UX, architecture)
- Updates PRD with completion markers (✅ 🔄 📋 ⏸️)
- Outputs `.parallel-plan.md` with slice definitions and skill recommendations

### Phase 2: `/execute` — Mechanical Execution

```
/execute
```

Handles the **doing** part:
- Reads `.parallel-plan.md`
- Creates git worktrees for each slice
- Writes rich `.claude-task.md` files with full specs
- Spawns background agents with `--dangerously-skip-permissions`
- Monitors for `COMPLETE:` commits

### Complete Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│                           /plan                                       │
├─────────────────────────────────────────────────────────────────────┤
│  1. Enter plan mode (safe exploration)                               │
│  2. Analyze PRD and codebase                                         │
│  3. Clarify requirements with user                                   │
│  4. Generate feature specs (JTBD, design, UX, architecture)          │
│  5. Update PRD with completion markers                               │
│  6. Write .parallel-plan.md with slices + skill recommendations      │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                           /execute                                    │
├─────────────────────────────────────────────────────────────────────┤
│  1. Read .parallel-plan.md                                           │
│  2. Create worktrees for each slice                                  │
│  3. Write .claude-task.md with full specs                            │
│  4. Spawn agents (--dangerously-skip-permissions)                    │
│  5. Monitor for COMPLETE: commits                                    │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
         ┌──────────────────────┼──────────────────────┐
         ▼                      ▼                      ▼
    ┌─────────┐          ┌─────────┐          ┌─────────┐
    │ Agent 1 │          │ Agent 2 │          │ Agent 3 │
    │ Slice A │          │ Slice B │          │ Slice C │
    └─────────┘          └─────────┘          └─────────┘
         │                      │                      │
         └──────── All commit "COMPLETE:" ────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        /execute merge                                 │
├─────────────────────────────────────────────────────────────────────┤
│  1. Verify all COMPLETE: commits                                     │
│  2. Merge branches to main                                           │
│  3. Update PRD (🔄 → ✅)                                              │
│  4. Clean up worktrees and branches                                  │
└─────────────────────────────────────────────────────────────────────┘
```

### Why Two Phases?

| Aspect | Single Command | Two-Phase |
|--------|---------------|-----------|
| Iteration | Hard to adjust mid-spawn | Plan phase allows iteration |
| PRD sync | Manual | Automatic status updates |
| Clarity | Prompt generated on-the-fly | Plan file is reviewable |
| Resume | Start over if interrupted | Execute from existing plan |
| Audit trail | None | PRD history + plan files |
</two_phase_workflow>

<automated_spawning>
## Automated Agent Spawning

Background agents with `--dangerously-skip-permissions` work autonomously in isolated worktrees. PR review is the safety net.

### Why This Works Safely

- **Worktree isolation** — each agent can only affect its own feature branch, never main
- **PR review is the safety net** — nothing hits main without human review
- **Worst case is a bad branch** — delete it and re-run that slice
- **No credential exposure** — agents work within the repo boundary

### Rich Task Prompts (.claude-task.md)

Each worktree gets a `.claude-task.md` file with full specifications from the plan:

```markdown
# Task: [Slice Name]

You are working in worktree: [path]
Branch: [branch-name]

## Recommended Skills
- `frontend-design` — For distinctive visual design
- `atomic-design-system` — Component hierarchy patterns

## Jobs to be Done
| Job Type | Description |
|----------|-------------|
| **Functional** | [What user needs to accomplish] |
| **Emotional** | [How user wants to feel] |
| **Success** | [Measurable outcome] |

## Design Spec
**Layout**: [Description]
**Component Hierarchy**: [Tree structure]
**State Variations**: Loading, Empty, Error, Success

## UX Architecture
**User Flow**: [Step-by-step]
**Interactions**: [Click, hover, drag behaviors]

## Technical Architecture
**File Structure**: [Directory layout]
**State Management**: [Approach]
**Data Flow**: [Source → Transform → Render]

## Files You Own
- [List of files/directories]

## Frozen Files (DO NOT MODIFY)
- [List of shared files]

## Success Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]
- Commit: "COMPLETE: [description]"

Begin working now. Read the recommended skills first.
```

### Spawning

```bash
cd [worktree-path] && claude --dangerously-skip-permissions -p "$(cat .claude-task.md)" &
```

### Completion Detection

Agents signal completion by committing with message starting with "COMPLETE:".
Check via: `git log -1 --oneline | grep "COMPLETE:"`

### Why This Scales

- **No bottlenecks** — no permission approvals to slow agents down
- **True parallelism** — all agents work simultaneously
- **Rich context** — JTBD, design, UX specs reduce ambiguity
- **Safe** — worktree isolation + PR review = bad branch is worst case
- **Skill guidance** — agents know which patterns to follow
</automated_spawning>

<intake>
## What parallel development task do you need?

1. **Plan parallel work** — Analyze codebase, clarify requirements, generate feature specs, create slice plan
2. **Execute plan** — Create worktrees and spawn background agents from `.parallel-plan.md`
3. **Check status** — View status of all worktrees and running agents
4. **Merge completed work** — Merge all completed branches, update PRD, cleanup
5. **Sync worktree** — Fetch latest changes, rebase, and run tests
6. **Learn patterns** — Get guidance on vertical slicing and coordination patterns

**Wait for response before proceeding.**
</intake>

<routing>
| Response | Action |
|----------|--------|
| 1, "plan", "start", "new" | Run `/plan` — Strategic planning with detailed feature specs |
| 2, "execute", "spawn", "run" | Run `/execute` — Creates worktrees and spawns agents |
| 3, "status", "check", "progress" | Run `/execute status` — Shows worktree and agent progress |
| 4, "merge", "done", "complete" | Run `/execute merge` — Merges all completed branches |
| 5, "sync", "rebase", "update" | Run `/execute sync` — Syncs worktree with main |
| 6, "learn", "patterns", "help" | Read references: [vertical-slicing.md](./references/vertical-slicing.md), [coordination-patterns.md](./references/coordination-patterns.md) |

**After reading references, apply patterns to the user's specific context.**
</routing>

<parallel_agents>
## Agent Orchestration

### Phase 1: Planning (`/plan`)
```
┌─────────────────────────┐
│ Enter Plan Mode         │
│ → Safe exploration      │
│ → No side effects       │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ Discovery (parallel)    │
│ → Analyze PRD           │
│ → Analyze codebase      │
│ → Identify patterns     │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ Clarification           │
│ → AskUserQuestion       │
│ → Resolve JTBD          │
│ → Scope decisions       │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ Feature Specs           │
│ → JTBD per feature      │
│ → Design specs          │
│ → UX architecture       │
│ → Technical arch        │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ Output                  │
│ → Update PRD (markers)  │
│ → .parallel-plan.md     │
└─────────────────────────┘
```

### Phase 2: Execution (`/execute`)
```
┌─────────────────────────┐
│ Read .parallel-plan.md  │
│ → Validate slices       │
│ → Create worktrees      │
│ → Write task prompts    │
└───────────┬─────────────┘
            │
            ▼
┌───────────┴───────────┬─────────────────────┐
▼                       ▼                     ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ Agent 1     │  │ Agent 2     │  │ Agent 3     │
│ Slice A     │  │ Slice B     │  │ Slice C     │
│ (background)│  │ (background)│  │ (background)│
└──────┬──────┘  └──────┬──────┘  └──────┬──────┘
       │                │                │
       └── COMPLETE: ───┴── COMPLETE: ───┘
                        │
                        ▼
            ┌─────────────────────────┐
            │ /execute merge          │
            │ → Merge to main         │
            │ → Update PRD (✅)       │
            │ → Cleanup worktrees     │
            └─────────────────────────┘
```
</parallel_agents>

<setup_workflow>
## Setup Workflow

Use the two-phase workflow for all parallel development:

### Quick Start

```bash
# Phase 1: Plan
/plan
# → Enters plan mode
# → Analyzes codebase and PRD
# → Clarifies requirements
# → Generates feature specs
# → Outputs .parallel-plan.md

# Phase 2: Execute
/execute
# → Reads .parallel-plan.md
# → Creates worktrees
# → Spawns agents
# → Monitors for COMPLETE:

# Check progress
/execute status

# When all complete
/execute merge
```

### What `/plan` Produces

**.parallel-plan.md** with detailed slice definitions:

```markdown
# Parallel Development Plan

**Generated**: 2026-02-04
**Session Focus**: Canvas Foundation

## Slices

### Slice 1: Canvas Graph Core

**Branch**: feature-canvas-core

**Recommended Skills**:
- `frontend-design` — Distinctive visual design
- `atomic-design-system` — Component hierarchy

#### Jobs to be Done
| Job Type | Description |
|----------|-------------|
| **Functional** | User needs to see component dependencies |
| **Success** | Identify load-bearing components in <10s |

#### Design Spec
**Layout**: Full-viewport graph canvas
**Component Hierarchy**:
ComponentGraphPanel (organism)
├── GraphCanvas (molecule)
│   ├── GraphNode (atom)
│   └── GraphEdge (atom)
└── GraphControls (molecule)

**State Variations**: Loading, Empty, Error, Success

#### UX Architecture
**User Flow**:
1. Open Canvas tab → Loading
2. Graph renders → Zoom-to-fit
3. Hover node → Tooltip
4. Click node → Selection

#### Technical Architecture
**Files Owned**: src/components/ComponentGraph/
**Frozen**: package.json, src/lib/workspace-ui/

**Success Criteria**:
- [ ] Graph renders with 10+ nodes
- [ ] Zoom/pan works
- Commit: "COMPLETE: Canvas graph core"

---

### Slice 2: Parsing Engine
[Similar structure...]

## Merge Order
1. Slice 2 (no dependencies)
2. Slice 1 (uses parsing types)
```

### PRD Completion Markers

`/plan` updates the PRD with standardized markers:

```markdown
## Implementation Status

### ✅ Complete
| Feature | Commit | Date |
|---------|--------|------|
| Workspace Shell | abc123 | 2026-02-01 |

### 🔄 In Progress
| Feature | Branch | Notes |
|---------|--------|-------|
| Canvas Graph | feature-canvas | Running |

### 📋 Next Up
| Feature | Priority | Dependencies |
|---------|----------|--------------|
| Heatmap Overlay | P1 | Canvas Graph |

### ⏸️ Deferred
| Feature | Reason |
|---------|--------|
| Email Notifications | Not needed for v1 |
```
</setup_workflow>

<sync_workflow>
## Sync Workflow

Run `/execute sync` in a worktree to stay current with main:

```bash
/execute sync
```

This will:
1. Stash uncommitted changes
2. Fetch and rebase on origin/main
3. Run tests
4. Restore stashed changes

### Handling Conflicts

If rebase conflicts occur:
1. Identify conflicting files
2. Check if file should be in this worktree's slice
3. If yes: resolve conflict, continue rebase
4. If no: slice boundaries were violated — fix the plan

```bash
# After resolving conflicts
git add <resolved-files>
git rebase --continue
```
</sync_workflow>

<merge_workflow>
## Merge Workflow

When all agents have committed with `COMPLETE:` prefix:

```bash
/execute merge
```

This will:
1. Verify all worktrees have `COMPLETE:` commits
2. Merge each feature branch to main (--no-ff)
3. Run tests/build validation
4. Update PRD (🔄 → ✅ for merged features)
5. Remove worktrees and branches
6. Delete tracking files (.parallel-plan.md, .parallel-agents.md)

### Output

```markdown
## Parallel Merge Complete!

### Merged Branches
- feature-canvas-core: abc123 - COMPLETE: Canvas graph
- feature-parsing: def456 - COMPLETE: Parsing engine

### PRD Updated
- Canvas Graph: ✅ Complete (was 🔄)
- Parsing Engine: ✅ Complete (was 🔄)

### Next Up (per PRD)
- 📋 Heatmap Overlay
- 📋 Ghost Preview
```
</merge_workflow>

<reference_index>
## Reference Files

All references in `references/`:

**Setup & Management:**
- [git-worktree-patterns.md](./references/git-worktree-patterns.md) — Worktree commands, directory structure, best practices

**Work Division:**
- [vertical-slicing.md](./references/vertical-slicing.md) — How to split work for minimal conflicts

**Coordination:**
- [coordination-patterns.md](./references/coordination-patterns.md) — Multi-agent coordination, communication patterns

**Integration:**
- [merge-strategies.md](./references/merge-strategies.md) — Merge workflows, conflict resolution, cleanup
</reference_index>

<commands>
## Available Commands

- `/plan` — Strategic planning: analyze codebase, clarify requirements, generate feature specs, output `.parallel-plan.md`
- `/execute` — Execution: create worktrees, spawn agents, monitor progress
- `/execute status` — Check agent progress
- `/execute merge` — Merge completed branches, update PRD, cleanup
- `/execute sync` — Sync worktree with main
- `/execute clean` — Remove a specific worktree
</commands>

<anti_patterns>
## Anti-Patterns

### Setup Anti-Patterns

**Horizontal slicing** — Splitting by layer instead of feature
```
✗ "Worktree A does all backend, B does all frontend"
✓ "Worktree A does auth (full stack), B does billing (full stack)"
```

**Overlapping slices** — Multiple worktrees touching same files
```
✗ Both worktrees modify src/utils/helpers.js
✓ Shared utilities are frozen or split into separate files
```

**Main as workspace** — Doing development directly on main
```
✗ cd project && claude (working on main)
✓ cd project-feature && claude (working on feature branch)
```

### Coordination Anti-Patterns

**Silent divergence** — Not syncing with main for days
```
✗ Work for a week, then face massive merge conflicts
✓ Sync daily, merge when feature slices are complete
```

**Cross-worktree dependencies** — One worktree waiting on another
```
✗ "I can't start until you finish the user model"
✓ Slice work so each worktree can progress independently
```

**Communication over convention** — Relying on messages instead of structure
```
✗ "Don't touch api/users.js, I'm working on it"
✓ api/users.js is exclusively in one worktree's slice
```

### Merge Anti-Patterns

**Big bang merge** — Saving all merges for the end
```
✗ All 3 worktrees merge at once on Friday
✓ Each worktree merges when its slice is complete
```

**Merge commit avalanche** — Too many merge commits cluttering history
```
✗ 50 merge commits for one feature
✓ Rebase feature branch, then single merge to main
```

**Conflict avoidance** — Skipping sync because conflicts are scary
```
✗ "I'll deal with conflicts later"
✓ Small, frequent syncs = small, easy conflicts
```
</anti_patterns>

<success_criteria>
## Success Criteria

You've done parallel development well when:

### Setup
- [ ] Worktrees are created with clear, non-overlapping slices
- [ ] Each worktree has its own feature branch
- [ ] Documentation exists showing who owns what
- [ ] Shared/frozen files are identified

### Execution
- [ ] Each worktree can work independently without blocking
- [ ] Daily syncs happen with minimal conflicts
- [ ] Merge conflicts are small and localized
- [ ] Progress is visible across all worktrees

### Integration
- [ ] Features merge to main incrementally
- [ ] Main branch always passes tests
- [ ] No big-bang merge at the end
- [ ] Worktrees clean up after completion

### The Ultimate Test

**Can you spin up a new Claude instance in a new worktree and have it start working immediately without coordinating with other instances?**

If yes, you've structured parallel development correctly.
</success_criteria>
