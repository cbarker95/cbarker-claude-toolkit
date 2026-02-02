# Design Token Naming & Architecture

<overview>
Design tokens are the atomic building blocks of a design system, providing a way to
centrally record and widely reuse purposeful visual decisions. This reference is based
on Nathan Curtis's EightShapes taxonomy for naming tokens in design systems.

**Core insight:** Effective token names improve and sustain a team's shared understanding
of visual style through design, code, and other interdisciplinary handoffs. Terms matter.

This reference covers:
- Four level groups: Base, Modifiers, Objects, Namespaces
- Naming principles and anti-patterns
- Promotion rules (the "3 times" rule)
- Three-tier architecture (global → semantic → component)
- Completeness, order, and polyhierarchy
</overview>

<three_tier_architecture>
## Three-Tier Token Architecture

Most mature systems (IBM Carbon, Atlassian, Salesforce Lightning) use three tiers:

```
┌─────────────────────────────────────────────────────────────┐
│  TIER 3: Component Tokens                                    │
│  button-primary-background-hover                             │
│  ↓ references                                                │
├─────────────────────────────────────────────────────────────┤
│  TIER 2: Semantic/Alias Tokens                               │
│  color-action-primary-hover                                  │
│  ↓ references                                                │
├─────────────────────────────────────────────────────────────┤
│  TIER 1: Global/Primitive Tokens                             │
│  color-blue-600 → #2563EB                                    │
└─────────────────────────────────────────────────────────────┘
```

### Tier 1: Global (Primitive) Tokens

**Purpose:** Raw foundational values without semantic meaning.
**Scope:** Platform-agnostic core building blocks.
**Rule:** Always have explicit values; never reference other tokens.

```css
/* Colors - using scales */
--color-blue-50: #eff6ff;
--color-blue-100: #dbeafe;
--color-blue-500: #3b82f6;
--color-blue-900: #1e3a8a;

/* Spacing - geometric progression */
--space-1: 4px;
--space-2: 8px;
--space-3: 12px;
--space-4: 16px;
--space-6: 24px;
--space-8: 32px;

/* Typography */
--font-size-xs: 12px;
--font-size-sm: 14px;
--font-size-base: 16px;
--font-size-lg: 18px;
--font-weight-normal: 400;
--font-weight-medium: 500;
--font-weight-bold: 700;

/* Shadows */
--shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
--shadow-md: 0 4px 6px rgba(0,0,0,0.1);
--shadow-lg: 0 10px 15px rgba(0,0,0,0.1);
```

**Naming pattern:** `{category}-{type/variant}-{scale}`

### Tier 2: Semantic (Alias) Tokens

**Purpose:** Map global tokens to UI roles with intent and meaning.
**Scope:** Introduce semantic clarity; enable theming.
**Rule:** Always reference Tier 1 tokens.

```css
/* Semantic color roles */
--color-text-primary: var(--color-gray-900);
--color-text-secondary: var(--color-gray-600);
--color-text-disabled: var(--color-gray-400);
--color-text-inverse: var(--color-white);

--color-background-default: var(--color-white);
--color-background-subtle: var(--color-gray-50);
--color-background-elevated: var(--color-white);

--color-border-default: var(--color-gray-200);
--color-border-strong: var(--color-gray-400);

/* Action colors (interactive elements) */
--color-action-primary: var(--color-blue-600);
--color-action-primary-hover: var(--color-blue-700);
--color-action-primary-active: var(--color-blue-800);

/* Feedback colors */
--color-feedback-success: var(--color-green-600);
--color-feedback-warning: var(--color-yellow-500);
--color-feedback-error: var(--color-red-600);
--color-feedback-info: var(--color-blue-500);

/* Semantic spacing */
--space-component-gap: var(--space-2);
--space-section-gap: var(--space-8);
--space-page-margin: var(--space-6);
```

**Naming pattern:** `{category}-{concept/role}-{variant}`

### Tier 3: Component Tokens

**Purpose:** Apply styles within specific component contexts.
**Scope:** Scoped to individual components; allow overrides.
**Rule:** Reference Tier 2 tokens; enable component variants.

```css
/* Button tokens */
--button-background-primary: var(--color-action-primary);
--button-background-primary-hover: var(--color-action-primary-hover);
--button-background-secondary: var(--color-background-subtle);
--button-text-primary: var(--color-text-inverse);
--button-text-secondary: var(--color-text-primary);
--button-border-radius: var(--radius-md);
--button-padding-x: var(--space-4);
--button-padding-y: var(--space-2);

/* Input tokens */
--input-background: var(--color-background-default);
--input-border: var(--color-border-default);
--input-border-focus: var(--color-action-primary);
--input-text: var(--color-text-primary);
--input-placeholder: var(--color-text-secondary);
--input-border-radius: var(--radius-sm);

/* Card tokens */
--card-background: var(--color-background-elevated);
--card-border: var(--color-border-default);
--card-shadow: var(--shadow-md);
--card-padding: var(--space-4);
--card-border-radius: var(--radius-lg);
```

**Naming pattern:** `{component}-{element}-{property}-{variant}-{state}`
</three_tier_architecture>

<level_groups>
## Token Naming Levels (EightShapes Taxonomy)

Tokens combine multiple **naming levels** to form sufficiently descriptive names.
These levels are organized into four groups:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  NAMESPACE LEVELS (prepended first)                                          │
│  system (esds) → theme (ocean) → domain (retail)                            │
├─────────────────────────────────────────────────────────────────────────────┤
│  OBJECT LEVELS (establish context)                                           │
│  component-group (forms) → component (button) → element (left-icon)         │
├─────────────────────────────────────────────────────────────────────────────┤
│  BASE LEVELS (the backbone)                                                  │
│  category (color) → concept (action) → property (background)                │
├─────────────────────────────────────────────────────────────────────────────┤
│  MODIFIER LEVELS (appended last)                                             │
│  variant (primary) → state (hover) → scale (100) → mode (on-dark)          │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Example Token Decomposition

```
$esds-color-neutral-42
  └─┬─┘ └──┬──┘ └─┬──┘└┬┘
    │      │      │    └── scale (lightness: 42)
    │      │      └─────── variant (neutral)
    │      └────────────── category (color)
    └───────────────────── namespace/system (esds)

$esds-color-feedback-background-error
  └─┬─┘ └──┬──┘ └───┬───┘ └───┬────┘ └─┬─┘
    │      │        │         │        └── variant (error)
    │      │        │         └─────────── property (background)
    │      │        └───────────────────── concept (feedback)
    │      └────────────────────────────── category (color)
    └───────────────────────────────────── namespace (esds)

$esds-forms-color-border
  └─┬─┘ └─┬──┘ └──┬──┘ └──┬──┘
    │     │       │       └── property (border)
    │     │       └────────── category (color)
    │     └────────────────── component-group (forms)
    └──────────────────────── namespace (esds)

$esds-input-left-icon-color-fill
  └─┬─┘ └─┬──┘ └───┬───┘ └──┬──┘ └─┬─┘
    │     │        │        │      └── property (fill)
    │     │        │        └───────── category (color)
    │     │        └────────────────── element (left-icon)
    │     └─────────────────────────── component (input)
    └───────────────────────────────── namespace (esds)
```
</level_groups>

<base_levels>
## Base Levels

Base levels form a token's **backbone**, combining category, concept, and property.

### Category

Tokens exist within a prototypical category. Common categories include:

| Category | Variants (aka) | Description |
|----------|----------------|-------------|
| `color` | — | All color values |
| `font` | `type`, `typography`, `text` | Typography properties |
| `space` | `units`, `dimension`, `spacing` | Spacing/margins/padding |
| `size` | `sizing` | Dimensions, widths, heights |
| `elevation` | `z-index`, `layer`, `layering` | Stacking order |
| `breakpoints` | `media-query`, `responsive` | Responsive breakpoints |
| `shadow` | `depth` | Box shadows, drop shadows |
| `touch` | — | Touch target sizes |
| `time` | `animation`, `duration` | Animation timing |

**Principle: Avoid homonyms.** `type` is problematic—it could mean typography or
a category of thing. `text` is similarly overloaded (content vs typography vs property).
Teams often settle on `font` since `typography` is long.

### Property

A property is paired with a category to define what aspect is being styled:

```
Category    Property        Example Token
────────    ────────        ─────────────
color       text            $color-text
color       background      $color-background
color       border          $color-border
color       fill            $color-fill
font        size            $font-size
font        weight          $font-weight
font        line-height     $font-line-height
font        letter-spacing  $font-letter-spacing
space       inset           $space-inset
space       stack           $space-stack
space       inline          $space-inline
```

**Note:** Category/property pairs alone are too general—they lack purposeful context.
We need concepts and modifiers.

### Concept

Concepts group tokens within a category by purpose or domain:

**Color Concepts:**

| Concept | Variants (aka) | Typical Variants |
|---------|----------------|------------------|
| `feedback` | `notification`, `messaging`, `alert` | success, warning, error, info |
| `action` | `cta`, `interactive`, `interaction` | primary, secondary, tertiary |
| `visualization` | `dataviz`, `charting`, `charts` | categorical colors, sequential |
| `commerce` | — | sale, clearance, inventory, timing |
| `neutral` | `gray`, `greyscale` | scale from light to dark |

**Typography Concepts:**

| Concept | Variants (aka) | Typical Scales |
|---------|----------------|----------------|
| `heading` | `header`, `headline`, `display` | 1, 2, 3, 4, 5, 6 |
| `body` | `text` | xs, sm, md, lg |
| `eyebrow` | `overline`, `kicker` | — |
| `lead` | `lede`, `deck`, `subheader` | — |

**Principle: Homogeneity within, heterogeneity between.**
Keep concept contents similar (all `visualization` colors are for charts)
and distinct between concepts (`visualization` ≠ `commerce`).
</base_levels>

<modifier_levels>
## Modifier Levels

Modifiers refine tokens with variant, state, scale, and mode distinctions.

### Variant

Variants distinguish alternative use cases within the same concept:

**Text/Hierarchy Variants:**
```
primary     (aka: default, base)     → Main content
secondary   (aka: subdued, subtle)   → Supporting content
tertiary    (aka: nonessential)      → De-emphasized content
```

**Feedback Variants:**
```
success     (aka: confirmation, positive)
error       (aka: danger, alert, critical)
warning
information (aka: info)
new
```

**Action Variants:**
```
primary     → Main call-to-action
secondary   → Alternative action
tertiary    → Low-emphasis action
destructive → Dangerous/irreversible action
```

**Principle: Flexibility vs Specificity.**

Flexible (less specific):
```css
$color-success: #22c55e;  /* Apply to text, background, or border */
```

Specific (more precise):
```css
$color-text-success: #166534;
$color-background-success: #dcfce7;
$color-border-success: #22c55e;
```

Flexibility is shorter but risks misapplication. Specificity is longer but precise.

### State

States modify tokens based on interaction:

| State | Description |
|-------|-------------|
| `default` | Normal resting state |
| `hover` | Pointer positioned above |
| `press` / `active` | Between press and release |
| `focus` | Able to accept input |
| `disabled` | Not able to accept input |
| `visited` | Link already visited |
| `error` | In error state |
| `selected` | Currently selected |

**Full example with state:**
```
$color-action-text-secondary-focus
  └───┬───┘ └─┬─┘ └───┬───┘ └──┬──┘
      │       │       │        └── state
      │       │       └─────────── variant
      │       └─────────────────── property
      └─────────────────────────── category + concept
```

### Scale

Scales quantify varying sizes, intensities, or levels:

| Scale Type | Examples | Use Case |
|------------|----------|----------|
| **Enumerated** | `1`, `2`, `3`, `4`, `5` | Heading levels |
| **Ordered** | `50`, `100`, `200`...`900` | Color palettes (Material) |
| **Bounded** | `0`-`100` (HSL lightness) | `neutral-42` = 42% lightness |
| **Proportion** | `quarter-x`, `half-x`, `1-x`, `2-x`, `4-x` | Spacing multipliers |
| **T-shirt** | `xs`, `s`, `m`, `l`, `xl`, `xxl` | General sizing |

**Pro tip from Nathan Curtis:** Size ≠ space. Consider using proportion (`1-x`, `2-x`)
instead of t-shirts (`sm`, `md`, `lg`) for spacing tokens.

### Mode

Mode distinguishes values across different surface/background contexts:

```
$color-action-background-secondary-hover-on-light
$color-action-background-secondary-hover-on-dark
                                         └──┬──┘
                                            mode
```

Common modes:
- `on-light` (aka `light`, default white/light backgrounds)
- `on-dark` (aka `dark`, dark backgrounds)
- `on-brand` (colored brand backgrounds)

**Principle: Theme ≠ Mode.**
A theme (like `courtyard` for Marriott) may still need both `on-light` and `on-dark`
modes. They're orthogonal concerns.

**Principle: Explicit vs Truncated Defaults.**
You can either:
- Include all modes: `$color-text-on-light`, `$color-text-on-dark`
- Assume default: `$color-text` (implies light), `$color-text-on-dark`

Parallel construction aids predictability; truncation reduces verbosity.
</modifier_levels>

<object_levels>
## Object Levels

Object levels scope tokens to specific components, elements, or component groups.

### Component

Tokens specific to a single component:

```css
/* Component-specific tokens */
$esds-input-color-border: var(--color-neutral-70);
$esds-input-border-radius: 4px;
$esds-card-shadow: var(--shadow-md);
$esds-button-min-width: 120px;
```

**Where to store:** Start in component-local scope (component specs, top of
`input.scss`), not in global tokens.

### Element (Nested within Component)

Tokens for elements nested within components (BEM-like):

```css
/* Element-specific tokens */
$esds-input-left-icon-color-fill
$esds-input-left-icon-size
$esds-input-inline-link-color-text
$esds-button-icon-margin-right
$esds-card-header-padding
```

Pattern: `{namespace}-{component}-{element}-{category}-{property}`

### Component Group

Tokens shared across related components:

```css
/* Forms group tokens - shared across Input, Select, Checkbox, Radio */
$esds-forms-color-border: var(--color-neutral-70);
$esds-forms-color-border-focus: var(--color-action-primary);
$esds-forms-border-radius: 4px;
$esds-forms-color-text-error: var(--color-feedback-error);
```

Common component groups:
- `forms` / `ui-controls` / `form-controls`
- `navigation`
- `cards`
- `modals` / `overlays`
- `feedback` / `notifications`
</object_levels>

<namespace_levels>
## Namespace Levels

Namespaces scope tokens to systems, themes, or domains.

### System Name

Prepend to distinguish system tokens from local variables:

```css
/* System namespace */
$esds-color-text-primary    /* EightShapes Design System */
$slds-color-text-default    /* Salesforce Lightning */
$mds-color-text-primary     /* Morningstar Design System */
$orbit-color-text-primary   /* Orbit by Kiwi */
```

**Tip:** Keep system names short (≤5 characters) or use acronyms.

### Theme

Themes shift color, typography, and other styles across a component catalog:

```css
/* Theme-specific overrides */
$aads-ocean-color-primary
$aads-sands-color-primary
$aads-sunset-color-secondary

/* Applied via aliasing */
$aads-color-text-primary = $aads-ocean-color-primary;
```

**Use case:** Multi-brand systems (Marriott hotels, product lines, white-labels).

### Domain

Domain namespaces for business unit or product area tokens:

```css
/* Domain-specific tokens */
$esds-consumer-color-marquee-text-primary
$esds-consumer-color-promo-clearance
$esds-consumer-font-family-marquee
$esds-retail-space-tiles-inset-2-x
```

**Use case:** Large organizations with multiple product teams extending a core system.
</namespace_levels>

<principles>
## Naming Principles

### 1. Avoid Homonyms

Problematic terms that mean multiple things:
- `type` → typography? or category of thing?
- `text` → typography? or content? or property?
- `size` → font-size? or dimension?

**Solution:** Choose unambiguous terms. Use `font` over `type`.

### 2. Homogeneity Within, Heterogeneity Between

Keep concept contents similar and concepts distinct:

```
✓ GOOD: visualization contains only chart colors
✓ GOOD: commerce contains only e-commerce colors
✗ BAD:  visualization contains chart colors AND sale/clearance colors
```

### 3. Flexibility vs Specificity

| Approach | Example | Trade-off |
|----------|---------|-----------|
| Flexible | `$color-success` | Shorter, but may be misapplied |
| Specific | `$color-background-success` | Longer, but precise application |

### 4. Explicit vs Truncated Defaults

```css
/* Explicit - parallel construction, predictable */
$color-text-on-light
$color-text-on-dark

/* Truncated - assumes light is default */
$color-text           /* implies on-light */
$color-text-on-dark
```

### 5. Start Within, Then Promote Across

```
Step 1: Create component-local token
        $esds-input-color-border in input.scss

Step 2: When same decision applies to 3+ components, promote
        $esds-forms-color-border (global)

Step 3: Replace local tokens with global reference
        $esds-input-color-border → removed
        Input, Select, Checkbox now use $esds-forms-color-border
```

### 6. Don't Globalize Decisions Prematurely

Keep tokens local until reuse is proven:

```
✗ BAD:  Create $esds-notched-layers-shadow immediately
        (only tooltip uses it so far)

✓ GOOD: Keep $esds-tooltip-shadow local
        Later, if popover and menu need same shadow,
        promote to $esds-notched-layers-shadow
```
</principles>

<promotion_rules>
## The "3 Times" Rule

**Promote to global when a decision is used 3+ times.**

### Promotion Workflow

```
┌─────────────────────────────────────────────────────────────┐
│  1 use   → Keep as local value or component token           │
│  2 uses  → Consider promoting, watch for third              │
│  3+ uses → Promote to semantic/global token                 │
└─────────────────────────────────────────────────────────────┘
```

### Example: Form Border Color

```
Initial state:
  input.scss:    $esds-input-color-border: #888888;
  select.scss:   border-color: #888888;  /* hardcoded */
  checkbox.scss: border-color: #888888;  /* hardcoded */

After promotion (3 components):
  _tokens.scss:  $esds-forms-color-border: #888888;
  input.scss:    border-color: $esds-forms-color-border;
  select.scss:   border-color: $esds-forms-color-border;
  checkbox.scss: border-color: $esds-forms-color-border;
```
</promotion_rules>

<anti_patterns>
## Anti-Patterns to Avoid

### 1. Hardcoded Values

```css
/* WRONG */
.button {
  background: #3b82f6;
  padding: 8px 16px;
}

/* RIGHT */
.button {
  background: var(--button-background-primary);
  padding: var(--button-padding-y) var(--button-padding-x);
}
```

### 2. Inconsistent Naming

```css
/* WRONG - inconsistent patterns */
--btnBgColor: blue;
--button-background: blue;
--ButtonBackgroundColor: blue;

/* RIGHT - consistent pattern */
--button-background-color: var(--color-action-primary);
```

### 3. Skipping Tiers

```css
/* WRONG - component references primitive directly */
--button-background: var(--color-blue-600);

/* RIGHT - component references semantic */
--button-background: var(--color-action-primary);
--color-action-primary: var(--color-blue-600);
```

### 4. Over-Tokenization

```css
/* WRONG - token for one-off value */
--hero-special-padding-left-mobile: 23px;

/* RIGHT - use nearest scale value or hardcode */
.hero { padding-left: var(--space-6); }
```

### 5. Cryptic Names

```css
/* WRONG */
--c-p-1: #3b82f6;
--sp4: 16px;

/* RIGHT */
--color-primary: #3b82f6;
--space-4: 16px;
```

### 6. No Semantic Layer

```css
/* WRONG - forces global changes */
.button { color: var(--color-blue-600); }
.link { color: var(--color-blue-600); }
/* Changing brand color requires finding all uses */

/* RIGHT - semantic indirection */
.button { color: var(--color-action-primary); }
.link { color: var(--color-action-primary); }
/* Change --color-action-primary once */
```

### 7. Mode-Specific Token Names

```css
/* WRONG - proliferates tokens */
--button-dark-background: #333;
--button-light-background: #fff;

/* RIGHT - single token, multiple values via themes */
--button-background: var(--color-surface);
```
</anti_patterns>

<lessons_learned>
## Lessons Learned (From Nathan Curtis)

### Completeness

**Don't include all possible levels—only what's needed.**

```css
/* GOOD - sufficient levels */
$esds-shape-tile-corner-radius
$esds-shape-tile-shadow-offset

/* BAD - redundant, over-specified */
$esds-shape-tile-corner-radius-default-on-light
$esds-shape-tile-corner-radius-default-on-dark
$esds-shape-tile-shadow-offset-default-on-light
$esds-shape-tile-shadow-offset-default-on-dark
```

### Order

There's no universal token level order, but patterns emerge:

```
1. Namespaces first    → $esds-
2. Objects next        → $esds-forms-
3. Base in middle      → $esds-forms-color-border-
4. Modifiers last      → $esds-forms-color-border-focus-on-dark
```

**Within base levels**, teams vary:
- Hierarchical: `color-interactive-background`
- Readable: `interactive-background-color`
- Paired: `color-background-interactive`

### Polyhierarchy

The same decision can exist at multiple levels (with aliasing):

```css
/* Both valid locations for "error red" */
$color-feedback-error: #B90000;                        /* Concept level */
$ui-controls-color-text-error: $color-feedback-error;  /* Object level */
```

This provides:
- Complete sets at each level
- Ability to diverge later if needed
- Clear traceability via aliasing
</lessons_learned>

<quick_reference>
## Quick Reference

### Level Order Template

```
{namespace}-{component-group}-{component}-{element}-{category}-{concept}-{property}-{variant}-{state}-{scale}-{mode}
```

**In practice, use only needed levels:**

| Complexity | Example | Levels Used |
|------------|---------|-------------|
| Simple | `$esds-color-blue-500` | namespace, category, variant, scale |
| Moderate | `$esds-color-text-secondary` | namespace, category, property, variant |
| Standard | `$esds-color-feedback-background-error` | namespace, category, concept, property, variant |
| Complex | `$esds-forms-color-border-focus` | namespace, group, category, property, state |
| Full | `$esds-button-icon-color-fill-primary-hover-on-dark` | all levels |

### Category Quick Reference

```
color       → text, background, border, fill, stroke
font        → family, size, weight, line-height, letter-spacing
space       → inset, stack, inline, gap
size        → width, height, min-width, max-width
elevation   → (numeric scale)
shadow      → (named scale: sm, md, lg)
radius      → (named scale or numeric)
breakpoint  → (named: sm, md, lg, xl)
time        → duration, delay, easing
```

### Common Variant Sets

```
Hierarchy:  primary, secondary, tertiary
Feedback:   success, warning, error, info
Action:     primary, secondary, tertiary, destructive
Emphasis:   strong, default, subtle, disabled
```
</quick_reference>

<implementation_checklist>
## Token Implementation Checklist

### Structure
- [ ] Three tiers defined (global → semantic → component)
- [ ] Consistent naming pattern across all tokens
- [ ] Scales use predictable progressions
- [ ] No hardcoded values in components

### Naming
- [ ] Names describe purpose, not value (`action-primary` not `blue-button`)
- [ ] Consistent case (kebab-case recommended)
- [ ] Consistent level ordering (category-concept-property-variant-state)
- [ ] No abbreviations that aren't universally understood

### Theming
- [ ] Semantic tokens enable theme switching
- [ ] No mode-specific token names (`-dark`, `-light`)
- [ ] Brand variations use same semantic structure

### Documentation
- [ ] All tokens documented with purpose
- [ ] Usage examples provided
- [ ] Deprecation path for removed tokens
- [ ] Token values visible to designers

### Tooling
- [ ] Tokens stored in JSON/YAML for multi-platform
- [ ] Style Dictionary or equivalent configured
- [ ] Figma tokens synced with code tokens
- [ ] Linting for hardcoded values
</implementation_checklist>

<references>
## Sources

- [Naming Tokens in Design Systems - Nathan Curtis, EightShapes](https://medium.com/eightshapes-llc/naming-tokens-in-design-systems-9e86c7444676)
- [Tokens in Design Systems - EightShapes](https://eightshapes.com/articles/tokens-in-design-systems/)
- [Reimagining a Token Taxonomy - Nathan Curtis, EightShapes](https://medium.com/eightshapes-llc/reimagining-a-token-taxonomy-462d35b2b033)
- [Style Dictionary - Token Structure](https://styledictionary.com/info/tokens/)
- [Fluent UI Token Naming Reference](https://microsoft.github.io/fluentui-token-pipeline/naming.html)
- Real-world systems: [Salesforce Lightning](https://www.lightningdesignsystem.com/design-tokens/), [Adobe Spectrum](https://spectrum.adobe.com/page/design-tokens/), [IBM Carbon](https://carbondesignsystem.com/guidelines/color/tokens/)
</references>
