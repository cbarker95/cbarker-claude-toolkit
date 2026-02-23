---
allowed-tools: Read, Write, Edit, Glob, Grep, Task, AskUserQuestion, TodoWrite, WebSearch, WebFetch, EnterPlanMode, ExitPlanMode
description: Research and propose new features for the PRD based on market, codebase, and gap analysis
---

# Discover Command

Research a product area and propose concrete, buildable features for the PRD. You are a senior PM running a discovery session — opinionated, evidence-driven, and focused on what to build next.

## Usage

```
/discover [topic or problem area]
/discover                          # auto-detect gaps from PRD
```

---

## Enter Plan Mode

Call `EnterPlanMode` immediately. All research and proposal work (Steps 1-4) happens in plan mode. The user approves the proposals before any PRD changes are made.

---

## Step 1: Find the PRD

Locate the PRD. Check these paths in order:
- `docs/product/PRD.md`
- `docs/PRD.md`
- `PRD.md`
- Any `*.md` file containing a `## Feature Status` table

If no PRD is found, tell the user and suggest running `/prd` first. Stop.

Read the PRD. Parse the **Feature Status** table to understand:
- What features exist and their status (COMPLETE, IN PROGRESS, NOT STARTED, etc.)
- The product vision and problem statement
- Target users and success metrics
- Technical constraints

---

## Step 2: Determine research focus

**If `$ARGUMENTS` is provided:** Use it as the research focus. Examples:
- `/discover user onboarding` — research onboarding features
- `/discover "users drop off during signup"` — research solutions to a specific problem
- `/discover mobile experience` — research mobile-specific features

**If no arguments:** Analyze the PRD for gaps:
- Areas mentioned in the vision but missing from Feature Status
- User flows that lack supporting features
- Competitor-standard capabilities that are absent
- Logical next steps after COMPLETE features

Tell the user what you're focusing on before starting research.

---

## Step 3: Parallel research

Launch three sub-agents **in parallel** using the Task tool:

**Agent 1: Market & Competitive Research**
```
subagent_type: general-purpose
prompt: "Research the market landscape for [focus area]:
1. Use WebSearch to find current trends, competitor features, and market expectations
2. Identify what leading products in this space offer
3. Note emerging trends or shifts in user expectations
4. Find any relevant industry benchmarks or standards

Focus: [topic from Step 2]
Product context: [product name and vision from PRD]

Return structured findings:
- Market trends (3-5 key trends)
- Competitor features (what others offer that we don't)
- User expectations (what users in this space expect as baseline)
- Emerging opportunities (where the market is heading)"
```

**Agent 2: Codebase & Technical Analysis**
```
subagent_type: Explore
prompt: "Analyze the current codebase to understand technical capabilities and constraints:
1. What's currently built? (features, routes, APIs, components)
2. What architecture patterns are established?
3. What would be easy to add based on existing patterns?
4. What would require significant new infrastructure?
5. Are there any partially built features or stubs?

Focus area: [topic from Step 2]

Return structured findings:
- Current capabilities (what exists)
- Architecture patterns (what's easy to extend)
- Technical enablers (what the codebase makes cheap)
- Technical constraints (what would be hard or require new infra)
- Partial implementations (started but not finished)"
```

**Agent 3: PRD Gap Analysis**
```
subagent_type: Explore
prompt: "Analyze the PRD at [path] for gaps and opportunities:
1. Read the full PRD including Feature Status table
2. Compare the product vision against current features — what's missing?
3. Look at user flows — are there gaps in the journey?
4. Check dependencies — are there features that would unlock others?
5. Look at COMPLETE features — what logical next steps do they enable?

Return structured findings:
- Vision-feature gaps (vision promises things not in Feature Status)
- User flow gaps (journeys that dead-end or lack support)
- Dependency opportunities (features that would unblock others)
- Natural extensions (logical next steps from what's built)
- Underserved areas (parts of the product with few features)"
```

Wait for all three agents to complete.

---

## Step 4: Synthesize and propose

Read the feature-discovery reference for frameworks:
- Read [feature-discovery.md](./skills/product-strategy/references/feature-discovery.md)

Synthesize the three research outputs into feature proposals. For each potential feature:

1. **Score it:** Impact (1-5) x Frequency (1-5) x Confidence (1-5)
2. **Filter:** Drop anything below 27 (3x3x3)
3. **Assess feasibility:** Easy / Medium / Hard based on codebase analysis
4. **Check dependencies:** Does it require other features first?
5. **Assign priority:** P0 / P1 / P2 using the decision tree

Produce 3-7 proposals. Each proposal needs:
- Feature name (concise, action-oriented)
- Priority (P0/P1/P2) with rationale
- Description (1-2 sentences)
- Evidence from research
- Dependencies
- PRD table row format

---

## Exit Plan Mode

Write the feature proposals to the plan file, then call `ExitPlanMode`. The user reviews and approves the proposals before any PRD changes are made. If the user rejects or requests changes, revise the proposals and exit plan mode again.

---

## Step 5: Present proposals for approval

Present all proposals to the user, then use AskUserQuestion with multi-select:

```
Based on market research, codebase analysis, and PRD gaps, here are my feature proposals:

### 1. [Feature Name] — P[X]
[What it does. Why it matters. Key evidence.]

### 2. [Feature Name] — P[X]
[What it does. Why it matters. Key evidence.]

### 3. [Feature Name] — P[X]
[What it does. Why it matters. Key evidence.]

[... up to 7]
```

```
AskUserQuestion (multiSelect: true):
"Which features should I add to the PRD?"
Options:
- [Feature 1 name] (P[X])
- [Feature 2 name] (P[X])
- [Feature 3 name] (P[X])
- [... up to 4 options per question, use multiple questions if needed]
```

If the user selects none, acknowledge and stop. If they want modifications, adjust and re-present.

---

## Step 6: Update the PRD

For each approved feature, add a row to the Feature Status table in the PRD:

```markdown
| [Feature Name] | P[X] | NOT STARTED | [Brief description from proposal] |
```

Add new rows at the appropriate position — group by priority (P0s first, then P1s, then P2s).

If the Feature Status table doesn't exist in the PRD, create the section:

```markdown
## Feature Status

<!-- Status: NOT STARTED | IN PROGRESS | COMPLETE | BLOCKED | DEFERRED -->
<!-- Priority: P0 (MVP) | P1 (post-MVP) | P2 (future) | -- (deferred) -->
<!-- /ship reads this table to pick the next feature and updates it with progress -->

| Feature | Priority | Status | Notes |
|---------|----------|--------|-------|
[existing rows if any]
[new approved features]
```

---

## Step 7: Report

```
Discovery complete.

Research focus: [topic]

Features added to PRD:
- [Feature 1] (P[X]) — [1-line description]
- [Feature 2] (P[X]) — [1-line description]

Features not selected:
- [Feature 3] — [brief reason if user gave one]

PRD updated: [count] new features added to Feature Status table.

Next steps:
- Run `/ship` to start building the highest-priority new feature
- Run `/discover [different topic]` to explore another area
- Run `/competitive` for deeper competitive analysis
```

---

## Edge Cases

**No PRD found:** Tell the user. Suggest `/prd`. Stop.

**No arguments and PRD has no gaps:** Tell the user the PRD looks comprehensive. Ask if there's a specific area they want to explore or if they want to look beyond current scope.

**Research returns thin results:** Be honest about evidence quality. Lower confidence scores accordingly. Propose fewer features rather than padding with weak ones.

**Proposals conflict with existing features:** Flag the conflict explicitly. Explain whether the proposal replaces, extends, or competes with the existing feature. Let the user decide.

**Feature requires prerequisite work:** Note the dependency. If the prerequisite doesn't exist in the PRD, propose it as a separate feature (likely P0 or P1).
