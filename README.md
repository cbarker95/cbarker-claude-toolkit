# cbarker's Claude Toolkit

A personal collection of reusable Claude Code customizations: skills, agents, and commands for product discovery, spec architecture, UX/UI design, design systems, frontend development, parallel development, and agent-native architecture.

## What's Included

### Skills (11)

| Skill | Description |
|-------|-------------|
| **spec-architecture** | Backend/frontend architecture for discovery specs — data modeling, API/IPC design, dependency analysis, component composition, testing strategy |
| **ux-ui-architecture** | UX/UI architecture for specs — task flows, navigation patterns, usability heuristics, component states, responsive behavior |
| **atomic-design-system** | Build and evaluate design systems using Brad Frost's atomic design methodology |
| **frontend-design** | Create distinctive, production-grade frontend interfaces with high design quality |
| **agent-native-architecture** | Patterns for building apps where agents are first-class citizens |
| **product-strategy** | Strategic product thinking, roadmap planning, competitive analysis, PRD generation |
| **saas-website-design** | High-conversion B2B SaaS websites, landing pages, and marketing copy |
| **mcp-tool-design** | Design MCP tools for agent-native applications |
| **parallel-development** | Git worktrees, multi-agent coordination, vertical slicing |
| **agent-testing** | Testing patterns for agent capabilities and behavior validation |
| **deployment-ops** | Deployment and operations patterns |

### Agents (28)

| Agent | Description |
|-------|-------------|
| **spec-reviewer** | Scores discovery specs 0-100 across 7 quality dimensions |
| **spec-improver** | Enhances specs based on reviewer findings — adds missing architecture, task flows, component usage |
| **figma-design-sync** | Synchronize implementations with Figma designs |
| **design-implementation-reviewer** | Verify UI matches Figma specifications |
| **design-iterator** | Iteratively refine designs with screenshot analysis |
| **design-reviewer** | Compare screenshots against Figma designs |
| **accessibility-checker** | WCAG 2.1 AA compliance auditing |
| **atomic-compliance-scorer** | Score codebase against atomic design principles |
| **atomic-migration-planner** | Plan component migrations to atomic design |
| **component-hierarchy-analyzer** | Classify components into atomic levels |
| **token-auditor** | Extract and audit design tokens |
| **framework-docs-researcher** | Gather documentation and best practices for frameworks |
| **best-practices-researcher** | Research external best practices and documentation |
| **git-history-analyzer** | Analyze git history for code evolution |
| **repo-research-analyst** | Research repository structure and patterns |
| **action-parity-auditor** | Audit agent vs UI action parity |
| **agent-behavior-validator** | Validate agent prompt compliance and edge cases |
| **capability-mapper** | Map UI capabilities to agent tools |
| **capability-test-generator** | Generate tests for agent business outcomes |
| **parity-test-generator** | Generate tests for agent/UI parity |
| **changelog-generator** | Generate changelogs from git history |
| **feature-proposer** | Turn research into buildable feature proposals |
| **mcp-tool-designer** | Design MCP tools following primitives pattern |
| **prd-generator** | Generate or update Product Requirements Documents |
| **release-planner** | Plan releases with versioning and changelogs |
| **roadmap-synthesizer** | Create prioritized product roadmaps |
| **vertical-slicer** | Split work for parallel development |
| **worktree-coordinator** | Manage parallel development across git worktrees |

### Commands (21)

| Command | Description |
|---------|-------------|
| `/prd` | Generate or update a Product Requirements Document |
| `/discover` | Research and generate a discovery specification for go-commando |
| `/review-spec` | Review a spec for quality — grades 7 dimensions, optionally auto-improves |
| `/implement` | Build the next feature from a discovery spec (one feature per invocation) |
| `/ship` | Ship the next feature from the PRD — find, build, verify, mark done |
| `/dev` | Co-development workflow for building products with AI |
| `/refine` | UX/UI iteration — visual tweaks, layout changes, design refinement |
| `/design-language` | Capture visual design language into DESIGN_LANGUAGE.md |
| `/compare` | Compare screenshot to Figma design |
| `/a11y` | Run accessibility audit on a URL |
| `/check` | Run full design verification on a URL |
| `/competitive` | Run competitive analysis to inform product strategy |
| `/roadmap` | Generate a product roadmap from PRD and priorities |
| `/release` | Plan and execute a software release |
| `/mcp-design` | Design MCP tools for agent-native applications |
| `/agent-native-audit` | Audit for agent-native architecture principles |
| `/parity-audit` | Audit action parity between UI and agent capabilities |
| `/generate-tests` | Generate agent capability and parity tests |
| `/atomic-audit` | Audit codebase for atomic design compliance |
| `/atomic-init` | Initialize atomic design system structure |
| `/atomic-migrate` | Migrate components to atomic design |

## Product Workflow

```
/prd                    Create the PRD with Feature Status table
  |
/discover               Research and propose features, generate specs
  |
/review-spec            Score spec quality (0-100), auto-improve gaps
  |
go-commando             Autonomous build loop (each feature is a spec item)
  |
/ship                   Build next PRD feature, verify, mark done
```

## Installation

### Option 1: Claude Code Plugin Marketplace

Install directly from the Claude Code marketplace if available.

### Option 2: Clone to your home directory (global)

```bash
git clone https://github.com/cbarker95/cbarker-claude-toolkit.git ~/.claude/plugins/marketplaces/cbarker-claude-toolkit
```

### Option 3: Copy what you need

```bash
git clone https://github.com/cbarker95/cbarker-claude-toolkit.git /tmp/cbarker-claude-toolkit

# Copy specific skills/agents/commands
cp -r /tmp/cbarker-claude-toolkit/skills/spec-architecture ~/.claude/skills/
cp /tmp/cbarker-claude-toolkit/agents/spec-reviewer.md ~/.claude/agents/
cp /tmp/cbarker-claude-toolkit/commands/review-spec.md ~/.claude/commands/
```

## Usage

Once installed, skills, agents, and commands are automatically available in Claude Code.

### Using Commands
```bash
# In Claude Code
/discover               # Generate a discovery spec
/review-spec Pipeline   # Review a spec for quality
/ship                   # Build next PRD feature
/a11y https://site.com  # Run accessibility audit
```

### Using Skills
Skills are loaded by Claude automatically when relevant to your task.

### Using Agents
Agents are used automatically by Claude when appropriate, or invoked via the Task tool.

## Structure

```
cbarker-claude-toolkit/
  .claude-plugin/
    plugin.json           # Plugin metadata
    marketplace.json      # Marketplace listing
  agents/                 # 28 specialized agents
  commands/               # 21 slash commands
  skills/                 # 11 comprehensive skills
    spec-architecture/    # Backend/frontend spec architecture
    ux-ui-architecture/   # UX/UI spec architecture
    atomic-design-system/ # Brad Frost atomic design
    frontend-design/      # Production frontend interfaces
    product-strategy/     # Product strategy and PRDs
    ...and 6 more
  hooks/                  # Git hooks
  docs/                   # Documentation
```

## License

MIT
