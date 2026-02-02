---
allowed-tools: Bash, Read, WebFetch, Task
argument-hint: <screenshot-path> <figma-url>
description: Compare a screenshot to a Figma design
---

# Design Compare Command

Compare a captured screenshot against its Figma design source.

## Arguments

- `$1` - Path to screenshot or URL to capture
- `$2` - Figma file/frame URL (optional if linked in project)

## Analysis Points

1. **Layout Differences**: Spacing, alignment, positioning
2. **Typography**: Font sizes, weights, line heights
3. **Colors**: Color accuracy, contrast ratios
4. **Components**: Design system component usage
5. **Responsive**: Breakpoint adherence

## Output

Generate a visual diff report highlighting:
- Pixel-level differences
- Semantic differences (intentional vs bugs)
- Severity ratings for each issue
