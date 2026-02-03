# Skills Guide

A comprehensive guide to the 8 skills in this toolkit. Each skill provides specialized capabilities for building, testing, designing, and shipping agent-native software.

## Overview

| Skill | Purpose | Key Commands |
|-------|---------|--------------|
| [Agent-Native Architecture](#agent-native-architecture) | Design applications where agents are first-class citizens | `/agent-native-audit` |
| [Agent Testing](#agent-testing) | Test that agents can do what they're supposed to do | `/parity-audit`, `/generate-tests` |
| [Atomic Design System](#atomic-design-system) | Build and evaluate design systems using atomic methodology | `/atomic-audit`, `/atomic-init`, `/atomic-migrate` |
| [Deployment Ops](#deployment-ops) | Ship software with releases, changelogs, and CI/CD | `/release`, `/roadmap`, `/competitive` |
| [Frontend Design](#frontend-design) | Create distinctive, production-grade frontend interfaces | `/frontend-design` |
| [MCP Tool Design](#mcp-tool-design) | Design MCP tools that empower agents | `/mcp-design`, `/parity-audit` |
| [Parallel Development](#parallel-development) | Coordinate multi-agent work with git worktrees | `/parallel`, `/slice` |
| [Product Strategy](#product-strategy) | Define vision, roadmaps, PRDs, and competitive positioning | `/prd`, `/roadmap`, `/competitive` |

## Skill Relationships

```
                    ┌──────────────────┐
                    │ Product Strategy │
                    │ (What to build)  │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │ Agent-Native     │
                    │ Architecture     │
                    │ (How to design)  │
                    └──┬──────────┬────┘
                       │          │
            ┌──────────▼──┐  ┌───▼──────────────┐
            │ MCP Tool    │  │ Atomic Design    │
            │ Design      │  │ System           │
            │ (Agent      │  │ (UI component    │
            │  tools)     │  │  structure)      │
            └──────┬──────┘  └───┬──────────────┘
                   │             │
            ┌──────▼──────┐  ┌──▼───────────────┐
            │ Agent       │  │ Frontend Design  │
            │ Testing     │  │ (Visual quality) │
            │ (Verify     │  │                  │
            │  agents)    │  │                  │
            └──────┬──────┘  └───┬──────────────┘
                   │             │
                   └──────┬──────┘
                          │
               ┌──────────▼──────────┐
               │ Parallel Development│
               │ (Coordinate work)   │
               └──────────┬──────────┘
                          │
               ┌──────────▼──────────┐
               │ Deployment Ops      │
               │ (Ship it)           │
               └─────────────────────┘
```

**Reading the diagram:**

- **Product Strategy** defines *what* to build and *why*
- **Agent-Native Architecture** defines the system design principles
- **MCP Tool Design** and **Atomic Design System** handle the implementation layer (tools for agents, components for UI)
- **Agent Testing** verifies the agent tools work; **Frontend Design** ensures the UI is polished
- **Parallel Development** coordinates multi-agent workflows across all of the above
- **Deployment Ops** ships the final product

---

## Agent-Native Architecture

**Build applications where agents are first-class citizens.**

### When to Use

- Designing a new agent-native system from scratch
- Adding agent capabilities to an existing application
- Reviewing architecture for agent readiness
- Implementing self-modifying or context-accumulating systems

### Core Concepts

The 5 core principles of agent-native architecture:

1. **Parity** -- Whatever a user can do through the UI, the agent should be able to achieve through tools
2. **Granularity** -- Prefer atomic primitives; features are outcomes achieved by an agent operating in a loop
3. **Composability** -- With atomic tools and parity, new features are just new prompts
4. **Emergent Capability** -- The agent can accomplish things you didn't explicitly design for
5. **Improvement Over Time** -- Applications get better through accumulated context and prompt refinement

### Key Topics

| Topic | Description |
|-------|-------------|
| Architecture patterns | Event-driven, unified orchestrator, agent-to-UI |
| Files as interface | Files as the universal data layer, shared workspace |
| Tool design | Primitive tools, dynamic capability discovery, CRUD |
| System prompts | Features defined as prompts, judgment criteria |
| Context injection | Runtime app state injected into agent prompts |
| Action parity | Ensuring agents match user capabilities |
| Self-modification | Agents that safely evolve their own prompts/code |
| Mobile patterns | iOS storage, checkpoint/resume, cost awareness |

### The Ultimate Test

> Describe an outcome to the agent that's within your application's domain but that you didn't build a specific feature for. Can it figure out how to accomplish it? If yes, you've built something agent-native.

### Cross-References

- **MCP Tool Design** -- Implements the primitives and parity principles
- **Agent Testing** -- Verifies parity and emergent capability
- **Product Strategy** -- Shapes what outcomes the agent should target

---

## Agent Testing

**Test that agents can actually do what they're supposed to do.**

### When to Use

- After implementing new agent tools
- After adding new UI capabilities (to verify parity)
- Before releasing agent-native features
- When debugging agent capability issues

### Core Concepts

Agent-native applications need different testing than traditional software:

- **Test outcomes, not steps** -- Verify the result, not which tools were called
- **Test capabilities, not tools** -- Ensure the agent can *achieve* things, not just that tools exist
- **Test parity continuously** -- For every UI action, verify the agent equivalent works

### Testing Pyramid

```
                 /\
                / E2E\         Full agent conversations
               /------\
              /Capability\     Agent achieves outcomes
             /------------\
            /   Parity     \   Agent matches UI capabilities
           /----------------\
          /   Tool Unit      \  Individual tools work correctly
         /--------------------\
```

1. **Tool Unit Tests** -- Each tool returns correct results
2. **Parity Tests** -- Every UI action has a working agent equivalent
3. **Capability Tests** -- Agent can achieve business outcomes
4. **E2E Tests** -- Full conversations produce expected results

### Commands

| Command | Description |
|---------|-------------|
| `/parity-audit` | Audit and test action parity |
| `/generate-tests` | Generate agent capability tests |

### Cross-References

- **Agent-Native Architecture** -- Defines the parity and capability principles being tested
- **MCP Tool Design** -- The tools being tested for CRUD completeness and parity

---

## Atomic Design System

**Implement and evaluate design systems using Brad Frost's atomic design methodology.**

### When to Use

- Building a new component library
- Auditing an existing UI for design consistency
- Extracting design tokens from existing styles
- Migrating legacy components to atomic hierarchy
- Documenting a design system

### Core Concepts

The 5 levels of atomic design:

| Level | Description | Example |
|-------|-------------|---------|
| **Atoms** | Foundational elements that can't be broken down further | Buttons, inputs, labels, icons |
| **Molecules** | Simple compositions of 2-3 atoms with a single purpose | Search form (input + button + label) |
| **Organisms** | Complex UI sections composed of molecules and atoms | Site header (logo + nav + search + user menu) |
| **Templates** | Page-level layouts with content placeholders | Grid systems, page scaffolding |
| **Pages** | Templates filled with real content | What users actually see |

### Import Rules

Strict hierarchy enforcement:

- Atoms cannot import other atoms (composition violation)
- Molecules can only import from atoms
- Organisms can import from atoms and molecules
- Templates compose organisms, molecules, and atoms

### Design Tokens

Three-tier token architecture following EightShapes methodology:

1. **Global tokens** -- Raw values (colors, spacing scales)
2. **Semantic tokens** -- Purpose-mapped values (`--color-action-primary`)
3. **Component tokens** -- Component-specific values (`--button-bg`)

### Commands

| Command | Description |
|---------|-------------|
| `/atomic-audit` | Run full atomic design audit with parallel agents |
| `/atomic-init` | Scaffold a new atomic design system |
| `/atomic-migrate` | Iterative migration using phased approach |

### Cross-References

- **Frontend Design** -- Applies the aesthetic and visual quality layer on top of atomic components
- **Agent-Native Architecture** -- Atomic components can be part of a shared workspace agents interact with

---

## Deployment Ops

**Ship software with confidence through automated releases, changelogs, and CI/CD.**

### When to Use

- Planning a release
- Generating changelogs from git history
- Setting up CI/CD pipelines
- Deciding on versioning strategy
- Managing feature flags
- Coordinating deployments

### Core Concepts

Three principles of deployment:

1. **Ship incrementally** -- Small changes, frequent deploys, fast feedback
2. **Automate the boring parts** -- Changelog generation, version bumping, release notes
3. **Keep humans in the loop for decisions** -- Release timing, rollbacks, customer communication

### Release Workflow

```
Develop  -->  Prepare Release  -->  Release
  |                |                  |
  v                v                  v
Feature work    Version bump       Deploy
Code review     Changelog          Announce
Merge to main   Release notes      Monitor
```

### Semantic Versioning

```
MAJOR.MINOR.PATCH
  |     |     |
  |     |     +-- Bug fixes (backwards compatible)
  |     +-------- New features (backwards compatible)
  +-------------- Breaking changes
```

### Commands

| Command | Description |
|---------|-------------|
| `/release` | Plan and execute a release |
| `/roadmap` | Generate product roadmap from issues/PRD |
| `/competitive` | Run competitive analysis |

### Cross-References

- **Product Strategy** -- Defines what goes into each release via PRDs and roadmaps
- **Parallel Development** -- Coordinates the multi-branch workflow that feeds into releases

---

## Frontend Design

**Create distinctive, production-grade frontend interfaces with high design quality.**

### When to Use

- Building web components, pages, or applications
- When visual quality and memorability matter
- Avoiding generic "AI slop" aesthetics
- Creating interfaces that feel genuinely designed for their context

### Core Concepts

The skill emphasizes bold, intentional design over safe defaults:

**Design Thinking Process:**

1. **Purpose** -- What problem does this interface solve? Who uses it?
2. **Tone** -- Pick a clear aesthetic direction (brutalist, maximalist, minimalist, retro-futuristic, etc.)
3. **Constraints** -- Technical requirements (framework, performance, accessibility)
4. **Differentiation** -- What makes this unforgettable?

**Aesthetics Focus Areas:**

| Area | Guidance |
|------|----------|
| Typography | Distinctive, characterful fonts -- avoid Inter, Roboto, Arial |
| Color & Theme | Dominant colors with sharp accents; cohesive palettes via CSS variables |
| Motion | High-impact moments (staggered reveals, scroll-triggers, hover states) |
| Spatial Composition | Asymmetry, overlap, diagonal flow, grid-breaking elements |
| Backgrounds & Details | Gradient meshes, noise textures, geometric patterns, grain overlays |

### Anti-Patterns

- Overused fonts (Inter, Roboto, Arial, system fonts)
- Cliched color schemes (purple gradients on white)
- Predictable layouts and cookie-cutter patterns
- Converging on the same choices across generations

### Commands

| Command | Description |
|---------|-------------|
| `/frontend-design` | Create distinctive frontend interfaces |

### Cross-References

- **Atomic Design System** -- Provides the structural hierarchy for components
- **Product Strategy** -- Defines who the audience is and what impression the UI should make

---

## MCP Tool Design

**Design MCP tools for agent-native applications.**

### When to Use

- Building tools that agents will use
- Creating MCP servers
- Auditing existing tools for agent compatibility
- Mapping UI actions to required agent tools
- Implementing dynamic capability discovery

### Core Concepts

5 principles of good MCP tool design:

| Principle | Description | Test |
|-----------|-------------|------|
| **Primitives, not workflows** | Tools are atomic operations, not multi-step processes | Does this tool make decisions, or enable them? |
| **Action parity** | Agents can achieve whatever users can do through UI | Pick any UI action -- can the agent match it? |
| **CRUD completeness** | Every entity has create, read, update, and delete | For each entity, do all four operations exist? |
| **Dynamic discovery** | Use runtime discovery instead of static enums | If the API adds a feature, can agents use it without code changes? |
| **Rich outputs** | Return enough info for agents to verify and iterate | Does the output include context, not just "Done"? |

### Tool Audit Checklist

When auditing tools, check each against:

1. **Primitives check** -- Tool does ONE thing, doesn't encode business logic
2. **Parity check** -- Every UI action has a tool equivalent
3. **CRUD check** -- Full create/read/update/delete for every entity
4. **Signature check** -- Inputs are data (not decisions), outputs are rich

### Commands

| Command | Description |
|---------|-------------|
| `/mcp-design` | Interactive MCP tool design workflow |
| `/parity-audit` | Audit action parity between UI and agent tools |

### Cross-References

- **Agent-Native Architecture** -- MCP tools implement the parity and granularity principles
- **Agent Testing** -- Validates that tools provide complete parity and capability

---

## Parallel Development

**Coordinate multi-agent work with git worktrees and vertical slicing.**

### When to Use

- Setting up parallel development workflows
- Splitting work across multiple Claude instances
- Coordinating merges from multiple workstreams
- Minimizing merge conflicts in team/multi-agent work

### Core Concepts

5 principles of parallel development:

1. **Vertical slicing** -- Split by feature, not by layer (auth full-stack, not "all backend")
2. **Shared-nothing architecture** -- Each worktree touches different files
3. **Main as integration point** -- Never code directly on main
4. **Frequent, small merges** -- Merge daily to avoid divergence
5. **Coordination over communication** -- Structure work so boundaries are in the system, not in messages

### Automated Agent Spawning

The most powerful pattern -- spawn background agents from a single terminal:

```
Single Claude Instance
  |-- creates worktrees
  |-- spawns background Task agents
  |-- monitors progress via TaskOutput
  |-- merges all when complete

     Agent 1 (bg)     Agent 2 (bg)     Agent 3 (bg)
     Task A           Task B           Task C
         \                |                /
          \               |               /
           +--- All commit "COMPLETE:" --+
                          |
                     Merge & Clean
```

Agents signal completion by committing with a message starting with `COMPLETE:`.

### Workflow Phases

| Phase | Steps |
|-------|-------|
| **Setup** | Analyze project, plan slices, create worktrees, document ownership |
| **Work** | Each agent works independently in its worktree |
| **Sync** | Daily rebase from main, run tests, resolve small conflicts |
| **Merge** | Final sync, merge to main, notify other worktrees, clean up |

### Commands

| Command | Description |
|---------|-------------|
| `/parallel` | Setup, sync, or merge worktrees |
| `/slice` | Analyze codebase and suggest vertical slicing |

### Cross-References

- **Deployment Ops** -- Parallel branches feed into the release workflow
- **Product Strategy** -- PRDs and roadmaps define the feature slices to parallelize

---

## Product Strategy

**Strategic product thinking, roadmap planning, competitive analysis, and PRD generation.**

### When to Use

- Defining product vision and goals
- Prioritizing features (Must/Should/Won't have)
- Analyzing competitors and market positioning
- Synthesizing user research into actionable insights
- Creating or updating Product Requirements Documents
- Making scope decisions and trade-offs

### Core Concepts

5 principles of product strategy:

1. **Problem-first thinking** -- Start with user pain, not solutions
2. **Jobs-to-be-Done** -- Users "hire" products for functional, emotional, and social jobs
3. **Scope discipline** -- Ruthlessly prioritize with Must/Should/Won't-have
4. **Outcome over output** -- Measure behavior change, not features shipped
5. **Continuous discovery** -- Strategy is ongoing, not one-time

### PRD Generation Workflow

```
Gather Context (parallel)        Clarify with User       Generate PRD
  |                                   |                      |
  +-- Existing plans                  +-- Target users       +-- docs/product/PRD.md
  +-- Current implementation          +-- Success definition
  +-- Technical constraints           +-- Scope boundaries
```

### Prioritization Frameworks

| Framework | Best For |
|-----------|----------|
| **MoSCoW** (Must/Should/Could/Won't) | Scope decisions within a release |
| **RICE** (Reach, Impact, Confidence, Effort) | Scoring and ranking a backlog |
| **Now/Next/Later** | Communicating a roadmap without false precision |

### Commands

| Command | Description |
|---------|-------------|
| `/prd` | Generate or update a Product Requirements Document |
| `/roadmap` | Create prioritized product roadmap |
| `/competitive` | Run competitive analysis |

### Cross-References

- **Agent-Native Architecture** -- Product strategy shapes what the agent-native system should accomplish
- **Deployment Ops** -- Roadmaps and PRDs define release content
- **Parallel Development** -- Feature slicing follows product priorities

---

## Quick Reference: All Commands

| Command | Skill | Description |
|---------|-------|-------------|
| `/agent-native-audit` | Agent-Native Architecture | Comprehensive agent-native architecture review |
| `/parity-audit` | Agent Testing / MCP Tool Design | Audit action parity between UI and agent tools |
| `/generate-tests` | Agent Testing | Generate agent capability and parity tests |
| `/atomic-audit` | Atomic Design System | Run full atomic design audit |
| `/atomic-init` | Atomic Design System | Scaffold a new atomic design system |
| `/atomic-migrate` | Atomic Design System | Iterative migration to atomic design |
| `/release` | Deployment Ops | Plan and execute a software release |
| `/roadmap` | Deployment Ops / Product Strategy | Generate a product roadmap |
| `/competitive` | Deployment Ops / Product Strategy | Run competitive analysis |
| `/frontend-design` | Frontend Design | Create distinctive frontend interfaces |
| `/mcp-design` | MCP Tool Design | Interactive MCP tool design workflow |
| `/parallel` | Parallel Development | Setup, sync, or merge git worktrees |
| `/slice` | Parallel Development | Analyze codebase for vertical slicing |
| `/prd` | Product Strategy | Generate or update a PRD |
| `/dev` | Cross-cutting | Co-development workflow with AI assistance |
| `/check` | Cross-cutting | Run full design verification on a URL |
| `/a11y` | Cross-cutting | Run accessibility audit on a URL |
| `/compare` | Cross-cutting | Compare a screenshot to a Figma design |

## Choosing the Right Skill

**"I need to decide what to build"** --> Product Strategy

**"I need to design the system architecture"** --> Agent-Native Architecture

**"I need to build tools for agents"** --> MCP Tool Design

**"I need to verify agents work correctly"** --> Agent Testing

**"I need to structure my UI components"** --> Atomic Design System

**"I need to build a polished interface"** --> Frontend Design

**"I need multiple agents working in parallel"** --> Parallel Development

**"I need to ship a release"** --> Deployment Ops
