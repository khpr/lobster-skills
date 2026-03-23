#!/bin/bash
# sp500-buffer-clean.sh — 清除 7 天前的 buffer 文章
BUFFER="$HOME/.openclaw/skills/sp500/buffer"
find "$BUFFER" -name "*.md" -mtime +7 -delete 2>/dev/null
find "$BUFFER" -name "*.jsonl" -mtime +7 -delete 2>/dev/null
echo "Buffer 清理完成（保留最近 7 天）"
