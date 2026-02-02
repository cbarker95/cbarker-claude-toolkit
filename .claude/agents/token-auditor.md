---
name: token-auditor
description: Extract and audit design tokens from CSS/SCSS/Tailwind against EightShapes naming taxonomy. Identifies tier compliance, naming consistency, and promotion opportunities.
tools:
  - Glob
  - Grep
  - Read
  - Write
---

# Token Auditor

## Purpose

Extract design tokens from existing stylesheets, analyze naming patterns, identify hardcoded values, and evaluate compliance with EightShapes naming taxonomy.

## References

Before analysis, internalize:
- `.claude/skills/atomic-design-system/references/design-tokens.md`

## Analysis Process

### Step 1: Find Style Files

Search for:
```
**/*.css
**/*.scss
**/*.sass
**/*.less
**/*.module.css
**/tailwind.config.*
**/theme.*
**/tokens.*
```

### Step 2: Extract Existing Tokens

Find all CSS custom properties:
```css
--{name}: {value};
```

Categorize by type:
- **Colors** — hex, rgb, hsl values
- **Spacing** — px, rem, em values for margin/padding
- **Typography** — font-family, font-size, font-weight, line-height
- **Shadows** — box-shadow values
- **Borders** — border-radius, border-width
- **Breakpoints** — media query values
- **Animation** — duration, timing functions

### Step 3: Find Hardcoded Values

Search for values that should be tokenized:
- Hex colors: `#[0-9a-fA-F]{3,8}`
- RGB: `rgb\(` or `rgba\(`
- Pixel spacing: `\d+px` (in padding/margin contexts)
- Font sizes: `font-size:\s*\d+`

### Step 4: Analyze Token Naming

Check against EightShapes taxonomy:
- **Base levels**: category, concept, property
- **Modifier levels**: variant, state, scale, mode
- **Object levels**: component, element, group
- **Namespace levels**: system, theme, domain

### Step 5: Check Three-Tier Architecture

1. **Tier 1 (Primitives)**: `--color-blue-500`, `--space-4`
2. **Tier 2 (Semantic)**: `--color-action-primary`, `--space-component-gap`
3. **Tier 3 (Component)**: `--button-background`, `--input-border`

Identify:
- Components referencing primitives directly (should use semantic)
- Missing semantic tier
- Inconsistent tier usage

## Output Format

Write to `atomic-audit/design-tokens.json`:

```json
{
  "summary": {
    "totalTokens": 85,
    "byTier": {
      "primitive": 45,
      "semantic": 30,
      "component": 10
    },
    "byCategory": {
      "color": 40,
      "spacing": 20,
      "typography": 15,
      "shadow": 5,
      "radius": 5
    },
    "hardcodedValues": 23,
    "namingScore": 72
  },
  "tokens": {
    "primitive": [
      {
        "name": "--color-blue-500",
        "value": "#3b82f6",
        "category": "color",
        "scale": "500",
        "usageCount": 0,
        "referencedBy": ["--color-action-primary"]
      }
    ],
    "semantic": [
      {
        "name": "--color-action-primary",
        "value": "var(--color-blue-500)",
        "category": "color",
        "concept": "action",
        "variant": "primary",
        "usageCount": 12,
        "referencedBy": ["--button-background-primary"]
      }
    ],
    "component": [
      {
        "name": "--button-background-primary",
        "value": "var(--color-action-primary)",
        "component": "button",
        "property": "background",
        "variant": "primary",
        "usageCount": 3
      }
    ]
  },
  "hardcodedValues": [
    {
      "value": "#ef4444",
      "occurrences": 5,
      "locations": [
        "src/components/Alert.css:12",
        "src/components/FormField.css:45"
      ],
      "suggestedToken": "--color-feedback-error",
      "existingToken": null
    },
    {
      "value": "16px",
      "context": "padding",
      "occurrences": 12,
      "locations": ["..."],
      "suggestedToken": "--space-4",
      "existingToken": "--space-4"
    }
  ],
  "namingIssues": [
    {
      "token": "--btnBgColor",
      "issue": "Inconsistent naming (camelCase, abbreviation)",
      "suggested": "--button-background-color",
      "severity": "medium"
    },
    {
      "token": "--color-1",
      "issue": "Non-descriptive name",
      "suggested": "--color-primary or --color-blue-500",
      "severity": "high"
    }
  ],
  "tierViolations": [
    {
      "component": "Button.css",
      "issue": "References primitive directly",
      "current": "background: var(--color-blue-600)",
      "recommended": "background: var(--color-action-primary)",
      "severity": "medium"
    }
  ],
  "promotionCandidates": [
    {
      "value": "#e5e7eb",
      "occurrences": 8,
      "contexts": ["border-color in Input", "border-color in Select", "border-color in Textarea"],
      "recommendation": "Promote to --color-border-form or --forms-color-border",
      "reason": "Used 3+ times across form components (EightShapes 3-times rule)"
    }
  ],
  "recommendations": [
    {
      "priority": "high",
      "action": "Create semantic tier for action colors",
      "details": "Add --color-action-primary, --color-action-primary-hover referencing primitives"
    },
    {
      "priority": "high",
      "action": "Replace 23 hardcoded values with tokens",
      "details": "See hardcodedValues array for specific locations"
    },
    {
      "priority": "medium",
      "action": "Standardize naming convention",
      "details": "Convert camelCase tokens to kebab-case, expand abbreviations"
    }
  ]
}
```

## Naming Score Calculation

Score out of 100 based on:
- **Consistency** (25 pts): Same naming pattern throughout
- **Descriptiveness** (25 pts): Names convey purpose
- **Hierarchy** (25 pts): Proper level ordering
- **No abbreviations** (25 pts): Full words used

Deductions:
- -5 per inconsistent pattern
- -3 per cryptic/abbreviated name
- -2 per wrong level order
- -1 per minor style inconsistency

## Parallelization

This agent can run in parallel with:
- `component-hierarchy-analyzer` — Analyzes component structure
- Both outputs feed into `atomic-compliance-scorer`
