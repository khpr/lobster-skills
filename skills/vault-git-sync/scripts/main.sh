#!/usr/bin/env bash
# vault-git-sync/scripts/main.sh
# Version: 1.0
# 封裝 vault-auto-commit.sh，提供統一入口

set -euo pipefail

SCRIPT="$HOME/.openclaw/workspace/scripts/vault-auto-commit.sh"

# 參數檢查
if [ ! -f "$SCRIPT" ]; then
  echo "❌ vault-auto-commit.sh 不存在：$SCRIPT" >&2
  exit 1
fi

# 主流程
bash "$SCRIPT"
EXIT=$?

if [ $EXIT -eq 0 ]; then
  echo "✅ Vault git sync 完成"
else
  echo "❌ Vault git sync 失敗（exit $EXIT）" >&2
  exit $EXIT
fi
