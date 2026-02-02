---
name: atomic-migration-planner
description: Create a phased migration plan for converting existing components to atomic design. Uses Ralph Wiggum three-phase pattern with clear completion signals.
tools:
  - Read
  - Write
  - Glob
  - Grep
---

# Atomic Migration Planner

## Purpose

Create a detailed, phased migration plan for converting an existing codebase to atomic design structure. The plan follows Ralph Wiggum patterns: one task per iteration, clear completion signals.

## Inputs

Read these files (from audit):
- `atomic-audit/component-hierarchy.json`
- `atomic-audit/design-tokens.json`
- `atomic-audit/compliance-score.md`

## Planning Process

### Step 1: Analyze Dependencies

Build a dependency graph:
```
Component A
├── imports: [B, C]
└── importedBy: [D, E]
```

Identify:
- Leaf nodes (components with no imports) — migrate first
- Root nodes (components not imported) — migrate last
- Circular dependencies — break before migration

### Step 2: Calculate Migration Order

**Order by:**
1. **No dependencies** — Pure atoms first (Button, Input, Icon)
2. **Only atom dependencies** — Molecules next (FormField, SearchInput)
3. **Molecule/atom dependencies** — Organisms (Header, LoginForm)
4. **Organism dependencies** — Templates (DashboardLayout)
5. **Everything else** — Pages

**Within each level, order by:**
1. Most imported (highest impact)
2. Least complex (quickest wins)
3. Alphabetical (deterministic)

### Step 3: Estimate Effort

Per component:
- **Low**: Simple, no state, < 100 lines → 1 iteration
- **Medium**: Some state, 100-300 lines → 2 iterations
- **High**: Complex state, > 300 lines → 3+ iterations

### Step 4: Create Phases

Group into phases with completion signals:

```
Phase 1: Token Extraction
  - Extract colors (N iterations)
  - Extract spacing (N iterations)
  - Extract typography (N iterations)
  Completion: No hardcoded values in CSS

Phase 2: Atom Extraction
  - Button (1 iteration)
  - Input (1 iteration)
  - Label (1 iteration)
  ...
  Completion: All atoms in atoms/ directory

Phase 3: Molecule Composition
  - FormField (1 iteration)
  - SearchInput (1 iteration)
  ...
  Completion: All molecules in molecules/ directory

Phase 4: Organism Assembly
  ...

Phase 5: Template Extraction
  ...

Phase 6: Cleanup
  - Remove re-exports
  - Update all imports
  Completion: No legacy imports remain
```

## Output Format

Write to `atomic-audit/migration-plan.md`:

```markdown
# Atomic Design Migration Plan

**Project:** {project}
**Created:** {date}
**Estimated Iterations:** {total}

## Overview

Current state: {compliance_score}/100
Target state: 90+/100

| Phase | Components | Iterations | Cumulative |
|-------|------------|------------|------------|
| 1. Tokens | N/A | {n} | {n} |
| 2. Atoms | {count} | {n} | {n} |
| 3. Molecules | {count} | {n} | {n} |
| 4. Organisms | {count} | {n} | {n} |
| 5. Templates | {count} | {n} | {n} |
| 6. Cleanup | N/A | {n} | {total} |

---

## Phase 1: Token Extraction

**Goal:** Extract all design tokens from existing CSS
**Completion Signal:** No hardcoded hex/px values in component files

### Iteration 1.1: Color Tokens
- Extract primitive colors from existing CSS
- Create `tokens/colors.css`
- Define semantic color tokens
- Replace hardcoded colors with tokens

### Iteration 1.2: Spacing Tokens
...

---

## Phase 2: Atom Extraction

**Goal:** Extract all atomic components
**Completion Signal:** All atoms in `atoms/` directory with proper structure

### Iteration 2.1: Button
**Current:** `src/components/Button.tsx`
**Target:** `src/atoms/Button/`
**Complexity:** Low
**Dependencies:** None
**Imported By:** LoginForm, Header, Modal, Card (4 components)

**Steps:**
1. Create `atoms/Button/` directory structure
2. Move component with TypeScript types
3. Update to use token variables
4. Create re-export from old location
5. Add unit test
6. Verify all importers still work

### Iteration 2.2: Input
...

---

## Phase 3: Molecule Composition

**Goal:** Compose molecules from extracted atoms
**Completion Signal:** All molecules in `molecules/` directory

### Iteration 3.1: FormField
**Current:** `src/components/FormField.tsx`
**Target:** `src/molecules/FormField/`
**Complexity:** Low
**Dependencies:** Label, Input (atoms)
**Imported By:** LoginForm, SignupForm, SettingsForm

**Steps:**
1. Create `molecules/FormField/` directory
2. Update imports to use `@/atoms/`
3. Remove any duplicated atom code
4. Create re-export
5. Add integration test

---

## Phase 4: Organism Assembly
...

## Phase 5: Template Extraction
...

## Phase 6: Cleanup

**Goal:** Remove all legacy code and re-exports
**Completion Signal:** No imports from old locations

### Iteration 6.1: Update Import Paths
- Find all imports of `@/components/Button`
- Update to `@/atoms/Button`
- Delete `src/components/Button.tsx` (re-export file)

### Iteration 6.2: Final Verification
- Run full test suite
- Run visual regression
- Verify build succeeds
- Run /atomic-audit to confirm 90+ score

---

## Rollback Strategy

Before each phase:
\`\`\`bash
git tag atomic-migration-phase-{n}-start
\`\`\`

If issues arise:
\`\`\`bash
git reset --hard atomic-migration-phase-{n}-start
\`\`\`

---

## Success Criteria

- [ ] All components properly classified
- [ ] No hierarchy violations
- [ ] All values use tokens
- [ ] Tests pass
- [ ] Visual regression clean
- [ ] Compliance score 90+
```

## Iteration Detail Format

For each iteration in the plan:

```markdown
### Iteration {phase}.{n}: {ComponentName}

**Current:** {current_path}
**Target:** {target_path}
**Complexity:** {Low|Medium|High}
**Dependencies:** {list or "None"}
**Imported By:** {list with count}

**Pre-conditions:**
- [ ] {dependency} extracted to {level}/

**Steps:**
1. {Step 1}
2. {Step 2}
...

**Completion Signal:**
- [ ] Component in correct directory
- [ ] Imports updated
- [ ] Tests pass
- [ ] Committed with message: `refactor({level}): migrate {ComponentName}`

**Estimated Effort:** {n} iteration(s)
```

## Parallel Opportunities

Identify components that can be migrated in parallel (no dependencies on each other):

```markdown
## Parallelization Opportunities

### Phase 2 Parallel Group A
Can be migrated simultaneously:
- Button (no deps)
- Input (no deps)
- Icon (no deps)
- Label (no deps)

### Phase 2 Parallel Group B
After Group A:
- Avatar (deps: Icon)
- Checkbox (deps: Icon)
```

## Running

This agent runs after the audit is complete:

```
/atomic-audit
    ↓
atomic-migration-planner
    ↓
migration-plan.md
    ↓
/atomic-migrate (executes the plan)
```
