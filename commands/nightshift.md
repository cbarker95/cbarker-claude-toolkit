---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite, EnterPlanMode, ExitPlanMode
argument-hint: "[feature1, feature2, ...] [--skip-on-failure]"
description: Batch-plan features for overnight autonomous development — plan with human, execute with Ralph Loop
---

# Nightshift Command

Batch-plan multiple features from the PRD while you're present, then hand off to Ralph Loop for autonomous overnight execution. Each feature is implemented, verified, committed, and marked COMPLETE in the PRD — one at a time, sequentially, while you sleep.

## Usage

```
/nightshift                              # auto-select NOT STARTED features
/nightshift Watch mode, Incremental      # specific features by name
/nightshift --skip-on-failure            # skip failed features (default behavior)
```

---

## Phase 1: Interactive Planning (Human Present)

### Step 1: Preflight checks

Check for existing state files:

1. If `.claude/ralph-loop.local.md` exists, a Ralph Loop is already active. Tell the user and suggest `/cancel-ralph` first. Stop.

2. If `.claude/nightshift-plan.md` exists, a previous nightshift session left state behind. Use `AskUserQuestion` to ask the user what to do. Provide options: "Resume" (skip completed/failed, continue from first queued — jump to Step 7), "Start fresh" (delete old state, proceed normally), and "Cancel".

   **STOP. Do not proceed until the user responds.**

3. Locate the PRD. Check these paths in order:
   - `docs/product/PRD.md`
   - `docs/PRD.md`
   - `PRD.md`
   - Any `*.md` file containing a `## Feature Status` table

   If no PRD is found, tell the user and suggest running `/prd` first. Stop.

---

### Step 2: Parse PRD and identify candidates

Read the **Feature Status** table from the PRD. Extract all features with their Priority, Status, and Notes.

Filter to features with Status = `NOT STARTED`. Group by priority (P0 > P1 > P2).

---

### Step 3: Feature selection

**If `$ARGUMENTS` contains feature names:** Match them to PRD rows. Present the matched set for confirmation.

**If no feature arguments:** Use `AskUserQuestion` to present all NOT STARTED features grouped by priority (P0, P1, P2) as a numbered list. Provide options: "All P1 features", "Pick specific features", and "Cancel".

**STOP. Do not proceed to Step 4 until the user responds.** If the user cancels or selects zero features, stop.

---

### Step 4: Dependency analysis and build ordering

For each selected feature, check the Notes column for "Depends on" references. Also check if any selected feature logically depends on another (e.g., a feature that extends an existing page depends on that page existing).

Propose a build order:
1. Features with no dependencies first
2. Features whose dependencies are already COMPLETE second
3. Features that depend on other selected features ordered after their dependencies
4. Features that depend on unselected, NOT STARTED features get flagged

Use `AskUserQuestion` to present the proposed build order. List each feature with its dependency status, and flag any features that depend on unselected/unbuilt work. Provide options: "Approve", "Reorder", "Remove flagged items and approve", and "Cancel".

**STOP. Do not proceed to Step 5 until the user responds.**

---

### Step 5: Batch planning

Call `EnterPlanMode`. This is the critical step — all plans are generated now, while the human is present.

For EACH feature in the approved order:

1. **Explore the codebase** — Read files related to the feature area. Identify existing patterns, utilities, and components to reuse. If it's a UI feature, read `docs/design/DESIGN_LANGUAGE.md`. Check CLAUDE.md for conventions.

2. **Write the plan section** in the plan file. Use this structure per feature:

```markdown
### [N]. [Feature Name] — P[X]

#### Approach
[2-3 paragraph implementation strategy. How this fits into the existing codebase.
What patterns to follow. Key architectural decisions.]

#### Changes
- `path/to/file.ext` — [create / modify] — [what and why]
- `path/to/file2.ext` — [create / modify] — [what and why]

#### Reusable Code
- [Existing utility/component] at [path] — [how it will be used]

#### Design Constraints
[If UI feature: key rules from DESIGN_LANGUAGE.md. Otherwise omit.]

#### Verification
- [Specific commands to run: npm run build, npm test, etc.]
- [What to check manually if no tests exist]

#### Commit Message
`feat: [concise description of what this feature adds]`
```

3. **Account for earlier features** — If feature N depends on changes from feature N-1, reference those planned changes. The execution phase will see the actual committed code, but the plan should note the dependency.

After all features are planned, call `ExitPlanMode`. The user reviews every plan at once. They can:
- Remove features from the queue
- Reorder features
- Request plan modifications for specific features
- Approve everything

If the user requests changes, revise and exit plan mode again. Repeat until approved.

---

### Step 6: Write nightshift state file

After the user approves all plans, write `.claude/nightshift-plan.md`:

```markdown
---
active: true
started_at: "[ISO timestamp]"
total_features: [N]
completed: 0
failed: 0
skip_on_failure: true
---

## Feature Queue

### 1. [Feature Name]
- **status:** queued
- **priority:** P[X]
- **started_at:**
- **completed_at:**
- **commit:**
- **failure_reason:**
- **plan:**
  [Full plan from Step 5, indented under this field]

---

### 2. [Feature Name]
- **status:** queued
- **priority:** P[X]
- **started_at:**
- **completed_at:**
- **commit:**
- **failure_reason:**
- **plan:**
  [Full plan]

---

[... all features ...]
```

Tell the user: "Nightshift plan written. [N] features queued. Starting Ralph Loop now — you can close the lid."

---

### Step 7: Activate Ralph Loop

Calculate max iterations: `total_features * 10` (generous buffer for retries).

Run the Ralph Loop setup. The prompt stored in `.claude/ralph-loop.local.md` is the **Nightshift Execution Prompt** below. Set `--completion-promise "NIGHTSHIFT COMPLETE"`.

The Ralph Loop is now active. The stop hook will handle iteration. Phase 1 is complete.

---

## Phase 2: Autonomous Execution (Ralph Loop)

### Step 8: Nightshift execution prompt

This is the prompt that Ralph Loop feeds on every iteration. It must be fully self-contained — the agent reads all state from files.

```
You are running a nightshift autonomous development session. Your job is to implement the next queued feature from the nightshift plan.

EVERY ITERATION, follow these steps exactly:

1. READ STATE
   Read .claude/nightshift-plan.md. Parse the YAML frontmatter and feature queue.
   Find the FIRST feature with status "queued".

   If NO features are "queued" (all are completed, failed, or skipped):
   → Jump to MORNING REPORT below.

2. MARK IN PROGRESS
   Update the feature's status to "in_progress" and set started_at to now.
   Update the YAML frontmatter current_index.
   Update the PRD Feature Status table: set this feature to IN PROGRESS with today's date.

3. EXPLORE AND IMPLEMENT
   Read the plan section for this feature carefully.
   Do a quick codebase exploration — previous iterations may have changed things.
   The plan is your guide, but the current codebase state is truth.

   Implement the feature following the plan:
   - Follow CLAUDE.md conventions (import type, no any, ESM, named exports)
   - Follow DESIGN_LANGUAGE.md if it's a UI feature
   - Create and modify only the files specified in the plan
   - If you discover the plan needs adjustment, adapt — but stay within scope

4. VERIFY
   Run verification commands from the plan (typically npm run build).
   If there are tests, run them too.
   The codebase MUST compile cleanly after your changes.

5. HANDLE RESULT

   IF VERIFICATION PASSES:
   a. Stage and commit ONLY the files you changed. Use the commit message from the plan.
      End every commit message with: Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
   b. Update .claude/nightshift-plan.md:
      - Set this feature's status to "completed"
      - Set completed_at to now
      - Set commit to the short SHA
      - Increment the completed counter in YAML frontmatter
   c. Update the PRD Feature Status table: set this feature to COMPLETE.
      Notes: "Shipped overnight [date]"

   IF VERIFICATION FAILS after 2 fix attempts:
   a. Revert all uncommitted changes: git checkout .
   b. Update .claude/nightshift-plan.md:
      - Set this feature's status to "failed"
      - Set completed_at to now
      - Set failure_reason to a clear description of what went wrong
      - Increment the failed counter in YAML frontmatter
   c. Update the PRD Feature Status table: set this feature to BLOCKED.
      Notes: "Nightshift failure: [brief reason]"
   d. Check skip_on_failure in the YAML frontmatter:
      - If true: continue (the next iteration will pick the next queued feature)
      - If false: jump to MORNING REPORT

6. EXIT
   You are done with this iteration. Exit normally.
   The Ralph Loop stop hook will re-enter you for the next feature.

---

MORNING REPORT

When all features have been processed (none remain "queued"), write .claude/nightshift-report.md:

# Nightshift Report

**Date:** [today]
**Started:** [started_at from YAML]
**Finished:** [now]

## Summary

| Metric | Count |
|--------|-------|
| Features queued | [total] |
| Completed | [N] |
| Failed | [N] |

## Completed

[For each completed feature:]
### [Feature Name]
- **Commit:** [short SHA]
- **What was built:** [1-2 sentence summary]

## Failed

[For each failed feature:]
### [Feature Name]
- **Reason:** [failure_reason]
- **Suggested fix:** [actionable suggestion]

## Next Steps
- [List 3-5 remaining NOT STARTED features from the PRD as candidates for the next nightshift]

---

Then output: <promise>NIGHTSHIFT COMPLETE</promise>

CRITICAL: Do NOT output the promise until ALL queued features have been processed OR skip_on_failure is false and a failure occurred. The promise must be TRUE.
```

---

## Edge Cases

**No PRD found:** Tell the user. Suggest `/prd`. Stop.

**No NOT STARTED features:** Tell the user all PRD features are complete or in progress. Stop.

**User selects 0 features:** Stop.

**Single feature selected:** Works fine — nightshift with 1 feature is `/ship` without approval gates.

**Feature already IN PROGRESS:** Ask the user if they want to include it (restart from scratch) or skip it.

**Feature depends on unselected, unbuilt work:** Flag during Step 4. Let the user decide: include the dependency, remove the feature, or proceed anyway.

**Ralph Loop already active:** Detected in Step 1. Suggest `/cancel-ralph` first.

**Previous nightshift state exists:** Detected in Step 1. Offer resume or fresh start.

**Emergency stop:** `/cancel-ralph` stops the loop. The nightshift state file preserves progress — the morning report can still be generated manually, or `/nightshift` can be run again to resume.
