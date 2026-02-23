# Vanilla JS & Web Components Patterns for Atomic Design

<overview>
This reference covers framework-agnostic implementation patterns for atomic design systems
using vanilla JavaScript, Web Components, and pure CSS. These patterns work without any
framework and can be used alongside any technology stack.
</overview>

<project_structure>
## Project Structure

### Recommended Structure

```
src/
├── tokens/
│   ├── colors.css
│   ├── typography.css
│   ├── spacing.css
│   ├── shadows.css
│   └── index.css           # Imports all token files
│
├── atoms/
│   ├── button/
│   │   ├── button.css
│   │   ├── button.js       # Web Component (optional)
│   │   └── index.js
│   ├── input/
│   ├── icon/
│   └── index.js
│
├── molecules/
│   ├── form-field/
│   ├── search-input/
│   └── index.js
│
├── organisms/
│   ├── header/
│   ├── footer/
│   └── index.js
│
├── templates/
│   ├── dashboard/
│   │   ├── dashboard.css
│   │   └── dashboard.html
│   └── index.js
│
├── styles/
│   ├── reset.css
│   ├── utilities.css
│   └── main.css            # Imports everything
│
└── index.html
```
</project_structure>

<css_tokens>
## CSS Custom Properties (Design Tokens)

### Token Files

```css
/* tokens/colors.css */
:root {
  /* Primitives (Tier 1) */
  --color-blue-50: #eff6ff;
  --color-blue-100: #dbeafe;
  --color-blue-500: #3b82f6;
  --color-blue-600: #2563eb;
  --color-blue-700: #1d4ed8;
  --color-blue-900: #1e3a8a;

  --color-gray-50: #f9fafb;
  --color-gray-100: #f3f4f6;
  --color-gray-200: #e5e7eb;
  --color-gray-400: #9ca3af;
  --color-gray-600: #4b5563;
  --color-gray-900: #111827;

  --color-white: #ffffff;
  --color-black: #000000;

  --color-green-500: #22c55e;
  --color-green-600: #16a34a;
  --color-red-500: #ef4444;
  --color-red-600: #dc2626;
  --color-yellow-500: #eab308;

  /* Semantic (Tier 2) */
  --color-text-primary: var(--color-gray-900);
  --color-text-secondary: var(--color-gray-600);
  --color-text-disabled: var(--color-gray-400);
  --color-text-inverse: var(--color-white);

  --color-background-default: var(--color-white);
  --color-background-subtle: var(--color-gray-50);
  --color-background-elevated: var(--color-white);

  --color-border-default: var(--color-gray-200);
  --color-border-strong: var(--color-gray-400);

  --color-action-primary: var(--color-blue-600);
  --color-action-primary-hover: var(--color-blue-700);
  --color-action-primary-active: var(--color-blue-800);

  --color-feedback-success: var(--color-green-600);
  --color-feedback-error: var(--color-red-600);
  --color-feedback-warning: var(--color-yellow-500);
}

/* Dark mode */
@media (prefers-color-scheme: dark) {
  :root {
    --color-text-primary: var(--color-gray-100);
    --color-text-secondary: var(--color-gray-400);
    --color-background-default: var(--color-gray-900);
    --color-background-subtle: var(--color-gray-800);
    --color-border-default: var(--color-gray-700);
  }
}

/* Manual dark mode toggle */
[data-theme="dark"] {
  --color-text-primary: var(--color-gray-100);
  --color-text-secondary: var(--color-gray-400);
  --color-background-default: var(--color-gray-900);
  --color-background-subtle: var(--color-gray-800);
  --color-border-default: var(--color-gray-700);
}
```

```css
/* tokens/typography.css */
:root {
  /* Font families */
  --font-family-sans: system-ui, -apple-system, sans-serif;
  --font-family-mono: ui-monospace, monospace;

  /* Font sizes */
  --font-size-xs: 0.75rem;   /* 12px */
  --font-size-sm: 0.875rem;  /* 14px */
  --font-size-base: 1rem;    /* 16px */
  --font-size-lg: 1.125rem;  /* 18px */
  --font-size-xl: 1.25rem;   /* 20px */
  --font-size-2xl: 1.5rem;   /* 24px */
  --font-size-3xl: 1.875rem; /* 30px */
  --font-size-4xl: 2.25rem;  /* 36px */

  /* Font weights */
  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;

  /* Line heights */
  --line-height-tight: 1.25;
  --line-height-normal: 1.5;
  --line-height-relaxed: 1.75;
}
```

```css
/* tokens/spacing.css */
:root {
  --space-0: 0;
  --space-1: 0.25rem;  /* 4px */
  --space-2: 0.5rem;   /* 8px */
  --space-3: 0.75rem;  /* 12px */
  --space-4: 1rem;     /* 16px */
  --space-5: 1.25rem;  /* 20px */
  --space-6: 1.5rem;   /* 24px */
  --space-8: 2rem;     /* 32px */
  --space-10: 2.5rem;  /* 40px */
  --space-12: 3rem;    /* 48px */
  --space-16: 4rem;    /* 64px */
}
```

```css
/* tokens/shadows.css */
:root {
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);

  --radius-sm: 0.25rem;  /* 4px */
  --radius-md: 0.375rem; /* 6px */
  --radius-lg: 0.5rem;   /* 8px */
  --radius-xl: 0.75rem;  /* 12px */
  --radius-full: 9999px;
}
```
</css_tokens>

<css_atoms>
## CSS-Only Atoms

### Button Atom

```css
/* atoms/button/button.css */
.button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
  border: none;
  border-radius: var(--radius-md);
  font-family: var(--font-family-sans);
  font-weight: var(--font-weight-medium);
  text-decoration: none;
  cursor: pointer;
  transition: background-color 0.2s, color 0.2s, box-shadow 0.2s;
}

.button:focus-visible {
  outline: 2px solid var(--color-action-primary);
  outline-offset: 2px;
}

.button:disabled,
.button[aria-disabled="true"] {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Variants */
.button--primary {
  background-color: var(--color-action-primary);
  color: var(--color-text-inverse);
}

.button--primary:hover:not(:disabled) {
  background-color: var(--color-action-primary-hover);
}

.button--secondary {
  background-color: var(--color-background-subtle);
  color: var(--color-text-primary);
}

.button--secondary:hover:not(:disabled) {
  background-color: var(--color-gray-200);
}

.button--ghost {
  background-color: transparent;
  color: var(--color-text-primary);
}

.button--ghost:hover:not(:disabled) {
  background-color: var(--color-background-subtle);
}

.button--destructive {
  background-color: var(--color-feedback-error);
  color: var(--color-text-inverse);
}

/* Sizes */
.button--sm {
  padding: var(--space-1) var(--space-2);
  font-size: var(--font-size-sm);
}

.button--md {
  padding: var(--space-2) var(--space-4);
  font-size: var(--font-size-base);
}

.button--lg {
  padding: var(--space-3) var(--space-6);
  font-size: var(--font-size-lg);
}

/* States */
.button--loading {
  position: relative;
  color: transparent;
}

.button--loading::after {
  content: "";
  position: absolute;
  width: 1em;
  height: 1em;
  border: 2px solid currentColor;
  border-right-color: transparent;
  border-radius: 50%;
  animation: button-spin 0.6s linear infinite;
}

@keyframes button-spin {
  to { transform: rotate(360deg); }
}
```

### Input Atom

```css
/* atoms/input/input.css */
.input {
  display: flex;
  align-items: center;
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-sm);
  background-color: var(--color-background-default);
  transition: border-color 0.2s, box-shadow 0.2s;
}

.input:focus-within {
  border-color: var(--color-action-primary);
  box-shadow: 0 0 0 3px rgb(37 99 235 / 0.1);
}

.input--error {
  border-color: var(--color-feedback-error);
}

.input--error:focus-within {
  box-shadow: 0 0 0 3px rgb(220 38 38 / 0.1);
}

.input--disabled {
  background-color: var(--color-background-subtle);
  cursor: not-allowed;
}

.input__field {
  flex: 1;
  border: none;
  background: transparent;
  padding: var(--space-2) var(--space-3);
  font-family: var(--font-family-sans);
  font-size: var(--font-size-base);
  color: var(--color-text-primary);
}

.input__field:focus {
  outline: none;
}

.input__field::placeholder {
  color: var(--color-text-secondary);
}

.input__field:disabled {
  cursor: not-allowed;
}

.input__addon {
  display: flex;
  align-items: center;
  padding: 0 var(--space-2);
  color: var(--color-text-secondary);
}

.input__addon--left {
  padding-right: 0;
}

.input__addon--right {
  padding-left: 0;
}
```

### HTML Usage

```html
<!-- Button examples -->
<button class="button button--primary button--md">
  Primary Button
</button>

<button class="button button--secondary button--md">
  Secondary Button
</button>

<button class="button button--ghost button--sm">
  <svg class="icon"><!-- icon --></svg>
  Ghost Button
</button>

<button class="button button--primary button--md button--loading" disabled>
  Loading...
</button>

<!-- Input examples -->
<div class="input">
  <input type="text" class="input__field" placeholder="Enter text...">
</div>

<div class="input input--error">
  <span class="input__addon input__addon--left">
    <svg class="icon"><!-- icon --></svg>
  </span>
  <input type="email" class="input__field" placeholder="Email" aria-invalid="true">
</div>
```
</css_atoms>

<web_components>
## Web Components

### Button Web Component

```javascript
// atoms/button/button.js
class BaseButton extends HTMLElement {
  static get observedAttributes() {
    return ['variant', 'size', 'disabled', 'loading'];
  }

  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
  }

  connectedCallback() {
    this.render();
    this.shadowRoot.querySelector('button').addEventListener('click', this.handleClick.bind(this));
  }

  disconnectedCallback() {
    this.shadowRoot.querySelector('button')?.removeEventListener('click', this.handleClick);
  }

  attributeChangedCallback() {
    if (this.shadowRoot) {
      this.render();
    }
  }

  handleClick(event) {
    if (this.hasAttribute('disabled') || this.hasAttribute('loading')) {
      event.preventDefault();
      return;
    }
    this.dispatchEvent(new CustomEvent('button-click', {
      bubbles: true,
      composed: true,
      detail: { originalEvent: event }
    }));
  }

  get variant() {
    return this.getAttribute('variant') || 'primary';
  }

  get size() {
    return this.getAttribute('size') || 'md';
  }

  get isDisabled() {
    return this.hasAttribute('disabled');
  }

  get isLoading() {
    return this.hasAttribute('loading');
  }

  render() {
    const disabled = this.isDisabled || this.isLoading;

    this.shadowRoot.innerHTML = `
      <style>
        :host {
          display: inline-block;
        }

        .button {
          display: inline-flex;
          align-items: center;
          justify-content: center;
          gap: var(--space-2, 0.5rem);
          border: none;
          border-radius: var(--radius-md, 0.375rem);
          font-family: var(--font-family-sans, system-ui);
          font-weight: var(--font-weight-medium, 500);
          cursor: pointer;
          transition: background-color 0.2s;
        }

        .button:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }

        .button--primary {
          background-color: var(--color-action-primary, #2563eb);
          color: var(--color-text-inverse, white);
        }

        .button--primary:hover:not(:disabled) {
          background-color: var(--color-action-primary-hover, #1d4ed8);
        }

        .button--secondary {
          background-color: var(--color-background-subtle, #f3f4f6);
          color: var(--color-text-primary, #111827);
        }

        .button--sm {
          padding: var(--space-1, 0.25rem) var(--space-2, 0.5rem);
          font-size: var(--font-size-sm, 0.875rem);
        }

        .button--md {
          padding: var(--space-2, 0.5rem) var(--space-4, 1rem);
          font-size: var(--font-size-base, 1rem);
        }

        .button--lg {
          padding: var(--space-3, 0.75rem) var(--space-6, 1.5rem);
          font-size: var(--font-size-lg, 1.125rem);
        }

        .spinner {
          width: 1em;
          height: 1em;
          border: 2px solid currentColor;
          border-right-color: transparent;
          border-radius: 50%;
          animation: spin 0.6s linear infinite;
        }

        @keyframes spin {
          to { transform: rotate(360deg); }
        }
      </style>

      <button
        class="button button--${this.variant} button--${this.size}"
        ${disabled ? 'disabled' : ''}
        aria-busy="${this.isLoading}"
      >
        ${this.isLoading ? '<span class="spinner"></span>' : ''}
        <slot></slot>
      </button>
    `;
  }
}

customElements.define('base-button', BaseButton);

// Usage:
// <base-button variant="primary" size="md">Click me</base-button>
// <base-button variant="secondary" loading>Loading...</base-button>
```

### Input Web Component

```javascript
// atoms/input/input.js
class BaseInput extends HTMLElement {
  static get observedAttributes() {
    return ['value', 'placeholder', 'type', 'disabled', 'error'];
  }

  constructor() {
    super();
    this.attachShadow({ mode: 'open' });
  }

  connectedCallback() {
    this.render();
    this.setupEventListeners();
  }

  setupEventListeners() {
    const input = this.shadowRoot.querySelector('input');

    input.addEventListener('input', (e) => {
      this.dispatchEvent(new CustomEvent('input-change', {
        bubbles: true,
        composed: true,
        detail: { value: e.target.value }
      }));
    });

    input.addEventListener('focus', () => {
      this.dispatchEvent(new CustomEvent('input-focus', { bubbles: true, composed: true }));
    });

    input.addEventListener('blur', () => {
      this.dispatchEvent(new CustomEvent('input-blur', { bubbles: true, composed: true }));
    });
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (oldValue !== newValue && this.shadowRoot.querySelector('input')) {
      if (name === 'value') {
        this.shadowRoot.querySelector('input').value = newValue || '';
      } else {
        this.render();
      }
    }
  }

  get value() {
    return this.getAttribute('value') || '';
  }

  set value(val) {
    this.setAttribute('value', val);
    const input = this.shadowRoot.querySelector('input');
    if (input) input.value = val;
  }

  render() {
    const hasError = this.hasAttribute('error');
    const isDisabled = this.hasAttribute('disabled');

    this.shadowRoot.innerHTML = `
      <style>
        :host {
          display: block;
        }

        .input {
          display: flex;
          align-items: center;
          border: 1px solid var(--color-border-default, #e5e7eb);
          border-radius: var(--radius-sm, 0.25rem);
          background-color: var(--color-background-default, white);
          transition: border-color 0.2s, box-shadow 0.2s;
        }

        .input:focus-within {
          border-color: var(--color-action-primary, #2563eb);
          box-shadow: 0 0 0 3px rgb(37 99 235 / 0.1);
        }

        .input--error {
          border-color: var(--color-feedback-error, #dc2626);
        }

        .input--disabled {
          background-color: var(--color-background-subtle, #f3f4f6);
          cursor: not-allowed;
        }

        .input__field {
          flex: 1;
          border: none;
          background: transparent;
          padding: var(--space-2, 0.5rem) var(--space-3, 0.75rem);
          font-family: var(--font-family-sans, system-ui);
          font-size: var(--font-size-base, 1rem);
          color: var(--color-text-primary, #111827);
          outline: none;
        }

        .input__field::placeholder {
          color: var(--color-text-secondary, #4b5563);
        }

        ::slotted([slot="left"]),
        ::slotted([slot="right"]) {
          display: flex;
          padding: 0 var(--space-2, 0.5rem);
          color: var(--color-text-secondary, #4b5563);
        }
      </style>

      <div class="input ${hasError ? 'input--error' : ''} ${isDisabled ? 'input--disabled' : ''}">
        <slot name="left"></slot>
        <input
          class="input__field"
          type="${this.getAttribute('type') || 'text'}"
          placeholder="${this.getAttribute('placeholder') || ''}"
          value="${this.value}"
          ${isDisabled ? 'disabled' : ''}
          ${hasError ? 'aria-invalid="true"' : ''}
        >
        <slot name="right"></slot>
      </div>
    `;
  }
}

customElements.define('base-input', BaseInput);

// Usage:
// <base-input placeholder="Enter email..." type="email"></base-input>
// <base-input error placeholder="Invalid input"></base-input>
```
</web_components>

<molecules_organisms>
## Molecules and Organisms

### FormField Molecule (CSS + HTML)

```css
/* molecules/form-field/form-field.css */
.form-field {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}

.form-field__label {
  font-size: var(--font-size-sm);
  font-weight: var(--font-weight-medium);
  color: var(--color-text-primary);
}

.form-field__label--required::after {
  content: " *";
  color: var(--color-feedback-error);
}

.form-field__helper {
  font-size: var(--font-size-sm);
  color: var(--color-text-secondary);
}

.form-field__error {
  font-size: var(--font-size-sm);
  color: var(--color-feedback-error);
}
```

```html
<!-- Form field molecule -->
<div class="form-field">
  <label class="form-field__label form-field__label--required" for="email">
    Email
  </label>
  <div class="input">
    <input
      type="email"
      id="email"
      class="input__field"
      placeholder="you@example.com"
      aria-describedby="email-error"
      aria-invalid="true"
    >
  </div>
  <span class="form-field__error" id="email-error">
    Please enter a valid email address
  </span>
</div>
```

### Header Organism

```css
/* organisms/header/header.css */
.header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-4) var(--space-6);
  background-color: var(--color-background-elevated);
  border-bottom: 1px solid var(--color-border-default);
}

.header__left {
  display: flex;
  align-items: center;
  gap: var(--space-6);
}

.header__nav {
  display: flex;
  gap: var(--space-1);
}

.header__nav-item {
  padding: var(--space-2) var(--space-3);
  color: var(--color-text-secondary);
  text-decoration: none;
  border-radius: var(--radius-sm);
  transition: background-color 0.2s, color 0.2s;
}

.header__nav-item:hover {
  background-color: var(--color-background-subtle);
  color: var(--color-text-primary);
}

.header__nav-item--active {
  background-color: var(--color-background-subtle);
  color: var(--color-action-primary);
}

.header__center {
  flex: 1;
  max-width: 400px;
  margin: 0 var(--space-6);
}

.header__right {
  display: flex;
  align-items: center;
  gap: var(--space-4);
}
```

```html
<!-- Header organism -->
<header class="header">
  <div class="header__left">
    <a href="/" class="header__logo">
      <img src="/logo.svg" alt="Company Logo" height="32">
    </a>
    <nav class="header__nav" aria-label="Main navigation">
      <a href="/products" class="header__nav-item header__nav-item--active">Products</a>
      <a href="/pricing" class="header__nav-item">Pricing</a>
      <a href="/docs" class="header__nav-item">Docs</a>
    </nav>
  </div>

  <div class="header__center">
    <div class="input">
      <span class="input__addon input__addon--left">
        <svg class="icon" aria-hidden="true"><!-- search icon --></svg>
      </span>
      <input type="search" class="input__field" placeholder="Search...">
    </div>
  </div>

  <div class="header__right">
    <button class="button button--primary button--md">
      Sign In
    </button>
  </div>
</header>
```
</molecules_organisms>

<templates>
## Templates

### Dashboard Template

```css
/* templates/dashboard/dashboard.css */
.dashboard-template {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.dashboard-template__header {
  flex-shrink: 0;
  position: sticky;
  top: 0;
  z-index: 100;
}

.dashboard-template__body {
  display: flex;
  flex: 1;
}

.dashboard-template__sidebar {
  width: 250px;
  flex-shrink: 0;
  background-color: var(--color-background-subtle);
  border-right: 1px solid var(--color-border-default);
  overflow-y: auto;
}

.dashboard-template__content {
  flex: 1;
  padding: var(--space-6);
  overflow-y: auto;
}

.dashboard-template__footer {
  flex-shrink: 0;
  border-top: 1px solid var(--color-border-default);
}

/* Responsive */
@media (max-width: 768px) {
  .dashboard-template__sidebar {
    position: fixed;
    left: -250px;
    top: 0;
    bottom: 0;
    z-index: 200;
    transition: left 0.3s ease;
  }

  .dashboard-template__sidebar--open {
    left: 0;
  }

  .dashboard-template__overlay {
    position: fixed;
    inset: 0;
    background: rgba(0, 0, 0, 0.5);
    z-index: 150;
    opacity: 0;
    visibility: hidden;
    transition: opacity 0.3s, visibility 0.3s;
  }

  .dashboard-template__sidebar--open + .dashboard-template__overlay {
    opacity: 1;
    visibility: visible;
  }
}
```

```html
<!-- Dashboard template -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard</title>
  <link rel="stylesheet" href="/styles/main.css">
</head>
<body>
  <div class="dashboard-template">
    <div class="dashboard-template__header">
      <!-- Header organism goes here -->
    </div>

    <div class="dashboard-template__body">
      <aside class="dashboard-template__sidebar" id="sidebar">
        <!-- Sidebar organism goes here -->
      </aside>
      <div class="dashboard-template__overlay" id="sidebar-overlay"></div>

      <main class="dashboard-template__content">
        <!-- Page content goes here -->
      </main>
    </div>

    <div class="dashboard-template__footer">
      <!-- Footer organism goes here -->
    </div>
  </div>

  <script>
    // Simple sidebar toggle for mobile
    const sidebar = document.getElementById('sidebar');
    const overlay = document.getElementById('sidebar-overlay');

    function toggleSidebar() {
      sidebar.classList.toggle('dashboard-template__sidebar--open');
    }

    overlay?.addEventListener('click', toggleSidebar);
  </script>
</body>
</html>
```
</templates>

<utility_classes>
## Utility Classes

```css
/* styles/utilities.css */

/* Display */
.hidden { display: none; }
.block { display: block; }
.inline-block { display: inline-block; }
.flex { display: flex; }
.inline-flex { display: inline-flex; }
.grid { display: grid; }

/* Flexbox */
.flex-row { flex-direction: row; }
.flex-col { flex-direction: column; }
.items-start { align-items: flex-start; }
.items-center { align-items: center; }
.items-end { align-items: flex-end; }
.justify-start { justify-content: flex-start; }
.justify-center { justify-content: center; }
.justify-end { justify-content: flex-end; }
.justify-between { justify-content: space-between; }
.flex-wrap { flex-wrap: wrap; }
.flex-1 { flex: 1; }

/* Gap */
.gap-1 { gap: var(--space-1); }
.gap-2 { gap: var(--space-2); }
.gap-3 { gap: var(--space-3); }
.gap-4 { gap: var(--space-4); }
.gap-6 { gap: var(--space-6); }
.gap-8 { gap: var(--space-8); }

/* Spacing (margin/padding) */
.m-0 { margin: 0; }
.m-auto { margin: auto; }
.mx-auto { margin-left: auto; margin-right: auto; }
.p-0 { padding: 0; }
.p-4 { padding: var(--space-4); }
.p-6 { padding: var(--space-6); }

/* Text */
.text-sm { font-size: var(--font-size-sm); }
.text-base { font-size: var(--font-size-base); }
.text-lg { font-size: var(--font-size-lg); }
.text-xl { font-size: var(--font-size-xl); }
.font-medium { font-weight: var(--font-weight-medium); }
.font-bold { font-weight: var(--font-weight-bold); }
.text-center { text-align: center; }

/* Colors */
.text-primary { color: var(--color-text-primary); }
.text-secondary { color: var(--color-text-secondary); }
.bg-default { background-color: var(--color-background-default); }
.bg-subtle { background-color: var(--color-background-subtle); }

/* Border */
.border { border: 1px solid var(--color-border-default); }
.border-none { border: none; }
.rounded-sm { border-radius: var(--radius-sm); }
.rounded-md { border-radius: var(--radius-md); }
.rounded-lg { border-radius: var(--radius-lg); }
.rounded-full { border-radius: var(--radius-full); }

/* Shadow */
.shadow-sm { box-shadow: var(--shadow-sm); }
.shadow-md { box-shadow: var(--shadow-md); }
.shadow-lg { box-shadow: var(--shadow-lg); }

/* Width/Height */
.w-full { width: 100%; }
.h-full { height: 100%; }
.min-h-screen { min-height: 100vh; }

/* Visibility */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}
```
</utility_classes>

<references>
## Related References

- [design-tokens.md](../design-tokens.md) — Token architecture
- [naming-conventions.md](../naming-conventions.md) — Naming patterns
- [component-hierarchy.md](../component-hierarchy.md) — Import rules
</references>
