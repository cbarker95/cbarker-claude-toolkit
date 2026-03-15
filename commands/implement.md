---
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
description: Build the next feature from a discovery specification — one 🟪 item per invocation
---

You are going to choose what to work on from `Docs/Specifications/$ARGUMENTS/README.md`. Identify the outstanding work by searching for the 🟪 marker, and choose whichever such feature seems the most appropriate next step. You must choose only ONE feature.

Having chosen a feature to implement, you should read around related areas of the spec to make sure you understand the context. Also read CLAUDE.md for project conventions, build commands, and testing strategies.

## Implementation

- Implement that single feature fully
- Include appropriate tests (unit, integration, UI — whatever the project uses)
- Ensure the build passes and tests pass before committing
- Update the feature's entry in the specification to replace the 🟪 marker with ✅ when it's done
- Commit the changes to this git repository with a short, descriptive commit message

## Build & Test

Run the project's build and test commands. Check CLAUDE.md, package.json, Makefile, Cargo.toml, or similar for the correct commands. Common patterns:

- Node.js: `npm run build`, `npm test`
- Rust: `cargo build`, `cargo test`
- Python: `pytest`
- Go: `go build ./...`, `go test ./...`
- .NET: `dotnet build`, `dotnet test`

If no test framework exists, verify the build succeeds and do a manual review for obvious issues.

## What to do if there's nothing to do!

**IMPORTANT:** If there is no remaining work to implement (no 🟪 markers found), output the following exact string, and quit:

```
NO_REMAINING_WORK
```
