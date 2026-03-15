# Usability Heuristics — Spec Evaluation Checklist

## Purpose

Jakob Nielsen's 10 usability heuristics are the industry-standard framework for evaluating interface design. Applied during spec writing (not just after implementation), they catch usability problems before a single line of code is written. This reference provides each heuristic with spec-specific evaluation questions, examples, and a scoring template.

---

## The 10 Heuristics

### 1. Visibility of System Status

The system should always keep users informed about what is going on, through appropriate feedback within reasonable time.

**What to check in a spec:**
- Does every action have visible feedback? (save → toast, submit → loading state, delete → confirmation)
- Are long operations represented? (progress bars, spinners, step indicators)
- Is the current state always clear? (active tab, selected item, current page in nav)
- Do status changes update in real-time? (pipeline progress, credit balance, sync status)
- Are background operations visible? (pending operations badge, processing indicator)

**Good compliance:**
```
User clicks "Analyze" → button shows spinner + "Analyzing..." label →
progress bar shows extraction stages → completion toast with results summary
```

**Violation:**
```
User clicks "Analyze" → page goes blank for 30 seconds → results appear with no explanation
```

**Common spec gaps:** Missing loading states, no feedback for background operations, no progress indication for multi-step processes.

---

### 2. Match Between System and Real World

The system should speak the users' language, using words, phrases, and concepts familiar to the user.

**What to check in a spec:**
- Are labels written in user language? ("Customers" not "Entities", "Interviews" not "Documents")
- Do concepts match the user's domain? (CDH terminology for product managers)
- Is the information organized in a natural, logical order?
- Are icons/metaphors intuitive? (trash can for delete, pencil for edit)
- Are internal terms hidden? (no "IPC handlers", "store methods", "reactive pipeline" in UI)

**Good compliance:**
```
Navigation: Customers | Opportunities | Discovery Tree | Settings
(Product management concepts the user already knows)
```

**Violation:**
```
Navigation: Entities | Extractions | OST Canvas | Configuration
(Internal system terminology)
```

**Common spec gaps:** Using developer jargon in UI labels, organizing by system architecture instead of user workflow.

---

### 3. User Control and Freedom

Users need a clear "emergency exit" to leave unwanted states without extended dialogue.

**What to check in a spec:**
- Can every action be undone? (Cmd+Z, undo button, revert option)
- Can users cancel in-progress operations? (cancel button on modals, abort button on long operations)
- Are destructive actions reversible? (archive vs permanent delete, trash with restore)
- Can users navigate away freely? (no modal trap, no forced completion)
- Is there a "back" action at every level? (breadcrumbs, back button, escape key)

**Good compliance:**
```
Delete interview → moves to Trash (recoverable for 30 days) → permanent delete requires explicit empty-trash action
```

**Violation:**
```
Delete interview → immediate permanent deletion with only a confirm dialog
```

**Common spec gaps:** Missing undo for batch operations, no cancel for long-running AI operations, modals with no escape/close.

---

### 4. Consistency and Standards

Users should not have to wonder whether different words, situations, or actions mean the same thing.

**What to check in a spec:**
- Are the same concepts called the same thing everywhere? (not "customer/client/account")
- Do similar actions work the same way? (all lists sort the same way, all saves show the same toast)
- Do components behave consistently? (all buttons have the same states, all cards have the same layout)
- Does the spec follow platform conventions? (Cmd+S to save on Mac, standard keyboard shortcuts)
- Are design system tokens used consistently? (same colors for same meanings)

**Good compliance:**
```
Every entity detail page has the same layout: header with title + actions, tabbed content below,
comments section at bottom. User learns the pattern once.
```

**Violation:**
```
Customer detail has tabs, Opportunity detail has accordion sections, Proposal detail has a sidebar.
Same type of page, three different patterns.
```

**Common spec gaps:** Inconsistent terminology across features, different patterns for same type of interaction.

---

### 5. Error Prevention

Even better than good error messages is a careful design which prevents a problem from occurring in the first place.

**What to check in a spec:**
- Are destructive actions gated by confirmation? ("Delete 5 items?" with count)
- Do forms validate before submission? (inline validation, disable submit until valid)
- Are constraints communicated upfront? (character limits shown, file size limits stated)
- Are dangerous options visually distinct? (red for destructive, separated from safe actions)
- Does the system prevent invalid states? (disabled options, type-ahead filtering)

**Good compliance:**
```
Credit-consuming operations show cost before execution: "This will use 2 credits (3 remaining).
Proceed?" with clear Cancel option.
```

**Violation:**
```
User clicks "Generate Snapshot" → credits silently deducted → user discovers they have no credits left
```

**Common spec gaps:** No pre-submission validation, no cost/impact preview for resource-consuming operations.

---

### 6. Recognition Rather Than Recall

Minimize the user's memory load by making objects, actions, and options visible.

**What to check in a spec:**
- Are options visible rather than requiring memorization? (dropdown vs typed command)
- Do related items show context? (customer name on interview, opportunity type badge)
- Are recent items accessible? (recent files, recent searches, history)
- Do forms have examples or placeholders? (input placeholder text, example values)
- Is help contextual? (tooltips, inline hints, not just a help page)

**Good compliance:**
```
Quick switcher (Cmd+P) shows recent items first, then fuzzy-matches all items.
Each result shows type icon + name + context (parent entity).
```

**Violation:**
```
User must remember and type exact file paths to navigate. No search, no recent items, no suggestions.
```

**Common spec gaps:** Missing search/filter on lists, no autocomplete for entity references, no contextual hints.

---

### 7. Flexibility and Efficiency of Use

Accelerators — unseen by novices — may speed up expert interaction.

**What to check in a spec:**
- Are keyboard shortcuts documented? (Cmd+K for Ask, Cmd+N for new, Cmd+S for save)
- Can power users customize workflows? (configurable defaults, saved filters, templates)
- Are there bulk operations? (select multiple → batch action)
- Can common sequences be shortened? (one-click actions vs multi-step wizards)
- Is there a command palette? (Cmd+P or Cmd+K for everything)

**Good compliance:**
```
New interview: Drag & drop file (quick path) OR menu → Import → select file (guided path)
Power users: CLI `habitatd ingest [path]` for scripted batch import
```

**Violation:**
```
Adding an interview always requires: Menu → File → Import → Browse → Select → Confirm → Configure → Save
(8 steps, no shortcuts)
```

**Common spec gaps:** No keyboard shortcuts defined, no bulk operations for list views, no command palette.

---

### 8. Aesthetic and Minimalist Design

Every extra unit of information competes with the relevant units and diminishes their relative visibility.

**What to check in a spec:**
- Does each screen show only what's needed for the current task?
- Is secondary information hidden behind progressive disclosure? (expandable sections, "show more")
- Are decorative elements minimal? (content is the interface, not chrome)
- Is whitespace used deliberately? (breathing room, visual grouping)
- Are there elements that could be removed without losing functionality?

**Good compliance:**
```
Customer list: name, company, interview count, last contact date. That's it.
Details available on click-through, not crammed into the list row.
```

**Violation:**
```
Customer list row shows: name, company, email, phone, address, interview count, last contact,
opportunity count, evidence count, tags, created date, modified date — all in one row.
```

**Common spec gaps:** Cramming too much information into list views, no progressive disclosure strategy.

---

### 9. Help Users Recognize, Diagnose, and Recover from Errors

Error messages should be expressed in plain language, precisely indicate the problem, and suggest a solution.

**What to check in a spec:**
- Are error messages in plain language? (not error codes or stack traces)
- Do errors indicate what specifically went wrong? ("Email format invalid" not "Validation error")
- Do errors suggest how to fix the problem? ("Try a different email" or "Check your connection")
- Are errors visually prominent? (red borders, error icons, positioned near the problem)
- Do errors persist until resolved? (don't auto-dismiss important errors)

**Good compliance:**
```
"Could not connect to Zoom. Check that your OAuth token hasn't expired.
[Reconnect to Zoom] [Skip for now]"
```

**Violation:**
```
"Error: ZOOM_AUTH_FAILURE (code 401)"
```

**Common spec gaps:** Generic error messages, errors that disappear before the user reads them, no recovery actions.

---

### 10. Help and Documentation

Even though it is better if the system can be used without documentation, it may be necessary to provide help.

**What to check in a spec:**
- Is help contextual? (tooltips on confusing elements, "?" icons linking to relevant docs)
- Are empty states educational? ("No interviews yet. Interviews are customer conversations..." with CTA)
- Is onboarding progressive? (first-time tooltips, gradual feature introduction)
- Are common tasks documented inline? (keyboard shortcut hints in menus)
- Is search available in help? (searchable documentation, FAQ)

**Good compliance:**
```
First visit to Discovery Tree: overlay tooltip pointing to the Outcome node:
"Start here. Your outcome is the business goal you're trying to achieve."
[Got it] [Show me how]
```

**Violation:**
```
Discovery Tree page loads with complex node graph and no explanation. User must find and read
separate documentation to understand what anything means.
```

**Common spec gaps:** No onboarding flow, no contextual help, empty states without guidance.

---

## Heuristic Evaluation Scorecard Template

Use this template to evaluate a spec or feature:

| # | Heuristic | Score (0-4) | Evidence | Gaps | Severity |
|---|-----------|-------------|----------|------|----------|
| 1 | Visibility of system status | | | | |
| 2 | Match system/real world | | | | |
| 3 | User control & freedom | | | | |
| 4 | Consistency & standards | | | | |
| 5 | Error prevention | | | | |
| 6 | Recognition over recall | | | | |
| 7 | Flexibility & efficiency | | | | |
| 8 | Aesthetic & minimalist design | | | | |
| 9 | Error recovery | | | | |
| 10 | Help & documentation | | | | |
| | **Total** | **/40** | | | |

### Scoring Scale

| Score | Meaning |
|-------|---------|
| 0 | Not applicable or fully addressed |
| 1 | Cosmetic issue — fix if time allows |
| 2 | Minor issue — low priority fix |
| 3 | Major issue — important to fix |
| 4 | Usability catastrophe — must fix before implementation |

### Severity Interpretation

| Total Score | Rating | Recommendation |
|------------|--------|----------------|
| 0-5 | Excellent | Spec is ready for implementation |
| 6-12 | Good | Minor gaps, can proceed with notes |
| 13-20 | Fair | Address major issues before implementation |
| 21-30 | Poor | Significant rework needed |
| 31-40 | Critical | Fundamental UX problems, redesign required |

---

## How to Run a Heuristic Evaluation

1. **Read the spec** — Understand what's being built and for whom
2. **Walk each task flow** — Mentally simulate each user journey
3. **Score each heuristic** — For each of the 10, rate 0-4 with specific evidence
4. **Identify top gaps** — Focus on severity 3-4 items first
5. **Recommend fixes** — Each gap gets a concrete recommendation
6. **Re-evaluate** — After spec improvements, score again to confirm improvement
