#!/usr/bin/env bash
set -euo pipefail

# Project root: repo clone folder (four levels up from this script)
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
if [[ ! -f "$ROOT/project.godot" ]]; then
  echo "error: project.godot not found at $ROOT" >&2
  exit 1
fi

if [[ -x "${HOME}/.local/bin/godot" ]]; then
  GODOT="${GODOT:-$HOME/.local/bin/godot}"
else
  GODOT="${GODOT:-godot}"
fi

# Kill only processes whose command line references this project path
if command -v pkill >/dev/null 2>&1; then
  pkill -f "godot.*${ROOT}" 2>/dev/null || true
  pkill -f "Godot_.*${ROOT}" 2>/dev/null || true
fi

sleep 0.25

# New instance (GUI); background so the agent does not block
nohup "$GODOT" --path "$ROOT" >/dev/null 2>&1 &
echo "started: $GODOT --path $ROOT"
