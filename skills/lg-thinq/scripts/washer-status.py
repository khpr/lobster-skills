#!/usr/bin/env python3
"""LG ThinQ washer status checker"""
import asyncio, json, os, sys
from aiohttp import ClientSession

PAT = os.environ.get('LG_THINQ_PAT', '')
if not PAT:
    env_file = os.path.expanduser('~/.openclaw/.env')
    if os.path.exists(env_file):
        for line in open(env_file):
            if line.startswith('LG_THINQ_PAT='):
                PAT = line.strip().split('=', 1)[1]

DEVICE_ID = 'e03578db6c1aa852fe3b6918197df556f304301eb100e3e51fea6724f5943771'
COUNTRY = 'TW'
CLIENT_ID = '65260af7e8e6547b51fdccf930097c51eb9885a8c594bb3f3c7b4956b2c0c79781f931a1'

STATE_ZH = {
    'INITIAL': '待機', 'RUNNING': '洗衣中', 'RINSING': '沖洗中',
    'SPINNING': '脫水中', 'DRYING': '烘乾中', 'END': '洗完了',
    'PAUSE': '暫停', 'RESERVED': '預約中', 'RINSE_HOLD': '浸泡中',
    'ERROR': '錯誤', 'POWER_OFF': '關機', 'SLEEP': '休眠',
    'DETECTING': '偵測中', 'COOL_DOWN': '冷卻中',
    'STEAM_SOFTENING': '蒸氣柔軟', 'REFRESHING': '清新中'
}

async def main():
    from thinqconnect import ThinQApi
    async with ClientSession() as session:
        api = ThinQApi(session=session, access_token=PAT, country_code=COUNTRY, client_id=CLIENT_ID)
        status = await api.async_get_device_status(DEVICE_ID)
        
        if not status:
            print('無法取得狀態')
            return
        
        s = status[0]
        state = s.get('runState', {}).get('currentState', '?')
        state_zh = STATE_ZH.get(state, state)
        remain_h = s.get('timer', {}).get('remainHour', 0)
        remain_m = s.get('timer', {}).get('remainMinute', 0)
        total_h = s.get('timer', {}).get('totalHour', 0)
        total_m = s.get('timer', {}).get('totalMinute', 0)
        cycles = s.get('cycle', {}).get('cycleCount', '?')
        remote = s.get('remoteControlEnable', {}).get('remoteControlEnabled', False)
        
        print(f'🧺 洗衣機狀態：{state_zh}')
        if state in ('RUNNING', 'RINSING', 'SPINNING', 'DRYING', 'STEAM_SOFTENING'):
            print(f'⏱️ 剩餘：{remain_h}小時{remain_m}分')
            print(f'📊 總計：{total_h}小時{total_m}分')
        print(f'🔄 累計洗衣：{cycles}次')
        print(f'📡 遠端控制：{"開啟" if remote else "關閉"}')
        
        # JSON output for programmatic use
        if '--json' in sys.argv:
            print(json.dumps(s, ensure_ascii=False))

asyncio.run(main())
