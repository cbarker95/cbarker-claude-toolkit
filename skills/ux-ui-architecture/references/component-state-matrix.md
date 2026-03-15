# Component State Matrix

## Purpose

Every interactive component in a spec needs all its states documented. Missing states are the #1 cause of "it looks unfinished" feedback. A button without a loading state, a form field without an error state, an input without a disabled state — these gaps become developer questions during implementation and user complaints after launch.

This reference provides templates and examples for complete state documentation.

---

## The 8 Interaction States

| # | State | Trigger | Typical Visual Change | User Expectation |
|---|-------|---------|----------------------|------------------|
| 1 | **Default** | No interaction | Base appearance | "This is interactive, I can use it" |
| 2 | **Hover** | Cursor over element | Subtle visual change (bg shift, shadow) | "This will respond if I click" |
| 3 | **Active/Pressed** | Mouse down / touch start | Pressed-in appearance | "My click is registering" |
| 4 | **Focus** | Tab navigation / click | Visible outline/ring | "This is where keyboard input goes" |
| 5 | **Disabled** | Component inactive | Muted colors, no cursor | "This isn't available right now" |
| 6 | **Loading** | Async operation in progress | Spinner, skeleton, pulse | "Something is happening, wait" |
| 7 | **Error** | Validation failure or system error | Red indicators, error message | "Something went wrong, here's how to fix it" |
| 8 | **Success** | Operation completed | Green indicators, check mark | "It worked!" |

---

## State Matrix Template

Use this table for every interactive component in a spec:

```markdown
### {Component Name} States

| State | Visual Changes | Behavior | Accessibility |
|-------|---------------|----------|---------------|
| Default | {describe appearance} | {clickable, focusable} | {role, aria-label} |
| Hover | {what changes on hover} | {cursor change, tooltip} | {n/a — hover not accessible} |
| Active | {what changes on press} | {what happens on click} | {aria-pressed if toggle} |
| Focus | {focus ring/outline style} | {keyboard activation} | {focus visible, tab order} |
| Disabled | {muted appearance} | {not clickable, tooltip explains why} | {aria-disabled="true"} |
| Loading | {spinner/skeleton} | {not clickable during load} | {aria-busy="true", live region} |
| Error | {error indicators} | {error message shown, recovery path} | {aria-invalid, aria-describedby} |
| Success | {success indicators} | {brief flash, then return to default} | {status announcement} |
```

---

## Worked Example: Button Component

### Button States (Primary Variant)

| State | Visual Changes | Behavior | Accessibility |
|-------|---------------|----------|---------------|
| Default | Dark gradient bg (from-[#1E1B18] to-[#37322D]), white text, rounded-2xl, shadow-skeuo-primary | Clickable, cursor-pointer | role="button", aria-label={text} |
| Hover | Lighter gradient, enhanced shadow, slight translateY(-1px) | Cursor stays pointer, tooltip if icon-only | n/a |
| Active | Gradient darkens, shadow shrinks (pressed-in), translateY(0) | Click handler fires | aria-pressed if toggle button |
| Focus | Blue ring (ring-2 ring-habitat-500 ring-offset-2) | Space/Enter activates | Focus visible, included in tab order |
| Disabled | warm-300 bg, warm-400 text, no gradient, no shadow | cursor-not-allowed, click ignored, tooltip shows reason | aria-disabled="true" |
| Loading | Spinner replaces label text, button width maintained, bg unchanged | Click ignored during loading | aria-busy="true", aria-label="Loading..." |
| Error | Red-500 border, shake animation (150ms), error tooltip | Click still works (retry) | aria-invalid="true" |
| Success | Brief green-500 border flash + check icon (300ms), then return to default | Standard click behavior resumes | Status: "{action} completed" announcement |

---

## Worked Example: Form Field Component

### Text Input States

| State | Visual Changes | Behavior | Accessibility |
|-------|---------------|----------|---------------|
| Default | White bg, warm-200 border, warm-500 placeholder text | Clickable to focus, shows placeholder | role="textbox", aria-label or linked label |
| Hover | warm-300 border, cursor-text | Click to focus | n/a |
| Active | n/a (active = focused for inputs) | n/a | n/a |
| Focus | habitat-500 border (2px), subtle blue shadow, placeholder fades | Keyboard input accepted, cursor blinks | Focus visible, label moves to float position |
| Disabled | warm-100 bg, warm-200 border, warm-400 text | Not editable, cursor-not-allowed | aria-disabled="true", value still readable |
| Loading | Skeleton pulse in input area, or spinner in trailing position | Not editable during load | aria-busy="true" |
| Error | Red-500 border, red-50 bg tint, error message below in red-600 text, error icon in trailing position | Still editable (user can fix), error clears on valid input | aria-invalid="true", aria-describedby pointing to error message |
| Success | Green-500 border (brief), check icon in trailing position (brief, then fades) | Standard input behavior | Validation success announced |

### Error Message Pattern
```
┌─────────────────────────────────────┐
│ Email address                       │  ← Label (warm-700, text-sm)
│ ┌─────────────────────────────────┐ │
│ │ not-an-email              ⚠️   │ │  ← Input with error (red border, red icon)
│ └─────────────────────────────────┘ │
│ Please enter a valid email address  │  ← Error message (red-600, text-xs)
└─────────────────────────────────────┘
```

---

## State Transitions

Document what triggers each state change:

```
Default ──hover──→ Hover ──mouseout──→ Default
Default ──focus──→ Focus ──blur──→ Default
Focus ──keydown──→ Active ──keyup──→ Focus
Default ──click──→ Active ──release──→ Loading ──complete──→ Success ──300ms──→ Default
Loading ──error──→ Error ──user fixes──→ Default
```

### Transition Timing

| Transition | Duration | Easing |
|-----------|----------|--------|
| Default → Hover | 150ms | ease-out |
| Hover → Default | 150ms | ease-in |
| Default → Focus | 0ms (instant) | n/a |
| Active → Loading | 0ms (instant) | n/a |
| Loading → Success | 0ms (instant) | n/a |
| Success → Default | 300ms | ease-out (fade) |
| Error → Default | 150ms | ease-out |
| Shake animation (error) | 150ms | ease-in-out |

---

## Compound States

Components can be in multiple states simultaneously:

| Combination | Behavior | Example |
|------------|----------|---------|
| Disabled + Loading | Show loading indicator in disabled style | "Checking availability..." on a grayed-out button |
| Error + Focus | Show error styling with focus ring | Form field with validation error that user is editing |
| Loading + Hover | Hover effect suppressed during loading | Button shows spinner, hover doesn't change appearance |
| Disabled + Hover | Show tooltip explaining why disabled | "Connect Zoom first" tooltip on disabled "Import" button |
| Error + Disabled | Show error with disabled styling | Field with server-side validation error that user can't fix |

---

## Accessibility Requirements Per State

| State | Required | Recommended |
|-------|----------|-------------|
| Default | role, aria-label (if no visible text) | aria-describedby for instructions |
| Hover | — | Consider hover alternatives for touch |
| Active | aria-pressed (for toggle buttons) | — |
| Focus | Visible focus indicator (WCAG 2.4.7) | Focus ring with sufficient contrast |
| Disabled | aria-disabled="true" | Tooltip explaining why disabled |
| Loading | aria-busy="true" | Live region for progress updates |
| Error | aria-invalid="true", aria-describedby → error message | Error summary for forms |
| Success | Status role or live region announcement | — |

### Focus Management Rules

1. **Tab order**: All interactive elements must be reachable by Tab key
2. **Focus trap**: Modals trap focus within themselves
3. **Focus restoration**: When a modal closes, focus returns to the trigger element
4. **Skip links**: Long pages have "skip to main content" link
5. **Focus visible**: Focus indicators meet WCAG 2.4.7 (visible, sufficient contrast)

---

## Spec Documentation Pattern

When adding component states to a discovery spec, use this format:

```markdown
### Component: {ComponentName}

**Atomic level**: {atom | molecule | organism}
**Existing component?**: {Yes — reuse from atoms/Button | No — create new}
**Interactive?**: {Yes — state matrix required | No — single static appearance}

#### State Matrix
[Use template table above]

#### Transitions
[Describe key transition animations and timing]

#### Accessibility
[List ARIA attributes and focus management requirements]
```

---

## Anti-Patterns

### Missing Focus State
```
✗ Button has hover and active states but no focus ring
  (keyboard users can't see what's selected)
✓ Focus ring visible on all interactive elements with 2px ring, offset-2
```

### Disappearing Error Messages
```
✗ Error toast appears for 3 seconds then vanishes
  (user might not have read it)
✓ Error message persists until the user takes corrective action or dismisses it
```

### Loading Without Context
```
✗ Spinner with no label (what's loading? how long?)
✓ Spinner with label "Analyzing interview... (2 of 5 stages)" and progress indicator
```

### Disabled Without Explanation
```
✗ Button is grayed out with no indication of why
✓ Disabled button has tooltip: "Connect to Zoom first" with link to Settings
```
