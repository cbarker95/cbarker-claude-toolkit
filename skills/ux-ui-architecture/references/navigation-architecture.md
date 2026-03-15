# Navigation Architecture

## Purpose

Navigation architecture determines whether users can find and discover features. Bad IA hides functionality behind non-intuitive labels or deep nesting. Good IA mirrors user mental models so features feel obvious. This reference covers IA models, the LATCH categorization method, navigation pattern types, and evaluation criteria.

Based on Nielsen Norman Group's information architecture research and industry-standard IA practices.

---

## Three Components of Information Architecture (NN/G)

### 1. Navigation Systems

The UI elements that help users move through content:
- **Global navigation** — Always visible (sidebar, top nav, icon rail)
- **Local navigation** — Context-specific (sub-nav, breadcrumbs, tabs)
- **Contextual navigation** — Inline links, related items, cross-references
- **Supplemental navigation** — Search, quick switcher, site map

### 2. Taxonomies and Labeling

How content is categorized and named:
- **Labels** — What you call things (use user language, not developer jargon)
- **Categories** — How things are grouped (by type, by status, by domain concept)
- **Metadata** — Tags, dates, types that enable filtering and sorting

### 3. Full IA Structure

The complete information backbone:
- **Hierarchy** — Parent-child relationships between content areas
- **Relationships** — Cross-links between related content (wikilinks, backlinks)
- **Sequences** — Ordered workflows (onboarding steps, review pipelines)

---

## LATCH Method

Five fundamental ways to organize any information. Choose based on user task:

| Method | Organize By | Best When | Example |
|--------|------------|-----------|---------|
| **L**ocation | Physical/spatial position | Geographic data, floor plans, maps | Offices by region, stores by city |
| **A**lphabet | A-Z ordering | Reference lists, contacts, glossaries | Customer list A-Z, feature index |
| **T**ime | Chronological sequence | Events, history, timelines | Interview timeline, activity feed, changelog |
| **C**ategory | Shared attributes | Similar items, types, roles | Opportunities by type (pain point, unmet need, desire) |
| **H**ierarchy | Magnitude/importance | Priority ordering, rankings | Opportunities by evidence weight, P0/P1/P2 priorities |

### Applying LATCH to Specs

When designing a new information display, ask:
1. What is the user's primary task? (finding a specific item? browsing? comparing?)
2. Which LATCH method matches that task?
3. Can multiple LATCH methods coexist? (e.g., list sortable by name OR date OR category)

---

## Polyhierarchy

Content can exist in multiple organizational paths simultaneously:

```
By Customer:           By Opportunity Type:       By Status:
├── Acme Corp          ├── Pain Points            ├── Active
│   ├── Interview 1    │   ├── Opp A (Acme)       │   ├── Opp A
│   ├── Opp A          │   └── Opp C (Beta Inc)   │   └── Opp B
│   └── Opp B          ├── Unmet Needs            └── Archived
└── Beta Inc           │   └── Opp B (Acme)           └── Opp C
    ├── Interview 2    └── Desires
    └── Opp C              └── Opp D (Beta Inc)
```

The same opportunity appears in customer, type, and status views. This is good — it supports different user tasks without duplicating data.

**Spec implication:** Design multiple views/filters for the same data, not separate copies.

---

## Navigation Pattern Types

### Hub-and-Spoke

Central hub page with links to detail pages. User returns to hub between tasks.

```
         ┌──── Page A
         │
Hub ─────┼──── Page B
         │
         └──── Page C
```

**Best for:** Dashboard-centric apps, settings pages, admin panels.
**Example:** Home dashboard → click card → detail page → back to dashboard.

### Nested/Hierarchical

Drill-down through levels. Each level narrows focus.

```
Level 1 ──→ Level 2 ──→ Level 3
Customers    Customer     Interview
             Detail       Detail
```

**Best for:** Entity-relationship exploration, file systems, documentation.
**Example:** Customers list → Customer detail → Interview detail.

### Flat/Tabbed

All sections at same level, switchable via tabs or segments.

```
┌──────┬──────┬──────┬──────┐
│ Tab A│ Tab B│ Tab C│ Tab D│
└──────┴──────┴──────┴──────┘
│         Content Area        │
```

**Best for:** Multi-aspect views of same entity, settings categories.
**Example:** Customer detail tabs: Overview | Interviews | Opportunities | Notes.

### Rail-Based (Icon Rail + Sidebar)

Vertical icon rail for mode switching + persistent sidebar for content navigation.

```
┌────┬──────────┬──────────────────┐
│    │          │                  │
│ 🏠 │ Sidebar  │                  │
│ 👥 │ (context │   Main Content   │
│ 🌳 │  files)  │                  │
│ ⚙️ │          │                  │
│    │          │                  │
└────┴──────────┴──────────────────┘
```

**Best for:** Power-user apps with multiple modes and deep content trees.
**Example:** habitatd icon rail (Home, Customers, Discovery Tree, Settings) + file explorer sidebar + tabbed content area.

### Breadcrumb

Shows path from root to current location. Enables jump to any parent.

```
Home > Customers > Acme Corp > Interview #3
```

**Best for:** Deep hierarchies, file systems, content management.
**Caution:** Don't use breadcrumbs as primary navigation — they're supplemental.

---

## Navigation Pattern Selection Guide

| App Characteristic | Recommended Pattern | Why |
|-------------------|-------------------|-----|
| Few top-level areas (<5) | Icon rail or top nav | Everything visible at once |
| Many top-level areas (5+) | Sidebar with categories | Scrollable, groupable |
| Deep content hierarchies | Nested + breadcrumbs | Drill-down with escape hatches |
| Multiple independent modes | Rail-based | Each mode is a different context |
| Single-entity multi-aspect | Tabbed | All facets of one thing |
| Dashboard-centric | Hub-and-spoke | Start from overview, drill into detail |
| Keyboard-heavy users | Quick switcher (Cmd+P) | Bypass navigation entirely |
| Mobile or narrow viewports | Bottom tab bar or hamburger | Touch-friendly, space-efficient |

---

## Findability and Discoverability

Two distinct IA outcomes:

### Findability
Can users locate a feature when they know it exists?

**Evaluation questions:**
- Can the user describe what they're looking for? (label matches mental model)
- Is the navigation label predictable? ("Settings" not "Configuration Hub")
- Is the feature within 2 clicks from any starting point?
- Does search find it? (label, aliases, description all searchable)

### Discoverability
Can users learn about features they didn't know existed?

**Evaluation questions:**
- Are new features surfaced in relevant contexts? (contextual suggestions)
- Does the navigation reveal capability? (visible labels, not hidden menus)
- Are related features cross-linked? (backlinks, "related" sections)
- Is there progressive disclosure? (basic features visible, advanced discoverable)

---

## IA Validation Methods

### Card Sort (Low-Effort)
Give users cards with feature names. Ask them to group the cards into categories and label the groups.
- **Reveals:** User mental models for categorization
- **Use for:** Designing top-level navigation labels

### Tree Test (Low-Effort)
Give users a text-only hierarchy. Ask them to find specific items.
- **Reveals:** Whether the hierarchy matches user expectations
- **Use for:** Validating navigation structure before building UI

### First-Click Test
Show a page design. Ask users "where would you click to do X?"
- **Reveals:** Whether primary actions are visible and intuitive
- **Use for:** Validating page layout and action placement

---

## Example: Analyzing an Existing IA

### habitatd Navigation Analysis

```
Icon Rail (mode selector):
├── 🏠 Home        → Hub-and-spoke: dashboard with health, insights, activity
├── 👥 Customers   → Nested: customer list → customer detail → interview detail
├── 🌳 Discovery   → Canvas: OST tree (outcome → opportunity → solution → experiment)
└── ⚙️ Settings    → Flat/tabbed: workspace, integrations, pipeline, account

Sidebar (content navigator — always visible):
├── Interviews/    → File explorer: vault-backed interview files
├── Opportunities/ → File explorer: opportunity markdown files
├── Solutions/     → File explorer: solution files
├── Proposals/     → File explorer: proposal files
└── Snapshots/     → File explorer: interview snapshot files

Content Area (tabbed):
└── Named tabs for open files/pages, closeable, reorderable
```

**IA Assessment:**
- ✓ Rail-based pattern appropriate for multiple independent modes
- ✓ Sidebar provides persistent file access across all modes
- ✓ LATCH: Category (by entity type in sidebar), Hierarchy (in Discovery Tree)
- ✗ Gap: No quick switcher (Cmd+P) for fast navigation
- ✗ Gap: No cross-references between related entities in different views

---

## Anti-Patterns

### Feature-Organized IA
```
✗ Nav labels map to code modules: "Ingest | Analyze | Propose | Export"
✓ Nav labels map to user concepts: "Customers | Opportunities | Discovery Tree"
```

### Deep Nesting Without Escape
```
✗ Settings → Advanced → Integrations → OAuth → Zoom → Callback → Configuration
✓ Settings → Integrations (flat list with search and direct links)
```

### Inconsistent Taxonomy Depth
```
✗ Some nav items have 5 sub-levels, others have 0
✓ Consistent depth across similar content types (all entities have list → detail → sub-detail)
```

### Hidden Navigation
```
✗ Features only accessible through right-click context menus or undocumented shortcuts
✓ Primary features visible in persistent navigation, shortcuts as accelerators
```
