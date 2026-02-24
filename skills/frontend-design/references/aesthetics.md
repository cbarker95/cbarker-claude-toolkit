# Aesthetics & Visual Design

Creative guidelines for distinctive, production-grade interfaces that avoid generic AI aesthetics.

**IMPORTANT**: If the project has a `DESIGN_LANGUAGE.md`, follow it precisely. These guidelines apply as creative direction when no project design language exists, or for aspects the design language doesn't cover.

## Design Thinking

Before coding, commit to a BOLD aesthetic direction:

- **Tone**: Pick an intentional extreme — brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian. Use these for inspiration but design one true to the aesthetic direction.
- **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

Choose a clear conceptual direction and execute it with precision.

## Typography

Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt for distinctive choices that elevate the design. Pair a distinctive display font with a refined body font.

**Exception**: If the project's design language specifies a font system (e.g., system fonts only), follow that constraint. Creative font choices apply only when the design language allows it or doesn't exist.

## Colour & Theme

Commit to a cohesive aesthetic. Use CSS variables or theme tokens for consistency. Dominant colours with sharp accents outperform timid, evenly-distributed palettes.

## Motion

Use animations for effects and micro-interactions. Prioritise CSS-only solutions for HTML. Use Motion library for React when available.

Focus on high-impact moments: one well-orchestrated page load with staggered reveals (`animation-delay`) creates more delight than scattered micro-interactions. Use scroll-triggering and hover states that surprise.

## Spatial Composition

Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density.

## Backgrounds & Visual Details

Create atmosphere and depth rather than defaulting to solid colours. Apply creative forms like gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, decorative borders, and grain overlays.

## Matching Complexity to Vision

Maximalist designs need elaborate code with extensive animations and effects. Minimalist or refined designs need restraint, precision, and careful attention to spacing, typography, and subtle details. Elegance comes from executing the vision well — not from adding more.

Vary between light and dark themes, different fonts, different aesthetics across projects. NEVER converge on the same choices (Space Grotesk, for example) across generations.

## Anti-Patterns — Never Do These

- Overused font families (Inter, Roboto, Arial, system fonts as a default aesthetic choice)
- Cliched colour schemes (particularly purple gradients on white backgrounds)
- Predictable layouts and cookie-cutter component patterns
- Generic AI-generated aesthetics that lack context-specific character
- Using the same aesthetic across different projects — each should feel distinct

Interpret creatively and make unexpected choices that feel genuinely designed for the context. Claude is capable of extraordinary creative work — don't hold back.
