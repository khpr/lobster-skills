# 小米設備清單

## 已連通

| 設備 | 型號 | IP | Token | 指令 |
|------|------|-----|-------|------|
| 空氣清淨機 | zhimi.airpurifier.m1 | 10.0.0.8 | 875d11e0ec61531c361c0f3cb462ac57 | `miiocli airpurifier` |

## 待取 Token

| 設備 | IP | 備註 |
|------|-----|------|
| 未知 | 10.0.0.15 | token=fff，需雲端取 |
| 未知 | 10.0.0.7 | token=000，需雲端取 |

## 空淨機常用指令

```bash
# 狀態
miiocli airpurifier --ip 10.0.0.8 --token 875d11e0ec61531c361c0f3cb462ac57 status

# 開機
miiocli airpurifier --ip 10.0.0.8 --token 875d11e0ec61531c361c0f3cb462ac57 on

# 關機
miiocli airpurifier --ip 10.0.0.8 --token 875d11e0ec61531c361c0f3cb462ac57 off

# 設定模式（auto/silent/favorite）
miiocli airpurifier --ip 10.0.0.8 --token 875d11e0ec61531c361c0f3cb462ac57 set_mode auto
```

## 空淨機目前狀態（2026-03-18 掃描）
- 濾網壽命：0%（需更換！）
- 濾網已用：3500 小時
- AQI：10 μg/m³
- 溫度：23.7°C / 濕度：63%
