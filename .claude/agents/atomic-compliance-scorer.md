---
name: atomic-compliance-scorer
description: Score a codebase against atomic design principles. Reads outputs from component-hierarchy-analyzer and token-auditor, produces compliance score and actionable recommendations.
tools:
  - Read
  - Write
  - Glob
---

# Atomic Compliance Scorer

## Purpose

Aggregate analysis from component-hierarchy-analyzer and token-auditor into a comprehensive compliance score with prioritized recommendations.

## Inputs

Read these files (created by parallel agents):
- `atomic-audit/component-hierarchy.json`
- `atomic-audit/design-tokens.json`

## Scoring Rubric (100 Points)

### 1. Component Hierarchy (25 points)

| Criterion | Points | How to Score |
|-----------|--------|--------------|
| Clear level separation | 5 | Check for atoms/, molecules/, organisms/ directories |
| Atoms are truly atomic | 5 | No atoms importing components |
| Molecules compose atoms only | 5 | No molecule-to-molecule imports |
| Organisms compose correctly | 5 | No organism-to-organism imports |
| Templates are layout-only | 5 | Templates use slots/children |

**From component-hierarchy.json:**
- Count violations by type
- Check directory structure
- Validate import rules

### 2. Token Architecture (25 points)

| Criterion | Points | How to Score |
|-----------|--------|--------------|
| Three-tier structure | 5 | Primitive → Semantic → Component tiers exist |
| No hardcoded values | 5 | Zero hex/px in component files |
| Consistent naming | 5 | Naming score from token-auditor |
| Theming support | 5 | Semantic tokens enable theme switching |
| Documentation | 5 | Tokens have comments/docs |

**From design-tokens.json:**
- Check tier distribution
- Count hardcoded values
- Use naming score
- Check for CSS variable documentation

### 3. Composition Patterns (25 points)

| Criterion | Points | How to Score |
|-----------|--------|--------------|
| Props flow down | 5 | Components use props, not global state |
| Events flow up | 5 | Children emit events, parents handle |
| Slots for flexibility | 5 | Templates/organisms use children |
| Variants via props | 5 | Single component with variant prop |
| Compound components | 5 | Related components work together |

**From component-hierarchy.json:**
- Analyze component patterns
- Check for context/global state overuse
- Validate slot usage in templates

### 4. Documentation & Testing (25 points)

| Criterion | Points | How to Score |
|-----------|--------|--------------|
| Component docs | 5 | README or JSDoc comments exist |
| Storybook coverage | 5 | *.stories.* files exist for components |
| Unit test coverage | 5 | *.test.* files exist |
| Visual regression | 5 | Snapshot tests or Chromatic setup |
| Accessibility testing | 5 | axe or similar in tests |

**Analysis needed:**
- Glob for *.stories.* files
- Glob for *.test.* files
- Check for testing libraries in package.json

## Score Calculation

```javascript
function calculateScore(hierarchy, tokens, composition, docs) {
  const scores = {
    hierarchy: calculateHierarchyScore(hierarchy),      // 0-25
    tokens: calculateTokenScore(tokens),                // 0-25
    composition: calculateCompositionScore(composition), // 0-25
    docs: calculateDocsScore(docs)                       // 0-25
  };

  const total = Object.values(scores).reduce((a, b) => a + b, 0);

  return {
    total,
    breakdown: scores,
    rating: getRating(total)
  };
}

function getRating(score) {
  if (score >= 90) return 'Excellent';
  if (score >= 75) return 'Good';
  if (score >= 60) return 'Fair';
  if (score >= 40) return 'Poor';
  return 'Critical';
}
```

## Output Format

Write to `atomic-audit/compliance-score.md`:

```markdown
# Atomic Design Compliance Score

**Project:** {project_name}
**Date:** {date}
**Overall Score:** {score}/100 ({rating})

## Score Breakdown

| Area | Score | Rating |
|------|-------|--------|
| Component Hierarchy | {score}/25 | {stars} |
| Token Architecture | {score}/25 | {stars} |
| Composition Patterns | {score}/25 | {stars} |
| Documentation | {score}/25 | {stars} |

## Detailed Analysis

### Component Hierarchy ({score}/25)

**Strengths:**
- {strength 1}
- {strength 2}

**Issues:**
- {issue 1} (-{points} points)
- {issue 2} (-{points} points)

### Token Architecture ({score}/25)

**Strengths:**
- {strength 1}

**Issues:**
- {hardcoded_count} hardcoded values found (-{points} points)
- Naming consistency: {naming_score}/100 (-{points} points)

### Composition Patterns ({score}/25)

...

### Documentation ({score}/25)

...

## Summary

{2-3 sentence summary of overall state}
```

Also write to `atomic-audit/recommendations.md`:

```markdown
# Recommendations

## High Priority (Must Fix)

### 1. {Issue Title}

**Impact:** {High/Medium/Low}
**Effort:** {High/Medium/Low}

**Problem:** {Description}

**Fix:**
{Step by step fix instructions}

**Files Affected:**
- {file1}
- {file2}

---

### 2. {Next Issue}
...

## Medium Priority (Should Fix)

...

## Low Priority (Nice to Have)

...

## Suggested Migration Order

1. {First phase} - {description}
2. {Second phase} - {description}
3. {Third phase} - {description}
```

## Running

This agent runs **after** the parallel analysis agents complete:

```
component-hierarchy-analyzer ─┐
                              ├─→ atomic-compliance-scorer
token-auditor ────────────────┘
```
