# Component Hierarchy & Composition Patterns

<overview>
This reference defines the rules for how atomic design components relate to and
compose each other. Proper hierarchy ensures maintainability, prevents circular
dependencies, and makes the system predictable.

**The core rule:** Components can only import from levels below them, never from
the same level or above.
</overview>

<import_rules>
## Import Rules

### The Hierarchy

```
Level 5: Pages
    ↓ can import
Level 4: Templates
    ↓ can import
Level 3: Organisms
    ↓ can import
Level 2: Molecules
    ↓ can import
Level 1: Atoms
    ↓ can import
Level 0: Design Tokens / Utilities
```

### Import Matrix

| Component Level | Can Import From |
|-----------------|-----------------|
| **Atoms** | Tokens, utilities only |
| **Molecules** | Atoms, tokens, utilities |
| **Organisms** | Molecules, atoms, tokens, utilities |
| **Templates** | Organisms, molecules, atoms, tokens |
| **Pages** | Templates, organisms, molecules, atoms, tokens |

### What's NOT Allowed

```typescript
// ❌ WRONG: Atom importing atom
// atoms/Button/Button.tsx
import { Icon } from '../Icon';  // Atoms shouldn't compose atoms

// ❌ WRONG: Molecule importing molecule
// molecules/SearchInput/SearchInput.tsx
import { FormField } from '../FormField';  // Molecules at same level

// ❌ WRONG: Organism importing organism
// organisms/Header/Header.tsx
import { Footer } from '../Footer';  // Organisms at same level

// ❌ WRONG: Lower level importing higher level
// atoms/Button/Button.tsx
import { Header } from '../../organisms/Header';  // Atom importing organism!
```

### What IS Allowed

```typescript
// ✓ CORRECT: Molecule importing atoms
// molecules/SearchInput/SearchInput.tsx
import { Button } from '@/atoms/Button';
import { Input } from '@/atoms/Input';
import { Icon } from '@/atoms/Icon';

// ✓ CORRECT: Organism importing molecules and atoms
// organisms/Header/Header.tsx
import { NavItem } from '@/molecules/NavItem';
import { SearchInput } from '@/molecules/SearchInput';
import { Button } from '@/atoms/Button';
import { Logo } from '@/atoms/Logo';

// ✓ CORRECT: Template importing organisms
// templates/DashboardTemplate/DashboardTemplate.tsx
import { Header } from '@/organisms/Header';
import { Sidebar } from '@/organisms/Sidebar';
import { Footer } from '@/organisms/Footer';
```
</import_rules>

<composition_patterns>
## Composition Patterns

### Pattern 1: Slot-Based Composition

Templates and organisms often use slots (children) rather than hard-coding content:

```tsx
// templates/PageTemplate.tsx
interface PageTemplateProps {
  header: React.ReactNode;
  sidebar?: React.ReactNode;
  children: React.ReactNode;
  footer: React.ReactNode;
}

export function PageTemplate({ header, sidebar, children, footer }: PageTemplateProps) {
  return (
    <div className="page">
      <header className="page__header">{header}</header>
      <div className="page__body">
        {sidebar && <aside className="page__sidebar">{sidebar}</aside>}
        <main className="page__content">{children}</main>
      </div>
      <footer className="page__footer">{footer}</footer>
    </div>
  );
}

// Usage in page
<PageTemplate
  header={<Header />}
  sidebar={<Sidebar />}
  footer={<Footer />}
>
  <ProductGrid products={products} />
</PageTemplate>
```

### Pattern 2: Compound Components

Related atoms/molecules that work together:

```tsx
// molecules/Tabs (compound component pattern)
const Tabs = ({ children, defaultValue }) => {
  const [activeTab, setActiveTab] = useState(defaultValue);
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
};

Tabs.List = ({ children }) => (
  <div className="tabs__list" role="tablist">{children}</div>
);

Tabs.Tab = ({ value, children }) => {
  const { activeTab, setActiveTab } = useTabsContext();
  return (
    <button
      role="tab"
      aria-selected={activeTab === value}
      onClick={() => setActiveTab(value)}
    >
      {children}
    </button>
  );
};

Tabs.Panel = ({ value, children }) => {
  const { activeTab } = useTabsContext();
  if (activeTab !== value) return null;
  return <div role="tabpanel">{children}</div>;
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

### Pattern 3: Render Props / Headless

Separate logic from presentation:

```tsx
// molecules/Dropdown (headless)
interface DropdownProps {
  children: (props: {
    isOpen: boolean;
    toggle: () => void;
    close: () => void;
  }) => React.ReactNode;
}

export function Dropdown({ children }: DropdownProps) {
  const [isOpen, setIsOpen] = useState(false);
  const toggle = () => setIsOpen(!isOpen);
  const close = () => setIsOpen(false);

  return <>{children({ isOpen, toggle, close })}</>;
}

// Usage - consumer controls presentation
<Dropdown>
  {({ isOpen, toggle }) => (
    <div>
      <Button onClick={toggle}>Menu</Button>
      {isOpen && (
        <div className="dropdown-menu">
          <NavItem>Item 1</NavItem>
          <NavItem>Item 2</NavItem>
        </div>
      )}
    </div>
  )}
</Dropdown>
```

### Pattern 4: Variant Props

Atoms and molecules expose variants rather than having multiple similar components:

```tsx
// atoms/Button.tsx
interface ButtonProps {
  variant: 'primary' | 'secondary' | 'ghost' | 'destructive';
  size: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
  isDisabled?: boolean;
  leftIcon?: React.ReactNode;
  rightIcon?: React.ReactNode;
  children: React.ReactNode;
}

// Usage
<Button variant="primary" size="md">Submit</Button>
<Button variant="ghost" size="sm" leftIcon={<Icon name="edit" />}>Edit</Button>
<Button variant="destructive" isLoading>Delete</Button>
```
</composition_patterns>

<state_management>
## State Ownership

### Rule: State Lives at the Highest Necessary Level

```
Pages         → Application/route state, data fetching
Templates     → Layout state (sidebar open/closed)
Organisms     → Section state (form values, local UI state)
Molecules     → Minimal state (dropdown open, input focus)
Atoms         → NO state (stateless, controlled)
```

### Atoms: Always Controlled

```tsx
// ✓ CORRECT: Atom is controlled (no internal state)
function Input({ value, onChange, ...props }) {
  return <input value={value} onChange={onChange} {...props} />;
}

// ❌ WRONG: Atom with internal state
function Input({ defaultValue, ...props }) {
  const [value, setValue] = useState(defaultValue);
  return <input value={value} onChange={e => setValue(e.target.value)} {...props} />;
}
```

### Molecules: Minimal UI State Only

```tsx
// ✓ CORRECT: Molecule manages its own UI state
function Dropdown({ trigger, children }) {
  const [isOpen, setIsOpen] = useState(false);  // UI state OK
  return (
    <div>
      <div onClick={() => setIsOpen(!isOpen)}>{trigger}</div>
      {isOpen && <div className="dropdown-menu">{children}</div>}
    </div>
  );
}

// ❌ WRONG: Molecule managing business data
function UserSelector({ onSelect }) {
  const [users, setUsers] = useState([]);
  useEffect(() => {
    fetchUsers().then(setUsers);  // Data fetching belongs in organism/page
  }, []);
  // ...
}
```

### Organisms: Section-Level State

```tsx
// ✓ CORRECT: Organism manages form state
function LoginForm({ onSubmit }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await onSubmit({ email, password });
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <form onSubmit={handleSubmit}>
      <FormField label="Email" value={email} onChange={setEmail} />
      <FormField label="Password" type="password" value={password} onChange={setPassword} />
      {error && <Alert variant="error">{error}</Alert>}
      <Button type="submit">Log In</Button>
    </form>
  );
}
```

### Pages: Application State & Data Fetching

```tsx
// ✓ CORRECT: Page handles data fetching and app state
function DashboardPage() {
  const { data: user, isLoading } = useUser();
  const { data: stats } = useStats();
  const { data: activity } = useActivity();

  if (isLoading) return <LoadingTemplate />;

  return (
    <DashboardTemplate
      header={<Header user={user} />}
      sidebar={<Sidebar navigation={user.navigation} />}
    >
      <StatsGrid stats={stats} />
      <ActivityFeed items={activity} />
    </DashboardTemplate>
  );
}
```
</state_management>

<dependency_enforcement>
## Enforcing the Hierarchy

### ESLint Rules

```javascript
// .eslintrc.js
module.exports = {
  rules: {
    'import/no-restricted-paths': [
      'error',
      {
        zones: [
          // Atoms cannot import from molecules, organisms, templates, pages
          {
            target: './src/atoms',
            from: './src/molecules',
            message: 'Atoms cannot import molecules',
          },
          {
            target: './src/atoms',
            from: './src/organisms',
            message: 'Atoms cannot import organisms',
          },
          // Molecules cannot import from organisms, templates, pages
          {
            target: './src/molecules',
            from: './src/organisms',
            message: 'Molecules cannot import organisms',
          },
          // Organisms cannot import from templates, pages
          {
            target: './src/organisms',
            from: './src/templates',
            message: 'Organisms cannot import templates',
          },
          // Templates cannot import from pages
          {
            target: './src/templates',
            from: './src/pages',
            message: 'Templates cannot import pages',
          },
        ],
      },
    ],
  },
};
```

### TypeScript Path Aliases

```json
// tsconfig.json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/atoms/*": ["src/atoms/*"],
      "@/molecules/*": ["src/molecules/*"],
      "@/organisms/*": ["src/organisms/*"],
      "@/templates/*": ["src/templates/*"],
      "@/pages/*": ["src/pages/*"],
      "@/tokens/*": ["src/tokens/*"]
    }
  }
}
```

### Folder Structure

```
src/
├── tokens/              # Level 0: Design tokens
│   ├── colors.ts
│   ├── typography.ts
│   └── spacing.ts
├── atoms/               # Level 1: Atoms
│   ├── Button/
│   ├── Input/
│   └── Icon/
├── molecules/           # Level 2: Molecules
│   ├── FormField/
│   ├── SearchInput/
│   └── NavItem/
├── organisms/           # Level 3: Organisms
│   ├── Header/
│   ├── Footer/
│   └── ProductCard/
├── templates/           # Level 4: Templates
│   ├── DashboardTemplate/
│   └── MarketingTemplate/
└── pages/               # Level 5: Pages
    ├── HomePage/
    └── DashboardPage/
```
</dependency_enforcement>

<common_mistakes>
## Common Mistakes

### Mistake 1: Organisms Importing Organisms

```tsx
// ❌ WRONG
// organisms/PageLayout/PageLayout.tsx
import { Header } from '../Header';
import { Footer } from '../Footer';
import { Sidebar } from '../Sidebar';

// ✓ CORRECT: This should be a Template
// templates/PageLayout/PageLayout.tsx
import { Header } from '@/organisms/Header';
import { Footer } from '@/organisms/Footer';
import { Sidebar } from '@/organisms/Sidebar';
```

### Mistake 2: Atoms Composing Atoms

```tsx
// ❌ WRONG
// atoms/IconButton/IconButton.tsx
import { Button } from '../Button';
import { Icon } from '../Icon';

// ✓ CORRECT: IconButton is a Molecule
// molecules/IconButton/IconButton.tsx
import { Button } from '@/atoms/Button';
import { Icon } from '@/atoms/Icon';
```

### Mistake 3: Molecules With Too Much Responsibility

```tsx
// ❌ WRONG: This molecule does too much
// molecules/ProductCard/ProductCard.tsx
function ProductCard({ product }) {
  return (
    <div>
      <img src={product.image} />
      <h3>{product.title}</h3>
      <p>{product.description}</p>
      <span>{product.price}</span>
      <Rating value={product.rating} />
      <Button onClick={() => addToCart(product)}>Add to Cart</Button>
      <Button variant="ghost" onClick={() => toggleWishlist(product)}>
        <Icon name="heart" />
      </Button>
    </div>
  );
}

// ✓ CORRECT: ProductCard is an Organism
// organisms/ProductCard/ProductCard.tsx
```

### Mistake 4: Passing Too Many Props Down

```tsx
// ❌ WRONG: Prop drilling through many levels
<Page
  headerLogo={logo}
  headerNavItems={navItems}
  headerUserName={user.name}
  headerUserAvatar={user.avatar}
  // ... 20 more header props
/>

// ✓ CORRECT: Compose at the appropriate level
<Page>
  <Header>
    <Logo src={logo} />
    <Nav items={navItems} />
    <UserMenu user={user} />
  </Header>
  {/* ... */}
</Page>
```
</common_mistakes>

<references>
## Related References

- [core-concepts.md](./core-concepts.md) — Level definitions
- [naming-conventions.md](./naming-conventions.md) — File/component naming
- [testing-strategies.md](./testing-strategies.md) — Testing at each level
</references>
