---
name: atomic-design-system
description: Implement and evaluate design systems using Brad Frost's atomic design methodology. Use for building component libraries, auditing existing UIs, extracting design tokens, migrating legacy components, and documenting design systems.
---

<why_now>
## Why Atomic Design Now

Brad Frost's atomic design methodology has become the de facto standard for building scalable design systems. The insight: **build systems, not pages**. By starting with the smallest elements (atoms) and composing them into increasingly complex structures (molecules, organisms, templates, pages), teams create:

- **Consistent UIs** — Components built from shared atoms look and behave consistently
- **Maintainable systems** — Change an atom, and all molecules/organisms using it update
- **Scalable architecture** — New features compose existing pieces rather than reinventing
- **Clear vocabulary** — Teams speak the same language about component hierarchy

The methodology isn't about rigid categorization—it's about understanding **hierarchical composition**: how smaller building blocks combine to create larger, more complex structures.

As Brad Frost himself said: "The specific labels (atoms, molecules, organisms, templates, pages) have never been the point... But they're still useful as a mental model."
</why_now>

<core_principles>
## Core Principles

### 1. Atoms: The Foundational Elements

Atoms are UI elements that can't be broken down further without losing meaning:
- HTML elements: buttons, inputs, labels, icons
- Design tokens: colors, typography, spacing
- Abstract elements: color palettes, animations

**Test:** Can this be broken into smaller functional pieces? If no, it's an atom.

### 2. Molecules: Simple Compositions

Molecules combine atoms into simple, functional units:
- Search form = input + button + label
- Card header = avatar + title + timestamp
- Nav item = icon + label

**Test:** Is this a simple combination of 2-3 atoms with a single purpose?

### 3. Organisms: Complex Sections

Organisms are complex UI sections composed of molecules and atoms:
- Site header = logo + navigation + search form + user menu
- Product card = image + title + price + rating + add-to-cart
- Comment section = comment form + comment list

**Test:** Is this a distinct section of the interface that could stand alone?

### 4. Templates: Page-Level Layouts

Templates define page structure without real content:
- Layout with content placeholders
- Grid systems and page scaffolding
- Wire-frame-level structure

**Test:** Does this define where content goes without being the content?

### 5. Pages: Concrete Instances

Pages are templates filled with real content:
- Actual data replaces placeholders
- Real images, text, and interactions
- What users actually see and interact with

**Test:** Is this the final output with real content that users experience?
</core_principles>

<intake>
## What aspect of atomic design do you need help with?

1. **Audit existing codebase** — Analyze components for atomic design compliance
2. **Implement new system** — Build atomic design system from scratch
3. **Extract design tokens** — Pull tokens from existing styles (EightShapes methodology)
4. **Migrate components** — Refactor existing components to atomic hierarchy
5. **Document system** — Generate component documentation
6. **Evaluate compliance** — Score against atomic design principles
7. **Framework patterns** — React, Vue, or vanilla implementation patterns

**Wait for response before proceeding.**
</intake>

<routing>
| Response | Action |
|----------|--------|
| 1, "audit", "analyze" | Read [evaluation-criteria.md](./references/evaluation-criteria.md), suggest running `/atomic-audit` command |
| 2, "implement", "new", "build", "create" | Read [core-concepts.md](./references/core-concepts.md) and [component-hierarchy.md](./references/component-hierarchy.md), suggest `/atomic-init` |
| 3, "token", "extract", "design token" | Read [design-tokens.md](./references/design-tokens.md) — comprehensive EightShapes naming taxonomy |
| 4, "migrate", "refactor", "convert" | Read [migration-patterns.md](./references/migration-patterns.md), suggest `/atomic-migrate` |
| 5, "document", "docs", "storybook" | Read [documentation-templates.md](./references/documentation-templates.md) |
| 6, "evaluate", "score", "compliance" | Read [evaluation-criteria.md](./references/evaluation-criteria.md) |
| 7, "react" | Read [framework-patterns/react-patterns.md](./references/framework-patterns/react-patterns.md) |
| 7, "vue" | Read [framework-patterns/vue-patterns.md](./references/framework-patterns/vue-patterns.md) |
| 7, "vanilla", "web components", "css" | Read [framework-patterns/vanilla-patterns.md](./references/framework-patterns/vanilla-patterns.md) |

**After reading references, apply patterns to the user's specific context.**
</routing>

<parallel_agents>
## Parallelized Sub-Agents

For comprehensive audits, launch these agents **in parallel**:

### Analysis Phase (Parallel)
```
┌─────────────────────────┐  ┌─────────────────────────┐
│ component-hierarchy-    │  │ token-auditor           │
│ analyzer                │  │                         │
│ → Classifies components │  │ → Extracts design tokens│
│   into atomic levels    │  │   from CSS/SCSS         │
└───────────┬─────────────┘  └───────────┬─────────────┘
            │                            │
            └──────────┬─────────────────┘
                       ▼
         ┌─────────────────────────┐
         │ atomic-compliance-scorer│
         │ → Scores and recommends │
         └─────────────────────────┘
```

### Migration Phase (Sequential with Ralph Wiggum Loop)
```
┌─────────────────────────┐
│ atomic-migration-planner│
│ → Plans phased migration│
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────────────────────────┐
│ Ralph Wiggum Loop (one task per iteration)  │
│                                             │
│ Iteration 1: Extract Button atom            │
│ Iteration 2: Extract Input atom             │
│ Iteration 3: Compose SearchForm molecule    │
│ ...                                         │
│ Completion signal: all components migrated  │
└─────────────────────────────────────────────┘
```
</parallel_agents>

<ralph_wiggum_integration>
## Ralph Wiggum Patterns for Atomic Design

### Three-Phase Migration

**Phase 1: Token Extraction**
```markdown
Prompt: "Extract all design tokens from existing CSS"
Completion signal: tokens.json exists with all values mapped
```

**Phase 2: Atom Identification**
```markdown
Prompt: "Identify and extract atomic components"
Completion signal: atoms/ directory with all atom components
```

**Phase 3: Composition**
```markdown
Prompt: "Compose atoms into molecules, then organisms"
Completion signal: molecules/ and organisms/ directories complete
```

### One Task Per Iteration

Each iteration handles one component:
```
Iteration 1: Extract Button → atoms/Button/
Iteration 2: Extract Input → atoms/Input/
Iteration 3: Extract Icon → atoms/Icon/
Iteration 4: Compose SearchInput → molecules/SearchInput/
...
```

### Backpressure Constraints

Define rules that reject invalid structures:
```markdown
## Constraints
- Atoms cannot import other atoms (composition violation)
- Molecules can only import from atoms/
- Organisms can import from atoms/ and molecules/
- If an import violates hierarchy → build fails
```
</ralph_wiggum_integration>

<reference_index>
## Reference Files

All references in `references/`:

**Core Concepts:**
- [core-concepts.md](./references/core-concepts.md) — Atoms, molecules, organisms, templates, pages
- [component-hierarchy.md](./references/component-hierarchy.md) — Composition patterns, nesting rules
- [design-tokens.md](./references/design-tokens.md) — EightShapes naming taxonomy (comprehensive)
- [naming-conventions.md](./references/naming-conventions.md) — Component/file naming, BEM

**Framework Patterns:**
- [framework-patterns/react-patterns.md](./references/framework-patterns/react-patterns.md) — React implementation
- [framework-patterns/vue-patterns.md](./references/framework-patterns/vue-patterns.md) — Vue implementation
- [framework-patterns/vanilla-patterns.md](./references/framework-patterns/vanilla-patterns.md) — Web components, CSS

**Process:**
- [testing-strategies.md](./references/testing-strategies.md) — Component testing, visual regression
- [migration-patterns.md](./references/migration-patterns.md) — Refactoring to atomic
- [documentation-templates.md](./references/documentation-templates.md) — Storybook, docs
- [evaluation-criteria.md](./references/evaluation-criteria.md) — Scoring rubric
</reference_index>

<commands>
## Available Commands

- `/atomic-audit [path]` — Run full atomic design audit with parallel agents
- `/atomic-init [framework]` — Scaffold new atomic design system
- `/atomic-migrate` — Iterative migration using Ralph Wiggum pattern
</commands>

<anti_patterns>
## Anti-Patterns

### Structural Anti-Patterns

**Organism importing organism** — Organisms should compose molecules/atoms, not other organisms
```
✗ Header imports Footer
✓ Header composes Logo + Nav + SearchForm + UserMenu
```

**Molecule with too many atoms** — If a molecule has 5+ atoms, it's probably an organism
```
✗ SearchSection (input + button + filters + results + pagination)
✓ SearchSection as organism containing SearchForm molecule + ResultsList organism
```

**Atoms with internal state** — Atoms should be stateless; state belongs in molecules/organisms
```
✗ Button with internal loading state
✓ Button receives isLoading prop from parent
```

### Token Anti-Patterns

**Skipping semantic tier** — Components referencing primitives directly
```
✗ --button-bg: var(--color-blue-600);
✓ --button-bg: var(--color-action-primary);
```

**Hardcoded values in components** — All values should reference tokens
```
✗ padding: 16px;
✓ padding: var(--space-4);
```

See [design-tokens.md](./references/design-tokens.md) for comprehensive token anti-patterns.
</anti_patterns>

<success_criteria>
## Success Criteria

You've built a proper atomic design system when:

### Structure
- [ ] Clear atom/molecule/organism/template/page hierarchy
- [ ] Atoms are truly atomic (single HTML element or token)
- [ ] Molecules compose 2-3 atoms with single purpose
- [ ] Organisms are self-contained interface sections
- [ ] Templates define layout without content
- [ ] Import rules enforced (atoms → molecules → organisms)

### Tokens
- [ ] Three-tier token architecture (global → semantic → component)
- [ ] EightShapes naming taxonomy followed
- [ ] No hardcoded values in components
- [ ] Tokens enable theming

### Documentation
- [ ] Every component documented with props/usage
- [ ] Storybook or equivalent with all states
- [ ] Design token documentation
- [ ] Composition guidelines

### The Ultimate Test

**Can a new developer understand the component hierarchy in 5 minutes?**
**Can they add a new molecule without guidance?**

If yes, you've built a successful atomic design system.
</success_criteria>
