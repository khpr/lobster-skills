# dispatch-tracker 使用範例

## 每個 Turn 啟動（自動）
```
bash main.sh check
```
有輸出 → 主動回報；無 → 靜默

## 派工前
```
bash main.sh add "claude" "重構 auth 模組" "V-042"
```

## 收到結果後
```
bash main.sh done "claude" "auth 模組"
```

## 查看全部
```
bash main.sh list
```
