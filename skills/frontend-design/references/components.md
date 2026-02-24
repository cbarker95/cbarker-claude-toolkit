# Component Architecture

Universal patterns for building maintainable, composable UI components.

## Composition Over Duplication

**Always** prefer composing existing components over creating new ones from scratch:

- Before building, search the codebase for existing components that solve part of the problem
- Extend via composition (wrapping, prop forwarding) rather than copying implementation
- If an existing component needs modification, extend it — don't fork it
- If there's a reason not to compose, get explicit confirmation from the user

## Component Hierarchy (Atomic Design)

Components should be placed at the correct complexity level:

| Level | Can Use | Examples |
|-------|---------|----------|
| **Foundations** | CSS, HTML only | Tokens, theme, icons |
| **Atoms** | Foundations only | Button, Input, Badge, Link |
| **Molecules** | Atoms + Foundations | SearchInput, IconButton, FormField |
| **Organisms** | Molecules + Atoms | Dialog, DataTable, Navigation |
| **Templates** | All components | Page layouts, app shells |

If an existing component is at the wrong level, flag it — don't use it as justification for incorrect placement.

## TypeScript Patterns

### Props Definition

Define props as a `type` (not interface) with semantic JSDoc:

```tsx
type SearchInputProps = {
  /** When the user needs to filter a list or dataset in real-time. */
  value: string;
  /** Fires on every keystroke. Parent controls the filter logic. */
  onChange: (value: string) => void;
  /** Shown when the input is empty. Describes what can be searched. */
  placeholder?: string;
};
```

- JSDoc explains WHEN to use the prop, not just what it does
- Required props have no `?`; optional props do
- Use intersection (`&`) to extend base component props
- Use `Omit<>` to remove props you're hardcoding in a wrapper
- Use `Pick<ComponentProps<typeof Base>, "propA" | "propB">` to re-expose specific props from composed components — keeps types and JSDoc aligned with the source

### Component Definition

```tsx
export const SearchInput = forwardRef<HTMLInputElement, SearchInputProps>(
  ({ value, onChange, placeholder = "Search...", className, ...props }, ref) => {
    const handleChange = useCallback(
      (e: ChangeEvent<HTMLInputElement>) => onChange(e.target.value),
      [onChange]
    );

    return (
      <input
        {...props}
        ref={ref}
        className={cn(className, "...")}
        value={value}
        onChange={handleChange}
        placeholder={placeholder}
      />
    );
  }
);
SearchInput.displayName = "SearchInput";
```

Key conventions:
- **Spread props first** — `{...props}` before explicit values prevents accidental overrides
- **Merge classNames** — Accept `className` and merge with component styles
- **`displayName`** — Required for `forwardRef` components
- **`forwardRef`** — Use when the component wraps an HTML element
- **Named exports** — Never use default exports for components

### Callback Naming

- Props: `onX` prefix (`onSave`, `onChange`, `onDelete`)
- Internal handlers: `handleX` prefix (`handleSave`, `handleChange`, `handleDelete`)

## File Structure

Each component lives in its own directory:

```
components/
  SearchInput/
    SearchInput.tsx        # Component implementation
    SearchInput.test.tsx   # Tests (co-located)
    index.ts               # Re-export: export * from "./SearchInput"
```

- Import from the component file, not the directory index
- One component per file (small helper components within the same file are acceptable)
- Co-locate tests with the component they test

## Import Rules

```tsx
// ✅ CORRECT: import from specific file
import { SearchInput } from "../SearchInput/SearchInput";

// ❌ WRONG: import from directory index
import { SearchInput } from "..";
import { SearchInput } from "../SearchInput";
```

Use `import type` for type-only imports:

```tsx
// ✅ CORRECT: standalone type import
import type { SearchInputProps } from "../SearchInput/SearchInput";

// ✅ CORRECT: inline type specifier in mixed import
import { SearchInput, type SearchInputProps } from "../SearchInput/SearchInput";

// ❌ WRONG: importing a type as a regular import
import { SearchInputProps } from "../SearchInput/SearchInput";
```

## Building Product Features

When building features, compose shared components for everything where they exist. Only add custom styling when no component exists for the purpose:

```tsx
import { useState, useCallback } from "react";
import type { ChangeEvent } from "react";

type FeatureFormProps = {
  /** When the form is part of a creation flow (e.g., new customer, new insight). */
  title: string;
  /** Called with the form value when the user confirms. */
  onSave: (value: string) => Promise<void>;
  /** Called when the user cancels without saving. */
  onCancel: () => void;
};

export const FeatureForm = ({ title, onSave, onCancel }: FeatureFormProps) => {
  const [value, setValue] = useState("");

  const handleChange = useCallback(
    (e: ChangeEvent<HTMLInputElement>) => setValue(e.target.value),
    []
  );

  const handleSave = useCallback(async () => {
    await onSave(value);
    setValue("");
  }, [onSave, value]);

  return (
    <div className="flex flex-col gap-4">
      <h2 className="text-lg font-semibold">{title}</h2>
      <input
        value={value}
        onChange={handleChange}
        className="h-10 px-3 rounded-xl border border-warm-200"
      />
      <div className="flex gap-2">
        <button onClick={onCancel} className="h-10 px-4 rounded-lg text-warm-500">
          Cancel
        </button>
        <button onClick={handleSave} className="h-10 px-4 rounded-xl bg-warm-800 text-white shadow-skeuo">
          Save
        </button>
      </div>
    </div>
  );
};
```

This demonstrates: semantic prop JSDoc, `handleX`/`onX` naming, composition of design tokens, and clean separation of concerns.
