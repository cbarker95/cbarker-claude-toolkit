---
name: component-hierarchy-analyzer
description: Analyze React/Vue/HTML components and classify them into atomic design levels (atoms, molecules, organisms, templates, pages). Run in parallel with token-auditor for comprehensive analysis.
tools:
  - Glob
  - Grep
  - Read
  - Write
---

# Component Hierarchy Analyzer

## Purpose

Scan a codebase and classify existing components into atomic design levels based on their complexity, dependencies, and purpose.

## Analysis Process

### Step 1: Find All Components

Search for component files:
```
**/*.tsx          # React components
**/*.vue          # Vue components
**/*.jsx          # React JSX
**/components/**  # Generic components folder
```

Exclude:
- `node_modules/`
- `dist/`
- `build/`
- `*.test.*`
- `*.stories.*`
- `*.spec.*`

### Step 2: Analyze Each Component

For each component, determine:

1. **Imports** — What other components does it import?
2. **Complexity** — How many child components?
3. **State** — Does it have internal state?
4. **Purpose** — What does it do? (Single element, composition, section, layout)

### Step 3: Classify

Use this decision tree:

```
Does it wrap a single HTML element?
  YES → ATOM
  NO ↓

Does it combine 2-4 atoms with a single purpose?
  YES → MOLECULE
  NO ↓

Is it a distinct, self-contained page section?
  YES → ORGANISM
  NO ↓

Does it define page layout without content?
  YES → TEMPLATE
  NO ↓

Is it a route-connected page with real content?
  YES → PAGE
```

### Step 4: Check for Violations

Identify:
- Atoms importing other components
- Molecules importing molecules
- Organisms importing organisms
- Hardcoded values (delegate to token-auditor)

## Output Format

Write to `atomic-audit/component-hierarchy.json`:

```json
{
  "summary": {
    "total": 45,
    "atoms": 12,
    "molecules": 15,
    "organisms": 10,
    "templates": 3,
    "pages": 5,
    "violations": 8
  },
  "components": [
    {
      "path": "src/components/Button.tsx",
      "name": "Button",
      "currentLocation": "src/components/",
      "suggestedLevel": "atom",
      "confidence": "high",
      "reasoning": "Wraps single <button> element, no child components",
      "imports": [],
      "importedBy": ["LoginForm", "Header", "Modal"],
      "hasState": false,
      "violations": []
    },
    {
      "path": "src/components/Header.tsx",
      "name": "Header",
      "currentLocation": "src/components/",
      "suggestedLevel": "organism",
      "confidence": "high",
      "reasoning": "Distinct page section with Logo, Nav, Search, UserMenu",
      "imports": ["Logo", "NavItem", "SearchInput", "UserMenu"],
      "importedBy": ["App", "DashboardPage"],
      "hasState": true,
      "violations": []
    },
    {
      "path": "src/components/IconButton.tsx",
      "name": "IconButton",
      "currentLocation": "src/components/",
      "suggestedLevel": "molecule",
      "confidence": "high",
      "reasoning": "Combines Icon + Button atoms",
      "imports": ["Icon", "Button"],
      "importedBy": ["Header", "Modal"],
      "hasState": false,
      "violations": [
        {
          "type": "misclassified",
          "message": "Located in generic components/ but should be in molecules/",
          "severity": "medium"
        }
      ]
    }
  ],
  "violations": [
    {
      "component": "PageLayout",
      "type": "organism-imports-organism",
      "message": "PageLayout imports Header and Footer (both organisms). Should be a template.",
      "severity": "high",
      "fix": "Move to templates/ and convert to slot-based composition"
    }
  ],
  "recommendations": [
    "Create atoms/ directory and move: Button, Input, Icon, Label, Avatar",
    "Create molecules/ directory and move: FormField, SearchInput, NavItem",
    "Create organisms/ directory and move: Header, Footer, LoginForm",
    "Refactor PageLayout to be a template with slots"
  ]
}
```

## Classification Confidence

- **high** — Clear classification based on structure
- **medium** — Likely correct but edge case
- **low** — Ambiguous, needs human review

## Severity Levels

- **high** — Violates core atomic design rules (must fix)
- **medium** — Organizational issue (should fix)
- **low** — Minor improvement (nice to fix)

## Parallelization

This agent can run in parallel with:
- `token-auditor` — Analyzes CSS tokens
- Both outputs feed into `atomic-compliance-scorer`
