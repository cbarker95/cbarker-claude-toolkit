#!/usr/bin/env bash
# Auto-format files after Edit/Write/MultiEdit
# Detects the project's formatter (prettier, biome) and runs it on the changed file
set -euo pipefail

# Read JSON input from stdin
INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
# Handle both direct tool_input and nested structures
ti = data.get('tool_input', data)
print(ti.get('file_path', ''))" 2>/dev/null || true)

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Only format source files
case "$FILE_PATH" in
  *.ts|*.tsx|*.js|*.jsx|*.css|*.scss|*.html|*.json)
    ;;
  *)
    exit 0
    ;;
esac

# Find the project root (nearest package.json)
DIR=$(dirname "$FILE_PATH")
PROJECT_ROOT=""
while [ "$DIR" != "/" ]; do
  if [ -f "$DIR/package.json" ]; then
    PROJECT_ROOT="$DIR"
    break
  fi
  DIR=$(dirname "$DIR")
done

if [ -z "$PROJECT_ROOT" ]; then
  exit 0
fi

cd "$PROJECT_ROOT" || exit 0

# Detect and run formatter
if [ -f ".prettierrc" ] || [ -f ".prettierrc.json" ] || [ -f ".prettierrc.js" ] || \
   [ -f ".prettierrc.cjs" ] || [ -f ".prettierrc.yaml" ] || [ -f ".prettierrc.yml" ] || \
   [ -f "prettier.config.js" ] || [ -f "prettier.config.cjs" ] || \
   grep -q '"prettier"' package.json 2>/dev/null; then
  npx prettier --write "$FILE_PATH" 2>/dev/null || true
elif [ -f "biome.json" ] || [ -f "biome.jsonc" ]; then
  npx biome format --write "$FILE_PATH" 2>/dev/null || true
fi
