# Testing Strategies for Atomic Design Systems

<overview>
Testing atomic design systems requires a layered approach that matches the component
hierarchy. Each level has different testing needs—atoms need unit tests, molecules
need integration tests, and organisms need behavior tests.

This reference covers testing strategies at each atomic level plus visual regression
and accessibility testing.
</overview>

<testing_pyramid>
## The Atomic Testing Pyramid

```
                    ┌─────────────────┐
                    │     E2E Tests   │  ← Pages (critical flows)
                    │    (few, slow)  │
                  ┌─┴─────────────────┴─┐
                  │  Integration Tests  │  ← Organisms (behavior)
                  │   (some, medium)    │
              ┌───┴─────────────────────┴───┐
              │   Component/Unit Tests      │  ← Atoms & Molecules
              │      (many, fast)           │
          ┌───┴─────────────────────────────┴───┐
          │        Visual Regression            │  ← All levels
          │        (snapshot-based)             │
      ┌───┴─────────────────────────────────────┴───┐
      │           Accessibility Tests               │  ← All levels
      │             (automated + manual)            │
      └─────────────────────────────────────────────┘
```

### Test Distribution by Level

| Level | Test Types | Coverage Goal |
|-------|------------|---------------|
| **Atoms** | Unit tests, visual snapshots | 100% of variants/states |
| **Molecules** | Unit + integration, visual | Core functionality |
| **Organisms** | Integration, behavior | User flows |
| **Templates** | Layout tests, responsive | Breakpoints |
| **Pages** | E2E, smoke tests | Critical paths |
</testing_pyramid>

<atom_testing>
## Atom Testing

Atoms are stateless and simple—test all variants and states.

### What to Test

- All visual variants render correctly
- All size variants render correctly
- Disabled state behavior
- Event handlers fire correctly
- Accessibility attributes present
- Keyboard interaction works

### Example: Button Atom Tests

```typescript
// atoms/Button/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { axe, toHaveNoViolations } from 'jest-axe';
import { Button } from './Button';

expect.extend(toHaveNoViolations);

describe('Button', () => {
  describe('rendering', () => {
    it('renders children correctly', () => {
      render(<Button>Click me</Button>);
      expect(screen.getByRole('button', { name: 'Click me' })).toBeInTheDocument();
    });

    it('renders with left icon', () => {
      render(
        <Button leftIcon={<span data-testid="icon">+</span>}>
          Add Item
        </Button>
      );
      expect(screen.getByTestId('icon')).toBeInTheDocument();
    });

    it('renders with right icon', () => {
      render(
        <Button rightIcon={<span data-testid="icon">→</span>}>
          Next
        </Button>
      );
      expect(screen.getByTestId('icon')).toBeInTheDocument();
    });
  });

  describe('variants', () => {
    it.each(['primary', 'secondary', 'ghost', 'destructive'] as const)(
      'renders %s variant',
      (variant) => {
        render(<Button variant={variant}>Button</Button>);
        const button = screen.getByRole('button');
        expect(button).toHaveClass(`button--${variant}`);
      }
    );
  });

  describe('sizes', () => {
    it.each(['sm', 'md', 'lg'] as const)('renders %s size', (size) => {
      render(<Button size={size}>Button</Button>);
      const button = screen.getByRole('button');
      expect(button).toHaveClass(`button--${size}`);
    });
  });

  describe('states', () => {
    it('is disabled when isDisabled is true', () => {
      render(<Button isDisabled>Button</Button>);
      expect(screen.getByRole('button')).toBeDisabled();
    });

    it('shows loading state', () => {
      render(<Button isLoading>Button</Button>);
      const button = screen.getByRole('button');
      expect(button).toHaveAttribute('aria-busy', 'true');
      expect(button).toBeDisabled();
    });

    it('is disabled when loading', () => {
      const handleClick = jest.fn();
      render(<Button isLoading onClick={handleClick}>Button</Button>);

      fireEvent.click(screen.getByRole('button'));
      expect(handleClick).not.toHaveBeenCalled();
    });
  });

  describe('interactions', () => {
    it('calls onClick when clicked', async () => {
      const handleClick = jest.fn();
      render(<Button onClick={handleClick}>Click me</Button>);

      await userEvent.click(screen.getByRole('button'));
      expect(handleClick).toHaveBeenCalledTimes(1);
    });

    it('does not call onClick when disabled', async () => {
      const handleClick = jest.fn();
      render(<Button isDisabled onClick={handleClick}>Click me</Button>);

      await userEvent.click(screen.getByRole('button'));
      expect(handleClick).not.toHaveBeenCalled();
    });

    it('can be focused via keyboard', async () => {
      render(<Button>Click me</Button>);

      await userEvent.tab();
      expect(screen.getByRole('button')).toHaveFocus();
    });

    it('can be activated via Enter key', async () => {
      const handleClick = jest.fn();
      render(<Button onClick={handleClick}>Click me</Button>);

      await userEvent.tab();
      await userEvent.keyboard('{Enter}');
      expect(handleClick).toHaveBeenCalledTimes(1);
    });

    it('can be activated via Space key', async () => {
      const handleClick = jest.fn();
      render(<Button onClick={handleClick}>Click me</Button>);

      await userEvent.tab();
      await userEvent.keyboard(' ');
      expect(handleClick).toHaveBeenCalledTimes(1);
    });
  });

  describe('accessibility', () => {
    it('has no accessibility violations', async () => {
      const { container } = render(<Button>Click me</Button>);
      const results = await axe(container);
      expect(results).toHaveNoViolations();
    });

    it('has no violations when disabled', async () => {
      const { container } = render(<Button isDisabled>Click me</Button>);
      const results = await axe(container);
      expect(results).toHaveNoViolations();
    });
  });
});
```

### Example: Input Atom Tests

```typescript
// atoms/Input/Input.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Input } from './Input';

describe('Input', () => {
  it('renders with placeholder', () => {
    render(<Input value="" onChange={() => {}} placeholder="Enter text" />);
    expect(screen.getByPlaceholderText('Enter text')).toBeInTheDocument();
  });

  it('calls onChange with new value', async () => {
    const handleChange = jest.fn();
    render(<Input value="" onChange={handleChange} />);

    await userEvent.type(screen.getByRole('textbox'), 'hello');
    expect(handleChange).toHaveBeenLastCalledWith('hello');
  });

  it('displays the value', () => {
    render(<Input value="test value" onChange={() => {}} />);
    expect(screen.getByRole('textbox')).toHaveValue('test value');
  });

  it('is disabled when isDisabled is true', () => {
    render(<Input value="" onChange={() => {}} isDisabled />);
    expect(screen.getByRole('textbox')).toBeDisabled();
  });

  it('shows error state', () => {
    render(<Input value="" onChange={() => {}} hasError />);
    expect(screen.getByRole('textbox')).toHaveAttribute('aria-invalid', 'true');
  });
});
```
</atom_testing>

<molecule_testing>
## Molecule Testing

Molecules combine atoms—test the integration and composite behavior.

### What to Test

- Atoms compose correctly
- Data flows between atoms
- Combined behavior works
- Error states propagate
- Accessibility of the composition

### Example: FormField Molecule Tests

```typescript
// molecules/FormField/FormField.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { axe } from 'jest-axe';
import { FormField } from './FormField';

describe('FormField', () => {
  const defaultProps = {
    label: 'Email',
    value: '',
    onChange: jest.fn(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('composition', () => {
    it('renders label and input', () => {
      render(<FormField {...defaultProps} />);

      expect(screen.getByLabelText('Email')).toBeInTheDocument();
    });

    it('associates label with input via htmlFor', () => {
      render(<FormField {...defaultProps} />);

      const input = screen.getByLabelText('Email');
      const label = screen.getByText('Email');

      expect(label).toHaveAttribute('for', input.id);
    });

    it('shows required indicator when isRequired', () => {
      render(<FormField {...defaultProps} isRequired />);

      expect(screen.getByText('*')).toBeInTheDocument();
    });
  });

  describe('helper text and errors', () => {
    it('shows helper text', () => {
      render(<FormField {...defaultProps} helperText="We'll never share your email" />);

      expect(screen.getByText("We'll never share your email")).toBeInTheDocument();
    });

    it('shows error message instead of helper text when error', () => {
      render(
        <FormField
          {...defaultProps}
          helperText="Helper"
          errorMessage="Email is required"
        />
      );

      expect(screen.getByText('Email is required')).toBeInTheDocument();
      expect(screen.queryByText('Helper')).not.toBeInTheDocument();
    });

    it('marks input as invalid when error', () => {
      render(<FormField {...defaultProps} errorMessage="Invalid" />);

      expect(screen.getByLabelText('Email')).toHaveAttribute('aria-invalid', 'true');
    });

    it('associates error message with input via aria-describedby', () => {
      render(<FormField {...defaultProps} errorMessage="Invalid email" />);

      const input = screen.getByLabelText('Email');
      const errorId = input.getAttribute('aria-describedby');
      const error = document.getElementById(errorId!);

      expect(error).toHaveTextContent('Invalid email');
    });
  });

  describe('interactions', () => {
    it('calls onChange when typing', async () => {
      const handleChange = jest.fn();
      render(<FormField {...defaultProps} onChange={handleChange} />);

      await userEvent.type(screen.getByLabelText('Email'), 'test@example.com');

      expect(handleChange).toHaveBeenCalled();
    });
  });

  describe('accessibility', () => {
    it('has no accessibility violations', async () => {
      const { container } = render(<FormField {...defaultProps} />);
      expect(await axe(container)).toHaveNoViolations();
    });

    it('has no violations with error state', async () => {
      const { container } = render(
        <FormField {...defaultProps} errorMessage="Invalid" />
      );
      expect(await axe(container)).toHaveNoViolations();
    });
  });
});
```

### Example: SearchInput Molecule Tests

```typescript
// molecules/SearchInput/SearchInput.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { SearchInput } from './SearchInput';

describe('SearchInput', () => {
  it('renders input and button', () => {
    render(<SearchInput onSearch={() => {}} />);

    expect(screen.getByPlaceholderText('Search...')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /search/i })).toBeInTheDocument();
  });

  it('calls onSearch when form submitted', async () => {
    const handleSearch = jest.fn();
    render(<SearchInput onSearch={handleSearch} />);

    await userEvent.type(screen.getByPlaceholderText('Search...'), 'query');
    await userEvent.click(screen.getByRole('button', { name: /search/i }));

    expect(handleSearch).toHaveBeenCalledWith('query');
  });

  it('calls onSearch when Enter pressed', async () => {
    const handleSearch = jest.fn();
    render(<SearchInput onSearch={handleSearch} />);

    await userEvent.type(screen.getByPlaceholderText('Search...'), 'query{Enter}');

    expect(handleSearch).toHaveBeenCalledWith('query');
  });

  it('shows clear button when value exists', async () => {
    render(<SearchInput onSearch={() => {}} />);

    expect(screen.queryByRole('button', { name: /clear/i })).not.toBeInTheDocument();

    await userEvent.type(screen.getByPlaceholderText('Search...'), 'test');

    expect(screen.getByRole('button', { name: /clear/i })).toBeInTheDocument();
  });

  it('clears input and calls onSearch when clear clicked', async () => {
    const handleSearch = jest.fn();
    render(<SearchInput onSearch={handleSearch} />);

    await userEvent.type(screen.getByPlaceholderText('Search...'), 'test');
    await userEvent.click(screen.getByRole('button', { name: /clear/i }));

    expect(screen.getByPlaceholderText('Search...')).toHaveValue('');
    expect(handleSearch).toHaveBeenCalledWith('');
  });

  it('shows loading state', () => {
    render(<SearchInput onSearch={() => {}} isLoading />);

    expect(screen.getByRole('button', { name: /search/i })).toHaveAttribute('aria-busy', 'true');
  });
});
```
</molecule_testing>

<organism_testing>
## Organism Testing

Organisms have complex behavior—test user flows and interactions.

### What to Test

- Complete user workflows
- State management
- Form validation
- Error handling
- API integration (mocked)

### Example: LoginForm Organism Tests

```typescript
// organisms/LoginForm/LoginForm.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LoginForm } from './LoginForm';

describe('LoginForm', () => {
  const defaultProps = {
    onSubmit: jest.fn(),
    onForgotPassword: jest.fn(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('rendering', () => {
    it('renders email and password fields', () => {
      render(<LoginForm {...defaultProps} />);

      expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
      expect(screen.getByLabelText(/password/i)).toBeInTheDocument();
    });

    it('renders submit button', () => {
      render(<LoginForm {...defaultProps} />);

      expect(screen.getByRole('button', { name: /log in/i })).toBeInTheDocument();
    });

    it('renders forgot password link', () => {
      render(<LoginForm {...defaultProps} />);

      expect(screen.getByText(/forgot password/i)).toBeInTheDocument();
    });
  });

  describe('validation', () => {
    it('shows error when email is empty', async () => {
      render(<LoginForm {...defaultProps} />);

      await userEvent.click(screen.getByRole('button', { name: /log in/i }));

      expect(screen.getByText(/email is required/i)).toBeInTheDocument();
    });

    it('shows error when email is invalid', async () => {
      render(<LoginForm {...defaultProps} />);

      await userEvent.type(screen.getByLabelText(/email/i), 'invalid');
      await userEvent.click(screen.getByRole('button', { name: /log in/i }));

      expect(screen.getByText(/valid email/i)).toBeInTheDocument();
    });

    it('shows error when password is too short', async () => {
      render(<LoginForm {...defaultProps} />);

      await userEvent.type(screen.getByLabelText(/email/i), 'test@example.com');
      await userEvent.type(screen.getByLabelText(/password/i), '123');
      await userEvent.click(screen.getByRole('button', { name: /log in/i }));

      expect(screen.getByText(/at least 8 characters/i)).toBeInTheDocument();
    });

    it('clears error when user starts typing', async () => {
      render(<LoginForm {...defaultProps} />);

      await userEvent.click(screen.getByRole('button', { name: /log in/i }));
      expect(screen.getByText(/email is required/i)).toBeInTheDocument();

      await userEvent.type(screen.getByLabelText(/email/i), 't');
      expect(screen.queryByText(/email is required/i)).not.toBeInTheDocument();
    });
  });

  describe('submission', () => {
    it('calls onSubmit with form data when valid', async () => {
      const handleSubmit = jest.fn().mockResolvedValue(undefined);
      render(<LoginForm {...defaultProps} onSubmit={handleSubmit} />);

      await userEvent.type(screen.getByLabelText(/email/i), 'test@example.com');
      await userEvent.type(screen.getByLabelText(/password/i), 'password123');
      await userEvent.click(screen.getByRole('button', { name: /log in/i }));

      expect(handleSubmit).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
      });
    });

    it('shows loading state during submission', async () => {
      const handleSubmit = jest.fn().mockImplementation(
        () => new Promise((resolve) => setTimeout(resolve, 100))
      );
      render(<LoginForm {...defaultProps} onSubmit={handleSubmit} />);

      await userEvent.type(screen.getByLabelText(/email/i), 'test@example.com');
      await userEvent.type(screen.getByLabelText(/password/i), 'password123');
      await userEvent.click(screen.getByRole('button', { name: /log in/i }));

      expect(screen.getByRole('button', { name: /log in/i })).toHaveAttribute('aria-busy', 'true');
    });

    it('shows error when submission fails', async () => {
      const handleSubmit = jest.fn().mockRejectedValue(new Error('Invalid credentials'));
      render(<LoginForm {...defaultProps} onSubmit={handleSubmit} />);

      await userEvent.type(screen.getByLabelText(/email/i), 'test@example.com');
      await userEvent.type(screen.getByLabelText(/password/i), 'password123');
      await userEvent.click(screen.getByRole('button', { name: /log in/i }));

      await waitFor(() => {
        expect(screen.getByText(/invalid email or password/i)).toBeInTheDocument();
      });
    });
  });

  describe('forgot password', () => {
    it('calls onForgotPassword when link clicked', async () => {
      render(<LoginForm {...defaultProps} />);

      await userEvent.click(screen.getByText(/forgot password/i));

      expect(defaultProps.onForgotPassword).toHaveBeenCalled();
    });
  });
});
```
</organism_testing>

<visual_testing>
## Visual Regression Testing

Use Storybook + Chromatic or Percy for visual testing.

### Storybook Stories for Visual Tests

```typescript
// atoms/Button/Button.stories.tsx
import type { Meta, StoryObj } from '@storybook/react';
import { Button } from './Button';

const meta: Meta<typeof Button> = {
  title: 'Atoms/Button',
  component: Button,
  parameters: {
    chromatic: { viewports: [320, 768, 1200] },
  },
  argTypes: {
    variant: {
      control: 'select',
      options: ['primary', 'secondary', 'ghost', 'destructive'],
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
    },
  },
};

export default meta;
type Story = StoryObj<typeof Button>;

// Individual stories for visual testing
export const Primary: Story = {
  args: { variant: 'primary', children: 'Primary Button' },
};

export const Secondary: Story = {
  args: { variant: 'secondary', children: 'Secondary Button' },
};

export const Ghost: Story = {
  args: { variant: 'ghost', children: 'Ghost Button' },
};

export const Destructive: Story = {
  args: { variant: 'destructive', children: 'Delete' },
};

export const Loading: Story = {
  args: { isLoading: true, children: 'Loading...' },
};

export const Disabled: Story = {
  args: { isDisabled: true, children: 'Disabled' },
};

// Matrix story for all combinations
export const AllVariants: Story = {
  render: () => (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
      {(['primary', 'secondary', 'ghost', 'destructive'] as const).map((variant) => (
        <div key={variant} style={{ display: 'flex', gap: '0.5rem', alignItems: 'center' }}>
          {(['sm', 'md', 'lg'] as const).map((size) => (
            <Button key={`${variant}-${size}`} variant={variant} size={size}>
              {variant} {size}
            </Button>
          ))}
        </div>
      ))}
    </div>
  ),
};

// States story
export const AllStates: Story = {
  render: () => (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
      <Button>Default</Button>
      <Button isDisabled>Disabled</Button>
      <Button isLoading>Loading</Button>
    </div>
  ),
};
```

### Chromatic Configuration

```javascript
// .storybook/main.js
module.exports = {
  stories: ['../src/**/*.stories.@(js|jsx|ts|tsx)'],
  addons: ['@storybook/addon-essentials'],
  staticDirs: ['../public'],
};

// chromatic.config.json
{
  "projectToken": "your-project-token",
  "buildScriptName": "build-storybook",
  "onlyChanged": true,
  "zip": true
}
```

### Snapshot Tests (Alternative)

```typescript
// Button.snapshot.test.tsx
import { render } from '@testing-library/react';
import { Button } from './Button';

describe('Button Snapshots', () => {
  it.each(['primary', 'secondary', 'ghost', 'destructive'] as const)(
    'matches snapshot for %s variant',
    (variant) => {
      const { container } = render(<Button variant={variant}>Button</Button>);
      expect(container.firstChild).toMatchSnapshot();
    }
  );
});
```
</visual_testing>

<accessibility_testing>
## Accessibility Testing

### Automated Testing with jest-axe

```typescript
// setupTests.ts
import '@testing-library/jest-dom';
import { toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);
```

```typescript
// Reusable a11y test helper
import { axe, toHaveNoViolations } from 'jest-axe';
import { render, RenderResult } from '@testing-library/react';

export async function testAccessibility(ui: React.ReactElement): Promise<void> {
  const { container } = render(ui);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
}

// Usage
describe('Button accessibility', () => {
  it('has no violations', async () => {
    await testAccessibility(<Button>Click me</Button>);
  });
});
```

### Storybook Accessibility Addon

```javascript
// .storybook/main.js
module.exports = {
  addons: ['@storybook/addon-a11y'],
};

// Story with a11y config
export const Primary: Story = {
  args: { variant: 'primary', children: 'Button' },
  parameters: {
    a11y: {
      config: {
        rules: [
          { id: 'color-contrast', enabled: true },
          { id: 'button-name', enabled: true },
        ],
      },
    },
  },
};
```

### Manual Testing Checklist

```markdown
## Keyboard Navigation
- [ ] All interactive elements focusable via Tab
- [ ] Focus order logical
- [ ] Focus visible (outline/ring)
- [ ] Escape closes modals/dropdowns
- [ ] Enter/Space activates buttons
- [ ] Arrow keys navigate lists/menus

## Screen Reader
- [ ] All images have alt text
- [ ] Form fields have labels
- [ ] Errors announced via aria-live
- [ ] Dynamic content updates announced
- [ ] Headings have proper hierarchy

## Visual
- [ ] Color contrast meets WCAG AA (4.5:1 text, 3:1 UI)
- [ ] Not relying on color alone for meaning
- [ ] Text resizable to 200% without loss
- [ ] Touch targets at least 44x44px
```
</accessibility_testing>

<e2e_testing>
## E2E Testing (Pages)

### Playwright Example

```typescript
// e2e/login.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Login Page', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
  });

  test('successful login redirects to dashboard', async ({ page }) => {
    await page.fill('[data-testid="email-input"]', 'user@example.com');
    await page.fill('[data-testid="password-input"]', 'password123');
    await page.click('[data-testid="submit-button"]');

    await expect(page).toHaveURL('/dashboard');
  });

  test('shows error for invalid credentials', async ({ page }) => {
    await page.fill('[data-testid="email-input"]', 'wrong@example.com');
    await page.fill('[data-testid="password-input"]', 'wrongpassword');
    await page.click('[data-testid="submit-button"]');

    await expect(page.locator('[role="alert"]')).toContainText('Invalid');
  });

  test('forgot password link navigates correctly', async ({ page }) => {
    await page.click('text=Forgot password');
    await expect(page).toHaveURL('/forgot-password');
  });
});
```
</e2e_testing>

<test_ids>
## Test ID Conventions

```typescript
// Consistent data-testid naming
const testIds = {
  // Pattern: {component}-{element}-{variant}
  button: 'button',
  submitButton: 'submit-button',
  cancelButton: 'cancel-button',

  input: 'input',
  emailInput: 'email-input',
  passwordInput: 'password-input',

  form: 'form',
  loginForm: 'login-form',

  modal: 'modal',
  modalClose: 'modal-close',
  modalContent: 'modal-content',

  // Pattern: {section}-{element}
  header: 'header',
  headerLogo: 'header-logo',
  headerNav: 'header-nav',
  headerUserMenu: 'header-user-menu',
};
```
</test_ids>

<checklist>
## Testing Checklist

### Atoms
- [ ] All variants render correctly
- [ ] All sizes render correctly
- [ ] Disabled state works
- [ ] Event handlers fire
- [ ] Keyboard accessible
- [ ] No a11y violations
- [ ] Visual snapshots captured

### Molecules
- [ ] Atoms compose correctly
- [ ] Data flows between atoms
- [ ] Combined behavior works
- [ ] Error states propagate
- [ ] Aria relationships set up

### Organisms
- [ ] User workflows complete
- [ ] Form validation works
- [ ] Error handling works
- [ ] Loading states show
- [ ] API integration tested (mocked)

### Templates
- [ ] Layout renders correctly
- [ ] Responsive breakpoints work
- [ ] Slots receive content

### Pages
- [ ] Critical paths covered by E2E
- [ ] Error pages render
- [ ] Loading states handle
</checklist>
