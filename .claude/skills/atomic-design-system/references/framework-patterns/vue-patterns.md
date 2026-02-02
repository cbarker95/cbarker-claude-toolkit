# Vue Patterns for Atomic Design

<overview>
This reference covers Vue 3-specific implementation patterns for atomic design systems,
including Composition API, TypeScript integration, and styling approaches.
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
│   │   └── index.ts
│   │
│   ├── atoms/
│   │   ├── BaseButton/
│   │   │   ├── BaseButton.vue
│   │   │   ├── BaseButton.spec.ts
│   │   │   ├── BaseButton.stories.ts
│   │   │   └── index.ts
│   │   ├── BaseInput/
│   │   └── index.ts
│   │
│   ├── molecules/
│   │   ├── FormField/
│   │   └── index.ts
│   │
│   ├── organisms/
│   │   ├── AppHeader/
│   │   └── index.ts
│   │
│   ├── templates/
│   │   ├── DashboardLayout/
│   │   └── index.ts
│   │
│   └── index.ts
│
├── pages/
│   ├── HomePage.vue
│   └── DashboardPage.vue
│
└── App.vue
```

### Vite Path Aliases (vite.config.ts)

```typescript
import { defineConfig } from 'vite';
import vue from '@vitejs/plugin-vue';
import path from 'path';

export default defineConfig({
  plugins: [vue()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@atoms': path.resolve(__dirname, './src/design-system/atoms'),
      '@molecules': path.resolve(__dirname, './src/design-system/molecules'),
      '@organisms': path.resolve(__dirname, './src/design-system/organisms'),
      '@templates': path.resolve(__dirname, './src/design-system/templates'),
      '@tokens': path.resolve(__dirname, './src/design-system/tokens'),
    },
  },
});
```
</project_structure>

<atom_patterns>
## Atom Patterns

### Basic Atom with Script Setup

```vue
<!-- atoms/BaseButton/BaseButton.vue -->
<script setup lang="ts">
import { computed } from 'vue';

export interface Props {
  variant?: 'primary' | 'secondary' | 'ghost' | 'destructive';
  size?: 'sm' | 'md' | 'lg';
  isLoading?: boolean;
  isDisabled?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  variant: 'primary',
  size: 'md',
  isLoading: false,
  isDisabled: false,
});

const emit = defineEmits<{
  click: [event: MouseEvent];
}>();

const isButtonDisabled = computed(() => props.isDisabled || props.isLoading);

const buttonClasses = computed(() => [
  'base-button',
  `base-button--${props.variant}`,
  `base-button--${props.size}`,
  {
    'base-button--loading': props.isLoading,
    'base-button--disabled': isButtonDisabled.value,
  },
]);

function handleClick(event: MouseEvent) {
  if (!isButtonDisabled.value) {
    emit('click', event);
  }
}
</script>

<template>
  <button
    :class="buttonClasses"
    :disabled="isButtonDisabled"
    :aria-busy="isLoading"
    @click="handleClick"
  >
    <span v-if="isLoading" class="base-button__spinner">
      <BaseSpinner size="sm" />
    </span>
    <span v-if="$slots.leftIcon && !isLoading" class="base-button__icon-left">
      <slot name="leftIcon" />
    </span>
    <span class="base-button__label">
      <slot />
    </span>
    <span v-if="$slots.rightIcon && !isLoading" class="base-button__icon-right">
      <slot name="rightIcon" />
    </span>
  </button>
</template>

<style scoped>
.base-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-md);
  font-weight: var(--font-weight-medium);
  transition: all 0.2s ease;
}

.base-button--primary {
  background: var(--color-action-primary);
  color: var(--color-text-inverse);
}

.base-button--primary:hover:not(:disabled) {
  background: var(--color-action-primary-hover);
}

.base-button--sm {
  padding: var(--space-1) var(--space-2);
  font-size: var(--font-size-sm);
}

.base-button--md {
  padding: var(--space-2) var(--space-4);
  font-size: var(--font-size-base);
}

.base-button--lg {
  padding: var(--space-3) var(--space-6);
  font-size: var(--font-size-lg);
}
</style>
```

### Input Atom with v-model

```vue
<!-- atoms/BaseInput/BaseInput.vue -->
<script setup lang="ts">
import { computed } from 'vue';

export interface Props {
  modelValue: string;
  placeholder?: string;
  type?: 'text' | 'email' | 'password' | 'number';
  hasError?: boolean;
  isDisabled?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  type: 'text',
  hasError: false,
  isDisabled: false,
});

const emit = defineEmits<{
  'update:modelValue': [value: string];
  focus: [event: FocusEvent];
  blur: [event: FocusEvent];
}>();

const inputClasses = computed(() => [
  'base-input',
  {
    'base-input--error': props.hasError,
    'base-input--disabled': props.isDisabled,
  },
]);

function handleInput(event: Event) {
  const target = event.target as HTMLInputElement;
  emit('update:modelValue', target.value);
}
</script>

<template>
  <div :class="inputClasses">
    <span v-if="$slots.left" class="base-input__left">
      <slot name="left" />
    </span>

    <input
      :value="modelValue"
      :type="type"
      :placeholder="placeholder"
      :disabled="isDisabled"
      :aria-invalid="hasError"
      class="base-input__field"
      @input="handleInput"
      @focus="emit('focus', $event)"
      @blur="emit('blur', $event)"
    />

    <span v-if="$slots.right" class="base-input__right">
      <slot name="right" />
    </span>
  </div>
</template>

<style scoped>
.base-input {
  display: flex;
  align-items: center;
  border: 1px solid var(--color-border-default);
  border-radius: var(--radius-sm);
  background: var(--color-background-default);
}

.base-input--error {
  border-color: var(--color-feedback-error);
}

.base-input__field {
  flex: 1;
  border: none;
  background: transparent;
  padding: var(--space-2) var(--space-3);
}

.base-input__field:focus {
  outline: none;
}

.base-input:focus-within {
  border-color: var(--color-action-primary);
  box-shadow: 0 0 0 2px var(--color-action-primary-alpha);
}
</style>
```

### Index Export

```typescript
// atoms/BaseButton/index.ts
export { default as BaseButton } from './BaseButton.vue';
export type { Props as BaseButtonProps } from './BaseButton.vue';
```
</atom_patterns>

<molecule_patterns>
## Molecule Patterns

### FormField Molecule

```vue
<!-- molecules/FormField/FormField.vue -->
<script setup lang="ts">
import { computed, useId } from 'vue';
import { BaseLabel } from '@atoms/BaseLabel';
import { BaseInput } from '@atoms/BaseInput';
import { BaseText } from '@atoms/BaseText';

export interface Props {
  modelValue: string;
  label: string;
  helperText?: string;
  errorMessage?: string;
  isRequired?: boolean;
  isDisabled?: boolean;
  type?: 'text' | 'email' | 'password';
}

const props = withDefaults(defineProps<Props>(), {
  isRequired: false,
  isDisabled: false,
  type: 'text',
});

const emit = defineEmits<{
  'update:modelValue': [value: string];
}>();

const fieldId = useId();
const hasError = computed(() => Boolean(props.errorMessage));
const describedById = computed(() =>
  hasError.value ? `${fieldId}-error` : props.helperText ? `${fieldId}-helper` : undefined
);
</script>

<template>
  <div class="form-field">
    <BaseLabel :for="fieldId" :isRequired="isRequired">
      {{ label }}
    </BaseLabel>

    <BaseInput
      :id="fieldId"
      :modelValue="modelValue"
      :type="type"
      :hasError="hasError"
      :isDisabled="isDisabled"
      :aria-describedby="describedById"
      @update:modelValue="emit('update:modelValue', $event)"
    >
      <template v-if="$slots.left" #left>
        <slot name="left" />
      </template>
      <template v-if="$slots.right" #right>
        <slot name="right" />
      </template>
    </BaseInput>

    <BaseText
      v-if="hasError"
      :id="`${fieldId}-error`"
      variant="error"
      size="sm"
    >
      {{ errorMessage }}
    </BaseText>

    <BaseText
      v-else-if="helperText"
      :id="`${fieldId}-helper`"
      variant="secondary"
      size="sm"
    >
      {{ helperText }}
    </BaseText>
  </div>
</template>

<style scoped>
.form-field {
  display: flex;
  flex-direction: column;
  gap: var(--space-1);
}
</style>
```

### SearchInput Molecule

```vue
<!-- molecules/SearchInput/SearchInput.vue -->
<script setup lang="ts">
import { ref } from 'vue';
import { BaseInput } from '@atoms/BaseInput';
import { BaseButton } from '@atoms/BaseButton';
import { BaseIcon } from '@atoms/BaseIcon';

export interface Props {
  placeholder?: string;
  isLoading?: boolean;
  modelValue?: string;
}

const props = withDefaults(defineProps<Props>(), {
  placeholder: 'Search...',
  isLoading: false,
  modelValue: '',
});

const emit = defineEmits<{
  'update:modelValue': [value: string];
  search: [value: string];
}>();

const searchValue = ref(props.modelValue);

function handleSearch() {
  emit('search', searchValue.value);
}

function handleClear() {
  searchValue.value = '';
  emit('update:modelValue', '');
  emit('search', '');
}

function handleInput(value: string) {
  searchValue.value = value;
  emit('update:modelValue', value);
}
</script>

<template>
  <form class="search-input" @submit.prevent="handleSearch">
    <BaseInput
      :modelValue="searchValue"
      :placeholder="placeholder"
      @update:modelValue="handleInput"
    >
      <template #left>
        <BaseIcon name="search" />
      </template>
      <template v-if="searchValue" #right>
        <BaseButton
          variant="ghost"
          size="sm"
          type="button"
          aria-label="Clear search"
          @click="handleClear"
        >
          <BaseIcon name="x" />
        </BaseButton>
      </template>
    </BaseInput>

    <BaseButton type="submit" :isLoading="isLoading">
      Search
    </BaseButton>
  </form>
</template>

<style scoped>
.search-input {
  display: flex;
  gap: var(--space-2);
}
</style>
```

### Provide/Inject Pattern (Compound Components)

```vue
<!-- molecules/Tabs/TabsRoot.vue -->
<script setup lang="ts">
import { provide, ref, readonly } from 'vue';
import { TABS_INJECTION_KEY } from './keys';

export interface Props {
  defaultValue: string;
}

const props = defineProps<Props>();

const activeTab = ref(props.defaultValue);

function setActiveTab(value: string) {
  activeTab.value = value;
}

provide(TABS_INJECTION_KEY, {
  activeTab: readonly(activeTab),
  setActiveTab,
});
</script>

<template>
  <div class="tabs">
    <slot />
  </div>
</template>
```

```vue
<!-- molecules/Tabs/TabsTab.vue -->
<script setup lang="ts">
import { inject, computed } from 'vue';
import { TABS_INJECTION_KEY } from './keys';

export interface Props {
  value: string;
}

const props = defineProps<Props>();

const tabs = inject(TABS_INJECTION_KEY);
if (!tabs) {
  throw new Error('TabsTab must be used within TabsRoot');
}

const isActive = computed(() => tabs.activeTab.value === props.value);

function handleClick() {
  tabs.setActiveTab(props.value);
}
</script>

<template>
  <button
    role="tab"
    :aria-selected="isActive"
    :class="['tabs-tab', { 'tabs-tab--active': isActive }]"
    @click="handleClick"
  >
    <slot />
  </button>
</template>
```

```typescript
// molecules/Tabs/keys.ts
import type { InjectionKey, Ref } from 'vue';

export interface TabsContext {
  activeTab: Readonly<Ref<string>>;
  setActiveTab: (value: string) => void;
}

export const TABS_INJECTION_KEY: InjectionKey<TabsContext> = Symbol('tabs');
```
</molecule_patterns>

<organism_patterns>
## Organism Patterns

### Header Organism

```vue
<!-- organisms/AppHeader/AppHeader.vue -->
<script setup lang="ts">
import { BaseLogo } from '@atoms/BaseLogo';
import { BaseButton } from '@atoms/BaseButton';
import { NavItem } from '@molecules/NavItem';
import { SearchInput } from '@molecules/SearchInput';
import { UserMenu } from '@molecules/UserMenu';

export interface NavItemData {
  label: string;
  href: string;
  isActive?: boolean;
}

export interface User {
  name: string;
  avatar: string;
}

export interface Props {
  user?: User | null;
  navItems: NavItemData[];
}

defineProps<Props>();

const emit = defineEmits<{
  search: [query: string];
  login: [];
  logout: [];
}>();
</script>

<template>
  <header class="app-header">
    <div class="app-header__left">
      <BaseLogo />
      <nav class="app-header__nav" aria-label="Main navigation">
        <NavItem
          v-for="item in navItems"
          :key="item.href"
          :href="item.href"
          :isActive="item.isActive"
        >
          {{ item.label }}
        </NavItem>
      </nav>
    </div>

    <div class="app-header__center">
      <SearchInput @search="emit('search', $event)" />
    </div>

    <div class="app-header__right">
      <UserMenu
        v-if="user"
        :user="user"
        @logout="emit('logout')"
      />
      <BaseButton v-else @click="emit('login')">
        Log In
      </BaseButton>
    </div>
  </header>
</template>

<style scoped>
.app-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-4) var(--space-6);
  background: var(--color-background-elevated);
  border-bottom: 1px solid var(--color-border-default);
}

.app-header__left {
  display: flex;
  align-items: center;
  gap: var(--space-6);
}

.app-header__nav {
  display: flex;
  gap: var(--space-2);
}
</style>
```

### LoginForm Organism

```vue
<!-- organisms/LoginForm/LoginForm.vue -->
<script setup lang="ts">
import { reactive, ref } from 'vue';
import { FormField } from '@molecules/FormField';
import { BaseButton } from '@atoms/BaseButton';
import { BaseLink } from '@atoms/BaseLink';

interface FormData {
  email: string;
  password: string;
}

interface FormErrors {
  email?: string;
  password?: string;
  form?: string;
}

const emit = defineEmits<{
  submit: [data: FormData];
  forgotPassword: [];
}>();

const formData = reactive<FormData>({
  email: '',
  password: '',
});

const errors = reactive<FormErrors>({});
const isSubmitting = ref(false);

function validate(): boolean {
  errors.email = undefined;
  errors.password = undefined;

  if (!formData.email) {
    errors.email = 'Email is required';
  } else if (!/\S+@\S+\.\S+/.test(formData.email)) {
    errors.email = 'Please enter a valid email';
  }

  if (!formData.password) {
    errors.password = 'Password is required';
  } else if (formData.password.length < 8) {
    errors.password = 'Password must be at least 8 characters';
  }

  return !errors.email && !errors.password;
}

async function handleSubmit() {
  if (!validate()) return;

  isSubmitting.value = true;
  errors.form = undefined;

  try {
    emit('submit', { ...formData });
  } catch (error) {
    errors.form = 'Invalid email or password';
  } finally {
    isSubmitting.value = false;
  }
}
</script>

<template>
  <form class="login-form" @submit.prevent="handleSubmit">
    <div v-if="errors.form" class="login-form__error" role="alert">
      {{ errors.form }}
    </div>

    <FormField
      v-model="formData.email"
      label="Email"
      type="email"
      :errorMessage="errors.email"
      isRequired
      autocomplete="email"
    />

    <FormField
      v-model="formData.password"
      label="Password"
      type="password"
      :errorMessage="errors.password"
      isRequired
      autocomplete="current-password"
    />

    <div class="login-form__actions">
      <BaseButton type="submit" :isLoading="isSubmitting">
        Log In
      </BaseButton>
      <BaseLink @click="emit('forgotPassword')">
        Forgot password?
      </BaseLink>
    </div>
  </form>
</template>

<style scoped>
.login-form {
  display: flex;
  flex-direction: column;
  gap: var(--space-4);
}

.login-form__error {
  padding: var(--space-3);
  background: var(--color-feedback-error-background);
  color: var(--color-feedback-error);
  border-radius: var(--radius-sm);
}

.login-form__actions {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: var(--space-2);
}
</style>
```
</organism_patterns>

<template_patterns>
## Template Patterns

### Slot-Based Template

```vue
<!-- templates/DashboardLayout/DashboardLayout.vue -->
<script setup lang="ts">
export interface Props {
  hasSidebar?: boolean;
}

withDefaults(defineProps<Props>(), {
  hasSidebar: true,
});
</script>

<template>
  <div class="dashboard-layout">
    <header class="dashboard-layout__header">
      <slot name="header" />
    </header>

    <div class="dashboard-layout__body">
      <aside v-if="hasSidebar" class="dashboard-layout__sidebar">
        <slot name="sidebar" />
      </aside>

      <main class="dashboard-layout__content">
        <slot />
      </main>
    </div>

    <footer v-if="$slots.footer" class="dashboard-layout__footer">
      <slot name="footer" />
    </footer>
  </div>
</template>

<style scoped>
.dashboard-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.dashboard-layout__header {
  flex-shrink: 0;
}

.dashboard-layout__body {
  display: flex;
  flex: 1;
}

.dashboard-layout__sidebar {
  width: 250px;
  flex-shrink: 0;
  border-right: 1px solid var(--color-border-default);
}

.dashboard-layout__content {
  flex: 1;
  padding: var(--space-6);
}

.dashboard-layout__footer {
  flex-shrink: 0;
}
</style>
```

### Usage in Page

```vue
<!-- pages/DashboardPage.vue -->
<script setup lang="ts">
import { DashboardLayout } from '@templates/DashboardLayout';
import { AppHeader } from '@organisms/AppHeader';
import { Sidebar } from '@organisms/Sidebar';
import { StatsGrid } from '@organisms/StatsGrid';
import { ActivityFeed } from '@organisms/ActivityFeed';

// Data fetching with composables
const { user } = useUser();
const { stats } = useStats();
const { activity } = useActivity();
</script>

<template>
  <DashboardLayout>
    <template #header>
      <AppHeader :user="user" :navItems="navItems" />
    </template>

    <template #sidebar>
      <Sidebar :navigation="user.navigation" />
    </template>

    <StatsGrid :stats="stats" />
    <ActivityFeed :items="activity" />
  </DashboardLayout>
</template>
```
</template_patterns>

<composables>
## Composables

### useToggle

```typescript
// composables/useToggle.ts
import { ref, readonly } from 'vue';

export function useToggle(initialValue = false) {
  const value = ref(initialValue);

  function toggle() {
    value.value = !value.value;
  }

  function setTrue() {
    value.value = true;
  }

  function setFalse() {
    value.value = false;
  }

  return {
    value: readonly(value),
    toggle,
    setTrue,
    setFalse,
  };
}
```

### useClickOutside

```typescript
// composables/useClickOutside.ts
import { onMounted, onUnmounted, Ref } from 'vue';

export function useClickOutside(
  elementRef: Ref<HTMLElement | null>,
  callback: () => void
) {
  function handler(event: MouseEvent) {
    if (!elementRef.value) return;
    if (!elementRef.value.contains(event.target as Node)) {
      callback();
    }
  }

  onMounted(() => {
    document.addEventListener('mousedown', handler);
  });

  onUnmounted(() => {
    document.removeEventListener('mousedown', handler);
  });
}

// Usage
const dropdownRef = ref<HTMLElement | null>(null);
const { value: isOpen, setFalse: close } = useToggle();

useClickOutside(dropdownRef, close);
```
</composables>

<testing>
## Testing

### Component Testing with Vitest

```typescript
// atoms/BaseButton/BaseButton.spec.ts
import { describe, it, expect, vi } from 'vitest';
import { mount } from '@vue/test-utils';
import BaseButton from './BaseButton.vue';

describe('BaseButton', () => {
  it('renders slot content', () => {
    const wrapper = mount(BaseButton, {
      slots: { default: 'Click me' },
    });

    expect(wrapper.text()).toContain('Click me');
  });

  it('emits click event when clicked', async () => {
    const wrapper = mount(BaseButton);

    await wrapper.trigger('click');

    expect(wrapper.emitted('click')).toHaveLength(1);
  });

  it('is disabled when isDisabled is true', () => {
    const wrapper = mount(BaseButton, {
      props: { isDisabled: true },
    });

    expect(wrapper.attributes('disabled')).toBeDefined();
  });

  it('applies variant class', () => {
    const wrapper = mount(BaseButton, {
      props: { variant: 'secondary' },
    });

    expect(wrapper.classes()).toContain('base-button--secondary');
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
