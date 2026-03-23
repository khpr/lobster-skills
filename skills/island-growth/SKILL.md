---
name: island-growth
description: |
  依 token 累計自動升級島嶼等級。觸發底圖生成與 Dashboard 更新。
  
  觸發：[自動] 每小時 cron 自動檢查、島嶼、升級、等級、成長。
  不觸發：手動查 token 用量（用 /status）、要改等級規則（改設定）。
metadata:
  openclaw:
    emoji: "🏝️"
---

# Island Growth System

## 概述

龍蝦島隨系統使用量成長。每小時檢查 token 累計，達標自動升級（Lv 1→15）。
升級時自動生成新底圖 + 4 時段變體（dawn/day/dusk/night），使用者不被劇透。

## 組件

| 組件 | 路徑 | 用途 |
|------|------|------|
| 統計更新腳本 | `scripts/island-stats-update.sh` | 每小時 cron，更新 system.json + 偵測升級 + 天色切換 |
| 天色切換腳本 | `scripts/island-timeofday.sh` | 依時段 cp 底圖到 clawisland-current.png |
| 升級生圖腳本 | `scripts/island-levelup-gen.sh` | 升級時生 4 張底圖（Nano Banana 2） |
| Prompt 文件 | `scripts/island-timeofday-prompt.md` | 生圖提示詞 + 演進表 + 龍蝦風格定義 |
| Dashboard | 兩處同步（見下方） | 島的前端頁面 |
| 累計器 | `data/island-token-accumulator.json` | 持久化 token 累計 + 等級 |
| system.json | `data/system.json` (+ hud copy) | Dashboard 讀取的即時資料 |

## 雙入口同步

| 位置 | 網址 |
|------|------|
| `Vault/90_System/Deliverables/lobster-dashboard.html` | vault.life-os.work |
| `~/.openclaw/workspace/dashboard/hud/island/index.html` | line.life-os.work/hud/island/ |

改了主版必須 cp 到兩處。`island-timeofday.sh` 每次跑也會同步 clawisland-current.png。

## 升級表

| 等級 | Token (M) | 外觀主題 |
|------|-----------|---------|
| Lv 1 | 0 | 荒蕪廢土 |
| Lv 2 | 209 | 冒出希望（新芽、幼苗、修補） |
| Lv 3 | 211 | 野花蔓延（更多綠葉、蔬菜、野花） |
| Lv 4 | 213 | 安居雛形（樹冠、菜園、晾衣繩、燈籠） |
| Lv 5 | 215 | 廢土家園（風車、串燈、長椅、彩繪） |
| Lv 6 | 217 | 繁榮基地（溫室、彩旗、水車、動物欄） |
| Lv 7-15 | +2M/級 | 持續演進 |

## Skill 數顯示

Skill 數（自建 skill + 活躍 cron）僅用於展示，不參與升級計算。

## 天色系統

| 時段 | 時間 | 底圖 | 龍蝦姿勢 |
|------|------|------|---------|
| dawn | 05:00-07:00 | lv{N}-dawn | 站立 (standing) |
| day | 07:00-17:00 | lv{N} | 遠望 (gaze) |
| dusk | 17:00-19:00 | lv{N}-dusk | 沈思 (think) |
| night | 19:00-05:00 | lv{N}-night | 睡眠 (sleep) |

- CSS 天色漸層 + 雲色 + 星星覆蓋層也隨時段變化
- 龍蝦 30 分鐘換定點（5 位置），姿勢跟天色走

## 觸發流程

1. `island-stats` cron（每小時）→ `island-stats-update.sh`
2. 取 claude token 總量 + 計算 ability count
3. 比對升級表 → 寫 system.json → 尾巴跑 `island-timeofday.sh`
4. 如果升級 → 寫 `/tmp/island-levelup-flag.json`
5. heartbeat 偵測 flag → `island-levelup-gen.sh`
6. 生 4 張底圖（白天 + dawn/dusk/night）→ 部署 → 刪 flag
7. 使用者打開看到驚喜

## 底圖資產

- 路徑：`assets/clawisland-lv{N}[-dawn|-dusk|-night].png`
- 活動圖：`assets/clawisland-current.png`（cron 每小時 cp，非 symlink）
- 尺寸：714×1280（9:16 直式）
- 風格：廢土 low-poly 浮島（港口廢船背景）

## 龍蝦角色（v2 蒸汽龐克銅龍蝦）

- 銅橘色金屬機器人、圓護目鏡、安全帽、大鉗子
- Sprite：`island-assets/sprites/claw-sprite-{pose}-v2.png`（RGBA 去背）
- 4 姿勢：standing / gaze / think / sleep
