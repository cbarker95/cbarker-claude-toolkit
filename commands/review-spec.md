---
allowed-tools: Read, Glob, Grep, Task, AskUserQuestion, Write, Edit
description: Review a discovery spec for quality — grades backend/frontend/UX architecture, component usage, build order, and test strategy. Optionally auto-improves.
---

# Review Spec Command

Review a discovery specification against seven quality dimensions. Produces a scorecard and can optionally auto-improve the spec using the spec-improver agent.

## Usage

```
/review-spec [spec name or path]
/review-spec ReactivePipeline           — reviews Docs/Specifications/ReactivePipeline/README.md
/review-spec CollaborationAnnotations   — reviews Docs/Specifications/CollaborationAnnotations/README.md
/review-spec                            — asks which spec to review
```

---

## Step 1: Find the Spec

If `$ARGUMENTS` is empty, **STOP HERE.** List available specs and ask which to review:

1. Glob for `Docs/Specifications/*/README.md`
2. Present the list:

```
Available specs:
  1. {SpecName1}
  2. {SpecName2}
  ...

Which spec should I review? (Enter number or name)
```

**Do not proceed until the user has replied.**

If `$ARGUMENTS` is provided, resolve to a spec file:
- Check `Docs/Specifications/{$ARGUMENTS}/README.md`
- If not found, check `Docs/Specifications/Plans/{$ARGUMENTS}*.md`
- If still not found, search for a matching file with Glob

If the spec file cannot be found, tell the user and stop.

---

## Step 2: Load Context (Parallel)

Read these files in parallel:

1. **The target spec** — the file being reviewed
2. **CLAUDE.md** — project conventions and architecture
3. **docs/design/DESIGN_LANGUAGE.md** — design system tokens and patterns
4. **Component inventory** — Glob for:
   - `desktop/src/renderer/components/atoms/*/`
   - `desktop/src/renderer/components/molecules/*/`
   - `desktop/src/renderer/components/organisms/*/`
5. **src/types.ts** (first 50 lines) — existing type patterns

---

## Step 3: Run Spec Reviewer

Launch the spec-reviewer agent using the Task tool:

```
subagent_type: cbarker-claude-toolkit:spec-reviewer
prompt: "Review this discovery specification for quality across all 7 dimensions.

Spec file: {path to spec}
Spec content: {full spec content}

Project context:
- Architecture: {key points from CLAUDE.md}
- Design system: {key constraints from DESIGN_LANGUAGE.md}
- Existing components:
  Atoms: {list}
  Molecules: {list}
  Organisms: {list}

Produce a full quality scorecard with scores, strengths, gaps, and recommendations."
```

If the spec-reviewer agent is not available, perform the review inline using the scoring rubric from the agent definition. Read the spec-reviewer agent definition at `agents/spec-reviewer.md` for the complete rubric.

---

## Step 4: Present Results

Present the scorecard and ask the user what to do:

```
Spec Review Complete: {Spec Name}

  Score: {score}/100 ({rating})

  Dimension Breakdown:
  | Dimension              | Score   |
  |------------------------|---------|
  | Backend Architecture   | {n}/15  |
  | Frontend Architecture  | {n}/15  |
  | UX/UI Architecture     | {n}/15  |
  | Component Usage        | {n}/15  |
  | Design System          | {n}/10  |
  | Build Order            | {n}/15  |
  | Test Strategy          | {n}/15  |

  Top 3 gaps:
  1. {gap — specific and actionable}
  2. {gap}
  3. {gap}

Options:
  - Auto-improve — Run spec-improver to add missing sections automatically
  - Manual guide — I'll walk you through specific improvements
  - Export — Save the scorecard to Docs/Specifications/Reviews/
  - Done — No action needed
```

**Wait for the user to choose.**

---

## Step 5: Handle Response

### If "Auto-improve"

Launch the spec-improver agent:

```
subagent_type: cbarker-claude-toolkit:spec-improver
prompt: "Improve this discovery specification based on the review findings.

Spec file: {path to spec}
Spec content: {full spec content}

Review scorecard: {full scorecard}

Gaps to address:
{list of specific gaps from the review}

Project context:
- CLAUDE.md conventions: {summary}
- Design system: {summary}
- Existing components: {list}
- Existing types: {patterns from types.ts}

Add missing sections without removing existing content. Focus on the lowest-scoring dimensions first."
```

If the spec-improver agent is not available, perform improvements inline. Read the spec-improver agent definition at `agents/spec-improver.md` for the workflow.

After improvements are made, present the diff summary for user approval before saving:

```
Proposed improvements to {Spec Name}:

Sections added:
  - {section}: {brief description}
  - ...

Features reordered: {yes/no, details if yes}
Test files added: {count}

Save these improvements? (Yes / No / Show diff)
```

**Wait for user confirmation before writing changes.**

### If "Manual guide"

Walk through each gap from the review, one at a time. For each gap:

1. Explain what's missing and why it matters
2. Provide a template or example from the relevant skill reference
3. Ask if the user wants to add this section
4. If yes, draft the content and add it to the spec

### If "Export"

Write the scorecard to `Docs/Specifications/Reviews/{spec-name}-review-{date}.md`.

### If "Done"

Stop. Output:

```
Review complete. Run /review-spec again anytime to re-evaluate.
```

---

## Step 6: Report

After improvements (if any), present the final summary:

```
Review complete: {Spec Name}

  Before: {original score}/100 ({original rating})
  After:  {new score}/100 ({new rating})   ← only if improved

  Changes made:
  - {list of sections added/modified}

  The spec is ready for go-commando:
    node scripts/go-commando.js implement {SpecName}
```

---

## Notes

- The review uses 7 dimensions totaling 100 points (see agents/spec-reviewer.md for full rubric)
- Ratings: Excellent (90+), Good (75-89), Fair (60-74), Poor (40-59), Critical (<40)
- Run `/review-spec` after `/discover` to verify spec quality before go-commando
- The auto-improve option uses the spec-improver agent to surgically add missing sections
- Manual guide option references `ux-ui-architecture` and `spec-architecture` skill materials
