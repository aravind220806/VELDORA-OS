#!/usr/bin/env python3
"""Live checks, restoring the workspace and volume when finished."""
import json
from pathlib import Path
import subprocess
import time
import os
import signal

if os.environ.get("VELDORA_ISOLATED") != "1":
    raise SystemExit("Run tests/veldora_isolated.py; live-host input testing is disabled.")

veldora_root = Path(__file__).resolve().parent
veldora_output = veldora_root/'veldora-previews'
veldora_output.mkdir(exist_ok=True)
veldora_checks = []


def veldora_run(*veldora_args):
    return subprocess.check_output(veldora_args, text=True).strip()


def veldora_ipc(*veldora_args):
    return veldora_run('qs','ipc','-c','veldora','call','veldora',*veldora_args)


def veldora_status():
    return json.loads(veldora_ipc('status'))


def veldora_layers():
    veldora_data = json.loads(veldora_run('hyprctl','layers','-j'))
    return [x['namespace'] for m in veldora_data.values() for level in m['levels'].values() for x in level]


def veldora_check(veldora_name, veldora_condition):
    if not veldora_condition:
        raise AssertionError(veldora_name)
    veldora_checks.append(veldora_name)
    print('PASS:', veldora_name, flush=True)


def veldora_capture(veldora_name):
    time.sleep(0.4)
    veldora_run('grim', str(veldora_output/('veldora-'+veldora_name+'.png')))


veldora_original_workspace = json.loads(veldora_run('hyprctl','activeworkspace','-j'))['id']
veldora_original_volume = veldora_status()['volume']
veldora_used = {x['id'] for x in json.loads(veldora_run('hyprctl','workspaces','-j'))}
veldora_test_workspace = next(x for x in range(9, 100) if x not in veldora_used)
try:
    veldora_ipc('close')
    veldora_check('Hyprland configuration has no errors', not veldora_run('hyprctl','configerrors'))
    veldora_ipc('workspace', str(veldora_test_workspace))
    time.sleep(0.5)
    veldora_check('Workspace switching uses the live Lua API', json.loads(veldora_run('hyprctl','activeworkspace','-j'))['id'] == veldora_test_workspace)
    veldora_check('Bar, dock and preserved wallpaper are mapped', {'veldora-top','veldora-dock','veldora-backdrop'}.issubset(veldora_layers()))
    veldora_capture('desktop')
    veldora_ipc('controls')
    veldora_check('Control Center opens', veldora_status()['controls'])
    veldora_capture('controls')
    veldora_ipc('close')
    veldora_ipc('launcher')
    time.sleep(0.4)
    veldora_check('Launcher opens with real desktop entries', veldora_status()['launcher'] and veldora_status()['applications'] > 0)
    veldora_capture('launcher')
    veldora_run('wtype', 'kitty')
    veldora_capture('search')
    veldora_prior_windows = {w['address'] for w in json.loads(veldora_run('hyprctl','clients','-j'))}
    veldora_run('wtype','-k','Return')
    time.sleep(0.8)
    veldora_new_windows = [w for w in json.loads(veldora_run('hyprctl','clients','-j')) if w['address'] not in veldora_prior_windows and w['class'] == 'kitty']
    veldora_check('Enter launches the selected desktop application', bool(veldora_new_windows) and not veldora_status()['launcher'])
    for veldora_window in veldora_new_windows:
        os.kill(veldora_window['pid'], signal.SIGTERM)
    veldora_ipc('launcher')
    time.sleep(0.3)
    veldora_run('wtype','-k','Escape')
    time.sleep(0.3)
    veldora_check('Escape dismisses the launcher', not veldora_status()['launcher'])
    veldora_run('notify-send','--app-name=Veldora','A quieter desktop','Your space, softly rounded.')
    time.sleep(0.3)
    veldora_check('Notification server displays a real notification', 'veldora-notifications' in veldora_layers())
    veldora_capture('notification')
    time.sleep(5)
    veldora_check('Notifications expire after five seconds', 'veldora-notifications' not in veldora_layers())
    veldora_ipc('volume','1.2')
    time.sleep(0.4)
    veldora_check('Shell volume control caps output at 100 percent', veldora_status()['volume'] <= 1.0001)
    veldora_check('Volume change produces an OSD', veldora_status()['osd'] == 'volume')
    veldora_capture('osd')
    time.sleep(1.6)
    veldora_check('OSD disappears after 1.5 seconds', veldora_status()['osd'] == '')
    veldora_logs = veldora_run('qs','log','-c','veldora','--no-color','-t','200')
    veldora_check('Quickshell has no warnings or errors', not any(x in veldora_logs for x in [' WARN ', ' ERROR ', 'ReferenceError', 'TypeError']))
    (veldora_output/'veldora-validation.json').write_text(json.dumps({'checks':veldora_checks,'physical_super_key':'Confirmed by user','not_exercised':['poweroff','reboot','suspend','lock','disconnect Wi-Fi/Bluetooth','microphone mutation','second monitor']},indent=2)+'\n')
finally:
    veldora_ipc('close')
    veldora_run('wpctl','set-volume','@DEFAULT_AUDIO_SINK@',str(veldora_original_volume))
    veldora_ipc('workspace',str(veldora_original_workspace))
