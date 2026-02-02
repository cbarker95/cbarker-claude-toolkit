# Atomic Design Core Concepts

<overview>
Atomic design is a methodology for creating design systems composed of five distinct
levels: atoms, molecules, organisms, templates, and pages. Introduced by Brad Frost
in 2013, it provides a mental model for building interfaces as hierarchical compositions.

**The core insight:** We're not designing pages, we're designing systems of components.

This reference covers:
- The five levels in detail
- Classification criteria
- Common examples at each level
- Edge cases and judgment calls
</overview>

<atoms>
## Level 1: Atoms

Atoms are the foundational building blocks—UI elements that can't be broken down
further without losing their meaning or functionality.

### Characteristics

- **Indivisible:** Breaking them apart renders them non-functional
- **Abstract:** Often not useful on their own (a label without context)
- **Foundational:** Everything else is built from atoms
- **Stateless:** No internal state; receive all data via props

### Examples

**HTML Element Atoms:**
```
Button          → <button>
Input           → <input>
Label           → <label>
Image           → <img>
Icon            → <svg> or icon font
Link            → <a>
Heading         → <h1>-<h6>
Paragraph       → <p>
List Item       → <li>
Table Cell      → <td>
```

**Design Token Atoms:**
```
Colors          → --color-blue-500, --color-text-primary
Typography      → --font-size-base, --font-weight-bold
Spacing         → --space-4, --space-8
Shadows         → --shadow-sm, --shadow-md
Border Radius   → --radius-sm, --radius-full
Animations      → --duration-fast, --ease-in-out
```

**Abstract Atoms:**
```
Color Palette   → Brand colors, semantic colors
Type Scale      → Heading sizes, body sizes
Spacing Scale   → 4px, 8px, 16px, 24px, 32px
Icon Set        → Collection of icons
```

### Classification Test

Ask: **"Can this be broken into smaller functional pieces?"**

```
Button → Can you break a button into smaller parts?
         The text inside? That's content, not structure.
         No → It's an atom.

Card   → Can you break a card into smaller parts?
         Image, title, description, button...
         Yes → It's NOT an atom (it's a molecule or organism).
```

### Common Atom Components

```
atoms/
├── Button/
│   ├── Button.tsx
│   ├── Button.styles.ts
│   └── Button.test.tsx
├── Input/
├── Label/
├── Icon/
├── Avatar/
├── Badge/
├── Checkbox/
├── Radio/
├── Toggle/
├── Spinner/
├── Divider/
└── Typography/
    ├── Heading/
    ├── Text/
    └── Caption/
```
</atoms>

<molecules>
## Level 2: Molecules

Molecules are simple combinations of atoms that form functional units. They do
one thing and do it well.

### Characteristics

- **Simple composition:** 2-4 atoms combined
- **Single purpose:** One clear function
- **Reusable:** Used in multiple organisms
- **Portable:** Can move between contexts

### Examples

**Form Molecules:**
```
FormField       → Label + Input + ErrorMessage
SearchInput     → Input + Button (search icon)
Checkbox Field  → Checkbox + Label
Select Field    → Label + Select + HelpText
Password Input  → Input + Toggle (show/hide)
```

**Display Molecules:**
```
MediaObject     → Image + Text block
Stat            → Label + Value + Trend indicator
NavItem         → Icon + Label + Badge
ListItem        → Checkbox + Text + Actions
Breadcrumb Item → Link + Separator
```

**Interactive Molecules:**
```
Pagination      → Prev button + Page numbers + Next button
Rating          → Star icons (interactive)
Toggle Group    → Multiple toggle buttons
Stepper         → Decrement + Value + Increment
```

### Classification Test

Ask: **"Is this a simple combination with a single purpose?"**

```
SearchInput → Input + Button
             Simple? Yes (2 atoms)
             Single purpose? Yes (search)
             → It's a molecule.

Header      → Logo + Nav + Search + User Menu
             Simple? No (4+ distinct pieces)
             Single purpose? No (multiple functions)
             → It's NOT a molecule (it's an organism).
```

### The "One Thing" Rule

A molecule should answer: **"What does this do?"** with a single phrase:

```
✓ FormField      → "Captures a single form value"
✓ SearchInput    → "Submits a search query"
✓ MediaObject    → "Displays media with text"
✓ NavItem        → "Links to a destination"

✗ ProductCard    → "Displays product AND adds to cart AND shows rating"
                   (Multiple things = organism)
```

### Common Molecule Components

```
molecules/
├── FormField/
├── SearchInput/
├── MediaObject/
├── NavItem/
├── ListItem/
├── Stat/
├── Rating/
├── Breadcrumb/
├── Pagination/
├── Toast/
├── Tooltip/
└── Dropdown/
```
</molecules>

<organisms>
## Level 3: Organisms

Organisms are complex, distinct sections of an interface composed of molecules
and atoms. They represent discrete pieces of the UI.

### Characteristics

- **Complex composition:** Multiple molecules and atoms
- **Self-contained:** Standalone interface sections
- **Contextual:** Often tied to specific content types
- **Stateful:** May manage internal state

### Examples

**Navigation Organisms:**
```
Header          → Logo + MainNav + Search + UserMenu
Footer          → FooterNav + Social + Legal + Newsletter
Sidebar         → Logo + Navigation + UserProfile
MobileNav       → Hamburger + Drawer + NavItems
```

**Content Organisms:**
```
ProductCard     → Image + Title + Price + Rating + AddToCart
ArticleCard     → Image + Category + Title + Excerpt + Author
CommentSection  → CommentForm + CommentList
HeroSection     → Heading + Subheading + CTA + BackgroundImage
```

**Form Organisms:**
```
LoginForm       → Email field + Password field + Remember me + Submit
SignupForm      → Name + Email + Password + Terms + Submit
CheckoutForm    → Shipping + Payment + Review + Submit
SearchFilters   → Category + Price range + Rating + Apply
```

**Data Organisms:**
```
DataTable       → Header row + Body rows + Pagination + Actions
UserList        → Search + Filters + UserCards + Pagination
Dashboard       → Stats + Charts + RecentActivity
```

### Classification Test

Ask: **"Is this a distinct, self-contained section of the interface?"**

```
Header → Distinct section? Yes (top of page, always present)
         Self-contained? Yes (has all it needs)
         → It's an organism.

Button → Distinct section? No (just an element)
         Self-contained? Yes, but too simple
         → It's NOT an organism (it's an atom).
```

### Organism Boundaries

Organisms should be **"seams" in the interface**—natural boundaries where you
could potentially swap out the implementation:

```
┌─────────────────────────────────────────────┐
│ Header (organism)                           │
├─────────────────────────────────────────────┤
│ ┌─────────────────┐ ┌─────────────────────┐ │
│ │ HeroSection     │ │ Sidebar             │ │
│ │ (organism)      │ │ (organism)          │ │
│ └─────────────────┘ │                     │ │
│ ┌─────────────────┐ │                     │ │
│ │ ProductGrid     │ │                     │ │
│ │ (organism)      │ │                     │ │
│ └─────────────────┘ └─────────────────────┘ │
├─────────────────────────────────────────────┤
│ Footer (organism)                           │
└─────────────────────────────────────────────┘
```

### Common Organism Components

```
organisms/
├── Header/
├── Footer/
├── Sidebar/
├── HeroSection/
├── ProductCard/
├── ProductGrid/
├── ArticleList/
├── CommentSection/
├── LoginForm/
├── SearchResults/
├── DataTable/
├── Modal/
├── Drawer/
└── Notification/
```
</organisms>

<templates>
## Level 4: Templates

Templates are page-level layouts that define the structure and placement of
organisms without real content. They're the skeleton of a page.

### Characteristics

- **Layout-focused:** Define where things go, not what they are
- **Content-agnostic:** Use placeholder content
- **Reusable:** Same template, different content
- **Structural:** Grid systems, content areas

### Examples

**Common Templates:**
```
MarketingPageTemplate
├── Header slot
├── Hero slot
├── Features slot (3-column grid)
├── Testimonials slot
├── CTA slot
└── Footer slot

DashboardTemplate
├── Sidebar slot
├── Header slot
├── Main content area
│   ├── Stats row
│   ├── Charts grid
│   └── Activity feed
└── (No footer)

ArticleTemplate
├── Header slot
├── Breadcrumbs slot
├── Article content (constrained width)
├── Sidebar (related articles)
└── Footer slot
```

### Classification Test

Ask: **"Does this define structure without being tied to specific content?"**

```
DashboardTemplate → Defines: sidebar + header + content areas
                    Content: placeholder boxes
                    → It's a template.

DashboardPage     → Defines: same structure
                    Content: actual charts, real data
                    → It's NOT a template (it's a page).
```

### Template vs Organism

The distinction:
- **Organism:** A discrete, portable UI section (ProductCard)
- **Template:** Page-level structure that positions organisms

```
Template = "Where organisms go"
Organism = "What fills those slots"
```

### Common Templates

```
templates/
├── MarketingPageTemplate/
├── DashboardTemplate/
├── ArticleTemplate/
├── ProductPageTemplate/
├── CheckoutTemplate/
├── AuthTemplate/
├── SettingsTemplate/
└── ErrorTemplate/
```
</templates>

<pages>
## Level 5: Pages

Pages are specific instances of templates filled with real content. They're what
users actually see and interact with.

### Characteristics

- **Concrete:** Real content, real data
- **Specific:** Tied to actual use cases
- **Testable:** Where we validate the full experience
- **Route-connected:** Usually mapped to URLs

### Examples

```
HomePage (uses MarketingPageTemplate)
├── Header with real logo, nav
├── Hero with "Welcome to Acme" headline
├── Features showing actual product features
├── Testimonials with real customer quotes
└── Footer with real links

UserDashboard (uses DashboardTemplate)
├── Sidebar with user's actual navigation
├── Header with user's name, avatar
├── Stats showing user's real metrics
├── Charts with user's actual data
└── Activity feed with recent events
```

### Classification Test

Ask: **"Is this a template filled with real content?"**

```
/dashboard      → DashboardTemplate + real user data → Page
/products/123   → ProductPageTemplate + actual product → Page
/checkout       → CheckoutTemplate + cart items → Page
```

### Pages in Code

Pages often live in routing:

```
pages/
├── index.tsx           → HomePage
├── dashboard.tsx       → DashboardPage
├── products/
│   ├── index.tsx       → ProductListPage
│   └── [id].tsx        → ProductDetailPage
├── checkout.tsx        → CheckoutPage
└── auth/
    ├── login.tsx       → LoginPage
    └── signup.tsx      → SignupPage
```
</pages>

<edge_cases>
## Edge Cases and Judgment Calls

### "Is this an atom or molecule?"

**Rule of thumb:** If it wraps a single HTML element, it's an atom. If it combines
multiple elements for a purpose, it's a molecule.

```
Avatar        → Single <img> with styling → Atom
AvatarGroup   → Multiple avatars composed → Molecule

Icon          → Single <svg> → Atom
IconButton    → Icon + Button behavior → Molecule
```

### "Is this a molecule or organism?"

**Rule of thumb:** If it does one thing, molecule. If it's a distinct section with
multiple purposes, organism.

```
SearchInput   → Submits a query → Molecule
SearchSection → Input + filters + results → Organism

NavItem       → Links somewhere → Molecule
Header        → Branding + nav + actions → Organism
```

### "Should I create a new atom or use an existing one?"

Create new atom when:
- The HTML element needs specific styling not covered
- It has unique accessibility requirements
- It's used in 3+ places

Reuse existing atom when:
- Differences are only in props/variants
- The styling variations fit the existing API
- It's a one-off usage

### Labels Don't Matter

Brad Frost: "The specific labels have never been the point."

What matters:
- Understanding hierarchical composition
- Building from small to large
- Creating reusable, composable pieces

If your team calls them "elements, components, sections, layouts, views"—that's fine,
as long as the hierarchy is clear.
</edge_cases>

<references>
## Sources

- [Atomic Design - Brad Frost](https://atomicdesign.bradfrost.com/)
- [Atomic Design Methodology - Chapter 2](https://atomicdesign.bradfrost.com/chapter-2/)
- [Build Systems, Not Pages - Design Systems](https://www.designsystems.com/brad-frosts-atomic-design-build-systems-not-pages/)
</references>
