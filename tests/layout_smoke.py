"""Explicit integration test; run only against an isolated Hyprland test session."""
import json
import os
from pathlib import Path
import subprocess
import time

assert os.environ.get('HYPRLAND_INSTANCE_SIGNATURE'), 'Set the isolated compositor signature'
assert os.environ.get('DBUS_SESSION_BUS_ADDRESS'), 'Set the isolated session bus'


def surfaces():
    result = json.loads(subprocess.check_output(['hyprctl', '-j', 'layers']))
    return {item['namespace']: item for output in result.values() for level in output['levels'].values() for item in level}


idle = surfaces()
assert idle['veldora-island']['w'] < 200
assert idle['veldora-island']['h'] < 36
assert idle['veldora-left']['y'] == idle['veldora-island']['y'] == idle['veldora-right']['y']
assert 'veldora-dock' not in idle and 'veldora-clock' not in idle and 'veldora-details' not in idle
subprocess.run(['notify-send', '-t', '1000', 'A notification temporarily expands the island'], check=True)
time.sleep(0.6)
assert surfaces()['veldora-island']['w'] > idle['veldora-island']['w']
time.sleep(6)
assert surfaces()['veldora-island']['w'] == idle['veldora-island']['w'], 'Island must return to date/time width'
main = str(Path(__file__).resolve().parents[1] / 'shell/main.py')
subprocess.run(['python', main, '--toggle'], check=True)
time.sleep(0.4)
assert 'veldora-details' in surfaces()
subprocess.run(['python', main, '--toggle'], check=True)
time.sleep(0.4)
assert 'veldora-details' not in surfaces()
print('Layout smoke passed: aligned top pills, compact idle, transient expansion, auto-collapse, manual controls.')
