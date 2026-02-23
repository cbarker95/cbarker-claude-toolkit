# Initialize Atomic Design System

Scaffold a new atomic design system with the recommended folder structure, token files, and starter components.

## Arguments
- `$ARGUMENTS` - Optional framework: `react` (default), `vue`, or `vanilla`

## What Gets Created

```
src/
├── design-system/
│   ├── tokens/
│   │   ├── colors.css         # Primitive + semantic color tokens
│   │   ├── typography.css     # Font families, sizes, weights
│   │   ├── spacing.css        # Spacing scale (4, 8, 12, 16, 24...)
│   │   ├── shadows.css        # Shadow + radius tokens
│   │   └── index.css          # Imports all token files
│   │
│   ├── atoms/
│   │   ├── Button/
│   │   │   ├── Button.{tsx|vue|js}
│   │   │   ├── Button.css
│   │   │   ├── Button.test.{tsx|js}
│   │   │   └── index.{ts|js}
│   │   ├── Input/
│   │   ├── Label/
│   │   ├── Icon/
│   │   └── index.{ts|js}
│   │
│   ├── molecules/
│   │   ├── FormField/
│   │   └── index.{ts|js}
│   │
│   ├── organisms/
│   │   └── index.{ts|js}
│   │
│   ├── templates/
│   │   └── index.{ts|js}
│   │
│   └── index.{ts|js}          # Main export
│
└── .storybook/                # Storybook config (if React/Vue)
    ├── main.{ts|js}
    └── preview.{ts|js}
```

## Token Defaults

### colors.css
```css
:root {
  /* Primitives */
  --color-blue-50: #eff6ff;
  --color-blue-500: #3b82f6;
  --color-blue-600: #2563eb;
  --color-blue-700: #1d4ed8;

  --color-gray-50: #f9fafb;
  --color-gray-100: #f3f4f6;
  --color-gray-200: #e5e7eb;
  --color-gray-400: #9ca3af;
  --color-gray-600: #4b5563;
  --color-gray-900: #111827;

  --color-green-600: #16a34a;
  --color-red-600: #dc2626;
  --color-yellow-500: #eab308;

  /* Semantic */
  --color-text-primary: var(--color-gray-900);
  --color-text-secondary: var(--color-gray-600);
  --color-text-inverse: white;

  --color-background-default: white;
  --color-background-subtle: var(--color-gray-50);

  --color-border-default: var(--color-gray-200);

  --color-action-primary: var(--color-blue-600);
  --color-action-primary-hover: var(--color-blue-700);

  --color-feedback-success: var(--color-green-600);
  --color-feedback-error: var(--color-red-600);
  --color-feedback-warning: var(--color-yellow-500);
}
```

## Starter Components

Create these starter atoms:
- **Button** — Primary, secondary, ghost, destructive variants; sm, md, lg sizes
- **Input** — Text input with error state, left/right slots
- **Label** — Form label with required indicator
- **Icon** — SVG icon wrapper

Create one starter molecule:
- **FormField** — Composes Label + Input + error text

## Post-Init Steps

After initialization:
1. Install dependencies (if framework-specific)
2. Set up path aliases in tsconfig/vite config
3. Configure Storybook (optional)
4. Run `/atomic-audit` to verify structure

## Usage

```
/atomic-init           # Initialize with React
/atomic-init react     # Explicit React
/atomic-init vue       # Vue 3 with Composition API
/atomic-init vanilla   # Plain CSS + Web Components
```

## References

Read for implementation details:
- `.claude/skills/atomic-design-system/references/core-concepts.md`
- `.claude/skills/atomic-design-system/references/design-tokens.md`
- `.claude/skills/atomic-design-system/references/framework-patterns/{framework}-patterns.md`
