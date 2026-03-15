# Task Flow Patterns

## Purpose

Task flows define the complete user journey through a feature — every entry point, every decision, every error state, every edge case. A spec without thorough task flows forces developers to invent behavior at implementation time, leading to inconsistent error handling, missing edge cases, and features that crumble outside the happy path.

This reference provides templates and patterns for writing task flows that eliminate ambiguity.

---

## Task Flow Template

Every task flow should follow this structure:

```markdown
### Flow N: {Descriptive journey name}

**User**: {Who — persona or role}
**Entry point**: {Where the user starts — nav link, notification, deep link, keyboard shortcut}

1. User {action} → System {response}
   - IF {condition A}: {behavior}
   - IF {condition B}: {behavior}
2. User {action} → System {response}
3. ...

**Success**: {What "done" looks like for the user — observable outcome}
**Error states**: {What can go wrong and how the system recovers}
**Edge cases**: {Empty states, boundary conditions, permissions, concurrent access}
```

---

## Entry Point Taxonomy

Every feature should document ALL ways a user can reach it. Missing entry points = missing discoverability.

| Entry Point Type | Description | Example |
|-----------------|-------------|---------|
| **Primary navigation** | Always-visible nav element | Sidebar link, icon rail icon |
| **Secondary navigation** | Menu/dropdown access | User menu → Settings |
| **Keyboard shortcut** | Direct keyboard access | Cmd+K for search, Cmd+, for settings |
| **Deep link** | URL-based direct access | /customers/123, /settings/integrations |
| **In-context action** | Action button within related content | "View opportunities" from customer detail |
| **Notification** | System-triggered navigation | Toast "New interview processed" → click to view |
| **Search/Quick switcher** | Found via search | Cmd+P, type feature name |
| **Cross-reference** | Link from another entity | Wikilink [[Customer A]] from interview |

**Rule:** Every feature must be reachable from at least 2 entry point types.

---

## Decision Tree Notation

Use IF/THEN/ELSE to show branching logic. Avoid linear-only flows.

### Simple Branch
```markdown
3. User clicks "Save" →
   - IF form valid: save to database, show success toast, navigate to list
   - IF validation errors: highlight invalid fields, scroll to first error, focus it
   - IF network offline: queue save locally, show "Will save when online" banner
```

### Multi-Branch Decision
```markdown
4. System evaluates content type →
   - IF interview transcript: auto-classify, enter reactive pipeline
   - IF meeting notes: prompt user "Is this an interview?" with Yes/No
   - IF unknown format: show in vault editor, no auto-processing
   - IF file too large (>10MB): show size warning, offer to proceed anyway
```

### Permission-Gated Branch
```markdown
2. User clicks "Analyze" →
   - IF Pro plan: proceed to analysis
   - IF Free plan + credits remaining: proceed, decrement credit
   - IF Free plan + no credits: show upgrade prompt with "what you'll get"
   - IF trial expired: show trial-ended modal with pricing
```

---

## Error Recovery Patterns

| Error Type | User Sees | Recovery Path | System Behavior |
|-----------|-----------|---------------|-----------------|
| **Validation** | Inline field errors, red borders | Fix input, errors clear on valid input | Prevent submission until valid |
| **Network** | "Connection lost" banner | Auto-retry on reconnect, manual retry button | Queue operations locally |
| **Permission** | "You don't have access" message | Link to request access or upgrade | Log access attempt |
| **Not found** | "Item not found" with suggestions | Link to search, link to similar items | 404 logging |
| **Rate limit** | "Too many requests" with countdown | Auto-retry after cooldown | Exponential backoff |
| **Conflict** | "This was updated by someone else" | Show diff, merge options | Optimistic locking |
| **Server error** | "Something went wrong" with retry | Retry button, support link | Error logging with context |
| **Timeout** | "Taking longer than expected" | Cancel or wait options | Background processing continue |

---

## Edge Case Checklist

Apply this checklist to every task flow to catch missing scenarios:

### Empty States
- [ ] What does the user see when there's no data? (first-time use, empty search results, no items)
- [ ] Is there a call-to-action in the empty state? ("Add your first interview", "Import data")
- [ ] Does the empty state explain what this area is for?

### First-Time Experience
- [ ] What does a brand new user see? (onboarding prompt, sample data, guided tour)
- [ ] Are there default values or suggestions to reduce friction?
- [ ] Is there a "skip" option for experienced users?

### Boundary Conditions
- [ ] What happens with 0 items? 1 item? 1000 items? 10,000 items?
- [ ] What happens with very long text? (truncation strategy, tooltips)
- [ ] What happens with special characters in input? (sanitization)
- [ ] Maximum/minimum limits and what happens at boundaries?

### Permissions & Access
- [ ] What does a user without permission see? (hidden elements vs disabled with explanation)
- [ ] Can features be partially accessible? (read but not write)
- [ ] What happens when permissions change mid-session?

### Concurrent Access
- [ ] What if two users edit the same item? (last-write-wins, conflict resolution, locking)
- [ ] What if data changes while the user has it open? (stale data handling)

### Undo & Recovery
- [ ] Can the user undo the action? (Cmd+Z, undo button, trash/archive instead of delete)
- [ ] Is there a confirmation step for destructive actions?
- [ ] Can deleted items be recovered? (trash, soft delete)

### Loading & Performance
- [ ] What does the user see during loading? (skeleton, spinner, progress bar)
- [ ] What if loading takes >3 seconds? (timeout message, cancel option)
- [ ] What if the page partially loads? (progressive rendering strategy)

---

## Information Hierarchy in Task Flows

Each step in a task flow should define what information is primary, secondary, and tertiary:

```markdown
### Screen: Customer Detail

**Primary** (user notices first):
- Customer name and company (large heading)
- Key metric: total interviews conducted (prominent number)

**Secondary** (user scans next):
- Contact list (table with names, roles, last contact date)
- Linked opportunities (card list with status badges)

**Tertiary** (available on demand):
- Interview history (collapsed timeline, expandable)
- Metadata (created date, tags, notes — in a details section)
- Related entities (wikilink connections — sidebar or tab)
```

---

## Worked Example: Complete Task Flow

### Flow: Adding a new interview to the vault

**User**: Product manager who just finished a customer call
**Entry points**:
- Drag file to vault directory (filesystem)
- "Add Interview" button on Home dashboard
- Import from connected service (Zoom, Teams)
- CLI: `habitatd ingest [path]`

1. User drops interview file into vault directory →
   - IF markdown (.md): proceed directly to step 2
   - IF supported format (.txt, .pdf, .docx, .vtt): translate to markdown first, then step 2
   - IF unsupported format: ignore file, no user notification (silent filter)

2. System detects file via vault watcher → debounce 300ms, emit VaultFileEvent →
   - IF pipeline enabled: proceed to step 3 automatically
   - IF pipeline disabled: file appears in vault browser, no auto-processing
   - IF duplicate filename: append timestamp suffix, proceed

3. System ingests document → parse frontmatter, extract content →
   - IF valid frontmatter: use metadata (customer, date, type)
   - IF no frontmatter: generate stub frontmatter with filename-derived metadata
   - IF parse error: log error, show toast "Could not parse [filename]", skip

4. System runs customer extraction (Haiku agent) →
   - Customer/Contact records created or matched to existing
   - IF new customer: create record, link to interview
   - IF existing customer matched: link to interview, update last-contact date
   - IF extraction uncertain: flag for manual review in classification queue

5. System generates interview snapshot (credit-gated) →
   - IF auto-approve ON + credits available: proceed, deduct 2 credits
   - IF auto-approve OFF: queue in pending operations, show badge on icon rail
   - IF no credits remaining: pause pipeline, show "Credits depleted" notification

6. System runs opportunity extraction →
   - New opportunities appear in OST canvas
   - Toast notification: "Interview processed: [filename] — [N] opportunities found"

**Success**: Interview fully processed and visible in vault with linked customers and opportunities.
**Error states**: Parse failure (toast + skip), credit depletion (pause + notify), network error during AI call (retry with backoff, queue for later).
**Edge cases**: Empty file (skip with warning), file deleted before processing completes (cancel pipeline run), very large file >5MB (warn, proceed if confirmed).

---

## Anti-Patterns

### Linear-Only Flows
```
✗ 1. User opens page → 2. User fills form → 3. User clicks submit → Done
✓ Shows branching at each step, error recovery, edge cases
```

### Vague System Responses
```
✗ "System processes the data"
✓ "System calls Haiku agent for customer extraction (≈2s), creates/matches Customer + Contact records,
   links to interview document, updates customer's last-contact timestamp"
```

### Missing "What If" Questions
```
✗ Flow assumes everything works perfectly
✓ Flow explicitly answers: What if the network is down? What if the user cancels mid-flow?
   What if there's no data? What if there's too much data? What if permissions change?
```
