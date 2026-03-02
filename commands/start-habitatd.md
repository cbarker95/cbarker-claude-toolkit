---
allowed-tools: Bash, Read, AskUserQuestion
description: Start habitatd backend + Electron app for full end-to-end testing
---

# Start habitatd

Spin up both the habitatd Fastify backend (port 3001) and the Electron desktop app so all AI features work end-to-end. Run this before any usability testing or feature verification.

## Usage

```
/start-habitatd              # auto-detect habitatd project from cwd or ~/habitatd
/start-habitatd ~/projects/habitatd  # explicit path
```

---

## Step 1: Locate the project

**If `$ARGUMENTS` is provided:** treat it as the absolute path to the habitatd project root.

**Otherwise:** check these paths in order:
1. Current working directory — look for `backend/` and `desktop/` subdirectories
2. `~/habitatd`
3. Ask the user: "Where is your habitatd project? (e.g. ~/habitatd)"

Set `PROJECT_ROOT` to the resolved path. All subsequent commands run from here.

---

## Step 2: Check dependencies

Run these checks in parallel:

```bash
# Backend deps
ls $PROJECT_ROOT/backend/node_modules/.bin/tsx 2>/dev/null && echo "ok" || echo "missing"

# Desktop deps
ls $PROJECT_ROOT/desktop/node_modules/.bin/vite 2>/dev/null && echo "ok" || echo "missing"
```

If either returns "missing", install deps first:
```bash
cd $PROJECT_ROOT/backend && npm install
cd $PROJECT_ROOT/desktop && npm install
```

---

## Step 3: Start the backend

Run the backend in the background:

```bash
cd $PROJECT_ROOT/backend && npm run dev
```

Use `run_in_background: true`. Note the task ID so you can reference it later.

---

## Step 4: Wait for backend to be ready

Poll every 2 seconds, up to 30 seconds, until the backend responds:

```bash
for i in $(seq 1 15); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001/auth/me 2>/dev/null)
  if [ "$STATUS" = "401" ] || [ "$STATUS" = "200" ]; then
    echo "Backend ready (HTTP $STATUS)"
    break
  fi
  echo "Waiting for backend... attempt $i/15"
  sleep 2
done
```

A `401` response means the backend is running (auth endpoint reachable, just not authenticated — expected). If after 30s it's still not up, show the backend task output and stop with an error message.

---

## Step 5: Start the Electron app

Run the desktop app in the background:

```bash
cd $PROJECT_ROOT/desktop && npm run electron:dev
```

Use `run_in_background: true`.

**Note:** `npm run electron:dev` unsets `ELECTRON_RUN_AS_NODE` internally so the GUI opens correctly. Never run `electron .` directly.

---

## Step 6: Confirm and report

Print a status summary:

```
habitatd is running.

  Backend   http://localhost:3001  (Fastify, JWT auth, AI proxy)
  Desktop   Electron window should be open

All AI features are active:
  • Analyze documents  (10 credits)
  • Ask panel          (1 credit)
  • Generate solutions (5 credits)
  • Propose features   (5 credits)

To stop: close the Electron window, then kill the backend task.
```

If the Electron window doesn't open within ~15 seconds, check whether `ELECTRON_RUN_AS_NODE` is set in the environment and warn the user to unset it.

---

## Troubleshooting

**Backend won't start:**
- Check `$PROJECT_ROOT/backend/` exists and has `package.json`
- Run `cd backend && npm install` if node_modules is missing
- Check port 3001 isn't already in use: `lsof -i :3001`

**Electron window doesn't open:**
- Make sure you're running `npm run electron:dev` from the `desktop/` directory, not from the project root
- VS Code sets `ELECTRON_RUN_AS_NODE=1` — the `electron:dev` script handles this automatically
- Check `desktop/node_modules` exists

**"Could not reach the server" on Analyze:**
- This means the backend isn't running. Run `/start-habitatd` again.
- The app caches your login session, so you'll appear logged in even when the backend is down — AI features require a live backend.
