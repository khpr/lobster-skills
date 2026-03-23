---
name: lg-thinq
description: "Control LG washer via ThinQ Connect API. Check wash status, remaining time, error alerts. Push notification when wash complete."
metadata: {"clawdbot":{"emoji":"🧺"}}
---

# LG ThinQ 洗衣機控制 🧺

## 認證

- PAT Token: 存在 `~/.openclaw/.env` → `LG_THINQ_PAT`
- Country: TW
- Client ID: `65260af7e8e6547b51fdccf930097c51eb9885a8c594bb3f3c7b4956b2c0c79781f931a1`

## 設備

| 設備 | Device ID | 型號 |
|------|-----------|------|
| 洗衣機 | `e03578db6c1aa852fe3b6918197df556f304301eb100e3e51fea6724f5943771` | F_V7_F___W.A__BTAT |

## 查狀態

```bash
/tmp/thinq-venv/bin/python3 ~/.openclaw/skills/lg-thinq/scripts/washer-status.py
```

### 狀態值對照

| currentState | 意思 |
|-------------|------|
| INITIAL | 待機 |
| RUNNING | 洗衣中 |
| RINSING | 沖洗中 |
| SPINNING | 脫水中 |
| DRYING | 烘乾中 |
| END | 洗完了 |
| PAUSE | 暫停 |
| RESERVED | 預約中 |
| RINSE_HOLD | 浸泡中 |
| ERROR | 錯誤 |
| POWER_OFF | 關機 |

### 可寫入操作（需開啟遠端控制）

| 操作 | 值 |
|------|-----|
| 開始洗衣 | `washerOperationMode: START` |
| 停止 | `washerOperationMode: STOP` |
| 關機 | `washerOperationMode: POWER_OFF` |
| 喚醒 | `washerOperationMode: WAKE_UP` |

### 推播通知

- `WASHING_IS_COMPLETE` — 洗完了
- `ERROR_DURING_WASHING` — 洗衣中出錯

### 錯誤代碼

TEMPERATURE_SENSOR_ERROR, OVERFILL_ERROR, LOCKED_MOTOR_ERROR, POWER_FAIL_ERROR, WATER_SUPPLY_ERROR, UNABLE_TO_LOCK_ERROR, WATER_DRAIN_ERROR, WATER_LEVEL_SENSOR_ERROR, DOOR_OPEN_ERROR, OUT_OF_BALANCE_ERROR

## 自然語言對應

| 使用者說 | 動作 |
|---------|------|
| 洗衣機狀態 / 洗好了嗎 | 查 currentState + remainHour/remainMinute |
| 洗衣幾次了 | 查 cycleCount |
| 停止洗衣 | POST washerOperationMode=STOP |

## Python venv

SDK: `thinqconnect`（裝在 `/tmp/thinq-venv/`）

⚠️ 如果 venv 不存在，重建：
```bash
python3 -m venv /tmp/thinq-venv
/tmp/thinq-venv/bin/pip install thinqconnect
```
