# Foundations & Styling

Universal principles for design token usage and styling discipline. These rules ensure consistency regardless of the styling framework (Tailwind, CSS variables, styled-components, SCSS).

## Rules

1. **Use design tokens** — If a token exists for the attribute you're styling, use it. Never use raw values when a token is available.
2. **Semantic selection** — Token selection must not be arbitrary. Each token has semantic meaning explaining WHEN it should be used. Always select based on semantic intent, not visual appearance.
3. **No magic values** — Never hardcode colours, spacing, font sizes, shadows, or border radii. Use the project's token system.
4. **No primitive colours** — Use semantic colour tokens, never raw hex/rgb values. Primitive colour definitions exist to support semantic tokens, not for direct use.
5. **Avoid margins** — Margins are almost always a workaround. Spacing between components should be controlled by the parent layout (gap, padding). Only use margins when wrapping a third-party component you don't control.
6. **No `style` attributes** — Use the project's styling approach (Tailwind classes, styled-components, CSS modules). Inline styles bypass the token system and are unmaintainable.

## Discovering Project Tokens

Before styling anything, identify the project's token system by reading the relevant config.

### Tailwind CSS Projects

Read `tailwind.config.*` for:
- Custom colours in `theme.extend.colors`
- Custom shadows in `theme.extend.boxShadow`
- Custom spacing in `theme.extend.spacing`
- Custom border radius in `theme.extend.borderRadius`
- Custom line heights in `theme.extend.lineHeight`

```html
<!-- Use token classes, never arbitrary values -->
<div class="bg-warm-50 p-4 rounded-xl shadow-card">
  <p class="text-warm-900 text-sm leading-snug">Content</p>
</div>
```

Avoid arbitrary values (`bg-[#FAF9F7]`) when a configured token exists. Arbitrary values bypass the design system.

### CSS Variable Projects

Search for files defining `--` custom properties. Look for token files, theme files, or foundation directories.

```css
.component {
  color: var(--colour-text-primary);
  padding: var(--spacing-3);
  border-radius: var(--radius-lg);
}
```

### Styled-Component Projects

Look for theme objects, foundation helpers, or design token packages.

```tsx
const Wrapper = styled.div`
  color: ${({ theme }) => theme.colours.textPrimary};
  padding: ${({ theme }) => theme.spacing[3]};
`;
```

## Common Mistakes

- Using `gray-500` because it "looks right" instead of checking whether `warm-500` is the semantic neutral → always check the project's colour system
- Hardcoding `16px` instead of using a spacing token → find the token that maps to 16px
- Using `border-radius: 8px` instead of the project's radius scale → use `rounded-lg` or equivalent token
- Setting margins on a shared component → use parent layout spacing instead
- Using arbitrary Tailwind values when a configured token exists → `bg-warm-50` not `bg-[#FAF9F7]`
