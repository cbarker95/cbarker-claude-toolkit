# Evaluation Criteria for Atomic Design Systems

<overview>
This reference provides a comprehensive scoring rubric for evaluating atomic design
system compliance. Use this to audit existing codebases or validate new implementations.
</overview>

<scoring_rubric>
## Scoring Rubric (100 Points Total)

### 1. Component Hierarchy (25 points)

| Criterion | Points | Description |
|-----------|--------|-------------|
| Clear level separation | 5 | Distinct atoms/, molecules/, organisms/, templates/ directories |
| Atoms are truly atomic | 5 | Atoms don't import other components |
| Molecules compose atoms only | 5 | Molecules only import from atoms/ |
| Organisms compose molecules/atoms | 5 | No organism-to-organism imports |
| Templates are layout-only | 5 | Templates use slots, no business logic |

**Scoring Guide:**
- 5/5: All components follow the rule
- 3-4: Most components follow, minor violations
- 1-2: Some attempt at hierarchy, many violations
- 0: No clear hierarchy

### 2. Token Architecture (25 points)

| Criterion | Points | Description |
|-----------|--------|-------------|
| Three-tier structure | 5 | Global → Semantic → Component tokens |
| No hardcoded values | 5 | Zero hex/px values in component CSS |
| Consistent naming | 5 | EightShapes taxonomy or equivalent |
| Theming support | 5 | Tokens enable theme switching |
| Documentation | 5 | All tokens documented with purpose |

**Scoring Guide:**
- 5/5: Fully implemented
- 3-4: Mostly implemented, minor gaps
- 1-2: Partially implemented
- 0: Not implemented

### 3. Composition Patterns (25 points)

| Criterion | Points | Description |
|-----------|--------|-------------|
| Props flow down | 5 | Data passed via props, not context/global |
| Events flow up | 5 | Child components emit events, parents handle |
| Slots for flexibility | 5 | Templates/organisms use children/slots |
| Variants via props | 5 | Single component with variant prop, not multiple |
| Compound components | 5 | Related components work together cleanly |

**Scoring Guide:**
- 5/5: Pattern consistently applied
- 3-4: Pattern mostly applied
- 1-2: Pattern sometimes applied
- 0: Pattern not used

### 4. Documentation & Testing (25 points)

| Criterion | Points | Description |
|-----------|--------|-------------|
| Component docs | 5 | Props, usage examples, accessibility notes |
| Storybook coverage | 5 | All variants/states have stories |
| Unit test coverage | 5 | Atoms/molecules have unit tests |
| Visual regression | 5 | Snapshot or Chromatic testing |
| Accessibility testing | 5 | axe or equivalent automated tests |

**Scoring Guide:**
- 5/5: 90%+ coverage
- 3-4: 70-89% coverage
- 1-2: 40-69% coverage
- 0: <40% coverage
</scoring_rubric>

<detailed_checklist>
## Detailed Evaluation Checklist

### Component Hierarchy Checklist

#### Atoms
- [ ] Each atom wraps a single HTML element or token concept
- [ ] Atoms have no child component imports
- [ ] Atoms are stateless (controlled via props)
- [ ] Atoms use design tokens for all styling
- [ ] Atoms have comprehensive prop types

**Common Violations:**
```typescript
// ❌ Atom importing another atom
// atoms/IconButton.tsx
import { Icon } from './Icon'; // This makes it a molecule!

// ❌ Atom with internal state
// atoms/Input.tsx
const [value, setValue] = useState(''); // Should be controlled

// ❌ Atom with hardcoded values
// atoms/Button.tsx
background: '#3b82f6'; // Should use token
```

#### Molecules
- [ ] Each molecule combines 2-4 atoms
- [ ] Molecules have a single, clear purpose
- [ ] Molecules only import from atoms/
- [ ] Molecules may have minimal UI state (dropdowns, focus)
- [ ] Molecules are reusable in multiple organisms

**Common Violations:**
```typescript
// ❌ Molecule importing molecule
// molecules/SearchForm.tsx
import { FormField } from '../FormField'; // Same level!

// ❌ Molecule with too many atoms (probably an organism)
// molecules/ProductCard.tsx
import { Image, Title, Price, Rating, Button, Badge, Icon }; // Too complex
```

#### Organisms
- [ ] Organisms represent distinct page sections
- [ ] Organisms can manage complex state
- [ ] Organisms only import from molecules/ and atoms/
- [ ] Organisms don't import other organisms
- [ ] Organisms are self-contained (could be removed/replaced)

**Common Violations:**
```typescript
// ❌ Organism importing organism
// organisms/PageLayout.tsx
import { Header } from './Header';
import { Footer } from './Footer'; // This is a template pattern!
```

#### Templates
- [ ] Templates define layout structure only
- [ ] Templates use slots/children for content
- [ ] Templates have no business logic
- [ ] Templates can import organisms, molecules, atoms
- [ ] Templates are reusable across multiple pages

#### Pages
- [ ] Pages use templates for layout
- [ ] Pages handle data fetching
- [ ] Pages connect to routing
- [ ] Pages pass real content to templates

### Token Architecture Checklist

#### Structure
- [ ] tokens/ directory exists
- [ ] Primitive tokens defined (color-blue-500)
- [ ] Semantic tokens reference primitives (color-action-primary)
- [ ] Component tokens reference semantic (button-background)
- [ ] All tokens in CSS custom properties format

#### Naming
- [ ] Consistent naming convention (kebab-case)
- [ ] Category-concept-property-variant-state order
- [ ] No cryptic abbreviations
- [ ] Scales are predictable (4, 8, 16 or sm, md, lg)

#### Usage
- [ ] No hex colors in component files
- [ ] No px values for spacing in components
- [ ] All components reference tokens
- [ ] Tokens support dark mode / theming

### Composition Checklist

#### Props Pattern
- [ ] Props are typed with TypeScript
- [ ] Props have sensible defaults
- [ ] Boolean props use is*/has* prefix
- [ ] Event props use on* prefix
- [ ] Ref forwarding where appropriate

#### State Pattern
- [ ] Atoms are stateless
- [ ] Molecules have minimal UI state only
- [ ] Organisms manage section state
- [ ] Pages manage application state
- [ ] No prop drilling (use composition instead)

### Documentation Checklist

#### Component Docs
- [ ] Description of purpose
- [ ] All props documented
- [ ] Usage examples provided
- [ ] Accessibility notes included
- [ ] Related components linked

#### Storybook
- [ ] Every component has stories
- [ ] All variants covered
- [ ] All states covered (disabled, loading, error)
- [ ] Interactive controls work
- [ ] Documentation tab filled out

#### Tests
- [ ] Unit tests for all atoms
- [ ] Integration tests for molecules
- [ ] Behavior tests for organisms
- [ ] Accessibility tests (jest-axe)
- [ ] Visual regression snapshots
</detailed_checklist>

<scoring_matrix>
## Quick Scoring Matrix

Use this matrix for rapid assessment:

| Area | 0 (None) | 1 (Poor) | 2 (Fair) | 3 (Good) | 4 (Great) | 5 (Excellent) |
|------|----------|----------|----------|----------|-----------|---------------|
| **Hierarchy** | No structure | Some folders | Mixed levels | Clear levels | Proper imports | Perfect hierarchy |
| **Tokens** | Hardcoded | Some tokens | Inconsistent | Three-tier | Well-named | Fully themed |
| **Composition** | Monolithic | Some split | Props work | Events work | Slots used | Compound patterns |
| **Docs** | None | READMEs | Some stories | Full stories | Tests exist | 90%+ coverage |

### Interpretation

| Total Score | Rating | Recommendation |
|-------------|--------|----------------|
| 90-100 | Excellent | Maintain and iterate |
| 75-89 | Good | Address minor gaps |
| 60-74 | Fair | Focused improvement needed |
| 40-59 | Poor | Significant refactoring needed |
| 0-39 | Critical | Consider full migration |
</scoring_matrix>

<audit_report_template>
## Audit Report Template

```markdown
# Atomic Design System Audit Report

**Project:** [Project Name]
**Date:** [Date]
**Auditor:** [Name/Agent]

## Executive Summary

**Overall Score:** XX/100 (Rating)

| Area | Score | Rating |
|------|-------|--------|
| Component Hierarchy | XX/25 | ⭐⭐⭐☆☆ |
| Token Architecture | XX/25 | ⭐⭐⭐⭐☆ |
| Composition Patterns | XX/25 | ⭐⭐☆☆☆ |
| Documentation | XX/25 | ⭐⭐⭐⭐⭐ |

## Component Inventory

### Atoms (X components)
| Component | Status | Issues |
|-----------|--------|--------|
| Button | ✅ Compliant | — |
| Input | ⚠️ Partial | Has internal state |
| Icon | ❌ Violation | Imports other atoms |

### Molecules (X components)
| Component | Status | Issues |
|-----------|--------|--------|
| FormField | ✅ Compliant | — |
| SearchInput | ⚠️ Partial | Too many atoms (5) |

### Organisms (X components)
| Component | Status | Issues |
|-----------|--------|--------|
| Header | ❌ Violation | Imports Footer organism |
| LoginForm | ✅ Compliant | — |

## Token Analysis

### Current State
- Total tokens defined: XX
- Primitive tokens: XX
- Semantic tokens: XX
- Component tokens: XX
- Hardcoded values found: XX occurrences

### Issues
1. [Issue description]
2. [Issue description]

## Recommendations

### High Priority
1. **[Recommendation]** - [Impact] - [Effort]
2. **[Recommendation]** - [Impact] - [Effort]

### Medium Priority
1. **[Recommendation]** - [Impact] - [Effort]

### Low Priority
1. **[Recommendation]** - [Impact] - [Effort]

## Migration Roadmap

| Phase | Description | Estimated Effort |
|-------|-------------|------------------|
| 1 | Token extraction | [X] iterations |
| 2 | Atom extraction | [X] iterations |
| 3 | Molecule composition | [X] iterations |
| 4 | Organism assembly | [X] iterations |

## Appendix

### Files Analyzed
- [file list]

### Tools Used
- [tool list]
```
</audit_report_template>

<common_issues>
## Common Issues and Fixes

### Issue: Atom Importing Atom

**Symptom:**
```typescript
// atoms/IconButton.tsx
import { Icon } from './Icon';
import { Button } from './Button';
```

**Fix:**
Move to molecules/ since it composes multiple atoms:
```typescript
// molecules/IconButton.tsx
import { Icon } from '@/atoms/Icon';
import { Button } from '@/atoms/Button';
```

### Issue: Hardcoded Colors

**Symptom:**
```css
.button { background: #3b82f6; }
```

**Fix:**
```css
.button { background: var(--color-action-primary); }
```

### Issue: Organism Importing Organism

**Symptom:**
```typescript
// organisms/PageLayout.tsx
import { Header } from './Header';
import { Footer } from './Footer';
```

**Fix:**
This is a template pattern:
```typescript
// templates/PageLayout.tsx
import { Header } from '@/organisms/Header';
import { Footer } from '@/organisms/Footer';
```

### Issue: Missing Semantic Token Tier

**Symptom:**
```css
.button {
  /* Component directly references primitive */
  background: var(--color-blue-600);
}
```

**Fix:**
```css
/* Add semantic tier */
:root {
  --color-action-primary: var(--color-blue-600);
}

.button {
  background: var(--color-action-primary);
}
```

### Issue: Molecule Too Complex

**Symptom:**
```typescript
// molecules/ProductCard.tsx - imports 6+ atoms
import { Image, Title, Price, Rating, Button, Badge, Icon, Text };
```

**Fix:**
This is an organism:
```typescript
// organisms/ProductCard.tsx
// Organism can import many atoms/molecules
```

### Issue: Stateful Atom

**Symptom:**
```typescript
// atoms/Input.tsx
const [value, setValue] = useState('');
```

**Fix:**
Make it controlled:
```typescript
// atoms/Input.tsx
interface InputProps {
  value: string;
  onChange: (value: string) => void;
}
// No internal state - fully controlled by parent
```
</common_issues>

<automated_checks>
## Automated Checks

### ESLint Rules for Hierarchy Enforcement

```javascript
// .eslintrc.js
module.exports = {
  rules: {
    'import/no-restricted-paths': [
      'error',
      {
        zones: [
          { target: './src/atoms', from: './src/molecules', message: 'Atoms cannot import molecules' },
          { target: './src/atoms', from: './src/organisms', message: 'Atoms cannot import organisms' },
          { target: './src/atoms', from: './src/templates', message: 'Atoms cannot import templates' },
          { target: './src/molecules', from: './src/organisms', message: 'Molecules cannot import organisms' },
          { target: './src/molecules', from: './src/templates', message: 'Molecules cannot import templates' },
          { target: './src/organisms', from: './src/templates', message: 'Organisms cannot import templates' },
        ],
      },
    ],
  },
};
```

### Token Linting (Stylelint)

```javascript
// stylelint.config.js
module.exports = {
  rules: {
    'color-no-hex': true, // Disallow hex colors
    'declaration-property-value-disallowed-list': {
      '/^(padding|margin)/': ['/^\\d+px$/'], // Disallow hardcoded px for spacing
    },
  },
};
```

### Dependency Graph Check Script

```bash
#!/bin/bash
# Check for hierarchy violations

echo "Checking for atom-to-atom imports..."
grep -r "from.*atoms/" src/atoms --include="*.tsx" | grep -v "index.ts"

echo "Checking for molecule-to-molecule imports..."
grep -r "from.*molecules/" src/molecules --include="*.tsx" | grep -v "index.ts"

echo "Checking for organism-to-organism imports..."
grep -r "from.*organisms/" src/organisms --include="*.tsx" | grep -v "index.ts"
```
</automated_checks>
