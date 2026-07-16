#!/bin/zsh
# 守护进程：每 5 秒探活，挂了自动拉起。用 mkdir 做单实例锁（macOS 无 flock）。
set -uo pipefail

ROOT="/Users/tangtang/kunming-gis-buildings"
PORT=8765
LOG_DIR="$ROOT/logs"
LOCK_DIR="$LOG_DIR/watchdog.lockdir"
mkdir -p "$LOG_DIR"

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  # 若锁目录存在但进程已死，清理后重试
  OLD_PID="$(cat "$LOCK_DIR/pid" 2>/dev/null || true)"
  if [ -n "${OLD_PID:-}" ] && kill -0 "$OLD_PID" 2>/dev/null; then
    echo "[$(date '+%F %T')] another watchdog running (pid $OLD_PID) — exit" >> "$LOG_DIR/watchdog.log"
    exit 0
  fi
  rm -rf "$LOCK_DIR"
  mkdir "$LOCK_DIR" || exit 0
fi

cleanup() {
  rm -rf "$LOCK_DIR"
}
trap cleanup EXIT INT TERM

cd "$ROOT"
echo $$ > "$LOCK_DIR/pid"
echo $$ > "$LOG_DIR/watchdog.pid"
echo "[$(date '+%F %T')] watchdog started (port $PORT, pid $$)" >> "$LOG_DIR/watchdog.log"

start_server() {
  if lsof -ti tcp:"$PORT" >/dev/null 2>&1; then
    lsof -ti tcp:"$PORT" | xargs kill -9 2>/dev/null || true
    sleep 0.4
  fi
  /usr/bin/python3 -m http.server "$PORT" --bind 127.0.0.1 \
    >> "$LOG_DIR/server.out.log" 2>> "$LOG_DIR/server.err.log" &
  echo $! > "$LOG_DIR/server.pid"
  sleep 1
}

if ! /usr/bin/curl -sf -o /dev/null --max-time 2 "http://127.0.0.1:${PORT}/product.html"; then
  echo "[$(date '+%F %T')] initial start" >> "$LOG_DIR/watchdog.log"
  start_server
fi

while true; do
  if ! /usr/bin/curl -sf -o /dev/null --max-time 2 "http://127.0.0.1:${PORT}/product.html"; then
    echo "[$(date '+%F %T')] server down — restarting" >> "$LOG_DIR/watchdog.log"
    start_server
  fi
  sleep 5
done
