# Page Architecture

Section ordering, layout patterns, and structural blueprints for high-conversion B2B SaaS pages. Architecture determines whether visitors scroll, scan, and convert — or bounce.

---

## Above-the-Fold Anatomy

The first viewport is the most important real estate on any page. It must accomplish four things in under 5 seconds:

1. **What is this?** — Clear headline communicating the product's outcome
2. **Is it for me?** — Subheadline targeting the specific audience or problem
3. **What do I do?** — Primary CTA with clear next step
4. **Can I trust it?** — Social proof hint (logos, metric, or endorsement)

### Hero Layout Pattern
```
┌──────────────────────────────────────────────────────┐
│  [Nav: Logo | Links | CTA button]                    │
├──────────────────────────────────────────────────────┤
│                                                      │
│  [H1: Outcome-driven headline]                       │
│  [Subhead: Specificity — who, how, or proof]         │
│                                                      │
│  [Primary CTA]  [Secondary CTA]                      │
│  [Friction reducer: "No credit card required"]       │
│                                                      │
│  [Visual: Product screenshot, demo, or illustration] │
│                                                      │
│  [Social proof bar: 5-7 logos or "10,000+ teams"]    │
│                                                      │
└──────────────────────────────────────────────────────┘
```

### Hero Variations

**Statement Hero** — Bold claim + proof
```
H1: "Deploy in 4 minutes, not 4 sprints"
Sub: "The deployment platform trusted by 2,800+ engineering teams"
```

**Question Hero** — Provoke recognition of the problem
```
H1: "Still coordinating releases over Slack?"
Sub: "There's a better way. Acme automates your entire deploy pipeline."
```

**Metric Hero** — Lead with a number
```
H1: "73% faster deploys. Zero manual steps."
Sub: "See why teams at Stripe and Ramp switched to Acme."
```

**Demo Hero** — Product visual does the talking
```
H1: [Minimal — 5-7 words]
[Large product screenshot or animated demo taking up 60% of viewport]
```

---

## Section Ordering by Page Type

### Homepage (Full Marketing Site)

The homepage qualifies visitors and routes them. It's not a feature dump — it's a guided narrative.

```
1. Hero            — Outcome headline + CTA + social proof hint
2. Logo Bar        — Recognized customer logos (trust signal)
3. Problem/Pain    — Articulate the pain (PAS framework)
4. Solution        — How your product solves it (3-4 key capabilities)
5. Social Proof    — Featured testimonial with name, title, result
6. How It Works    — 3-step simplicity narrative
7. Feature Deep    — 2-3 feature sections with visuals
8. Metrics         — Results customers have achieved (specific numbers)
9. Case Study      — Full testimonial or case study teaser
10. Pricing Teaser — Plans overview or "Start free" CTA
11. Final CTA      — Closing argument + primary CTA
12. Footer         — Links, legal, secondary CTAs
```

### Landing Page (Campaign / Launch)

Landing pages convert one audience on one action. Remove all distractions.

```
1. Hero            — Specific offer headline + single CTA
2. Problem         — The pain this specific audience feels
3. Solution        — How your product addresses it
4. Proof           — 1-2 testimonials or metrics
5. How It Works    — 3 simple steps
6. Objection       — Address the #1 reason they'd hesitate
7. Final CTA       — Same CTA as hero, with urgency or proof
```

**Landing page rules:**
- No navigation menu (or minimal — logo + CTA only)
- One CTA repeated, never competing actions
- Remove footer links that lead away from conversion
- Every element earns its place or gets cut

### Pricing Page

Pricing pages convert consideration-stage buyers. They need clarity, comparison, and confidence.

```
1. Header          — "Plans that scale with your team" (not just "Pricing")
2. Toggle          — Monthly / Annual (show savings)
3. Tier Cards      — 3 tiers with clear differentiation
4. Feature Matrix  — Detailed comparison table
5. FAQ             — Address pricing objections
6. Social Proof    — Testimonial from a paying customer
7. Enterprise CTA  — "Need more? Talk to us"
8. Final CTA       — "Start free today"
```

### Feature / Product Page

Feature pages convince evaluators that your product solves their specific problem.

```
1. Hero            — Feature-specific outcome headline
2. Problem         — The specific pain this feature addresses
3. Demo / Visual   — Show the feature in action
4. Benefits        — 3-4 outcomes (not feature descriptions)
5. Proof           — Testimonial from someone using this feature
6. Integration     — How it fits with tools they already use
7. CTA             — Try this feature / Start free
```

---

## The Scroll Story

Think of each page as a story told in scroll-lengths. Each section should:

1. **Build on the previous section** — Don't repeat; advance the argument
2. **Answer the next objection** — After "What is it?" comes "Does it work?" comes "Can I trust it?" comes "What does it cost?"
3. **End with a reason to keep scrolling** — Each section's last line should create curiosity about what's next

### Objection Sequence (Homepage)
```
Visitor arrives  → "What is this?"             → Hero answers
Keeps scrolling  → "Who else uses this?"        → Logo bar answers
Keeps scrolling  → "Do they understand my pain?" → Problem section answers
Keeps scrolling  → "How does it actually work?"  → Solution section answers
Keeps scrolling  → "Prove it"                   → Testimonial answers
Keeps scrolling  → "Is it complicated?"          → How It Works answers
Keeps scrolling  → "What about [specific need]?" → Feature sections answer
Keeps scrolling  → "What results can I expect?"  → Metrics section answers
Keeps scrolling  → "What does it cost?"          → Pricing teaser answers
Ready to act     → "I'm in"                     → Final CTA captures
```

---

## Sticky Nav and CTA Placement

### Navigation
- Fixed/sticky nav on scroll
- Logo (left) + main links (center) + CTA button (right)
- Nav CTA should be the secondary action ("Sign in") or primary ("Start free") depending on page type
- On landing pages: minimal nav (logo + CTA only) to reduce exit paths

### CTA Placement Rules
- **Hero**: Primary + Secondary CTA (always)
- **After social proof**: Repeat primary CTA (visitors who saw logos and are convinced)
- **After features**: Repeat CTA (visitors who evaluated capabilities)
- **After testimonials**: Repeat CTA (visitors who saw proof)
- **Page bottom**: Final CTA with closing argument (last chance before they leave)
- **Sticky**: Optional floating CTA bar that appears after scrolling past hero

**Minimum 3 CTAs per page.** Visitors convert at different points — don't make them scroll back to the top.

---

## Section Spacing and Rhythm

Create visual rhythm that guides the eye:

- **Alternating layouts**: Text-left/image-right → image-left/text-right for feature sections
- **Full-width breaks**: Use full-bleed background sections to create visual chapters
- **Whitespace**: Generous padding between sections (80-120px) signals quality and aids scanning
- **Contrast**: Alternate between light and dark/tinted section backgrounds to create clear boundaries

```
Section 1: Light bg      — Hero
Section 2: Light bg      — Logo bar (part of hero flow)
Section 3: Tinted bg     — Problem section (visual break)
Section 4: Light bg      — Solution / features
Section 5: Dark bg       — Testimonial (emphasis)
Section 6: Light bg      — How it works
Section 7: Tinted bg     — Metrics
Section 8: Light bg      — Pricing
Section 9: Dark bg       — Final CTA (urgency)
```
