# Responsive Patterns

## Purpose

Responsive behavior defines how layouts adapt across viewport sizes. For web apps, this means mobile, tablet, and desktop. For Electron desktop apps, this means handling window resizing, minimum dimensions, and sidebar collapse points. Specs that don't define responsive behavior produce UIs that break when windows are resized.

---

## Breakpoint Tiers

| Tier | Width Range | Typical Devices | Layout Strategy |
|------|------------|-----------------|-----------------|
| **Mobile** | 375–767px | Phones | Single column, stacked layout |
| **Tablet** | 768–1023px | Tablets, narrow windows | Two columns, sidebar optional |
| **Desktop** | 1024–1439px | Laptops, standard monitors | Full layout with sidebar |
| **Wide** | 1440px+ | Large monitors, ultrawide | Full layout with optional panes |

### Electron/Desktop-Specific Breakpoints

| Dimension | Value | What Happens |
|-----------|-------|--------------|
| **Minimum width** | 800px | Window cannot be resized smaller |
| **Sidebar collapse** | <960px | File explorer sidebar collapses to icon-only |
| **Comfortable width** | 1280px | Full sidebar + content area + potential side panel |
| **Split pane viable** | >1440px | Enough room for two content panes side by side |

---

## Layout Adaptation Strategies

### 1. Reflow
Content reflows from multi-column to single column as width decreases.
```
Desktop:  [Sidebar] [Main Col 1] [Main Col 2]
Tablet:   [Sidebar] [Main (single column)]
Mobile:   [Main (full width, sidebar hidden)]
```

### 2. Reveal/Hide
Elements show or hide based on available space.
```
Desktop:  [Icon Rail] [Sidebar] [Content] [Ask Panel]
Tablet:   [Icon Rail] [Content] (sidebar hidden behind hamburger)
```

### 3. Transform
Elements change form to fit available space.
```
Desktop:  DataTable with sortable columns
Mobile:   Card list (one card per row, key info only)
```

### 4. Collapse
Elements reduce to their compact form.
```
Desktop:  Full sidebar with labels and hierarchy
Narrow:   Icon-only sidebar (w-12, tooltips on hover)
```

### 5. Resize
Elements scale proportionally.
```
Wide:     Dashboard cards 4-across
Desktop:  Dashboard cards 3-across
Tablet:   Dashboard cards 2-across
```

---

## Common Responsive Patterns

### Column Drop
Columns stack vertically as width decreases:
```
Wide:     [A] [B] [C]
Desktop:  [A] [B]
          [C]
Mobile:   [A]
          [B]
          [C]
```
**Use for:** Dashboard grids, card layouts, metric displays.

### Layout Shifter
Layout fundamentally reorganizes:
```
Desktop:  [Sidebar | Main Content    ]
Mobile:   [Bottom Tab Bar           ]
          [Full-width Content       ]
```
**Use for:** App-level layout (sidebar → bottom tabs on mobile).

### Mostly Fluid
Multi-column layout that becomes single column, with max-width constraint:
```
Wide:     [margin] [content max-w-7xl] [margin]
Desktop:  [content full-width with padding]
Mobile:   [content full-width with reduced padding]
```
**Use for:** Content-heavy pages, documentation, forms.

### Off-Canvas
Content slides in from the edge when triggered:
```
Desktop:  [Sidebar always visible] [Content]
Mobile:   [Content] ← swipe or tap to reveal [Sidebar overlay]
```
**Use for:** Navigation sidebars, filter panels, detail panels.

---

## Touch vs Pointer Considerations

### Tap Targets
- Minimum tap target: **44×44px** (Apple HIG) or **48×48px** (Material)
- Minimum spacing between targets: **8px**
- Desktop icon buttons (32×32px) need larger touch targets on mobile

### Hover Alternatives
Hover-dependent interactions need touch alternatives:

| Hover Pattern | Touch Alternative |
|--------------|-------------------|
| Tooltip on hover | Long-press or info icon tap |
| Dropdown on hover | Tap to open dropdown |
| Preview on hover | Tap to expand / peek panel |
| Row actions on hover | Swipe to reveal actions / long-press menu |
| Color change on hover | Active state on tap |

### Gesture Support
| Gesture | Action | Platform Notes |
|---------|--------|----------------|
| Tap | Click/activate | Universal |
| Long-press | Context menu / preview | Universal |
| Swipe horizontal | Reveal actions / navigate | Mobile/tablet primarily |
| Swipe down | Pull-to-refresh | Mobile primarily |
| Pinch | Zoom (canvas views) | Touch devices |
| Two-finger scroll | Horizontal scroll | Trackpad/touch |

---

## Responsive Component Patterns

### Tables → Cards
```
Desktop: Full DataTable with columns, sorting, filtering
Mobile:  Card list — one card per row, 3-4 key fields, tap to expand
```

### Navigation → Hamburger/Bottom Tabs
```
Desktop: Persistent sidebar or icon rail with labels
Mobile:  Bottom tab bar (5 max items) or hamburger menu
```

### Sidebar → Drawer
```
Desktop: Persistent sidebar (w-64) with full content
Narrow:  Overlay drawer triggered by hamburger icon, dismissible
```

### Multi-Pane → Stacked
```
Desktop: Side-by-side panes (list | detail)
Mobile:  Full-screen list → tap → full-screen detail → back button
```

### Dashboard Grid → Stack
```
Desktop: 2-3 columns of metric cards
Mobile:  Single column, cards full-width, secondary metrics collapsed
```

---

## Spec Notation for Responsive

When documenting responsive behavior in a discovery spec, use this format:

```markdown
### Responsive Behavior

| Viewport | Layout Change | Elements Affected |
|----------|--------------|-------------------|
| <960px | Sidebar collapses to icon-only | FileNavigator, Sidebar |
| <800px | Minimum width — no further collapse | Window resize constrained |
| >1440px | Split pane available | SplitPaneContainer enabled |

### Component Adaptations

- **DataTable**: Below 768px, switches to card view
- **AskSidePanel**: Below 1024px, becomes overlay instead of inline
- **IconRail**: Always visible (w-12), labels hidden at all sizes
- **Dashboard cards**: 3-across at 1280px, 2-across at 960px, 1-across at 768px
```

---

## Electron-Specific Patterns

### Window Resize Behavior
```typescript
// Minimum window dimensions
mainWindow.setMinimumSize(800, 600);

// Sidebar collapse threshold
const SIDEBAR_COLLAPSE_THRESHOLD = 960;
```

### Window State Persistence
- Remember window position and size across sessions
- Remember sidebar collapsed/expanded state
- Remember split pane configuration

### Multi-Window Support
- Main window: full app
- Detached windows: individual documents (optional)
- Popout panels: Ask panel as separate window (optional)

---

## Anti-Patterns

### Desktop-Only Design
```
✗ Feature requires 1200px+ viewport, breaks at smaller sizes
✓ Feature works at minimum window size (800px) with graceful degradation
```

### Hidden-on-Mobile Critical Features
```
✗ Primary action only visible on desktop, hidden on mobile/narrow
✓ Primary actions always accessible, secondary actions adapt
```

### Hover-Dependent Interactions Without Alternatives
```
✗ Row actions only appear on hover (invisible on touch devices)
✓ Row actions: hover to reveal (desktop) + swipe to reveal (touch) + context menu (universal)
```

### Fixed Pixel Dimensions
```
✗ Component hardcoded to width: 400px (breaks on narrow viewports)
✓ Component uses max-width: 400px with flexible width for smaller viewports
```
