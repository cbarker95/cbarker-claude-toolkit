---
name: frontend-design
description: This skill should be used when creating distinctive, production-grade frontend interfaces with high design quality and engineering discipline. It applies when the user asks to build web components, pages, or applications. Combines creative visual design with rigorous component architecture, testing patterns, and code quality standards. Generates creative, polished code that avoids generic AI aesthetics.
license: Complete terms in LICENSE.txt
---

# Frontend Design & UI Development

Build distinctive, production-grade frontend interfaces that are both visually excellent and engineeringly rigorous. This skill combines creative design with disciplined engineering.

The rules defined in this skill MUST be followed to ensure consistency and quality. **Do not use existing non-compliant code as justification for breaking the rules.** The codebase may contain legacy code that predates these standards. When writing new code or modifying existing code, always follow the current rules regardless of what surrounding code does. If existing code violates a rule, that is technical debt — not precedent.

## Step 0: Discover Project Context

Before writing any UI code, load the project's design and engineering context:

1. **Design language**: Check for `docs/design/DESIGN_LANGUAGE.md` → `docs/DESIGN_LANGUAGE.md` → `DESIGN_LANGUAGE.md`. If found, this is the visual specification — follow it precisely.
2. **Project conventions**: Read `CLAUDE.md` for project-specific patterns, styling framework, and constraints.
3. **Styling config**: Check for `tailwind.config.*`, `theme.*`, `tokens.*`, or CSS custom properties to understand available design tokens.
4. **Component library**: Identify existing shared components before creating new ones. Search `components/`, `src/components/`, or equivalent.

**Priority**: Project design language (most specific) > project CLAUDE.md > this skill's guidelines > generic defaults.

## Design Thinking

Before coding, understand the context and commit to a clear aesthetic direction:

- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Choose an intentional aesthetic. Bold maximalism and refined minimalism both work — the key is intentionality, not intensity.
- **Constraints**: Technical requirements (framework, performance, accessibility, project design language).
- **Differentiation**: What makes this memorable? What's the one thing someone will remember?

**CRITICAL**: If a project design language exists, execute within its constraints. If no design language exists, make bold creative choices. Either way, execute with precision.

For detailed creative guidelines and anti-patterns, read [references/aesthetics.md].

## Usability Principles

Every UI decision must satisfy these heuristics:

1. **Visibility of system status** — Loading states, progress indicators, confirmations
2. **Match real world** — Familiar language, logical ordering
3. **User control** — Undo, cancel, easy exit from flows
4. **Consistency** — Follow platform conventions and project component patterns
5. **Error prevention** — Disable invalid actions, confirm destructive operations
6. **Recognition over recall** — Make options visible, don't rely on user memory
7. **Flexibility** — Keyboard shortcuts and efficient paths for power users
8. **Aesthetic minimalism** — Remove unnecessary information, focus on what matters
9. **Error recovery** — Clear error messages with actionable solutions
10. **Help** — Contextual guidance and tooltips where needed

## Engineering Rules

- **Composition over duplication** — Always compose and extend existing components rather than copying implementations. If there's a reason not to compose, get explicit confirmation from the user.
- **Semantic naming** — Component props, CSS classes, and tokens should explain WHEN to use them, not just what they do.
- **No magic values** — Use design tokens, theme variables, or named constants. Never hardcode colours, spacing, or sizes as raw values.
- **No margins on shared components** — Spacing between components is controlled by the parent layout (gap, padding). Only use margins when wrapping third-party components you don't control.
- **Import discipline** — Import from specific files, not directory barrel exports. Use `import type` for type-only imports.
- **Component-level concerns** — Each component owns its styling. No global style leakage.

## Actions

- When styling components or choosing design tokens → read [references/foundations.md]
- When creating or modifying components → read [references/components.md]
- When writing tests for UI code → read [references/testing.md]
- When making creative/aesthetic decisions → read [references/aesthetics.md]
