---
allowed-tools: Bash, Read, Write, WebFetch, Task
argument-hint: <url>
description: Run full design verification on a URL
---

# Design Check Command

Run a complete design verification check on the provided URL.

## Steps

1. **Capture Screenshot**: Use Playwright to capture the current state of `$ARGUMENTS`
2. **Fetch Design**: Get the corresponding Figma design using the Figma MCP
3. **Run Agents**: Execute in parallel:
   - Design comparison (visual diff)
   - Accessibility audit (WCAG 2.1 AA)
   - UX consistency check
4. **Generate Report**: Compile findings into a structured report

## Output Format

Provide a structured report with:
- Overall score (0-100)
- Design fidelity issues (with screenshots)
- Accessibility violations
- UX recommendations
- Priority ranking of issues
