---
allowed-tools: Read, Write, Edit, Glob, Grep, Task, AskUserQuestion, TodoWrite, WebFetch, WebSearch, EnterPlanMode, ExitPlanMode
description: Capture a project's visual design language from references (screenshots, URLs, mood keywords) into a DESIGN_LANGUAGE.md
---

# Design Language Command

Analyze visual references and the current codebase, then generate a `DESIGN_LANGUAGE.md` that defines the project's visual design language. This document becomes the single source of truth that other design tools (`design-iterator`, `/ship`, `/atomic-init`, `figma-design-sync`) discover and follow.

You are a senior design systems engineer. You translate visual references into precise, implementable specifications. Be opinionated about what works and what doesn't.

## Usage

```
/design-language                              # analyze existing project, ask for references
/design-language warm minimal apple-inspired  # mood keywords as starting point
/design-language update                       # update existing design language from new references
```

---

## Step 0: Enter Plan Mode

Call `EnterPlanMode` immediately. All research and synthesis (Steps 1-4) happens in plan mode. The user approves the design language before it is written to disk.

---

## Step 1: Check for existing design language

Look for an existing design language document:
- `docs/design/DESIGN_LANGUAGE.md`
- `docs/DESIGN_LANGUAGE.md`
- `DESIGN_LANGUAGE.md`

**If found AND `$ARGUMENTS` contains "update":** Read it. This is an update — preserve existing decisions, integrate new references. Proceed to Step 2.

**If found AND no "update":** Tell the user a design language already exists. Ask:
```
AskUserQuestion: "A design language already exists at [path]. What would you like to do?"
Options:
- Update it — integrate new references while preserving existing decisions
- Replace it — start fresh from new references
- Cancel — keep the existing one
```

**If not found:** Proceed to Step 2.

---

## Step 2: Discover project context

Launch two sub-agents **in parallel** using the Task tool:

**Agent 1: Codebase Styling Analysis**
```
subagent_type: Explore
prompt: "Analyze the current styling and visual patterns in this project:
1. Find and read: tailwind.config.*, *.css, *.scss, theme.*, tokens.*, postcss.config.*
2. Scan component files for Tailwind class patterns — extract common: colors, fonts, spacing, radius, shadows
3. Check for existing design tokens or CSS custom properties
4. Identify the styling framework (Tailwind, CSS Modules, styled-components, etc.)
5. Note any established visual patterns (card styles, button variants, input styles)

Return structured findings:
- Framework & tools (what's configured)
- Color palette (what colors are actually used, with hex values)
- Typography (font stacks, size scale, weights used)
- Spacing patterns (common padding/margin values)
- Border radius (values used)
- Shadows (if any)
- Component patterns (recurring class combinations)
- Gaps (things missing or inconsistent)"
```

**Agent 2: Reference Analysis** (only if `$ARGUMENTS` provided and not just "update")
```
subagent_type: general-purpose
prompt: "Analyze these visual references for design language extraction:

References: [from $ARGUMENTS — could be mood keywords, URLs, or description of screenshots in context]

For mood keywords: Use WebSearch to find exemplary products matching that aesthetic. Analyze 3-5 examples.
For URLs: Use WebFetch to analyze each site's visual approach.

Extract and return:
- Aesthetic direction (warm/cool, minimal/rich, playful/serious)
- Color approach (warm neutrals, bold accent, monochrome, etc.)
- Typography style (system fonts, geometric sans, humanist, serif, etc.)
- Spacing density (tight/comfortable/generous)
- Border radius approach (sharp, slightly rounded, very rounded, mixed)
- Shadow/depth approach (flat, subtle depth, strong elevation)
- Key component patterns (button style, card style, input style)
- Distinctive elements (what makes this aesthetic unique)
- Anti-patterns (what this aesthetic avoids)"
```

Wait for both agents to complete. If no arguments were provided, only Agent 1 runs.

---

## Step 3: Gather references (if needed)

If no references were provided as arguments, ask the user:

```
AskUserQuestion: "I've analyzed your current styling. To define your design language, I need visual references.

What should I work from?"
Options:
- Mood keywords — describe the aesthetic (e.g., "warm minimal", "dark professional")
- URLs — products whose visual style you admire
- Screenshots — you'll paste or describe reference images
- Current codebase only — define the language from what already exists
```

If the user provides references, launch Agent 2 from Step 2 to analyze them.

---

## Step 4: Synthesize design language

Combine the analyses into a complete design language document. The document MUST follow this structure:

### Required Sections

1. **Visual Philosophy** — 2-3 paragraphs establishing the aesthetic direction and guiding principles
2. **Base Grid** — the spatial grid unit (typically 4px or 8px), with the rule that all dimensions must be multiples
3. **Color System** — complete palette with:
   - Neutral scale (background/border/text colors)
   - Brand/accent colors
   - Semantic colors (success/warning/error)
   - Usage rules for each
4. **Typography** — font stack, type scale with sizes/weights/line-heights (line-heights snapped to base grid)
5. **Spacing** — key spacing values on the base grid, component heights
6. **Border Radius** — scale from sharp to round with usage guidelines
7. **Shadows & Elevation** — elevation levels with specific shadow values
8. **Motion & Animation** — timing, easing, and anti-patterns
9. **Component Patterns** — cards, buttons, inputs, badges, navigation
10. **Anti-Patterns** — explicit list of things to never do
11. **Tailwind Configuration** — exact values to add to the Tailwind config (or equivalent for other frameworks)

### Synthesis Rules

- Map reference aesthetics to **specific, implementable values** — hex codes, pixel sizes, shadow definitions
- When the reference aesthetic conflicts with current codebase patterns, prefer the reference (that's the target)
- When values don't land on the base grid, round to the nearest multiple (prefer rounding up)
- Include a "Current Patterns to Migrate" subsection listing what needs to change
- Be precise about button styles — extract shadow, gradient, radius, and state definitions

---

## Step 5: Exit Plan Mode

Write the complete design language document to the plan file as a preview. Then call `ExitPlanMode`. The user reviews the full specification before anything is written.

If the user requests changes, revise and exit plan mode again.

---

## Step 6: Write the design language

Upon approval, write the document:

1. Create `docs/design/` directory if it doesn't exist
2. Write `docs/design/DESIGN_LANGUAGE.md` with the approved content
3. If a Tailwind config exists, ask the user:
   ```
   AskUserQuestion: "Should I also update the Tailwind config with the new design tokens?"
   Options:
   - Yes — update tailwind.config.* with the colors, shadows, radius, and line-heights from the design language
   - No — I'll update it manually
   ```

---

## Step 7: Update CLAUDE.md

Check if the project has a CLAUDE.md. If so, add or update a "Design Language" section:

```markdown
## Design Language

**Aesthetic:** [1-line summary]. See `docs/design/DESIGN_LANGUAGE.md` for the complete visual specification.

**Core constraints when building UI:**
- [5-10 most critical rules from the design language]

**Anti-patterns:** [3-5 key things to never do]
```

Keep this section concise — CLAUDE.md is read every session, so brevity matters. The full spec lives in the design language document.

---

## Step 8: Report

```
Design language captured: docs/design/DESIGN_LANGUAGE.md

Aesthetic: [1-line summary]
Sections: philosophy, colors, typography, spacing, radius, shadows, motion, components, anti-patterns
Tailwind config: [updated / not updated]
CLAUDE.md: [updated with design constraints / no CLAUDE.md found]

This document is now discoverable by:
- /refine — loads visual constraints before iterating on UI
- /ship — follows design language when building UI features
- design-iterator — uses as baseline for iterative refinement
- /atomic-init — generates tokens aligned with this language

To update later: /design-language update
To iterate on UI: /refine [description]
```

---

## Edge Cases

**No styling framework found:** Generate a CSS-variable-based specification instead of Tailwind tokens. Note that the project may need a framework added.

**Multiple conflicting references:** Ask the user to prioritize. Present the conflicts and let them choose.

**Update mode with major aesthetic shift:** Warn the user that this will significantly change the design language. Present a diff of what's changing.

**No references and no existing styling:** Generate a minimal, opiniated starting point based on the project type (desktop app, web app, CLI tool, etc.) rather than leaving it blank. Note that this is a starting point and should be refined with references.

**CLAUDE.md already has a Design Language section:** Update it rather than duplicating.
