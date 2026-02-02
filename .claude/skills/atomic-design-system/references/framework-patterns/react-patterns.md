# React Patterns for Atomic Design

<overview>
This reference covers React-specific implementation patterns for atomic design systems,
including component structure, styling approaches, and TypeScript integration.
</overview>

<project_structure>
## Project Structure

### Recommended Structure

```
src/
├── design-system/
│   ├── tokens/
│   │   ├── colors.ts
│   │   ├── typography.ts
│   │   ├── spacing.ts
│   │   ├── shadows.ts
│   │   └── index.ts
│   │
│   ├── atoms/
│   │   ├── Button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.styles.ts
│   │   │   ├── Button.test.tsx
│   │   │   ├── Button.stories.tsx
│   │   │   ├── types.ts
│   │   │   └── index.ts
│   │   ├── Input/
│   │   ├── Icon/
│   │   └── index.ts
│   │
│   ├── molecules/
│   │   ├── FormField/
│   │   ├── SearchInput/
│   │   └── index.ts
│   │
│   ├── organisms/
│   │   ├── Header/
│   │   ├── Footer/
│   │   └── index.ts
│   │
│   ├── templates/
│   │   ├── DashboardTemplate/
│   │   └── index.ts
│   │
│   └── index.ts          # Main export
│
├── pages/                 # App-specific pages
│   ├── HomePage.tsx
│   └── DashboardPage.tsx
│
└── App.tsx
```

### Path Aliases (tsconfig.json)

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/tokens": ["src/design-system/tokens"],
      "@/atoms/*": ["src/design-system/atoms/*"],
      "@/molecules/*": ["src/design-system/molecules/*"],
      "@/organisms/*": ["src/design-system/organisms/*"],
      "@/templates/*": ["src/design-system/templates/*"],
      "@/design-system": ["src/design-system"]
    }
  }
}
```
</project_structure>

<atom_patterns>
## Atom Patterns

### Basic Atom Structure

```tsx
// atoms/Button/Button.tsx
import { forwardRef } from 'react';
import type { ButtonProps } from './types';
import { buttonStyles, buttonVariants } from './Button.styles';

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      variant = 'primary',
      size = 'md',
      isLoading = false,
      isDisabled = false,
      leftIcon,
      rightIcon,
      children,
      className,
      ...props
    },
    ref
  ) => {
    const disabled = isDisabled || isLoading;

    return (
      <button
        ref={ref}
        className={buttonStyles({ variant, size, className })}
        disabled={disabled}
        aria-busy={isLoading}
        {...props}
      >
        {isLoading && <Spinner size="sm" />}
        {!isLoading && leftIcon && <span className="button-icon-left">{leftIcon}</span>}
        <span className="button-label">{children}</span>
        {!isLoading && rightIcon && <span className="button-icon-right">{rightIcon}</span>}
      </button>
    );
  }
);

Button.displayName = 'Button';
```

### Types File

```tsx
// atoms/Button/types.ts
import type { ButtonHTMLAttributes, ReactNode } from 'react';

export type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'destructive';
export type ButtonSize = 'sm' | 'md' | 'lg';

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: ButtonVariant;
  size?: ButtonSize;
  isLoading?: boolean;
  isDisabled?: boolean;
  leftIcon?: ReactNode;
  rightIcon?: ReactNode;
}
```

### Index Export

```tsx
// atoms/Button/index.ts
export { Button } from './Button';
export type { ButtonProps, ButtonVariant, ButtonSize } from './types';
```

### Input Atom with Controlled Pattern

```tsx
// atoms/Input/Input.tsx
import { forwardRef } from 'react';
import type { InputProps } from './types';

export const Input = forwardRef<HTMLInputElement, InputProps>(
  (
    {
      value,
      onChange,
      hasError = false,
      isDisabled = false,
      leftElement,
      rightElement,
      className,
      ...props
    },
    ref
  ) => {
    return (
      <div className={inputWrapperStyles({ hasError, isDisabled, className })}>
        {leftElement && <span className="input-left">{leftElement}</span>}
        <input
          ref={ref}
          value={value}
          onChange={(e) => onChange?.(e.target.value)}
          disabled={isDisabled}
          aria-invalid={hasError}
          className="input-field"
          {...props}
        />
        {rightElement && <span className="input-right">{rightElement}</span>}
      </div>
    );
  }
);
```
</atom_patterns>

<molecule_patterns>
## Molecule Patterns

### Composing Atoms

```tsx
// molecules/FormField/FormField.tsx
import { Label } from '@/atoms/Label';
import { Input } from '@/atoms/Input';
import { Text } from '@/atoms/Text';
import type { FormFieldProps } from './types';

export function FormField({
  label,
  helperText,
  errorMessage,
  isRequired = false,
  isDisabled = false,
  id,
  ...inputProps
}: FormFieldProps) {
  const hasError = Boolean(errorMessage);
  const fieldId = id || `field-${label.toLowerCase().replace(/\s/g, '-')}`;

  return (
    <div className="form-field">
      <Label htmlFor={fieldId} isRequired={isRequired}>
        {label}
      </Label>

      <Input
        id={fieldId}
        hasError={hasError}
        isDisabled={isDisabled}
        aria-describedby={hasError ? `${fieldId}-error` : `${fieldId}-helper`}
        {...inputProps}
      />

      {hasError ? (
        <Text id={`${fieldId}-error`} variant="error" size="sm">
          {errorMessage}
        </Text>
      ) : helperText ? (
        <Text id={`${fieldId}-helper`} variant="secondary" size="sm">
          {helperText}
        </Text>
      ) : null}
    </div>
  );
}
```

### SearchInput Molecule

```tsx
// molecules/SearchInput/SearchInput.tsx
import { useState, useCallback } from 'react';
import { Input } from '@/atoms/Input';
import { Button } from '@/atoms/Button';
import { Icon } from '@/atoms/Icon';
import type { SearchInputProps } from './types';

export function SearchInput({
  onSearch,
  placeholder = 'Search...',
  isLoading = false,
  defaultValue = '',
}: SearchInputProps) {
  const [value, setValue] = useState(defaultValue);

  const handleSubmit = useCallback(
    (e: React.FormEvent) => {
      e.preventDefault();
      onSearch(value);
    },
    [value, onSearch]
  );

  const handleClear = useCallback(() => {
    setValue('');
    onSearch('');
  }, [onSearch]);

  return (
    <form className="search-input" onSubmit={handleSubmit}>
      <Input
        value={value}
        onChange={setValue}
        placeholder={placeholder}
        leftElement={<Icon name="search" />}
        rightElement={
          value && (
            <Button
              variant="ghost"
              size="sm"
              onClick={handleClear}
              type="button"
              aria-label="Clear search"
            >
              <Icon name="x" />
            </Button>
          )
        }
      />
      <Button type="submit" isLoading={isLoading}>
        Search
      </Button>
    </form>
  );
}
```

### Compound Component Pattern

```tsx
// molecules/Tabs/Tabs.tsx
import { createContext, useContext, useState, ReactNode } from 'react';

interface TabsContextValue {
  activeTab: string;
  setActiveTab: (value: string) => void;
}

const TabsContext = createContext<TabsContextValue | null>(null);

function useTabsContext() {
  const context = useContext(TabsContext);
  if (!context) {
    throw new Error('Tabs compound components must be used within Tabs');
  }
  return context;
}

interface TabsProps {
  defaultValue: string;
  children: ReactNode;
}

export function Tabs({ defaultValue, children }: TabsProps) {
  const [activeTab, setActiveTab] = useState(defaultValue);

  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
}

Tabs.List = function TabsList({ children }: { children: ReactNode }) {
  return (
    <div className="tabs-list" role="tablist">
      {children}
    </div>
  );
};

Tabs.Tab = function Tab({ value, children }: { value: string; children: ReactNode }) {
  const { activeTab, setActiveTab } = useTabsContext();
  const isActive = activeTab === value;

  return (
    <button
      role="tab"
      aria-selected={isActive}
      className={`tabs-tab ${isActive ? 'tabs-tab--active' : ''}`}
      onClick={() => setActiveTab(value)}
    >
      {children}
    </button>
  );
};

Tabs.Panel = function TabsPanel({ value, children }: { value: string; children: ReactNode }) {
  const { activeTab } = useTabsContext();

  if (activeTab !== value) return null;

  return (
    <div role="tabpanel" className="tabs-panel">
      {children}
    </div>
  );
};

// Usage
<Tabs defaultValue="tab1">
  <Tabs.List>
    <Tabs.Tab value="tab1">Tab 1</Tabs.Tab>
    <Tabs.Tab value="tab2">Tab 2</Tabs.Tab>
  </Tabs.List>
  <Tabs.Panel value="tab1">Content 1</Tabs.Panel>
  <Tabs.Panel value="tab2">Content 2</Tabs.Panel>
</Tabs>
```
</molecule_patterns>

<organism_patterns>
## Organism Patterns

### Header Organism

```tsx
// organisms/Header/Header.tsx
import { Logo } from '@/atoms/Logo';
import { Button } from '@/atoms/Button';
import { NavItem } from '@/molecules/NavItem';
import { SearchInput } from '@/molecules/SearchInput';
import { UserMenu } from '@/molecules/UserMenu';
import type { HeaderProps } from './types';

export function Header({
  user,
  navItems,
  onSearch,
  onLogin,
  onLogout,
}: HeaderProps) {
  return (
    <header className="header">
      <div className="header__left">
        <Logo />
        <nav className="header__nav" aria-label="Main navigation">
          {navItems.map((item) => (
            <NavItem key={item.href} {...item} />
          ))}
        </nav>
      </div>

      <div className="header__center">
        <SearchInput onSearch={onSearch} />
      </div>

      <div className="header__right">
        {user ? (
          <UserMenu user={user} onLogout={onLogout} />
        ) : (
          <Button onClick={onLogin}>Log In</Button>
        )}
      </div>
    </header>
  );
}
```

### Form Organism with State

```tsx
// organisms/LoginForm/LoginForm.tsx
import { useState, useCallback } from 'react';
import { FormField } from '@/molecules/FormField';
import { Button } from '@/atoms/Button';
import { Link } from '@/atoms/Link';
import type { LoginFormProps, LoginFormData, LoginFormErrors } from './types';

export function LoginForm({ onSubmit, onForgotPassword }: LoginFormProps) {
  const [formData, setFormData] = useState<LoginFormData>({
    email: '',
    password: '',
  });
  const [errors, setErrors] = useState<LoginFormErrors>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  const validate = useCallback((): boolean => {
    const newErrors: LoginFormErrors = {};

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

  const handleSubmit = useCallback(
    async (e: React.FormEvent) => {
      e.preventDefault();

      if (!validate()) return;

      setIsSubmitting(true);
      try {
        await onSubmit(formData);
      } catch (error) {
        setErrors({ form: 'Invalid email or password' });
      } finally {
        setIsSubmitting(false);
      }
    },
    [formData, validate, onSubmit]
  );

  const updateField = useCallback(
    (field: keyof LoginFormData) => (value: string) => {
      setFormData((prev) => ({ ...prev, [field]: value }));
      // Clear error when user starts typing
      if (errors[field]) {
        setErrors((prev) => ({ ...prev, [field]: undefined }));
      }
    },
    [errors]
  );

  return (
    <form className="login-form" onSubmit={handleSubmit}>
      {errors.form && (
        <div className="login-form__error" role="alert">
          {errors.form}
        </div>
      )}

      <FormField
        label="Email"
        type="email"
        value={formData.email}
        onChange={updateField('email')}
        errorMessage={errors.email}
        isRequired
        autoComplete="email"
      />

      <FormField
        label="Password"
        type="password"
        value={formData.password}
        onChange={updateField('password')}
        errorMessage={errors.password}
        isRequired
        autoComplete="current-password"
      />

      <div className="login-form__actions">
        <Button type="submit" isLoading={isSubmitting} className="login-form__submit">
          Log In
        </Button>
        <Link onClick={onForgotPassword}>Forgot password?</Link>
      </div>
    </form>
  );
}
```
</organism_patterns>

<template_patterns>
## Template Patterns

### Slot-Based Template

```tsx
// templates/DashboardTemplate/DashboardTemplate.tsx
import type { ReactNode } from 'react';

interface DashboardTemplateProps {
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
      <header className="dashboard-template__header">{header}</header>

      <div className="dashboard-template__body">
        <aside className="dashboard-template__sidebar">{sidebar}</aside>
        <main className="dashboard-template__content">{children}</main>
      </div>

      {footer && (
        <footer className="dashboard-template__footer">{footer}</footer>
      )}
    </div>
  );
}
```

### Template with Layout Context

```tsx
// templates/PageTemplate/PageTemplate.tsx
import { createContext, useContext, ReactNode } from 'react';

interface PageLayoutContextValue {
  hasSidebar: boolean;
  sidebarPosition: 'left' | 'right';
}

const PageLayoutContext = createContext<PageLayoutContextValue>({
  hasSidebar: false,
  sidebarPosition: 'left',
});

export const usePageLayout = () => useContext(PageLayoutContext);

interface PageTemplateProps {
  header: ReactNode;
  sidebar?: ReactNode;
  sidebarPosition?: 'left' | 'right';
  children: ReactNode;
  footer?: ReactNode;
}

export function PageTemplate({
  header,
  sidebar,
  sidebarPosition = 'left',
  children,
  footer,
}: PageTemplateProps) {
  return (
    <PageLayoutContext.Provider
      value={{ hasSidebar: Boolean(sidebar), sidebarPosition }}
    >
      <div className="page-template">
        <div className="page-template__header">{header}</div>

        <div
          className={`page-template__body ${
            sidebar ? `page-template__body--sidebar-${sidebarPosition}` : ''
          }`}
        >
          {sidebar && sidebarPosition === 'left' && (
            <aside className="page-template__sidebar">{sidebar}</aside>
          )}

          <main className="page-template__main">{children}</main>

          {sidebar && sidebarPosition === 'right' && (
            <aside className="page-template__sidebar">{sidebar}</aside>
          )}
        </div>

        {footer && <div className="page-template__footer">{footer}</div>}
      </div>
    </PageLayoutContext.Provider>
  );
}
```
</template_patterns>

<styling_approaches>
## Styling Approaches

### CSS Modules

```tsx
// Button.module.css
.button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-md);
  font-weight: var(--font-weight-medium);
  transition: all 0.2s ease;
}

.primary {
  background: var(--color-action-primary);
  color: var(--color-text-inverse);
}

.primary:hover {
  background: var(--color-action-primary-hover);
}

.sm { padding: var(--space-1) var(--space-2); font-size: var(--font-size-sm); }
.md { padding: var(--space-2) var(--space-4); font-size: var(--font-size-base); }
.lg { padding: var(--space-3) var(--space-6); font-size: var(--font-size-lg); }
```

```tsx
// Button.tsx
import styles from './Button.module.css';
import clsx from 'clsx';

export function Button({ variant, size, className, ...props }) {
  return (
    <button
      className={clsx(
        styles.button,
        styles[variant],
        styles[size],
        className
      )}
      {...props}
    />
  );
}
```

### Tailwind CSS

```tsx
// Button.tsx with Tailwind
import { cva, type VariantProps } from 'class-variance-authority';

const buttonVariants = cva(
  'inline-flex items-center justify-center rounded-md font-medium transition-colors',
  {
    variants: {
      variant: {
        primary: 'bg-blue-600 text-white hover:bg-blue-700',
        secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200',
        ghost: 'hover:bg-gray-100',
        destructive: 'bg-red-600 text-white hover:bg-red-700',
      },
      size: {
        sm: 'px-2 py-1 text-sm',
        md: 'px-4 py-2 text-base',
        lg: 'px-6 py-3 text-lg',
      },
    },
    defaultVariants: {
      variant: 'primary',
      size: 'md',
    },
  }
);

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {}

export function Button({ variant, size, className, ...props }: ButtonProps) {
  return (
    <button className={buttonVariants({ variant, size, className })} {...props} />
  );
}
```

### Styled Components

```tsx
// Button.styles.ts
import styled, { css } from 'styled-components';

const variantStyles = {
  primary: css`
    background: ${({ theme }) => theme.colors.action.primary};
    color: ${({ theme }) => theme.colors.text.inverse};
    &:hover {
      background: ${({ theme }) => theme.colors.action.primaryHover};
    }
  `,
  secondary: css`
    background: ${({ theme }) => theme.colors.background.subtle};
    color: ${({ theme }) => theme.colors.text.primary};
  `,
};

const sizeStyles = {
  sm: css`
    padding: ${({ theme }) => `${theme.space[1]} ${theme.space[2]}`};
    font-size: ${({ theme }) => theme.fontSize.sm};
  `,
  md: css`
    padding: ${({ theme }) => `${theme.space[2]} ${theme.space[4]}`};
    font-size: ${({ theme }) => theme.fontSize.base};
  `,
};

export const StyledButton = styled.button<{
  $variant: 'primary' | 'secondary';
  $size: 'sm' | 'md' | 'lg';
}>`
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: ${({ theme }) => theme.radius.md};
  font-weight: ${({ theme }) => theme.fontWeight.medium};
  ${({ $variant }) => variantStyles[$variant]}
  ${({ $size }) => sizeStyles[$size]}
`;
```
</styling_approaches>

<hooks_patterns>
## Custom Hooks

### useComponentState Hook

```tsx
// hooks/useToggle.ts
import { useState, useCallback } from 'react';

export function useToggle(initialValue = false) {
  const [value, setValue] = useState(initialValue);

  const toggle = useCallback(() => setValue((v) => !v), []);
  const setTrue = useCallback(() => setValue(true), []);
  const setFalse = useCallback(() => setValue(false), []);

  return { value, toggle, setTrue, setFalse };
}

// Usage in molecule/organism
function Dropdown() {
  const { value: isOpen, toggle, setFalse: close } = useToggle();
  // ...
}
```

### useClickOutside Hook

```tsx
// hooks/useClickOutside.ts
import { useEffect, useRef, RefObject } from 'react';

export function useClickOutside<T extends HTMLElement>(
  handler: () => void
): RefObject<T> {
  const ref = useRef<T>(null);

  useEffect(() => {
    const listener = (event: MouseEvent | TouchEvent) => {
      if (!ref.current || ref.current.contains(event.target as Node)) {
        return;
      }
      handler();
    };

    document.addEventListener('mousedown', listener);
    document.addEventListener('touchstart', listener);

    return () => {
      document.removeEventListener('mousedown', listener);
      document.removeEventListener('touchstart', listener);
    };
  }, [handler]);

  return ref;
}

// Usage
function Dropdown() {
  const { value: isOpen, setFalse: close } = useToggle();
  const dropdownRef = useClickOutside<HTMLDivElement>(close);

  return (
    <div ref={dropdownRef}>
      {/* dropdown content */}
    </div>
  );
}
```
</hooks_patterns>

<testing>
## Testing Patterns

### Atom Testing

```tsx
// atoms/Button/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  it('renders children', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('calls onClick when clicked', () => {
    const handleClick = jest.fn();
    render(<Button onClick={handleClick}>Click me</Button>);

    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('is disabled when isDisabled is true', () => {
    render(<Button isDisabled>Click me</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });

  it('shows loading state', () => {
    render(<Button isLoading>Click me</Button>);
    expect(screen.getByRole('button')).toHaveAttribute('aria-busy', 'true');
  });

  it('applies variant classes', () => {
    const { rerender } = render(<Button variant="primary">Click me</Button>);
    expect(screen.getByRole('button')).toHaveClass('button--primary');

    rerender(<Button variant="secondary">Click me</Button>);
    expect(screen.getByRole('button')).toHaveClass('button--secondary');
  });
});
```

### Molecule Testing

```tsx
// molecules/FormField/FormField.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { FormField } from './FormField';

describe('FormField', () => {
  it('renders label and input', () => {
    render(<FormField label="Email" value="" onChange={() => {}} />);

    expect(screen.getByLabelText('Email')).toBeInTheDocument();
  });

  it('shows error message when provided', () => {
    render(
      <FormField
        label="Email"
        value=""
        onChange={() => {}}
        errorMessage="Email is required"
      />
    );

    expect(screen.getByText('Email is required')).toBeInTheDocument();
    expect(screen.getByRole('textbox')).toHaveAttribute('aria-invalid', 'true');
  });

  it('calls onChange with new value', async () => {
    const handleChange = jest.fn();
    render(<FormField label="Email" value="" onChange={handleChange} />);

    await userEvent.type(screen.getByRole('textbox'), 'test@example.com');
    expect(handleChange).toHaveBeenLastCalledWith('test@example.com');
  });
});
```
</testing>

<references>
## Related References

- [component-hierarchy.md](../component-hierarchy.md) — Import rules
- [naming-conventions.md](../naming-conventions.md) — Naming patterns
- [testing-strategies.md](../testing-strategies.md) — Comprehensive testing
</references>
