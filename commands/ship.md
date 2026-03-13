---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite, EnterPlanMode, ExitPlanMode
description: Ship the next feature from the PRD — find it, plan it, build it, verify it, mark it done
---

# Ship Command

Read the PRD, pick the next feature, plan how to build it, get approval, then execute. Ship is about the HOW — you research the codebase and design the implementation before writing any code.

## Usage

```
/ship [feature name or goal]
/ship                          # auto-detect next feature from PRD
```

---

## Step 1: Find the PRD and identify the target

Locate the PRD. Check these paths in order:
- `docs/product/PRD.md`
- `docs/PRD.md`
- `PRD.md`
- Any `*.md` file containing a `## Feature Status` table

If no PRD is found, tell the user and suggest running `/prd` first. Stop.

Read the **Feature Status** table from the PRD.

**If `$ARGUMENTS` is provided:** Match it to a feature in the table. If no exact match, use your judgment to find the closest one or treat it as a new goal that maps to a PRD feature.

**If no arguments:** Select the highest-priority feature that is `NOT STARTED`. Priority order: P0 > P1 > P2. Within the same priority, prefer features with no unmet dependencies.

---

## Step 2: Confirm with the user

Use `AskUserQuestion` to confirm the target feature with the user. Present the feature name, priority, and current status from the PRD. Provide options: "Yes — start building", "Pick a different one", and "Cancel".

**STOP. Do not proceed to Step 3 until the user responds.** The user's selection drives which feature gets built. If they pick a different feature, use that instead. If they cancel, stop.

---

## Step 3: Mark IN PROGRESS in the PRD

Update the Feature Status table in the PRD:
- Set the target feature's Status to `IN PROGRESS`
- Add today's date in the Notes column

Do this now, before entering plan mode, so the PRD reflects reality.

---

## Step 4: Enter Plan Mode

Call `EnterPlanMode`. Research the codebase and design the implementation approach. The user approves the plan before any code is written.

---

## Step 5: Design the implementation

Explore the codebase thoroughly:
- Read files related to the feature area
- Identify existing patterns, utilities, and components to reuse
- If UI feature: read `docs/design/DESIGN_LANGUAGE.md` for visual constraints
- Check CLAUDE.md for project conventions
- Map the architecture — understand what exists before proposing what to add

Write the implementation plan to the plan file:

```markdown
# Ship: [Feature Name]

## Feature
[Description from PRD + additional context from codebase exploration]

## Approach
[2-3 paragraph explanation of the implementation strategy — what patterns to follow,
key architectural decisions, how this fits into the existing codebase]

## Changes

### [filename.ext] — [create / modify]
- [What changes and why]

### [filename.ext] — [create / modify]
- [What changes and why]

[... all files that will be created or modified]

## Reusable Code
- [Existing utility/component] at [path] — [how it will be used]

## Design Constraints
[If UI feature: key rules from DESIGN_LANGUAGE.md that apply.
If not a UI feature: omit this section.]

## Verification
- [How to test: specific commands, manual checks, what to look for]
```

Then call `ExitPlanMode`. If the user wants a different approach, revise the plan and exit plan mode again.

---

## Step 6: Build the feature

Execute the approved plan. You have discretion over implementation details, but follow the agreed-upon architecture, file changes, and patterns from the plan.

- Write the code according to the plan
- Use whatever strategy fits the feature and codebase
- If you discover something during implementation that changes the approach significantly, tell the user rather than silently diverging from the plan

**The constraint is: leave the codebase in a working state when you're done.** Tests should pass. The build should succeed. If the project has neither tests nor a build step, verify the change works by whatever means are available.

Do not generate intermediate artifact files. The PRD is the only tracking artifact.

---

## Step 7: Verify

Run the project's verification steps. Detect what's available:
- If a test command exists (test scripts in package.json, Makefile, pytest, cargo test, go test, etc.), run it
- If a build command exists, run it
- If neither exists, do a manual review: check for syntax errors, broken imports, obvious regressions

If verification fails, fix the issues. If you cannot fix them after a reasonable effort, report what's broken and leave the feature marked IN PROGRESS.

---

## Step 8: Mark COMPLETE in the PRD

If verification passed:
- Set the target feature's Status to `COMPLETE`
- Add today's date and a brief note (e.g., "Shipped 2026-02-23")

If verification failed and you could not fix it:
- Leave the feature as `IN PROGRESS`
- Add a note explaining what's blocking

---

## Step 9: Report

Tell the user what happened:

```
Shipped: [Feature Name]

What was built:
- [2-4 bullet summary of what was implemented]

Verification:
- [Tests: pass/fail/none]
- [Build: pass/fail/none]

PRD updated: [Feature] marked COMPLETE.

Next up: [Next highest-priority NOT STARTED feature, or "All features complete"]
```

If the feature was NOT completed, adjust the report — explain what shipped, what didn't, and what's needed.

---

## Edge Cases

**No PRD found:** Tell the user. Suggest `/prd`. Stop.

**No NOT STARTED features:** Tell the user all PRD features are complete or in progress. Ask if they want to work on an IN PROGRESS or BLOCKED item, or add new features to the PRD.

**Feature depends on something not yet built:** Note the dependency. Ask the user whether to build the dependency first or proceed anyway.

**Feature is already IN PROGRESS:** Ask the user if they want to continue it or restart it.

**Feature is BLOCKED or DEFERRED:** Show the notes. Ask the user if the blocker is resolved and they want to proceed.

**Plan divergence during build:** If implementation reveals the plan needs significant changes (wrong assumptions, missing dependencies, better approach discovered), stop and tell the user rather than silently deviating. Offer to re-enter plan mode if the change is architectural.
