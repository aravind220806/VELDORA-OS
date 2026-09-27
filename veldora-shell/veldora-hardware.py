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


_last_cpu = None


def veldora_cpu():
    global _last_cpu
    try:
        with open('/proc/stat') as f:
            line = f.readline()
            if not line.startswith('cpu '): return '0%'
            fields = [float(x) for x in line.split()[1:8]]
            idle = fields[3] + fields[4]
            total = sum(fields)
            if _last_cpu is None:
                _last_cpu = (total, idle)
                return '5%'
            last_total, last_idle = _last_cpu
            _last_cpu = (total, idle)
            dt = total - last_total
            if dt <= 0: return '0%'
            pct = max(0, min(100, round(100 * (1 - (idle - last_idle) / dt))))
            return f'{pct}%'
    except Exception:
        return '0%'


def veldora_mem():
    try:
        mem = {}
        with open('/proc/meminfo') as f:
            for line in f:
                p = line.split(':')
                if len(p) == 2:
                    k = p[0].strip()
                    if k in ('MemTotal', 'MemAvailable', 'SwapTotal', 'SwapFree'):
                        mem[k] = int(p[1].split()[0])
        ram_tot = mem.get('MemTotal', 0)
        ram_avail = mem.get('MemAvailable', 0)
        ram_used = ram_tot - ram_avail
        ram_str = f'{ram_used / 1048576:.1f}G' if ram_tot else '0G'
        swap_tot = mem.get('SwapTotal', 0)
        swap_free = mem.get('SwapFree', 0)
        swap_used = swap_tot - swap_free
        swap_str = f'{round(swap_used / swap_tot * 100)}%' if swap_tot > 0 else '0%'
        return ram_str, swap_str
    except Exception:
        return '0G', '0%'


def veldora_storage():
    try:
        import shutil
        u = shutil.disk_usage('/')
        return f'{round(u.used / u.total * 100)}%'
    except Exception:
        return '0%'


def veldora_gpu():
    try:
        nv = veldora_run('nvidia-smi', '--query-gpu=clocks.current.graphics', '--format=csv,noheader,nounits')
        if nv:
            first = nv.split('\n')[0].strip()
            if first.isdigit():
                val = int(first)
                return f'{val/1000:.1f}GHz' if val >= 1000 else f'{val}MHz'
    except Exception:
        pass
    for p in list(pathlib.Path('/sys/class/drm').glob('card*/device/drm/card*/gt_*freq*')) + list(pathlib.Path('/sys/class/drm').glob('card*/gt_cur_freq_mhz')):
        try:
            if 'act_freq' in p.name or 'cur_freq' in p.name:
                val = int(p.read_text().strip())
                if val > 0:
                    return f'{val/1000:.1f}GHz' if val >= 1000 else f'{val}MHz'
        except Exception:
            pass
    return 'N/A'


def veldora_status():
    ram, swap = veldora_mem()
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as veldora_pool:
        veldora_wifi = veldora_pool.submit(veldora_run, 'nmcli', 'radio', 'wifi')
        veldora_network = veldora_pool.submit(veldora_run, 'nmcli', '-t', '-f', 'NAME', 'connection', 'show', '--active')
        veldora_bt = veldora_pool.submit(veldora_run, 'bluetoothctl', 'show')
        veldora_result = {
            'wifi': veldora_wifi.result() == 'enabled',
            'network': veldora_network.result().split('\n')[0] or 'Disconnected',
            'bluetooth': 'Powered: yes' in veldora_bt.result(),
            'bluetoothAvailable': bool(veldora_bt.result()),
            'brightness': veldora_brightness(),
            'battery': -1,
            'charging': False,
            'cpu': veldora_cpu(),
            'ram': ram,
            'swap': swap,
            'storage': veldora_storage(),
            'gpu': veldora_gpu()
        }
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
        veldora_data = veldora_status()
        while True:
            if veldora_tick % 6 == 0:
                veldora_data = veldora_status()
            else:
                veldora_data['brightness'] = veldora_brightness()
                veldora_data['cpu'] = veldora_cpu()
                ram, swap = veldora_mem()
                veldora_data['ram'] = ram
                veldora_data['swap'] = swap
                if veldora_tick % 10 == 0:
                    veldora_data['storage'] = veldora_storage()
                    veldora_data['gpu'] = veldora_gpu()
            if veldora_data != veldora_previous:
                print(json.dumps(veldora_data), flush=True)
                veldora_previous = veldora_data.copy()
            veldora_tick += 1
            time.sleep(0.5)
    else:
        print(json.dumps(veldora_status()))

