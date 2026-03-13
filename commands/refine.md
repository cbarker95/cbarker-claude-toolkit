---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion, TodoWrite
description: Iterate on UX/UI — refine layouts, interactions, and visual design without a PRD entry
---

# Refine Command

Structured UX/UI iteration. Lighter than `/ship` — no PRD entry needed. Loads the project's design language, uses the `frontend-design` skill for visual execution, and suggests stable patterns for CLAUDE.md.

## Usage

```
/refine chat should be a side panel alongside transcripts
/refine make the customer table feel more spacious
/refine the ask panel needs better empty state
/refine                  # ask what to refine
```

---

## Step 1: Load design context

Before doing anything else, load all available design constraints:

1. **Design language** — check for `docs/design/DESIGN_LANGUAGE.md`, then `docs/DESIGN_LANGUAGE.md`, then `DESIGN_LANGUAGE.md`. If found, read it. This defines colors, typography, spacing, shadows, component patterns, grid system, and anti-patterns. These are hard constraints — follow them.

2. **CLAUDE.md** — read the project's CLAUDE.md. Look for:
   - "Design Language" section (visual constraints summary)
   - "UX Patterns" section (stable layout/interaction decisions from previous refinements)
   - These represent decisions already made — don't contradict them unless the user explicitly asks.

3. **Frontend design skill** — the `frontend-design` skill is available for creative visual execution. When implementing visual changes, apply its principles for typography, color, motion, spatial composition, and attention to detail. The design language provides the *what* (specific values), the frontend-design skill provides the *how* (execution quality).

If no design language exists, note it:
```
No design language found. Visual changes will follow the frontend-design skill principles.
Consider running /design-language to define your project's visual spec.
```

---

## Step 2: Understand the target

**If `$ARGUMENTS` provided:** Use it as the refinement goal.

**If no arguments:** Use `AskUserQuestion` to ask the user what they want to refine. Provide options: "Layout/structure", "Visual polish", "Interaction", and "Component".

**STOP. Do not proceed until the user responds.**

Then explore the relevant codebase area:
- Read the components and pages involved
- Understand current layout, data flow, and interaction patterns
- Identify what specifically needs to change
- Note any design language constraints and UX patterns that apply

Tell the user what you found:
```
Current state: [brief description of what exists]
Design language: [relevant constraints that apply, or "none found"]
UX patterns: [any existing decisions that relate]
```

---

## Step 3: Propose approach

Use `AskUserQuestion` to present the refinement plan. Summarize the proposed changes, files affected, and how it aligns with the design language. Provide options: "Yes, go ahead", "Adjust", and "Cancel".

**STOP. Do not proceed to Step 4 until the user responds.** If the user adjusts, revise and re-present using `AskUserQuestion` again.

---

## Step 4: Implement

Make the changes. Use `TodoWrite` to track multi-step refinements.

- Follow design language constraints (grid, colors, spacing, shadows, anti-patterns)
- Apply `frontend-design` skill quality for visual execution
- For **complex visual refinement**, delegate to the `design-iterator` agent:
  ```
  Task (subagent_type: cbarker-claude-toolkit:design-iterator):
  "Iterate [N] times on [component/area]. Design language is at docs/design/DESIGN_LANGUAGE.md.
  Focus on: [specific aspect to improve]"
  ```

---

## Step 5: Verify

- If a build command exists, run it
- If TypeScript, run type checking
- If `agent-browser` is available, take a screenshot to verify visual changes
- Check for broken imports, missing styles, layout issues

Fix any issues before proceeding.

---

## Step 6: Suggest CLAUDE.md patterns

If this refinement establishes a reusable UX pattern, suggest adding it to CLAUDE.md:

Use `AskUserQuestion` to ask the user whether to add the pattern to CLAUDE.md. Describe the pattern clearly and provide options: "Yes, add it" and "No, this was specific to this change".

**STOP. Do not proceed until the user responds.**

If yes, append to the "UX Patterns" section in CLAUDE.md (create the section if missing).

Skip this step if the refinement didn't establish a generalizable pattern.

---

## Step 7: Report

```
Refined: [brief description]

Changes:
- [2-4 bullet summary]

Files modified:
- [list]

Design language: [followed / not found]
CLAUDE.md: [pattern added / no new pattern]
```

---

## Edge Cases

**No design language found:** Use `frontend-design` skill principles as the visual guide. Suggest `/design-language` at the end.

**Refinement contradicts existing UX pattern:** Flag it. Ask whether to update the pattern or adjust the refinement.

**Refinement scope creeps:** Pause and re-confirm scope. Suggest breaking into multiple `/refine` runs.

**Visual refinement needs many iterations:** Delegate to `design-iterator` agent rather than manually iterating.
