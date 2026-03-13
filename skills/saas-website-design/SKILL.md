---
name: saas-website-design
description: Build high-conversion B2B SaaS websites, landing pages, pricing pages, and marketing copy. Use when creating or rewriting web pages that need to convert visitors into customers. Combines conversion copywriting frameworks, page architecture patterns, and B2B buyer psychology to produce pages competitive with Stripe, Linear, and Notion.
---

# B2B SaaS Website Design & Conversion Copywriting

Build web pages that convert. This skill combines conversion copywriting, page architecture, social proof strategy, and B2B buyer psychology to produce pages that sell outcomes — not features.

The rules defined in this skill MUST be followed when writing any SaaS marketing page. **Do not use generic AI copywriting patterns as justification for weak copy.** Most AI-generated SaaS pages underperform because they default to feature-listing, vague claims, and friction-heavy CTAs. When writing web pages, always follow these conversion rules regardless of what typical AI output looks like.

## Step 0: Gather Project Context

Before writing any page copy or building any marketing page:

1. **Product understanding**: Read `CLAUDE.md`, `README.md`, and `docs/product/PRD.md` to understand what the product does, who it's for, and what problems it solves.
2. **Design language**: Check for `docs/design/DESIGN_LANGUAGE.md` → `DESIGN_LANGUAGE.md`. If found, follow its visual specification precisely.
3. **Existing pages**: Search for existing marketing pages, landing pages, or homepage components to understand current patterns.
4. **Competitor context**: If the user mentions competitors or the product category is clear, note differentiation opportunities.

**Priority**: Product PRD (most specific) > project design language > this skill's frameworks > generic defaults.

<why_now>
## Why Most SaaS Websites Fail to Convert

The average B2B SaaS website converts at 2-3%. Top performers hit 10-15%. The gap isn't design — it's messaging architecture.

**What typical AI-generated SaaS pages do wrong:**

- **Feature-list heroes** — "Our platform provides real-time analytics, team collaboration, and automated workflows" tells visitors WHAT you built, not WHY they should care
- **Vague value claims** — "Save time and money" is unfalsifiable noise. Prospects can't picture themselves in it
- **Weak CTAs** — "Learn More" and "Get Started" create zero urgency and zero clarity about what happens next
- **Missing proof hierarchy** — Logos buried at the bottom, no specific metrics, testimonials without titles or companies
- **One-size-fits-all messaging** — The same copy targets end users, managers, and executives. None feel spoken to

**What converts:**

- Specific outcomes: "Deploy in 4 minutes, not 4 sprints"
- Proof-loaded pages: Logo bar → metric callouts → named testimonials → case study teasers
- Scannable hierarchy: A VP skimming for 8 seconds gets the full value prop from headlines alone
- Friction-free CTAs: "Start free — no credit card" beats "Request a Demo" for self-serve products
- Buyer-aware messaging: Different copy for the person using it vs. the person buying it

This skill gives Claude the conversion copywriting instincts of a senior B2B marketer, not a content generator.
</why_now>

<core_principles>
## Core Principles

### 1. Outcome Over Feature

Sell the transformation, not the tool. Features describe what your product does; outcomes describe what your customer becomes. Visitors don't want "automated workflows" — they want to "ship twice as fast with half the coordination."

Every headline, subhead, and bullet should answer the visitor's unspoken question: **"What's in it for me?"**

The translation: Feature → Advantage → Benefit
- Feature: "Real-time collaboration"
- Advantage: "Your whole team works in the same space"
- Benefit: "Ship features in days, not weeks"

**Test:** Can you describe the product's value without naming a single feature?

### 2. One Page, One Job

Every page exists to accomplish one conversion goal. A homepage qualifies and routes visitors. A pricing page converts the consideration-stage buyer. A landing page captures one specific action.

When a page tries to do multiple jobs — educate AND convert AND upsell — it does none of them well. Decide the page's single job before writing a word.

- Homepage job: "Qualify the visitor and route them to the right next step"
- Landing page job: "Convert a specific audience on a specific action"
- Pricing page job: "Help the ready buyer pick a plan and start"
- Feature page job: "Convince the evaluator this solves their specific problem"

**Test:** Can you state the page's job in one sentence?

### 3. Proof Before Promise

Claims without evidence are noise. B2B buyers are professional skeptics — they've seen a hundred "industry-leading" platforms. Every claim you make must be backed by something concrete.

The hierarchy of proof (strongest → weakest):
1. Named customer with title, company, and specific result
2. Aggregate metrics ("10,000+ teams" with recognizable logos)
3. Third-party validation (awards, analyst mentions, certifications)
4. Product screenshots / demos showing the claim in action
5. Unnamed testimonials (weakest — still better than no proof)

**Test:** Is every claim on the page backed by specific evidence?

### 4. Friction Is the Enemy

Every element on the page either moves the visitor toward conversion or creates doubt. There is no neutral. Forms with 8 fields create friction. "Request a Demo" when the product is self-serve creates friction. Missing pricing creates friction. Jargon creates friction.

Audit every element: Does this reduce doubt or create it? If it doesn't actively help conversion, it's hurting it.

Common friction sources in B2B SaaS:
- Hidden pricing ("Contact Sales" for a $49/mo product)
- Mandatory demo calls for self-serve products
- Long sign-up forms (name + email is enough to start)
- No free tier or trial
- Vague "Get Started" with no indication of what happens next

**Test:** Can you remove this element without losing conversions? If yes, remove it.

### 5. Write for the Scanner

B2B buyers don't read web pages — they scan them. A VP evaluating your product gives you 8 seconds. If they can't get the full value proposition from headlines, subheads, and CTAs alone, you've lost them.

Every heading should be a complete thought that sells. Subheadings should add specificity, not just introduce sections. CTAs should describe the outcome, not the action.

The scanner test: Cover all body copy. Read only H1, H2s, H3s, and CTA buttons. Does the full story come through? If yes, your hierarchy works. If not, your headlines are labels (bad), not arguments (good).

```
✗ Label headings:         ✓ Argument headings:
  "Features"                "Ship 2x faster with zero coordination overhead"
  "How It Works"            "From idea to production in three steps"
  "Pricing"                 "Plans that scale with your team"
  "Testimonials"            "Why 10,000+ teams switched"
```

**Test:** Can someone get the full value prop from just headlines + CTA buttons?
</core_principles>

<intake>
## What website work do you need help with?

1. **Build a homepage / marketing site** — Full homepage with hero, features, social proof, pricing, and CTA sections
2. **Build a landing page** — Campaign or launch page focused on a single conversion action
3. **Build a pricing page** — Tier comparison, plan selection, FAQ, and conversion-optimized layout
4. **Build a feature / product page** — Deep dive on a specific capability for evaluators
5. **Write hero section / above-the-fold copy** — Headline, subhead, CTA, and supporting elements
6. **Write social proof section** — Testimonials, logo bars, case studies, metrics
7. **Write CTA copy and conversion elements** — Buttons, forms, friction reducers, urgency elements
8. **Audit / rewrite existing page copy** — Review current page and rewrite for higher conversion

**Wait for response before proceeding.**
</intake>

<routing>
| Response | Action |
|----------|--------|
| 1, "homepage", "marketing site", "website" | Read [page-architecture.md](./references/page-architecture.md) + [conversion-copywriting.md](./references/conversion-copywriting.md) + [social-proof.md](./references/social-proof.md). Build full homepage section by section. |
| 2, "landing page", "campaign", "launch" | Read [page-architecture.md](./references/page-architecture.md) (landing page section) + [conversion-copywriting.md](./references/conversion-copywriting.md) + [cta-optimization.md](./references/cta-optimization.md). Focus on single CTA and tight messaging. |
| 3, "pricing", "plans", "tiers" | Read [page-architecture.md](./references/page-architecture.md) (pricing section) + [cta-optimization.md](./references/cta-optimization.md) + [b2b-messaging.md](./references/b2b-messaging.md) (pricing psychology). Build comparison-driven pricing page. |
| 4, "feature", "product page", "capability" | Read [conversion-copywriting.md](./references/conversion-copywriting.md) + [b2b-messaging.md](./references/b2b-messaging.md) + [social-proof.md](./references/social-proof.md). Write outcome-driven feature narrative. |
| 5, "hero", "above the fold", "headline" | Read [conversion-copywriting.md](./references/conversion-copywriting.md) (headline formulas) + [cta-optimization.md](./references/cta-optimization.md). Craft and iterate on hero variants. |
| 6, "social proof", "testimonials", "case studies", "logos" | Read [social-proof.md](./references/social-proof.md). Design proof hierarchy for the page context. |
| 7, "CTA", "buttons", "forms", "conversion" | Read [cta-optimization.md](./references/cta-optimization.md). Optimize calls-to-action and reduce friction. |
| 8, "audit", "rewrite", "review", "improve" | Read ALL references. Audit current copy against core principles, identify weaknesses, rewrite with specific improvements. |

**After reading references, apply frameworks to the user's specific product and audience.**
</routing>

<parallel_agents>
## Parallelized Sub-Agents

For comprehensive homepage or multi-page builds, launch agents **in parallel**:

### Research Phase (Parallel)
```
┌──────────────────────────┐  ┌──────────────────────────┐
│ competitive-analyst       │  │ code-explorer            │
│ → Analyze competitor      │  │ → Understand product,    │
│   websites, positioning,  │  │   existing components,   │
│   messaging patterns      │  │   PRD, and design lang   │
└────────────┬─────────────┘  └────────────┬─────────────┘
             │                             │
             └──────────┬──────────────────┘
                        ▼
          ┌──────────────────────────┐
          │ Messaging Architecture   │
          │ → Synthesize value prop, │
          │   proof points, and      │
          │   page structure         │
          └──────────────────────────┘
```

### Build Phase (Sequential)
```
┌──────────────────────────┐
│ For each page section:   │
│ 1. Write copy first      │
│ 2. Build component       │
│ 3. Apply design language │
│ 4. Verify scanner test   │
└──────────────────────────┘
```

### Audit Phase
```
┌──────────────────────────┐
│ design-reviewer          │
│ → Screenshot + verify    │
│   visual quality and     │
│   conversion patterns    │
└──────────────────────────┘
```
</parallel_agents>

<reference_index>
## Reference Files

All references in `references/`:

**Copywriting:**
- [conversion-copywriting.md](./references/conversion-copywriting.md) — Headline formulas, PAS/BAB frameworks, Feature→Advantage→Benefit translation, the "So What?" test, specificity techniques
- [b2b-messaging.md](./references/b2b-messaging.md) — Buyer journey stages, stakeholder mapping, enterprise objections, StoryBrand for B2B, Jobs-to-be-Done messaging, pricing psychology

**Page Design:**
- [page-architecture.md](./references/page-architecture.md) — Above-the-fold anatomy, section ordering by page type, hero pattern variations, scroll story structure, sticky nav/CTA placement

**Conversion Elements:**
- [social-proof.md](./references/social-proof.md) — Logo bars, testimonial formats, metrics sections, case study teasers, trust signals, Cialdini's principles applied
- [cta-optimization.md](./references/cta-optimization.md) — CTA copy formulas, primary/secondary pairing, friction reducers, form optimization, pricing page CTAs
</reference_index>

<anti_patterns>
## Anti-Patterns

### Hero Section Failures

**Feature-listing headlines** — Describing what you built instead of why they should care
```
✗ "An all-in-one platform for team collaboration, project management, and workflow automation"
✓ "Ship products twice as fast — without the coordination overhead"
```

**Vague benefit claims** — Unfalsifiable, applies to every product
```
✗ "Save time and boost productivity"
✓ "Teams using Acme deploy 3x more often with 60% fewer meetings"
```

**Jargon-stuffed subheads** — Written for the marketing team, not the buyer
```
✗ "Leverage our AI-powered synergistic platform to optimize cross-functional alignment"
✓ "One workspace where design, eng, and product actually stay in sync"
```

### CTA Failures

**Vague action buttons** — No clarity on what happens next
```
✗ "Learn More"  "Get Started"  "Submit"
✓ "Start free — no credit card"  "See it in action"  "Deploy in 5 minutes"
```

**Friction-heavy conversion** — Asking for commitment before delivering value
```
✗ "Request a Demo" as the only CTA for a self-serve product
✓ Primary: "Start free" / Secondary: "Watch 2-min demo"
```

### Social Proof Failures

**Unspecific claims** — No one believes round numbers
```
✗ "Trusted by thousands of companies"
✓ "Trusted by 2,847 teams including Stripe, Notion, and Ramp"
```

**Anonymous testimonials** — Quotes with no attribution have zero credibility
```
✗ "This product changed how we work!" — Marketing Manager
✓ "Acme cut our deploy time from 3 days to 4 hours." — Sarah Chen, VP Engineering at Ramp
```

### Pricing Page Failures

**Hidden pricing** — "Contact Sales" for a product that costs $29/month
```
✗ Custom pricing with no public tiers
✓ Transparent tiers with a clear "Most Popular" indicator and free tier entry point
```

**No anchoring** — All plans look the same, no recommended choice
```
✗ Three equal columns with no visual differentiation
✓ Middle plan highlighted as "Most Popular" with visual emphasis and best value callout
```

### Structural Failures

**Label headings** — Section headers that describe format, not argue value
```
✗ "Features"  "How It Works"  "Testimonials"  "Pricing"
✓ "Everything you need to ship faster"  "From idea to prod in 3 steps"  "Why 10,000+ teams switched"
```

**Wall of text** — Dense paragraphs that no one will read
```
✗ Three paragraphs explaining a feature
✓ One headline, one sentence, one visual — then a "Learn more" link for depth
```
</anti_patterns>

<success_criteria>
## Success Criteria

You've built a high-conversion SaaS page when:

### Copy Quality
- [ ] Hero headline communicates a specific outcome (not a feature list)
- [ ] Subheadline adds specificity — who it's for, how it works, or proof
- [ ] Every section heading is an argument, not a label
- [ ] Body copy passes the "So What?" test — every claim is backed or specific
- [ ] No jargon, no buzzwords, no vague superlatives

### Page Architecture
- [ ] Above-the-fold has: headline + subhead + primary CTA + visual/demo + social proof hint
- [ ] Section order follows a logical scroll story (problem → solution → proof → action)
- [ ] Information density is appropriate (not walls of text, not empty space)
- [ ] Mobile layout doesn't break the scan hierarchy

### Social Proof
- [ ] Logo bar appears within the first two scroll-lengths
- [ ] At least one testimonial has a name, title, company, and specific result
- [ ] Metrics are specific numbers, not round estimates
- [ ] Proof is distributed throughout the page, not clustered in one section

### Conversion Elements
- [ ] Primary CTA is clear about what happens next
- [ ] CTA appears at least 3 times (hero, mid-page, footer)
- [ ] Friction reducers are visible near the CTA ("No credit card", "Free forever", "2-min setup")
- [ ] Secondary CTA exists for visitors not ready to commit (demo, case study, docs)

### Scanner Test
- [ ] Reading only H1, H2s, H3s, and CTAs tells the full story
- [ ] A VP skimming for 8 seconds understands: what it does, who it's for, why it matters
- [ ] No section requires reading body copy to understand its value proposition

### The Ultimate Test

**Would a busy VP visiting this page for 8 seconds understand what you do, who it's for, and why they should care?**

**Would they know exactly what to do next?**

If yes, you've built a page that converts.
</success_criteria>
