# Atomic Design Migration

Iteratively migrate existing components to atomic design structure using the Ralph Wiggum pattern.

## Arguments
- `$ARGUMENTS` - Optional: `--phase=N` to start at specific phase, or component path to migrate single component

## Ralph Wiggum Loop Pattern

This command uses **one task per iteration** with clear completion signals:

```
while not complete:
    1. Identify next component to migrate
    2. Classify into appropriate atomic level
    3. Extract to new location
    4. Update imports
    5. Run tests
    6. Commit checkpoint
    7. Check completion signal
```

## Migration Phases

### Phase 1: Audit (Pre-requisite)
Run `/atomic-audit` first to understand current state.

### Phase 2: Token Extraction
```
For each unique style value found:
    1. Create token in appropriate file (colors, spacing, etc.)
    2. Replace hardcoded value with token reference
    3. Verify visual unchanged
    4. Commit

Completion: No hardcoded hex/px values in component CSS
```

### Phase 3: Atom Extraction
```
For each identified atom:
    1. Create atoms/{ComponentName}/ directory
    2. Move/refactor component with TypeScript types
    3. Update to use tokens
    4. Create re-export from old location
    5. Add basic test
    6. Commit

Completion: All atoms in atoms/ directory
```

### Phase 4: Molecule Composition
```
For each identified molecule:
    1. Create molecules/{ComponentName}/ directory
    2. Refactor to import from @/atoms
    3. Remove duplicated atom code
    4. Create re-export from old location
    5. Add test
    6. Commit

Completion: All molecules in molecules/ directory
```

### Phase 5: Organism Assembly
```
For each identified organism:
    1. Create organisms/{ComponentName}/ directory
    2. Refactor to import from @/atoms and @/molecules
    3. Move complex state logic
    4. Create re-export
    5. Add test
    6. Commit

Completion: All organisms in organisms/ directory
```

### Phase 6: Template Extraction
```
For each page layout pattern:
    1. Create templates/{LayoutName}/ directory
    2. Extract layout structure
    3. Convert hardcoded content to slots
    4. Update pages to use template
    5. Commit

Completion: All templates in templates/ directory
```

### Phase 7: Cleanup
```
For each re-export file:
    1. Find all imports of old path
    2. Update to new atomic path
    3. Delete re-export file
    4. Run full test suite
    5. Commit

Completion: No imports from legacy locations
```

## Iteration Output

After each iteration, output:
```markdown
## Iteration N: {ComponentName}

**Action:** Extracted {ComponentName} to {level}/
**Status:** ✅ Complete
**Tests:** ✅ Passing
**Visual:** ✅ No changes

**Next:** {NextComponentName} or "Phase complete"
```

## Backpressure Constraints

The migration will **fail** and require fix if:
- Atom imports another atom
- Molecule imports from organisms/
- Hardcoded color/spacing value introduced
- Tests fail after migration
- Visual regression detected

## Checkpoint Strategy

```bash
# Create checkpoint before each phase
git tag atomic-migration-phase-{n}-start

# Commit after each component
git commit -m "refactor({level}): migrate {ComponentName} to atomic structure"
```

## Usage

```
/atomic-migrate                      # Full migration from Phase 2
/atomic-migrate --phase=3            # Start from Atom Extraction
/atomic-migrate src/components/Button.tsx  # Migrate single component
```

## Safety

- Creates checkpoints before each phase
- Commits after each component
- Can be stopped and resumed
- Never modifies without tests passing

## References

Read before running:
- `.claude/skills/atomic-design-system/references/migration-patterns.md`
- `.claude/skills/atomic-design-system/references/component-hierarchy.md`
