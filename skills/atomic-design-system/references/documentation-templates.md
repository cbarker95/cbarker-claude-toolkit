# Documentation Templates for Atomic Design Systems

<overview>
Good documentation is essential for design system adoption. This reference provides
templates for documenting components, tokens, and usage guidelines at each atomic level.
</overview>

<component_documentation>
## Component Documentation Structure

### Standard Component Doc Template

```markdown
# ComponentName

Brief description of what this component does and when to use it.

## Usage

\`\`\`tsx
import { ComponentName } from '@/atoms/ComponentName';

<ComponentName variant="primary">Label</ComponentName>
\`\`\`

## Props

| Prop | Type | Default | Description |
|------|------|---------|-------------|
| `variant` | `'primary' \| 'secondary'` | `'primary'` | Visual variant |
| `size` | `'sm' \| 'md' \| 'lg'` | `'md'` | Size of the component |
| `isDisabled` | `boolean` | `false` | Whether the component is disabled |
| `children` | `ReactNode` | — | Content to display |

## Examples

### Basic Usage

\`\`\`tsx
<ComponentName>Default</ComponentName>
\`\`\`

### With Variants

\`\`\`tsx
<ComponentName variant="primary">Primary</ComponentName>
<ComponentName variant="secondary">Secondary</ComponentName>
\`\`\`

### States

\`\`\`tsx
<ComponentName isDisabled>Disabled</ComponentName>
<ComponentName isLoading>Loading</ComponentName>
\`\`\`

## Accessibility

- Keyboard navigation: Tab to focus, Enter/Space to activate
- Screen reader: Announces label and state
- ARIA: Uses `aria-disabled` when disabled

## Design Tokens Used

- `--color-action-primary`: Primary background
- `--space-2`, `--space-4`: Padding
- `--radius-md`: Border radius

## Related Components

- [OtherComponent](./OtherComponent.md): For similar use cases
- [ParentOrganism](../organisms/ParentOrganism.md): Often contains this component
```
</component_documentation>

<storybook_stories>
## Storybook Story Templates

### Atom Story Template

```typescript
// atoms/Button/Button.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { Button } from './Button';

const meta: Meta<typeof Button> = {
  title: 'Atoms/Button',
  component: Button,
  tags: ['autodocs'],
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'A button component for triggering actions.',
      },
    },
  },
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'ghost', 'destructive'],
      description: 'Visual style variant',
      table: {
        type: { summary: 'string' },
        defaultValue: { summary: 'primary' },
      },
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
      description: 'Size of the button',
      table: {
        type: { summary: 'string' },
        defaultValue: { summary: 'md' },
      },
    },
    isLoading: {
      control: 'boolean',
      description: 'Shows loading spinner',
    },
    isDisabled: {
      control: 'boolean',
      description: 'Disables the button',
    },
    onClick: { action: 'clicked' },
  },
};

export default meta;
type Story = StoryObj<typeof Button>;

/**
 * The default button style. Use for primary actions.
 */
export const Primary: Story = {
  args: {
    variant: 'primary',
    children: 'Primary Button',
  },
};

/**
 * Secondary buttons for less prominent actions.
 */
export const Secondary: Story = {
  args: {
    variant: 'secondary',
    children: 'Secondary Button',
  },
};

/**
 * Ghost buttons for tertiary actions or within content.
 */
export const Ghost: Story = {
  args: {
    variant: 'ghost',
    children: 'Ghost Button',
  },
};

/**
 * Destructive buttons for dangerous actions like delete.
 */
export const Destructive: Story = {
  args: {
    variant: 'destructive',
    children: 'Delete',
  },
};

/**
 * Loading state shows a spinner and disables interaction.
 */
export const Loading: Story = {
  args: {
    isLoading: true,
    children: 'Loading...',
  },
};

/**
 * Disabled buttons cannot be interacted with.
 */
export const Disabled: Story = {
  args: {
    isDisabled: true,
    children: 'Disabled',
  },
};

/**
 * Buttons with icons for enhanced visual communication.
 */
export const WithIcon: Story = {
  args: {
    children: 'Add Item',
    leftIcon: <PlusIcon />,
  },
};

/**
 * All sizes comparison.
 */
export const Sizes: Story = {
  render: () => (
    <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
      <Button size="sm">Small</Button>
      <Button size="md">Medium</Button>
      <Button size="lg">Large</Button>
    </div>
  ),
};

/**
 * All variants comparison.
 */
export const AllVariants: Story = {
  render: () => (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
      <div style={{ display: 'flex', gap: '0.5rem' }}>
        <Button variant="primary">Primary</Button>
        <Button variant="secondary">Secondary</Button>
        <Button variant="ghost">Ghost</Button>
        <Button variant="destructive">Destructive</Button>
      </div>
      <div style={{ display: 'flex', gap: '0.5rem' }}>
        <Button variant="primary" isDisabled>Primary</Button>
        <Button variant="secondary" isDisabled>Secondary</Button>
        <Button variant="ghost" isDisabled>Ghost</Button>
        <Button variant="destructive" isDisabled>Destructive</Button>
      </div>
    </div>
  ),
};
```

### Molecule Story Template

```typescript
// molecules/FormField/FormField.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { useState } from 'react';
import { FormField } from './FormField';

const meta: Meta<typeof FormField> = {
  title: 'Molecules/FormField',
  component: FormField,
  tags: ['autodocs'],
  parameters: {
    layout: 'padded',
    docs: {
      description: {
        component: 'A form field combining label, input, and helper/error text.',
      },
    },
  },
  decorators: [
    (Story) => (
      <div style={{ maxWidth: '400px' }}>
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof FormField>;

/**
 * Basic form field with label and input.
 */
export const Default: Story = {
  render: () => {
    const [value, setValue] = useState('');
    return (
      <FormField
        label="Email"
        value={value}
        onChange={setValue}
        placeholder="you@example.com"
      />
    );
  },
};

/**
 * Required field with asterisk indicator.
 */
export const Required: Story = {
  render: () => {
    const [value, setValue] = useState('');
    return (
      <FormField
        label="Email"
        value={value}
        onChange={setValue}
        isRequired
      />
    );
  },
};

/**
 * Field with helper text for guidance.
 */
export const WithHelperText: Story = {
  render: () => {
    const [value, setValue] = useState('');
    return (
      <FormField
        label="Password"
        value={value}
        onChange={setValue}
        type="password"
        helperText="Must be at least 8 characters"
      />
    );
  },
};

/**
 * Field in error state with error message.
 */
export const WithError: Story = {
  render: () => {
    const [value, setValue] = useState('invalid');
    return (
      <FormField
        label="Email"
        value={value}
        onChange={setValue}
        errorMessage="Please enter a valid email address"
      />
    );
  },
};

/**
 * Disabled field that cannot be edited.
 */
export const Disabled: Story = {
  render: () => (
    <FormField
      label="Email"
      value="readonly@example.com"
      onChange={() => {}}
      isDisabled
    />
  ),
};
```

### Organism Story Template

```typescript
// organisms/LoginForm/LoginForm.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { within, userEvent, expect } from '@storybook/test';
import { LoginForm } from './LoginForm';

const meta: Meta<typeof LoginForm> = {
  title: 'Organisms/LoginForm',
  component: LoginForm,
  tags: ['autodocs'],
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'A complete login form with validation and error handling.',
      },
    },
  },
  decorators: [
    (Story) => (
      <div style={{ width: '400px', padding: '2rem' }}>
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof LoginForm>;

/**
 * Default login form.
 */
export const Default: Story = {
  args: {
    onSubmit: async (data) => {
      console.log('Submit:', data);
      await new Promise((r) => setTimeout(r, 1000));
    },
    onForgotPassword: () => console.log('Forgot password clicked'),
  },
};

/**
 * Form with validation errors displayed.
 */
export const WithValidationErrors: Story = {
  args: {
    ...Default.args,
  },
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement);

    // Click submit without filling form
    await userEvent.click(canvas.getByRole('button', { name: /log in/i }));

    // Verify error messages appear
    await expect(canvas.getByText(/email is required/i)).toBeInTheDocument();
    await expect(canvas.getByText(/password is required/i)).toBeInTheDocument();
  },
};

/**
 * Form during submission (loading state).
 */
export const Submitting: Story = {
  args: {
    onSubmit: async () => {
      await new Promise((r) => setTimeout(r, 10000)); // Long delay
    },
    onForgotPassword: () => {},
  },
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement);

    await userEvent.type(canvas.getByLabelText(/email/i), 'test@example.com');
    await userEvent.type(canvas.getByLabelText(/password/i), 'password123');
    await userEvent.click(canvas.getByRole('button', { name: /log in/i }));
  },
};

/**
 * Form showing server error.
 */
export const WithServerError: Story = {
  args: {
    onSubmit: async () => {
      await new Promise((r) => setTimeout(r, 500));
      throw new Error('Invalid credentials');
    },
    onForgotPassword: () => {},
  },
  play: async ({ canvasElement }) => {
    const canvas = within(canvasElement);

    await userEvent.type(canvas.getByLabelText(/email/i), 'test@example.com');
    await userEvent.type(canvas.getByLabelText(/password/i), 'password123');
    await userEvent.click(canvas.getByRole('button', { name: /log in/i }));
  },
};
```
</storybook_stories>

<token_documentation>
## Token Documentation

### Token Documentation Template

```markdown
# Design Tokens

Design tokens are the visual design atoms of the design system. They define
colors, typography, spacing, and other visual properties.

## Color Tokens

### Primitive Colors

| Token | Value | Preview |
|-------|-------|---------|
| `--color-blue-500` | #3b82f6 | ![](color-preview) |
| `--color-blue-600` | #2563eb | ![](color-preview) |
| `--color-gray-900` | #111827 | ![](color-preview) |

### Semantic Colors

| Token | References | Usage |
|-------|------------|-------|
| `--color-text-primary` | `--color-gray-900` | Main body text |
| `--color-text-secondary` | `--color-gray-600` | Secondary/helper text |
| `--color-action-primary` | `--color-blue-600` | Buttons, links, interactive |
| `--color-feedback-error` | `--color-red-600` | Error states, validation |

## Spacing Tokens

| Token | Value | Use Case |
|-------|-------|----------|
| `--space-1` | 4px | Tight spacing, icon gaps |
| `--space-2` | 8px | Default component padding |
| `--space-4` | 16px | Card padding, section gaps |
| `--space-6` | 24px | Large section gaps |
| `--space-8` | 32px | Page-level spacing |

## Typography Tokens

### Font Sizes

| Token | Value | Use Case |
|-------|-------|----------|
| `--font-size-xs` | 12px | Captions, labels |
| `--font-size-sm` | 14px | Secondary text, helper |
| `--font-size-base` | 16px | Body text |
| `--font-size-lg` | 18px | Large body, subheadings |
| `--font-size-xl` | 20px | Section headings |
| `--font-size-2xl` | 24px | Page headings |

### Font Weights

| Token | Value | Use Case |
|-------|-------|----------|
| `--font-weight-normal` | 400 | Body text |
| `--font-weight-medium` | 500 | Emphasis, buttons |
| `--font-weight-bold` | 700 | Headings, strong emphasis |

## Shadow Tokens

| Token | Value | Use Case |
|-------|-------|----------|
| `--shadow-sm` | `0 1px 2px rgba(0,0,0,0.05)` | Subtle elevation |
| `--shadow-md` | `0 4px 6px rgba(0,0,0,0.1)` | Cards, dropdowns |
| `--shadow-lg` | `0 10px 15px rgba(0,0,0,0.1)` | Modals, popovers |

## Border Radius Tokens

| Token | Value | Use Case |
|-------|-------|----------|
| `--radius-sm` | 4px | Inputs, small elements |
| `--radius-md` | 6px | Buttons, cards |
| `--radius-lg` | 8px | Large cards, modals |
| `--radius-full` | 9999px | Pills, avatars |
```
</token_documentation>

<usage_guidelines>
## Usage Guidelines Documentation

### Do's and Don'ts Template

```markdown
# Button Usage Guidelines

## When to Use

- Primary actions (Submit, Save, Confirm)
- Navigation actions (Continue, Next)
- Triggering workflows

## When NOT to Use

- Navigation links (use Link instead)
- Menu items (use MenuItem)
- Icon-only actions (use IconButton)

## Do's ✓

### Use clear, action-oriented labels

\`\`\`tsx
// ✓ Good
<Button>Save Changes</Button>
<Button>Add to Cart</Button>

// ✗ Avoid
<Button>Click Here</Button>
<Button>Submit</Button>
\`\`\`

### Use appropriate variants

\`\`\`tsx
// ✓ Good: Primary for main action
<Button variant="primary">Confirm Purchase</Button>

// ✓ Good: Destructive for dangerous actions
<Button variant="destructive">Delete Account</Button>

// ✗ Avoid: Primary for cancel
<Button variant="primary">Cancel</Button>
\`\`\`

### Provide loading feedback

\`\`\`tsx
// ✓ Good
<Button isLoading={isSubmitting}>
  {isSubmitting ? 'Saving...' : 'Save'}
</Button>
\`\`\`

## Don'ts ✗

### Don't use multiple primary buttons

\`\`\`tsx
// ✗ Bad: Two primary buttons compete
<Button variant="primary">Save Draft</Button>
<Button variant="primary">Publish</Button>

// ✓ Good: One primary, one secondary
<Button variant="secondary">Save Draft</Button>
<Button variant="primary">Publish</Button>
\`\`\`

### Don't disable without explanation

\`\`\`tsx
// ✗ Bad: Why is it disabled?
<Button isDisabled>Submit</Button>

// ✓ Good: Tooltip explains why
<Tooltip content="Complete all required fields first">
  <Button isDisabled>Submit</Button>
</Tooltip>
\`\`\`

## Accessibility Checklist

- [ ] Has accessible label (text or aria-label)
- [ ] Disabled state uses aria-disabled
- [ ] Loading state uses aria-busy
- [ ] Color contrast meets WCAG AA
- [ ] Touch target at least 44x44px
```
</usage_guidelines>

<changelog>
## Component Changelog Template

```markdown
# Button Changelog

## [2.0.0] - 2024-01-15

### Breaking Changes

- Renamed `loading` prop to `isLoading`
- Renamed `disabled` prop to `isDisabled`
- Removed `type` prop (use native `type` attribute)

### Migration

\`\`\`diff
- <Button loading disabled>Save</Button>
+ <Button isLoading isDisabled>Save</Button>
\`\`\`

## [1.2.0] - 2024-01-10

### Added

- New `ghost` variant
- New `leftIcon` and `rightIcon` props

### Changed

- Improved focus ring visibility

## [1.1.0] - 2024-01-05

### Added

- New `size="lg"` option
- Support for `as` prop for polymorphic rendering

### Fixed

- Fixed color contrast issue in secondary variant
```
</changelog>

<readme_template>
## Design System README Template

```markdown
# [System Name] Design System

A comprehensive design system built with atomic design principles.

## Installation

\`\`\`bash
npm install @company/design-system
\`\`\`

## Quick Start

\`\`\`tsx
// Import tokens
import '@company/design-system/tokens.css';

// Import components
import { Button, Input, FormField } from '@company/design-system';

function App() {
  return (
    <Button variant="primary">Get Started</Button>
  );
}
\`\`\`

## Documentation

- [Storybook](https://design-system.example.com)
- [Figma Library](https://figma.com/...)
- [Design Tokens](./docs/tokens.md)

## Component Status

| Component | Status | Version |
|-----------|--------|---------|
| Button | ✅ Stable | 2.0.0 |
| Input | ✅ Stable | 1.5.0 |
| Select | 🚧 Beta | 0.9.0 |
| DatePicker | 📋 Planned | — |

## Architecture

\`\`\`
src/
├── tokens/      # Design tokens (CSS custom properties)
├── atoms/       # Basic building blocks
├── molecules/   # Simple compositions
├── organisms/   # Complex sections
└── templates/   # Page layouts
\`\`\`

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md)

## License

MIT
```
</readme_template>
