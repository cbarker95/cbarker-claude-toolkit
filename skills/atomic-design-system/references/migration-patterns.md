# Migration Patterns for Atomic Design

<overview>
Migrating an existing codebase to atomic design requires a systematic approach.
This reference covers strategies for identifying, extracting, and refactoring
components into a proper atomic hierarchy.

The recommended approach follows the **Ralph Wiggum pattern**: phased migration
with clear completion signals, one component per iteration.
</overview>

<migration_phases>
## Migration Phases

```
┌─────────────────────────────────────────────────────────────┐
│  Phase 1: AUDIT                                              │
│  Inventory existing components, identify tokens, map hierarchy│
│  Completion: audit-report.json generated                     │
├─────────────────────────────────────────────────────────────┤
│  Phase 2: TOKEN EXTRACTION                                   │
│  Extract design tokens from existing CSS                     │
│  Completion: tokens/ directory with all values               │
├─────────────────────────────────────────────────────────────┤
│  Phase 3: ATOM EXTRACTION                                    │
│  Extract atomic components (one per iteration)               │
│  Completion: atoms/ directory complete, imports updated      │
├─────────────────────────────────────────────────────────────┤
│  Phase 4: MOLECULE COMPOSITION                               │
│  Compose molecules from atoms (one per iteration)            │
│  Completion: molecules/ directory complete                   │
├─────────────────────────────────────────────────────────────┤
│  Phase 5: ORGANISM ASSEMBLY                                  │
│  Build organisms from molecules/atoms (one per iteration)    │
│  Completion: organisms/ directory complete                   │
├─────────────────────────────────────────────────────────────┤
│  Phase 6: TEMPLATE CREATION                                  │
│  Extract page layouts into templates                         │
│  Completion: templates/ directory complete                   │
├─────────────────────────────────────────────────────────────┤
│  Phase 7: CLEANUP                                            │
│  Remove old components, update all imports                   │
│  Completion: No legacy component imports remain              │
└─────────────────────────────────────────────────────────────┘
```
</migration_phases>

<phase_1_audit>
## Phase 1: Audit

### Goals
- Inventory all existing components
- Identify repeated patterns
- Map current to target hierarchy
- Identify design tokens in CSS

### Audit Process

```typescript
// Example audit script output structure
interface ComponentAudit {
  path: string;
  name: string;
  currentLocation: string;
  suggestedLevel: 'atom' | 'molecule' | 'organism' | 'template' | 'page';
  dependencies: string[];
  dependents: string[];
  complexity: 'low' | 'medium' | 'high';
  hasTests: boolean;
  hasStories: boolean;
}

interface TokenAudit {
  colors: { value: string; occurrences: number; suggestedName: string }[];
  spacing: { value: string; occurrences: number; suggestedName: string }[];
  typography: { value: string; occurrences: number; suggestedName: string }[];
}

interface AuditReport {
  components: ComponentAudit[];
  tokens: TokenAudit;
  recommendations: string[];
}
```

### Component Classification Criteria

| Criterion | Atom | Molecule | Organism |
|-----------|------|----------|----------|
| Child components | 0 | 2-4 atoms | Multiple molecules/atoms |
| Single purpose | Yes | Yes | No (section) |
| Portable | Very | Yes | Somewhat |
| State | None | Minimal UI | Complex |
| Example | Button, Input | FormField, SearchInput | Header, LoginForm |

### Manual Classification Questions

For each component, ask:

1. **Can it be broken down further?** → If no, it's an atom
2. **Does it combine 2-4 simple elements?** → If yes, it's a molecule
3. **Is it a distinct page section?** → If yes, it's an organism
4. **Does it define layout without content?** → If yes, it's a template

### Audit Output Example

```json
{
  "components": [
    {
      "path": "src/components/Button.tsx",
      "name": "Button",
      "suggestedLevel": "atom",
      "dependencies": [],
      "dependents": ["LoginForm", "Header", "Modal"],
      "complexity": "low",
      "hasTests": true
    },
    {
      "path": "src/components/LoginForm.tsx",
      "name": "LoginForm",
      "suggestedLevel": "organism",
      "dependencies": ["Button", "Input", "Label"],
      "dependents": ["LoginPage"],
      "complexity": "high",
      "hasTests": false
    }
  ],
  "tokens": {
    "colors": [
      { "value": "#3b82f6", "occurrences": 23, "suggestedName": "--color-action-primary" },
      { "value": "#ef4444", "occurrences": 8, "suggestedName": "--color-feedback-error" }
    ]
  }
}
```
</phase_1_audit>

<phase_2_tokens>
## Phase 2: Token Extraction

### Goals
- Extract all design values from CSS
- Create token files
- Replace hardcoded values with tokens
- No visual changes

### Step-by-Step Process

**Step 2.1: Extract Colors**

```css
/* Before: Hardcoded values scattered */
.button-primary { background: #3b82f6; }
.link { color: #3b82f6; }
.error { color: #ef4444; }

/* After: Token references */
.button-primary { background: var(--color-action-primary); }
.link { color: var(--color-action-primary); }
.error { color: var(--color-feedback-error); }
```

```css
/* tokens/colors.css */
:root {
  /* Primitives */
  --color-blue-600: #3b82f6;
  --color-red-600: #ef4444;

  /* Semantic */
  --color-action-primary: var(--color-blue-600);
  --color-feedback-error: var(--color-red-600);
}
```

**Step 2.2: Extract Spacing**

```css
/* Before */
.card { padding: 16px; margin-bottom: 24px; }
.button { padding: 8px 16px; }

/* After */
.card { padding: var(--space-4); margin-bottom: var(--space-6); }
.button { padding: var(--space-2) var(--space-4); }
```

```css
/* tokens/spacing.css */
:root {
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-6: 24px;
  --space-8: 32px;
}
```

**Step 2.3: Extract Typography**

```css
/* Before */
.heading { font-size: 24px; font-weight: 700; }
.body { font-size: 16px; line-height: 1.5; }

/* After */
.heading { font-size: var(--font-size-2xl); font-weight: var(--font-weight-bold); }
.body { font-size: var(--font-size-base); line-height: var(--line-height-normal); }
```

### Completion Signal
```
✓ tokens/ directory exists with:
  - colors.css
  - spacing.css
  - typography.css
  - shadows.css
  - index.css
✓ No hardcoded hex colors in component CSS
✓ No hardcoded px values for spacing (except borders)
✓ Build passes
✓ Visual regression shows no changes
```
</phase_2_tokens>

<phase_3_atoms>
## Phase 3: Atom Extraction

### Goals
- Extract atomic components
- One component per iteration
- Update imports across codebase
- Maintain backward compatibility

### Ralph Wiggum Loop Pattern

```
For each identified atom:
  1. Create atom in atoms/{ComponentName}/
  2. Copy component code
  3. Update to use tokens
  4. Add TypeScript types
  5. Update imports in original location to re-export
  6. Run tests
  7. Commit
  8. → Next atom
```

### Example: Extracting Button Atom

**Iteration 1: Button**

```typescript
// Before: src/components/Button.tsx
export function Button({ children, onClick, variant = 'primary' }) {
  return (
    <button
      className={`btn btn-${variant}`}
      onClick={onClick}
    >
      {children}
    </button>
  );
}
```

```typescript
// After: src/atoms/Button/Button.tsx
import type { ButtonHTMLAttributes, ReactNode } from 'react';

export type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'destructive';
export type ButtonSize = 'sm' | 'md' | 'lg';

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  isLoading?: boolean;
  isDisabled?: boolean;
  children: ReactNode;
}

export function Button({
  variant = 'primary',
  size = 'md',
  isLoading = false,
  isDisabled = false,
  children,
  className,
  ...props
}: ButtonProps) {
  return (
    <button
      className={`button button--${variant} button--${size} ${className || ''}`}
      disabled={isDisabled || isLoading}
      aria-busy={isLoading}
      {...props}
    >
      {isLoading && <span className="button__spinner" />}
      {children}
    </button>
  );
}
```

```typescript
// Backward compatibility: src/components/Button.tsx
// Re-export from new location (temporary during migration)
export { Button } from '@/atoms/Button';
export type { ButtonProps, ButtonVariant, ButtonSize } from '@/atoms/Button';
```

### Atom Extraction Checklist

For each atom:
- [ ] Create folder: `atoms/{ComponentName}/`
- [ ] Create component file with TypeScript
- [ ] Create styles using tokens
- [ ] Create types file (if complex)
- [ ] Create index.ts for exports
- [ ] Add tests
- [ ] Add Storybook story
- [ ] Update old location to re-export
- [ ] Find and update direct imports (or leave re-export)
- [ ] Run full test suite
- [ ] Commit with message: `refactor(atoms): extract Button atom`

### Completion Signal
```
✓ atoms/ directory contains all identified atoms
✓ All atoms use design tokens
✓ All atoms have TypeScript types
✓ All atoms have tests
✓ Build passes
✓ No circular dependencies
```
</phase_3_atoms>

<phase_4_molecules>
## Phase 4: Molecule Composition

### Goals
- Compose molecules from atoms
- One component per iteration
- Ensure atoms are not modified

### Example: Creating FormField Molecule

```typescript
// src/molecules/FormField/FormField.tsx
import { Label } from '@/atoms/Label';
import { Input } from '@/atoms/Input';
import { Text } from '@/atoms/Text';

export interface FormFieldProps {
  label: string;
  value: string;
  onChange: (value: string) => void;
  helperText?: string;
  errorMessage?: string;
  isRequired?: boolean;
  isDisabled?: boolean;
}

export function FormField({
  label,
  value,
  onChange,
  helperText,
  errorMessage,
  isRequired,
  isDisabled,
}: FormFieldProps) {
  const hasError = Boolean(errorMessage);
  const fieldId = `field-${label.toLowerCase().replace(/\s/g, '-')}`;

  return (
    <div className="form-field">
      <Label htmlFor={fieldId} isRequired={isRequired}>
        {label}
      </Label>

      <Input
        id={fieldId}
        value={value}
        onChange={onChange}
        hasError={hasError}
        isDisabled={isDisabled}
        aria-describedby={hasError ? `${fieldId}-error` : undefined}
      />

      {hasError ? (
        <Text id={`${fieldId}-error`} variant="error" size="sm">
          {errorMessage}
        </Text>
      ) : helperText ? (
        <Text variant="secondary" size="sm">
          {helperText}
        </Text>
      ) : null}
    </div>
  );
}
```

### Molecule Composition Rules

```typescript
// ✓ CORRECT: Molecule imports atoms
import { Button } from '@/atoms/Button';
import { Input } from '@/atoms/Input';

// ✗ WRONG: Molecule imports another molecule
import { FormField } from '@/molecules/FormField'; // Should be in organism

// ✗ WRONG: Molecule imports organism
import { Header } from '@/organisms/Header'; // Never allowed
```

### Completion Signal
```
✓ molecules/ directory contains all identified molecules
✓ Molecules only import from atoms/
✓ All molecules have TypeScript types
✓ All molecules have tests
✓ Build passes
```
</phase_4_molecules>

<phase_5_organisms>
## Phase 5: Organism Assembly

### Goals
- Build organisms from molecules and atoms
- Handle complex state
- One component per iteration

### Example: Creating LoginForm Organism

```typescript
// src/organisms/LoginForm/LoginForm.tsx
import { useState, useCallback } from 'react';
import { FormField } from '@/molecules/FormField';
import { Button } from '@/atoms/Button';
import { Link } from '@/atoms/Link';
import { Alert } from '@/atoms/Alert';

export interface LoginFormData {
  email: string;
  password: string;
}

export interface LoginFormProps {
  onSubmit: (data: LoginFormData) => Promise<void>;
  onForgotPassword: () => void;
}

export function LoginForm({ onSubmit, onForgotPassword }: LoginFormProps) {
  const [formData, setFormData] = useState<LoginFormData>({
    email: '',
    password: '',
  });
  const [errors, setErrors] = useState<Partial<LoginFormData>>({});
  const [formError, setFormError] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const validate = useCallback(() => {
    const newErrors: Partial<LoginFormData> = {};

    if (!formData.email) {
      newErrors.email = 'Email is required';
    } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
      newErrors.email = 'Please enter a valid email';
    }

    if (!formData.password) {
      newErrors.password = 'Password is required';
    } else if (formData.password.length < 8) {
      newErrors.password = 'Password must be at least 8 characters';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, [formData]);

  const handleSubmit = useCallback(async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError(null);

    if (!validate()) return;

    setIsSubmitting(true);
    try {
      await onSubmit(formData);
    } catch (error) {
      setFormError('Invalid email or password');
    } finally {
      setIsSubmitting(false);
    }
  }, [formData, validate, onSubmit]);

  return (
    <form className="login-form" onSubmit={handleSubmit}>
      {formError && <Alert variant="error">{formError}</Alert>}

      <FormField
        label="Email"
        value={formData.email}
        onChange={(value) => setFormData(prev => ({ ...prev, email: value }))}
        errorMessage={errors.email}
        isRequired
      />

      <FormField
        label="Password"
        value={formData.password}
        onChange={(value) => setFormData(prev => ({ ...prev, password: value }))}
        errorMessage={errors.password}
        isRequired
      />

      <div className="login-form__actions">
        <Button type="submit" isLoading={isSubmitting}>
          Log In
        </Button>
        <Link onClick={onForgotPassword}>Forgot password?</Link>
      </div>
    </form>
  );
}
```

### Completion Signal
```
✓ organisms/ directory contains all identified organisms
✓ Organisms only import from molecules/ and atoms/
✓ All organisms have TypeScript types
✓ All organisms have tests
✓ Build passes
```
</phase_5_organisms>

<phase_6_templates>
## Phase 6: Template Creation

### Goals
- Extract page layouts into templates
- Templates define structure, not content
- Use slots/children for content areas

### Example: Extracting DashboardTemplate

```typescript
// Before: src/pages/Dashboard.tsx (layout mixed with content)
export function DashboardPage() {
  return (
    <div className="dashboard">
      <header className="dashboard-header">
        <Header user={user} />
      </header>
      <div className="dashboard-body">
        <aside className="dashboard-sidebar">
          <Sidebar />
        </aside>
        <main className="dashboard-main">
          {/* Content */}
        </main>
      </div>
    </div>
  );
}
```

```typescript
// After: src/templates/DashboardTemplate/DashboardTemplate.tsx
import type { ReactNode } from 'react';

export interface DashboardTemplateProps {
  header: ReactNode;
  sidebar: ReactNode;
  children: ReactNode;
  footer?: ReactNode;
}

export function DashboardTemplate({
  header,
  sidebar,
  children,
  footer,
}: DashboardTemplateProps) {
  return (
    <div className="dashboard-template">
      <header className="dashboard-template__header">
        {header}
      </header>
      <div className="dashboard-template__body">
        <aside className="dashboard-template__sidebar">
          {sidebar}
        </aside>
        <main className="dashboard-template__main">
          {children}
        </main>
      </div>
      {footer && (
        <footer className="dashboard-template__footer">
          {footer}
        </footer>
      )}
    </div>
  );
}
```

```typescript
// After: src/pages/Dashboard.tsx (uses template)
import { DashboardTemplate } from '@/templates/DashboardTemplate';
import { Header } from '@/organisms/Header';
import { Sidebar } from '@/organisms/Sidebar';

export function DashboardPage() {
  const { user } = useUser();

  return (
    <DashboardTemplate
      header={<Header user={user} />}
      sidebar={<Sidebar />}
    >
      <StatsGrid />
      <ActivityFeed />
    </DashboardTemplate>
  );
}
```

### Completion Signal
```
✓ templates/ directory contains extracted layouts
✓ Templates use slot-based composition
✓ Pages use templates
✓ Build passes
```
</phase_6_templates>

<phase_7_cleanup>
## Phase 7: Cleanup

### Goals
- Remove re-exports from old locations
- Update all imports to new paths
- Remove old component files
- Final verification

### Cleanup Steps

**Step 7.1: Update Import Paths**

```typescript
// Before: Using re-export
import { Button } from '@/components/Button';

// After: Direct import from atomic location
import { Button } from '@/atoms/Button';
```

**Step 7.2: Remove Re-exports**

```typescript
// Delete: src/components/Button.tsx (the re-export file)
// After verifying no imports remain
```

**Step 7.3: Final Verification**

```bash
# Check for old import paths
grep -r "from '@/components/" src/

# Should return no results for migrated components
```

### Completion Signal
```
✓ No imports from old locations
✓ Old component files deleted
✓ Build passes
✓ All tests pass
✓ Visual regression shows no changes
```
</phase_7_cleanup>

<incremental_strategy>
## Incremental Migration Strategy

For large codebases, migrate incrementally:

### Strategy 1: Feature-by-Feature

```
1. Pick a feature (e.g., Login)
2. Migrate all components in that feature
3. Ship to production
4. Pick next feature
5. Repeat
```

### Strategy 2: Bottom-Up (Recommended)

```
1. Extract ALL atoms first
2. Then ALL molecules
3. Then ALL organisms
4. Then templates
5. Ship each phase to production
```

### Strategy 3: Parallel Tracks (Ralph Wiggum + Git Worktrees)

```bash
# Create separate worktrees for parallel work
git worktree add ../atomic-tokens tokens-migration
git worktree add ../atomic-atoms atoms-migration
git worktree add ../atomic-molecules molecules-migration

# Each worktree runs its own migration loop
# Merge when each phase completes
```

### Coexistence Pattern

During migration, old and new can coexist:

```
src/
├── components/          # OLD: Legacy components (gradually emptied)
│   ├── Button.tsx       # Re-exports from @/atoms/Button
│   └── LoginForm.tsx    # Not yet migrated
│
├── atoms/               # NEW: Migrated atoms
│   └── Button/
│
├── molecules/           # NEW: Migrated molecules
│   └── FormField/
│
└── organisms/           # NEW: Migrated organisms
    └── Header/
```
</incremental_strategy>

<rollback_strategy>
## Rollback Strategy

### Before Each Phase

```bash
# Create a checkpoint
git tag migration-phase-{n}-start
```

### During Migration

```bash
# Commit frequently
git commit -m "refactor(atoms): extract Input atom"
```

### If Problems Arise

```bash
# Rollback to last good state
git revert HEAD~n..HEAD  # Revert last n commits

# Or reset to checkpoint
git reset --hard migration-phase-{n}-start
```

### Feature Flags (Optional)

```typescript
// For risky migrations, use feature flags
import { useFeatureFlag } from '@/utils/featureFlags';

function MyComponent() {
  const useNewAtomicButton = useFeatureFlag('atomic-button');

  if (useNewAtomicButton) {
    return <AtomicButton />;
  }
  return <LegacyButton />;
}
```
</rollback_strategy>
