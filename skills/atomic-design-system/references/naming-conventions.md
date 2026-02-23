# Naming Conventions

<overview>
Consistent naming conventions across components, files, and CSS classes are essential
for maintainable atomic design systems. This reference covers naming patterns for
all aspects of the system.

See [design-tokens.md](./design-tokens.md) for token-specific naming (EightShapes taxonomy).
</overview>

<component_naming>
## Component Naming

### General Rules

1. **PascalCase** for component names
2. **Descriptive, not generic** — `ProductCard` not `Card1`
3. **No level prefix** — `Button` not `AtomButton`
4. **Singular nouns** — `Button` not `Buttons`
5. **Compound names** for specificity — `SearchInput`, `NavItem`

### Naming by Level

| Level | Pattern | Examples |
|-------|---------|----------|
| Atoms | Single word when possible | `Button`, `Input`, `Icon`, `Avatar` |
| Molecules | Compound descriptive | `SearchInput`, `FormField`, `NavItem` |
| Organisms | Section/purpose-based | `Header`, `ProductCard`, `LoginForm` |
| Templates | Suffix with `Template` | `DashboardTemplate`, `ArticleTemplate` |
| Pages | Suffix with `Page` | `HomePage`, `DashboardPage`, `ProductPage` |

### Variant Naming

Use prop values, not separate components:

```tsx
// ✓ GOOD: Variants via props
<Button variant="primary" />
<Button variant="secondary" />
<Button variant="ghost" />

// ✗ BAD: Separate components for variants
<PrimaryButton />
<SecondaryButton />
<GhostButton />
```

Exception: When variants have significantly different APIs:

```tsx
// ✓ OK: Different APIs warrant different components
<TextInput />
<NumberInput min={0} max={100} step={1} />
<DateInput format="YYYY-MM-DD" />
```
</component_naming>

<file_structure>
## File Structure

### Component Folder Pattern

```
ComponentName/
├── ComponentName.tsx       # Main component
├── ComponentName.styles.ts # Styles (CSS-in-JS) or .css/.scss
├── ComponentName.test.tsx  # Tests
├── ComponentName.stories.tsx # Storybook stories
├── index.ts                # Public exports
└── types.ts                # TypeScript types (if complex)
```

### Index Exports

```typescript
// ComponentName/index.ts
export { ComponentName } from './ComponentName';
export type { ComponentNameProps } from './types';
```

### Full Project Structure

```
src/
├── tokens/
│   ├── colors.ts
│   ├── typography.ts
│   ├── spacing.ts
│   ├── shadows.ts
│   └── index.ts
│
├── atoms/
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.styles.ts
│   │   ├── Button.test.tsx
│   │   └── index.ts
│   ├── Input/
│   ├── Icon/
│   └── index.ts           # Re-exports all atoms
│
├── molecules/
│   ├── FormField/
│   ├── SearchInput/
│   └── index.ts
│
├── organisms/
│   ├── Header/
│   ├── Footer/
│   └── index.ts
│
├── templates/
│   ├── DashboardTemplate/
│   ├── MarketingTemplate/
│   └── index.ts
│
└── pages/
    ├── HomePage/
    ├── DashboardPage/
    └── index.ts
```

### Barrel Exports (index.ts)

```typescript
// atoms/index.ts
export * from './Button';
export * from './Input';
export * from './Icon';
export * from './Avatar';
// ...

// Usage elsewhere
import { Button, Input, Icon } from '@/atoms';
```
</file_structure>

<css_naming>
## CSS Naming

### BEM (Block Element Modifier)

Recommended for atomic design systems because it maps well to component hierarchy.

#### Syntax

```
.block__element--modifier
```

- **Block:** The component itself (`.card`, `.button`)
- **Element:** A part of the block (`.card__header`, `.card__body`)
- **Modifier:** A variant/state (`.button--primary`, `.button--disabled`)

#### Mapping to Atomic Levels

| Atomic Level | BEM Pattern | Example |
|--------------|-------------|---------|
| Atom | `.block` or `.block--modifier` | `.button`, `.button--primary` |
| Molecule | `.block__element` | `.search-input__button` |
| Organism | `.block__element` (deeper) | `.header__nav`, `.header__logo` |

#### Examples

```css
/* Atom: Button */
.button { }
.button--primary { }
.button--secondary { }
.button--large { }
.button--disabled { }

/* Molecule: SearchInput */
.search-input { }
.search-input__field { }
.search-input__button { }
.search-input__icon { }
.search-input--expanded { }

/* Organism: Header */
.header { }
.header__logo { }
.header__nav { }
.header__search { }
.header__user-menu { }
.header--sticky { }
.header--transparent { }
```

### CSS Modules

When using CSS Modules, class names are scoped automatically:

```css
/* Button.module.css */
.root { }          /* The button itself */
.primary { }       /* Variant */
.secondary { }
.icon { }          /* Child element */
.label { }
```

```tsx
// Button.tsx
import styles from './Button.module.css';

<button className={`${styles.root} ${styles.primary}`}>
  <span className={styles.icon}>{icon}</span>
  <span className={styles.label}>{children}</span>
</button>
```

### Tailwind / Utility-First

With Tailwind, use `@apply` for component classes or compose utilities:

```tsx
// Option 1: Utility classes directly
<button className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700">
  {children}
</button>

// Option 2: Extract to component classes
// Button.css
.button {
  @apply px-4 py-2 rounded-md font-medium;
}
.button-primary {
  @apply bg-blue-600 text-white hover:bg-blue-700;
}
```

### CSS-in-JS (Styled Components, Emotion)

```tsx
// Styled Components
const Button = styled.button<{ variant: 'primary' | 'secondary' }>`
  padding: ${({ theme }) => `${theme.space[2]} ${theme.space[4]}`};
  border-radius: ${({ theme }) => theme.radius.md};

  ${({ variant, theme }) => variant === 'primary' && `
    background: ${theme.colors.action.primary};
    color: ${theme.colors.text.inverse};
  `}
`;

// Emotion with object styles
const buttonStyles = (variant: string) => css({
  padding: `${tokens.space[2]} ${tokens.space[4]}`,
  borderRadius: tokens.radius.md,
  ...(variant === 'primary' && {
    background: tokens.colors.action.primary,
    color: tokens.colors.text.inverse,
  }),
});
```
</css_naming>

<props_naming>
## Props Naming

### Common Prop Patterns

| Prop Type | Pattern | Examples |
|-----------|---------|----------|
| Boolean | `is*`, `has*`, `should*` | `isLoading`, `isDisabled`, `hasError` |
| Event handlers | `on*` | `onClick`, `onChange`, `onSubmit` |
| Render props | `render*` | `renderIcon`, `renderFooter` |
| Children slots | Descriptive noun | `header`, `footer`, `leftIcon` |
| Variants | `variant`, `size`, `color` | `variant="primary"`, `size="lg"` |
| State | `*State` or just state name | `selectedState`, `open` |

### Standard Props by Component Type

**Button-like atoms:**
```typescript
interface ButtonProps {
  variant: 'primary' | 'secondary' | 'ghost' | 'destructive';
  size: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
  isDisabled?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  type?: 'button' | 'submit' | 'reset';
  onClick?: (event: React.MouseEvent) => void;
  children: React.ReactNode;
}
```

**Input-like atoms:**
```typescript
interface InputProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  isDisabled?: boolean;
  isReadOnly?: boolean;
  hasError?: boolean;
  errorMessage?: string;
  leftElement?: React.ReactNode;
  rightElement?: React.ReactNode;
}
```

**Card-like organisms:**
```typescript
interface CardProps {
  variant?: 'elevated' | 'outlined' | 'filled';
  header?: React.ReactNode;
  footer?: React.ReactNode;
  media?: React.ReactNode;
  children: React.ReactNode;
  onClick?: () => void;
  isInteractive?: boolean;
}
```

### Avoiding Prop Name Conflicts

```typescript
// ✗ BAD: 'class' conflicts with reserved word
interface Props {
  class?: string;  // Reserved in JS
}

// ✓ GOOD: Use className (React convention)
interface Props {
  className?: string;
}

// ✗ BAD: 'for' conflicts with reserved word
interface LabelProps {
  for?: string;
}

// ✓ GOOD: Use htmlFor (React convention)
interface LabelProps {
  htmlFor?: string;
}
```
</props_naming>

<typescript_naming>
## TypeScript Naming

### Types and Interfaces

```typescript
// Props interfaces: ComponentNameProps
interface ButtonProps { }
interface SearchInputProps { }
interface HeaderProps { }

// State types: ComponentNameState (if needed)
interface FormState { }
interface ModalState { }

// Context types: ComponentNameContext
interface ThemeContext { }
interface AuthContext { }

// Utility types: Descriptive, PascalCase
type ColorVariant = 'primary' | 'secondary' | 'success' | 'error';
type Size = 'sm' | 'md' | 'lg';
type Spacing = 1 | 2 | 3 | 4 | 6 | 8;
```

### Generic Type Parameters

```typescript
// Single type: T
function identity<T>(value: T): T { }

// Descriptive when multiple or complex
interface ListProps<TItem> {
  items: TItem[];
  renderItem: (item: TItem) => React.ReactNode;
}

// Common conventions
// T = Type, K = Key, V = Value, E = Element
type Record<K extends string, V> = { [key in K]: V };
```

### Exporting Types

```typescript
// types.ts
export interface ButtonProps {
  variant: ButtonVariant;
  size: ButtonSize;
  // ...
}

export type ButtonVariant = 'primary' | 'secondary' | 'ghost';
export type ButtonSize = 'sm' | 'md' | 'lg';

// index.ts
export { Button } from './Button';
export type { ButtonProps, ButtonVariant, ButtonSize } from './types';
```
</typescript_naming>

<testing_naming>
## Test Naming

### Test Files

```
ComponentName.test.tsx      # Unit tests
ComponentName.spec.tsx      # Alternative (spec)
ComponentName.e2e.tsx       # End-to-end tests
ComponentName.stories.tsx   # Storybook (visual tests)
```

### Test Descriptions

```typescript
describe('Button', () => {
  // Group by behavior/feature
  describe('rendering', () => {
    it('renders children correctly', () => { });
    it('renders with left icon when provided', () => { });
  });

  describe('variants', () => {
    it('applies primary styles when variant is primary', () => { });
    it('applies secondary styles when variant is secondary', () => { });
  });

  describe('interactions', () => {
    it('calls onClick when clicked', () => { });
    it('does not call onClick when disabled', () => { });
  });

  describe('accessibility', () => {
    it('has correct ARIA attributes', () => { });
    it('is keyboard accessible', () => { });
  });
});
```

### Test IDs

```tsx
// Use data-testid for test selection
<button data-testid="submit-button">Submit</button>
<input data-testid="email-input" />

// Naming pattern: kebab-case, descriptive
data-testid="login-form"
data-testid="user-menu-trigger"
data-testid="product-card-add-to-cart"
```
</testing_naming>

<storybook_naming>
## Storybook Naming

### Story Files

```typescript
// Button.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { Button } from './Button';

const meta: Meta<typeof Button> = {
  title: 'Atoms/Button',  // Category/ComponentName
  component: Button,
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof Button>;

// Story names: PascalCase, descriptive
export const Primary: Story = {
  args: { variant: 'primary', children: 'Primary Button' },
};

export const Secondary: Story = {
  args: { variant: 'secondary', children: 'Secondary Button' },
};

export const WithIcon: Story = {
  args: { leftIcon: <Icon name="plus" />, children: 'Add Item' },
};

export const Loading: Story = {
  args: { isLoading: true, children: 'Loading...' },
};
```

### Story Hierarchy

```
Atoms/
├── Button
├── Input
├── Icon
└── Avatar

Molecules/
├── FormField
├── SearchInput
└── NavItem

Organisms/
├── Header
├── Footer
└── ProductCard

Templates/
├── DashboardTemplate
└── MarketingTemplate

Pages/
├── HomePage
└── DashboardPage
```
</storybook_naming>

<checklist>
## Naming Checklist

### Components
- [ ] PascalCase names
- [ ] Descriptive, not generic
- [ ] No level prefixes (no `AtomButton`)
- [ ] Variants via props, not separate components

### Files
- [ ] Component folder matches component name
- [ ] Index file exports public API
- [ ] Test/story files follow naming pattern

### CSS
- [ ] Consistent methodology (BEM, CSS Modules, etc.)
- [ ] No overly generic class names
- [ ] Modifier classes for variants/states

### Props
- [ ] `is*`/`has*` for booleans
- [ ] `on*` for event handlers
- [ ] Consistent across similar components

### TypeScript
- [ ] `*Props` for prop interfaces
- [ ] Exported types for public API
- [ ] Descriptive generic parameters
</checklist>
