#!/bin/zsh
# 免管理员密码：只启动/确认 watchdog 保活（崩溃自动重启 + 开机 crontab）
set -euo pipefail

ROOT="/Users/tangtang/kunming-gis-buildings"
PORT=8765

mkdir -p "$ROOT/logs"
chmod +x "$ROOT/scripts/watchdog.sh" "$ROOT/scripts/serve.sh"

# 确保开机自启 crontab（无需密码）
(crontab -l 2>/dev/null | grep -v 'kunming-gis-buildings/scripts/watchdog.sh' || true
 echo '@reboot /bin/zsh /Users/tangtang/kunming-gis-buildings/scripts/watchdog.sh >> /Users/tangtang/kunming-gis-buildings/logs/watchdog.log 2>&1'
) | crontab -

# 重启守护
rm -rf "$ROOT/logs/watchdog.lockdir"
pkill -f "$ROOT/scripts/watchdog.sh" 2>/dev/null || true
sleep 0.4
nohup /bin/zsh "$ROOT/scripts/watchdog.sh" >> "$ROOT/logs/watchdog.log" 2>&1 &
disown
sleep 2

if curl -sf -o /dev/null --max-time 3 "http://127.0.0.1:${PORT}/product.html"; then
  echo "✓ 服务已运行（无需管理员密码）"
  echo "  地址：http://127.0.0.1:${PORT}/product.html"
  echo "  崩溃会自动重启；电脑重启后也会自动拉起。"
else
  echo "启动失败，请查看：$ROOT/logs/watchdog.log"
  exit 1
fi
