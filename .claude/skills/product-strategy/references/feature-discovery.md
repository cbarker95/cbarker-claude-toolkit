# Feature Discovery

## Purpose

Feature discovery is the systematic process of identifying what to build next. It bridges the gap between "we have a product direction" and "we have specific features in the PRD." Good discovery is research-driven, opinionated, and produces proposals that are concrete enough to build.

---

## Opportunity Scoring

Evaluate each potential feature across three dimensions:

```
Opportunity Score = Impact x Frequency x Confidence

Impact:     How much does this solve a real user problem? (1-5)
Frequency:  How often do users encounter this problem? (1-5)
Confidence: How strong is the evidence? (1-5)
```

### Scoring Guide

| Score | Impact | Frequency | Confidence |
|-------|--------|-----------|------------|
| 5 | Eliminates a critical blocker | Daily | Multiple data sources confirm |
| 4 | Significantly reduces friction | Weekly | Strong signal from research |
| 3 | Noticeable improvement | Monthly | Moderate evidence |
| 2 | Minor convenience | Occasionally | Anecdotal / inferred |
| 1 | Marginal benefit | Rarely | Gut feeling |

**Threshold:** Features scoring below 27 (3x3x3) need stronger evidence before proposing.

---

## Gap Analysis Framework

Identify features by mapping three sources of signal:

```
┌─────────────────────┐
│  What competitors    │
│  have that we don't  │──┐
└─────────────────────┘  │
                         │    ┌─────────────────────┐
┌─────────────────────┐  ├──▶│  FEATURE             │
│  What users need     │──┤    │  OPPORTUNITIES       │
│  but can't do today  │  │    └─────────────────────┘
└─────────────────────┘  │
                         │
┌─────────────────────┐  │
│  What our codebase   │──┘
│  enables cheaply     │
└─────────────────────┘
```

### Three-Source Analysis

**1. Competitive gaps** (market pull)
- What do competitors offer that we don't?
- Which of those actually matter to our users?
- Where are competitors weak that we could leapfrog?

**2. User needs** (demand pull)
- What problems appear in support tickets, feedback, or research?
- What workarounds are users building?
- What adjacent jobs are users hiring other tools for?

**3. Technical enablers** (supply push)
- What does our architecture make easy to add?
- What existing code could be exposed as a feature?
- What infrastructure investments would unlock multiple features?

**The sweet spot:** Features that appear in 2+ sources are strong candidates. Features in all 3 are high-conviction.

---

## User Pain Point Mapping

Connect observed problems to solution opportunities:

```markdown
| Pain Point | Evidence | Frequency | Current Workaround | Feature Opportunity |
|------------|----------|-----------|-------------------|-------------------|
| [Problem] | [Source] | [How often] | [What users do now] | [What we could build] |
```

### Evidence Sources (Strongest to Weakest)

1. **Observed behavior** — Analytics showing users struggling or dropping off
2. **Direct feedback** — Users explicitly requesting or complaining
3. **Support patterns** — Recurring support tickets about the same issue
4. **Competitive signals** — Competitors building for this need
5. **Inference** — Logical deduction from product usage patterns

### What Makes a Strong Pain Point

- **Frequent:** Users encounter it regularly, not once
- **Severe:** It blocks progress or causes significant frustration
- **Widespread:** Affects a meaningful segment, not edge cases
- **Currently unserved:** No good workaround exists

---

## Technical Feasibility Lens

Before proposing a feature, assess what the codebase can support:

| Factor | Assessment | Impact on Proposal |
|--------|------------|-------------------|
| **Architecture fit** | Does the current architecture support this naturally? | If no, note as dependency |
| **Data availability** | Do we have the data this feature needs? | If no, may need data collection first |
| **Existing patterns** | Can we follow established patterns? | If yes, lower effort estimate |
| **Integration points** | What existing code does this touch? | More touch points = higher risk |
| **Infrastructure** | Do we need new services, databases, or APIs? | New infra = higher effort, separate initiative |

### Feasibility Rating

- **Easy** — Follows existing patterns, touches few files, no new dependencies
- **Medium** — Requires new patterns or moderate refactoring, manageable scope
- **Hard** — Needs new infrastructure, significant refactoring, or architectural changes
- **Blocked** — Requires prerequisite work that doesn't exist yet

**Rule:** Never propose a "Hard" feature without also proposing the prerequisite work as a separate P0/P1 feature.

---

## Feature Proposal Template

Each proposal should follow this structure:

```markdown
### [Feature Name]

**Priority:** P0 / P1 / P2
**Feasibility:** Easy / Medium / Hard

**What:** [1-2 sentences describing the feature]

**Why:** [Evidence from research — what problem it solves, for whom]

**Evidence:**
- [Source 1: competitive, user feedback, analytics, etc.]
- [Source 2]

**Dependencies:** [Other features that must exist first, or "None"]

**PRD Row:**
| [Feature Name] | [Priority] | NOT STARTED | [Brief description from "What" above] |
```

---

## Prioritization Criteria

Assign P0 / P1 / P2 based on:

| Priority | Criteria | Examples |
|----------|----------|---------|
| **P0** | Product doesn't fulfill its core promise without this. High impact, high frequency, strong evidence. | Core workflows, critical integrations, blocking bugs |
| **P1** | Significant value-add for existing users. Clear demand signal. Medium-high impact. | Feature extensions, quality-of-life improvements, commonly requested items |
| **P2** | Nice-to-have. Lower frequency or niche audience. Speculative or forward-looking. | Advanced features, optimizations, experimental capabilities |

### Priority Decision Tree

```
Is the product fundamentally incomplete without this?
  YES → P0
  NO  → Do users actively request or struggle without it?
           YES → Is it frequent (weekly+) and widespread?
                    YES → P1
                    NO  → P2
           NO  → Is there strong competitive or market pressure?
                    YES → P1
                    NO  → P2
```

---

## Anti-Patterns

### 1. Feature Factory
**Problem:** Proposing features because you can, not because users need them.
**Fix:** Every proposal must cite evidence. "We could build this" is not a reason.

### 2. Solution-First Thinking
**Problem:** Starting with "let's add X" instead of "users have problem Y."
**Fix:** State the problem before the solution. If you can't articulate the problem, don't propose the feature.

### 3. Feature Parity Trap
**Problem:** Copying competitors feature-for-feature without understanding why.
**Fix:** Ask "do OUR users need this?" not "does the competitor have this?" Differentiation comes from solving problems differently, not from matching feature checklists.

### 4. Kitchen Sink Proposals
**Problem:** Proposing 20 features hoping some stick.
**Fix:** Propose 3-7 features max. A senior PM's job is to say no. Fewer, better proposals signal confidence and judgment.

### 5. Missing Feasibility Check
**Problem:** Proposing features that are architecturally impossible or would require months of prerequisite work, without acknowledging it.
**Fix:** Always assess technical feasibility. If a feature is "Hard," propose the prerequisite work as a separate item.

---

## Discovery Session Checklist

Before proposing features, ensure you've:

- [ ] Read the existing PRD and understood the product vision
- [ ] Identified what's already built vs planned vs missing
- [ ] Researched market trends and competitor offerings
- [ ] Analyzed the codebase for technical constraints and enablers
- [ ] Scored opportunities using the Impact x Frequency x Confidence framework
- [ ] Filtered to 3-7 high-conviction proposals
- [ ] Checked technical feasibility for each proposal
- [ ] Formatted proposals for the PRD Feature Status table
