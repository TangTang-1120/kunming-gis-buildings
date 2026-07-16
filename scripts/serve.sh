#!/bin/zsh
# Kunming GIS static server — exits non-zero on failure so LaunchAgent KeepAlive restarts it.
set -euo pipefail

ROOT="/Users/tangtang/kunming-gis-buildings"
PORT=8765
LOG_DIR="$ROOT/logs"
mkdir -p "$LOG_DIR"

cd "$ROOT"

# Free the port if a stale process is holding it
if lsof -ti tcp:"$PORT" >/dev/null 2>&1; then
  lsof -ti tcp:"$PORT" | xargs kill -9 2>/dev/null || true
  sleep 0.5
fi

exec /usr/bin/python3 -m http.server "$PORT" --bind 127.0.0.1
