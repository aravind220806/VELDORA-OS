#!/usr/bin/env python3
"""Small, bounded hardware adapter. No shell interpolation or third-party code."""
import concurrent.futures
import json
import pathlib
import subprocess
import sys
import time


def veldora_run(*veldora_args):
    try:
        veldora_result = subprocess.run(veldora_args, capture_output=True, text=True, timeout=4)
        return veldora_result.stdout.strip() if veldora_result.returncode == 0 else ""
    except (OSError, subprocess.TimeoutExpired):
        return ""


def veldora_brightness():
    for veldora_device in sorted(pathlib.Path('/sys/class/backlight').glob('*')):
        try:
            return round(100 * int((veldora_device/'brightness').read_text()) / int((veldora_device/'max_brightness').read_text()))
        except (OSError, ValueError, ZeroDivisionError):
            pass
    return -1


def veldora_status():
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as veldora_pool:
        veldora_wifi = veldora_pool.submit(veldora_run, 'nmcli', 'radio', 'wifi')
        veldora_network = veldora_pool.submit(veldora_run, 'nmcli', '-t', '-f', 'NAME', 'connection', 'show', '--active')
        veldora_bt = veldora_pool.submit(veldora_run, 'bluetoothctl', 'show')
        veldora_result = {'wifi': veldora_wifi.result() == 'enabled', 'network': veldora_network.result().split('\n')[0] or 'Disconnected', 'bluetooth': 'Powered: yes' in veldora_bt.result(), 'bluetoothAvailable': bool(veldora_bt.result()), 'brightness': veldora_brightness(), 'battery': -1, 'charging': False}
    for veldora_battery in pathlib.Path('/sys/class/power_supply').glob('*'):
        try:
            if (veldora_battery/'type').read_text().strip() == 'Battery':
                veldora_result['battery'] = int((veldora_battery/'capacity').read_text())
                veldora_result['charging'] = (veldora_battery/'status').read_text().strip() == 'Charging'
                break
        except (OSError, ValueError):
            pass
    return veldora_result


if __name__ == '__main__':
    if len(sys.argv) > 1 and sys.argv[1] == 'watch':
        veldora_previous = None
        veldora_tick = 0
        while True:
            if veldora_tick % 6 == 0:
                veldora_data = veldora_status()
            else:
                veldora_data['brightness'] = veldora_brightness()
            if veldora_data != veldora_previous:
                print(json.dumps(veldora_data), flush=True)
                veldora_previous = veldora_data.copy()
            veldora_tick += 1
            time.sleep(0.5)
    else:
        print(json.dumps(veldora_status()))
