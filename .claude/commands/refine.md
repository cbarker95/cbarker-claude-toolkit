---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite, TaskOutput, EnterPlanMode, ExitPlanMode, Skill
description: Iterate on shipped features — diagnose issues, plan refinements, implement one change at a time
---

# Refine Command

Post-ship iteration for when the implementation isn't quite right. Works through back-and-forth with you to diagnose what's off, builds a numbered iteration plan in the PRD, then implements each change one at a time.

## Usage

```
/refine [what feels off]
/refine                     # diagnose the most recently shipped feature
```

---

## Diagnose

Enter plan mode. Understand what was shipped and what needs to change.

Read `docs/product/PRD.md` and the relevant source files in parallel. Identify the target feature — either from `$ARGUMENTS` or by finding the most recently completed feature in the PRD.

If the user described specific complaints, start from those. Otherwise, ask what feels off:

```
AskUserQuestion: "What's not right about [feature name]?

- Visual: colors, spacing, typography, layout feel off
- Interaction: hover states, transitions, responsiveness
- Content: copy, hierarchy, information architecture
- Multiple things

Describe what you're seeing vs what you expected."
```

Invoke the `frontend-design` skill to ground aesthetic judgment when discussing visual changes.

Work back-and-forth with the user to convert vague complaints into **specific, measurable changes**. Each iteration must be ONE change:

| Too vague | Specific enough |
|-----------|----------------|
| "Make the hero bigger" | "Increase hero heading from 2rem to 3.5rem" |
| "The colors feel off" | "Replace #6B7280 subtext with #9CA3AF for softer contrast" |
| "Spacing is weird" | "Add 2rem top padding to the features grid" |
| "It looks boring" | "Add subtle gradient background (#F8F9FA → #FFFFFF) to hero section" |

Keep going until the user confirms the list is complete. If issues are structural or architectural — the feature needs rethinking, not polishing — recommend `/strategy evolve` or `/ship` instead and end cleanly.

---

## Plan

Still in plan mode. Write the iteration plan into the PRD:

```markdown
### Refining: [Feature Name]

**Target**: [Component/page path]
**Branch**: [current branch or refine-[name]]
**Started**: [date]

#### Iterations
- [ ] 1. [Specific change] — [rationale]
- [ ] 2. [Specific change] — [rationale]
- [ ] 3. [Specific change] — [rationale]
```

Place this in the Implementation Status section of the PRD, after Complete entries.

Exit plan mode to get user approval before making any changes.

---

## Iterate

Work through the iteration list in order. For each iteration:

1. **Make the ONE change** — nothing more, nothing less
2. **Verify visually** — take a screenshot if it's a visual change (use the design-iterator agent for complex visual work)
3. **Run build** — `npm run build` after every 2-3 iterations minimum, or immediately if the change is structural
4. **Mark complete** — check off the iteration in the PRD
5. **Commit** — descriptive message referencing the iteration number

Invoke skills based on what the refinement requires:

| Refinement Type | Skill |
|----------------|-------|
| Visual polish, typography, color, spacing | `frontend-design` |
| Component structure, token alignment | `atomic-design-system` |
| Complex visual iteration (colors not working, layout unbalanced) | Use `design-iterator` agent with 3-5 iterations |

**After all planned iterations are complete**, ask the user:

```
AskUserQuestion: "All [N] iterations are done. What do you think?

- Looks good — ship it
- Need more refinements (describe what's still off)
- One of the changes made things worse (which one?)"
```

If more refinements needed: return to **Diagnose** for another round.
If a change made things worse: revert that specific commit, then continue.

**Stop condition**: When neither you nor the user can identify ONE clear improvement, the refinement is done.

---

## Complete

When the user confirms refinement is done:

1. Run `npm run build` one final time
2. Update the PRD: convert `### Refining:` to a completion entry:
   ```markdown
   ### Refined: [Feature Name] — [date] ([commit hash])
   [N] iterations: [brief summary of what changed]
   ```
3. Report what was refined and the key files touched

---

## When It Fails

- **Build failures**: Fix in place. 3 attempts at the same failure, then stop and report
- **User wants to stop mid-refinement**: Commit WIP, keep PRD markers with checked/unchecked state for later
- **Scope escalation**: If diagnosis reveals structural problems, recommend `/strategy evolve` or `/ship` and end cleanly
- **Can't reproduce the issue**: Ask user for a screenshot or more specific description
