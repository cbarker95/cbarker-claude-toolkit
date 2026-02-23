# Atomic Design Audit

Run a comprehensive atomic design audit on the specified path with parallelized sub-agents.

## Arguments
- `$ARGUMENTS` - Optional path to audit (defaults to src/)

## Execution

### Phase 1: Parallel Analysis

Launch these agents **in parallel**:

1. **component-hierarchy-analyzer** — Scans all components, classifies into atomic levels, identifies violations
2. **token-auditor** — Extracts design tokens from CSS/SCSS, evaluates naming, finds hardcoded values

Wait for both to complete before proceeding.

### Phase 2: Scoring

3. **atomic-compliance-scorer** — Reads outputs from both analyzers, produces compliance score and recommendations

## Output Files

Create an `atomic-audit/` directory with:
- `component-hierarchy.json` — Component inventory with classifications
- `design-tokens.json` — Token extraction and analysis
- `compliance-score.md` — Overall score and detailed breakdown
- `recommendations.md` — Prioritized list of improvements

## Report Format

Generate a summary in this format:

```markdown
# Atomic Design Audit Report

**Path:** {audited_path}
**Date:** {date}

## Overall Score: XX/100

| Area | Score | Rating |
|------|-------|--------|
| Component Hierarchy | XX/25 | ⭐⭐⭐☆☆ |
| Token Architecture | XX/25 | ⭐⭐⭐⭐☆ |
| Composition Patterns | XX/25 | ⭐⭐☆☆☆ |
| Documentation | XX/25 | ⭐⭐⭐⭐⭐ |

## Key Findings

### Hierarchy Violations
- [List of components that violate import rules]

### Token Issues
- [List of hardcoded values and naming inconsistencies]

### Recommendations (Priority Order)
1. [High priority fix]
2. [Medium priority fix]
3. [Low priority fix]
```

## Usage

```
/atomic-audit                    # Audit src/
/atomic-audit src/components     # Audit specific path
```

## References

Read before running:
- `.claude/skills/atomic-design-system/references/evaluation-criteria.md`
- `.claude/skills/atomic-design-system/references/design-tokens.md`
