---
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Task, AskUserQuestion
description: UX/UI iteration — small tweaks, iterative visual work, or large-scope feedback with plan generation
---

# Refine Command

UX/UI iteration at any scale. Works in three modes:

- **Small**: Direct implementation of focused changes (single component, one issue)
- **Iterative**: Multiple visual passes using the design-iterator agent
- **Large-scope**: Generates a refinement plan with 🟪 markers that go-commando can execute autonomously

Use this for:
- Visual polish (spacing, typography, colour adjustments)
- Interaction improvements (hover states, transitions, micro-interactions)
- Accessibility fixes
- Responsive layout tweaks
- Design system alignment
- Broad feedback from user testing or stakeholder review (large-scope mode)

## Usage

```
/refine [what to work on]
/refine                    — asks what to refine
```

---

## Step 1: Understand the Refinement

If `$ARGUMENTS` is empty, **STOP HERE.** Ask the user:

```
What would you like to refine?

  - Visual polish on a specific component or page
  - Fix a specific UX issue (describe it)
  - Align something to the design system
  - Accessibility improvement
  - Something else (describe)
```

**Do not proceed until the user has replied.**

If `$ARGUMENTS` is provided, confirm the scope. **STOP HERE** and present:

```
Refining: [what was described]

Is this:
  - A small, focused change (I'll implement it directly)
  - Iterative visual work needing multiple passes (I'll use the design-iterator agent)
  - Large-scope feedback (I'll generate a refinement plan for go-commando)
```

**Do not proceed until the user has confirmed or clarified.**

---

## Step 2: Load Design Context

Look for the design language file in this order:
1. `docs/design/DESIGN_LANGUAGE.md`
2. `docs/DESIGN_LANGUAGE.md`
3. `DESIGN_LANGUAGE.md` (repo root)

If found, read it for visual principles, colour philosophy, and interaction guidelines.

Also read CLAUDE.md for:
- "Design Language" section (visual constraints summary)
- "UX Patterns" section (stable decisions from previous refinements)

If no design language exists, note it:
```
No design language found. Visual changes will follow general best practices.
Consider running /design-language to define your project's visual spec.
```

---

## Step 3: Explore Relevant Code

Before making changes, read the files being refined. Understand:
- Current implementation patterns
- Which design tokens and components are in use
- How this connects to surrounding components
- Any existing tests that cover this area

---

## Step 4: Implement the Refinement

For **small, focused changes** (single component, one issue):

Implement directly. Follow the project's established patterns, design language constraints, and conventions from CLAUDE.md.

For **iterative visual work** (multiple passes needed):

Delegate to the `design-iterator` agent if available:

```
Use Task tool:
  subagent_type: cbarker-claude-toolkit:design-iterator
  prompt: "Iterate [N] times on [specific component/page]:
    Current issue: [what looks wrong]
    Goal: [what it should look like]
    Files: [list relevant files]"
```

If the design-iterator agent isn't available, iterate manually — make changes, verify, adjust, repeat.

For **large-scope feedback** (broad changes across multiple components/pages):

This mode generates a refinement spec that go-commando can execute autonomously.

1. **Gather all feedback** — Ask the user to describe every change needed. Capture:
   - Which pages/components need changes
   - What's wrong with each (specific issues, not vague "make it better")
   - Any reference designs, screenshots, or competitor examples

2. **Analyze current code** — Read the affected files to understand what exists and how changes would be structured.

3. **Generate a refinement spec** — Write to `Docs/Specifications/Plans/{feature}-refinement.md` using the standard spec format with 🟪 markers:

   ```markdown
   # {Feature} — Refinement Specification

   > Refinement pass based on [user testing / stakeholder feedback / design review].
   > Run: `node scripts/go-commando.js implement Plans/{feature}-refinement`

   ## Overview
   {Summary of the feedback and what needs to change}

   ## Features

   🟪 ### 1. {Component/Page}: {Specific change}
   {What to change, why, and how}
   **Files:** [list]

   🟪 ### 2. {Component/Page}: {Another change}
   ...
   ```

   Each 🟪 item should be self-contained — completable in a single go-commando iteration.

4. **Present the plan** for approval. **STOP HERE** and wait for the user:

   ```text
   Refinement plan ready: Docs/Specifications/Plans/{feature}-refinement.md

     Changes planned: [N] items
     Files affected: [list]

     To execute automatically:
       node scripts/go-commando.js implement Plans/{feature}-refinement

     Or work through them manually — each item is a self-contained change.

     Review and approve?

   Options:
     - Approve (I'll write the file)
     - Adjust (describe changes)
     - Cancel
   ```

   **Do not write the file until the user approves.**

5. After approval, write the refinement spec and stop. The user will run go-commando separately.

---

## Step 5: Verify

Run the project's build and test commands to verify nothing is broken.

If the change is purely visual (no logic), a build check is sufficient.

Fix any issues before proceeding.

---

## Step 6: Suggest CLAUDE.md patterns

If this refinement establishes a reusable UX pattern, suggest adding it to CLAUDE.md:

```
This refinement established a pattern:
'[description]'

Should I add this to CLAUDE.md so future sessions follow it?
```

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

## Notes

- **Small and iterative modes** are for focused work within a single session
- If feedback is broad (touching many components, multiple pages, or requiring structural changes), use **large-scope mode** to generate a plan that go-commando can execute
- If you discover new features are needed (not just refinements to existing ones), stop and use `/discover` to create a discovery spec for the new work
