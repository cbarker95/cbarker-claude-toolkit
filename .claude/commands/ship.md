---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite
description: Ship the next feature from the PRD — find it, build it, verify it, mark it done
---

# Ship Command

Read the PRD, pick the next feature, build it, verify it, update the PRD. That's it.

You are Opus. You know how to plan and implement. This command gives you the loop, not the methodology.

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

Present the target feature and ask for confirmation:

```
AskUserQuestion: "Next up from the PRD:

**[Feature Name]** (Priority: [P-level], Status: [current status])
[Description from PRD if available]

Ship this feature?"

Options:
- Yes — start building
- Pick a different one — [tell me which]
- Cancel
```

If the user picks a different feature, use that instead. If they cancel, stop.

---

## Step 3: Mark IN PROGRESS in the PRD

Update the Feature Status table in the PRD:
- Set the target feature's Status to `IN PROGRESS`
- Add today's date in the Notes column

Do this now, before any implementation begins, so the PRD reflects reality.

---

## Step 4: Build the feature

Implement the feature. You have full discretion over how to do this:
- Read the codebase to understand patterns, conventions, and architecture
- Plan your approach
- Write the code
- Use whatever strategy fits the feature and codebase

**The only constraint is: leave the codebase in a working state when you're done.** Tests should pass. The build should succeed. If the project has neither tests nor a build step, verify the change works by whatever means are available.

Do not generate intermediate artifact files. The PRD is the only tracking artifact.

---

## Step 5: Verify

Run the project's verification steps. Detect what's available:
- If a test command exists (test scripts in package.json, Makefile, pytest, cargo test, go test, etc.), run it
- If a build command exists, run it
- If neither exists, do a manual review: check for syntax errors, broken imports, obvious regressions

If verification fails, fix the issues. If you cannot fix them after a reasonable effort, report what's broken and leave the feature marked IN PROGRESS.

---

## Step 6: Mark COMPLETE in the PRD

If verification passed:
- Set the target feature's Status to `COMPLETE`
- Add today's date and a brief note (e.g., "Shipped 2026-02-23")

If verification failed and you could not fix it:
- Leave the feature as `IN PROGRESS`
- Add a note explaining what's blocking

---

## Step 7: Report

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
