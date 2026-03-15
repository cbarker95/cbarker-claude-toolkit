---
allowed-tools: Read, Write, Edit, Glob, Grep, Task, AskUserQuestion, EnterPlanMode, ExitPlanMode
description: Research codebase and generate a discovery specification for go-commando to build
---

# Discover Command

Research the codebase, clarify requirements, and generate a discovery specification — a structured document with 🟪 markers that go-commando + `/implement` can build autonomously. This is the thinking step before building — it answers "what should we build and how should it be structured?" so that go-commando can build it.

## Usage

```
/discover [feature area or brief description]
/discover                    — asks what to discover
```

---

## Step 1: Understand the Discovery

If `$ARGUMENTS` is empty, **STOP HERE.** Ask the user:

```
What feature area should I research and spec out?

  - A new page or module (describe the user problem it solves)
  - An extension to an existing feature (which feature, what's missing)
  - A broad product area (describe)
  - Something else (describe)
```

**Do not proceed until the user has replied.**

If `$ARGUMENTS` is provided, confirm the scope. **STOP HERE** and present:

```
Discovering: [what was described]

I'll research the codebase and generate a discovery specification that go-commando can build.
The spec will include components, pages, data layers, and implementation details.

Proceed with research?
```

**Do not proceed until the user has confirmed.**

---

## Step 2: Enter Plan Mode

**Immediately call `EnterPlanMode`.** The entire discovery process — research, analysis, and spec drafting — happens inside plan mode. The discovery spec IS the plan. The user will review the complete spec before anything is saved to disk.

**This is mandatory. Do not skip this step.**

---

## Step 3: Check for Existing Specs and Template

Before researching, check what already exists:

1. Look for an existing spec at `Docs/Specifications/{Feature}/README.md`
2. Read the discovery spec template from `templates/discovery-spec-template.md` for the expected format. If not found, check `Docs/Specifications/_templates/discovery-spec-template.md` as a fallback.

If an existing spec is found, ask whether to update it or start fresh.

---

## Step 4: Parallel Discovery

Launch these sub-agents **in parallel** using the Task tool:

### Agent 1: Existing Documentation & Architecture

```
subagent_type: Explore
prompt: "Review the project architecture relevant to [feature area]:

1. Read CLAUDE.md for conventions, architecture, and build commands
2. Check for existing product context:
   - docs/product/PRD.md (if it exists — extract product area, personas, priorities)
   - Any existing specs in Docs/Specifications/ related to this area
3. Read README.md for product description and setup
4. Identify architectural patterns, conventions, and constraints

Return:
- Product context (if found)
- Target users for this feature
- Any existing specs or documentation
- Key architectural constraints or patterns to follow"
```

### Agent 2: Codebase Feature Analysis

```
subagent_type: Explore
prompt: "Analyze what's currently built in this repository relevant to [feature area]:

1. What pages/routes/endpoints exist?
2. What components/modules exist?
3. What patterns are established (state management, data flow, styling)?
4. What would be easy to extend vs. what requires new infrastructure?
5. Are there partially built features or stubs?

Create a feature inventory:
- BUILT: Fully functional
- PARTIAL: Started but incomplete
- MISSING: Referenced but not implemented

Return a feature map with classification, file locations, and reusable patterns."
```

### Agent 3: Design & UX Analysis

```
subagent_type: Explore
prompt: "Analyze the UI/UX patterns relevant to [feature area]:

1. Read docs/design/DESIGN_LANGUAGE.md if it exists
2. Examine existing components for visual patterns, layout conventions
3. Identify reusable components and design tokens
4. Look at user flows — how does navigation work?

Return:
- Design language constraints (if found)
- Reusable UI components
- Layout and navigation patterns
- Data display patterns (tables, cards, lists)"
```

---

## Step 5: Synthesize and Present Discovery Summary

After agents complete, synthesize findings into a summary. **STOP HERE** and present to the user:

```text
Discovery summary: [Feature Name]

  Existing code:
    - [BUILT items relevant to this feature]
    - [PARTIAL items that can be extended]
    - [MISSING items that need building]

  Proposed discovery spec:
    Components: [N] ([names])
    Pages/Views: [N] ([names])
    Data hooks/services: [N]

  Estimated 🟪 features: [N] items for go-commando to build

  Should I generate the full discovery specification?

Options:
  - Generate spec (I'll write it for your review before saving)
  - Adjust scope (describe changes)
  - Cancel
```

**Do not proceed until the user has confirmed.** Wait silently.

---

## Step 6: Draft the Spec to the Plan File

Write the full discovery spec to the plan file. Since you are already in plan mode (from Step 2), the user will see this spec for review when you call `ExitPlanMode`.

The spec will eventually go to `Docs/Specifications/{Feature}/README.md`, but only after the user approves the plan.

### Spec Structure

```markdown
# {Feature Name} — Discovery Specification

> **Run**: `node scripts/go-commando.js implement {SpecFolderName}`
>
> This spec is designed for autonomous execution via go-commando.js + /implement.
> Each 🟪 section is a self-contained unit of work. /implement will pick the next
> unfinished 🟪, build it, mark it ✅, and commit. The loop continues until all
> features are complete.

## Overview

{What this feature does and why — 2-3 sentences focused on user problem}

## Task Flows

### Flow 1: {Primary user journey}
**User**: {who}
**Entry point**: {where}
1. User {action} → System {response}
2. ...
**Success**: {outcome}
**Edge cases**: {empty states, errors}

## Architecture

{ASCII tree diagram showing component composition, data flow, navigation}

## Scope

- **Components**: {list}
- **Pages/Views**: {list}
- **Data/Services**: {list}
- **Out of scope**: {list}

---

## Features

🟪 ### 1. Foundation: {scaffolding, routes, types}
{description}
**Files:**
- [file paths with (new) or (modify)]

🟪 ### 2. Component: {Name}
{description}
**Files:**
- [file paths]

🟪 ### 3. Data layer: {hooks, services, types}
{description}
**Files:**
- [file paths]

🟪 ### 4. Page: {PageName}
{description — how components wire together}
**Files:**
- [file paths]
```

### Rules for Spec Generation

- **Every 🟪 feature must be self-contained** — completable in a single go-commando iteration
- **Foundation always comes first** — scaffolding, routes, types
- **Components before pages** — build parts, then assemble
- **Data layer before pages** — pages wire components to data
- **File paths must follow project conventions** (read from CLAUDE.md)
- **Each feature lists its files** with (new) or (modify) annotations
- **Include tests** for each component and page where the project has a test framework
- **Keep features small** — if a 🟪 item would take more than ~10 minutes, split it

---

## Step 7: Exit Plan Mode for Approval

Once the spec is complete in the plan file, call `ExitPlanMode`. The user will see the full spec and can:
- **Approve** — proceed to save
- **Request changes** — iterate on the spec in plan mode
- **Reject** — stop without saving

**Do not write the spec to `Docs/Specifications/` until the user approves the plan.**

---

## Step 8: Save and Report

After the user approves the plan, write the spec to `Docs/Specifications/{Feature}/README.md`. Create the directory if needed. Then output:

```text
Discovery spec saved: Docs/Specifications/{Feature}/README.md

  Features: [N] items ready for go-commando
  Estimated build: [rough estimate based on feature count]

  To build autonomously:
    node scripts/go-commando.js implement {Feature}

  To refine after building:
    /refine [specific issue]
```

---

## Notes

- The discovery spec is the input to go-commando + `/implement` — it defines what gets built
- Each 🟪 item should be completable in one `/implement` session (typically 1 component, 1 hook group, or 1 page)
- Keep the spec focused on what to build — detailed enough for autonomous execution, not a novel
- Run `/discover` again to add features to an existing spec or create a new one
- After go-commando builds the spec, use `/refine` for polish
