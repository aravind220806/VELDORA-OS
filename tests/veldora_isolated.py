#!/usr/bin/env python3
"""Render a staged shell on a private headless compositor and private session bus."""
import argparse
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time

VELDORA_REPO = Path(__file__).resolve().parents[1]


def veldora_main():
    veldora_parser = argparse.ArgumentParser()
    veldora_parser.add_argument('--inside', type=Path)
    veldora_args = veldora_parser.parse_args()
    if not veldora_args.inside:
        veldora_run = Path(tempfile.mkdtemp(prefix='veldora-isolated-', dir=VELDORA_REPO/'build'))
        subprocess.run([str(VELDORA_REPO/'scripts/prepare-profile.sh'),str(veldora_run/'profile')],check=True,stdout=subprocess.DEVNULL)
        veldora_env = os.environ.copy()
        veldora_env['VELDORA_HOST_SIGNATURE'] = veldora_env.get('HYPRLAND_INSTANCE_SIGNATURE','')
        veldora_bus = veldora_run/'bus.conf'
        veldora_bus.write_text('<busconfig><type>session</type><listen>unix:tmpdir=/tmp</listen><policy context="default"><allow send_destination="*"/><allow receive_sender="*"/><allow own="*"/></policy></busconfig>')
        return subprocess.call(['dbus-run-session','--config-file='+str(veldora_bus),'--','python',__file__,'--inside',str(veldora_run)],env=veldora_env)
    veldora_run = veldora_args.inside.resolve()
    assert veldora_run.is_relative_to(VELDORA_REPO/'build')
    veldora_root = veldora_run/'profile/airootfs'
    veldora_config = veldora_root/'etc/skel/.config'
    veldora_runtime = veldora_run/'runtime'; veldora_runtime.mkdir(mode=0o700)
    # AF_UNIX paths are limited to 108 bytes. The short link points into the repo.
    veldora_short_parent = Path(tempfile.mkdtemp(prefix='v'))
    veldora_short = veldora_short_parent/'r'; veldora_short.symlink_to(veldora_runtime,target_is_directory=True)
    veldora_env = os.environ.copy()
    for veldora_key in ['HYPRLAND_INSTANCE_SIGNATURE','WAYLAND_DISPLAY','DISPLAY','QS_CONFIG_PATH','QS_CONFIG_NAME']:
        veldora_env.pop(veldora_key,None)
    veldora_env.update({'XDG_RUNTIME_DIR':str(veldora_short),'XDG_CONFIG_HOME':str(veldora_config),
        'XDG_CACHE_HOME':str(veldora_run/'cache'),'XDG_STATE_HOME':str(veldora_run/'state'),
        'XDG_DATA_HOME':str(veldora_run/'data'),'AQ_DRM_DEVICES':'/dev/veldora-no-drm','__EGL_VENDOR_LIBRARY_FILENAMES':'/usr/share/glvnd/egl_vendor.d/50_mesa.json',
        'WLR_RENDER_DRM_DEVICE':'/dev/dri/renderD128','QT_QPA_PLATFORMTHEME':'','QT_ACCESSIBILITY':'0',
        'DBUS_SYSTEM_BUS_ADDRESS':'unix:path=/nonexistent-veldora-system-bus','WLR_RENDERER_ALLOW_SOFTWARE':'1','VELDORA_ISOLATED':'1','QT_QPA_PLATFORM':'wayland'})
    # Read-only focus probe exists only in the disposable staged copy.
    veldora_island_file = veldora_config/'quickshell/veldora/VeldoraIsland.qml'
    veldora_island_source = veldora_island_file.read_text().replace('import QtQuick\n','import QtQuick\nimport Quickshell.Io\n',1)
    veldora_island_source = veldora_island_source.rstrip()[:-1] + '''
    IpcHandler {
        target: "veldora-test-focus"
        function label(): string {
            const item = veldoraIslandCard.Window.window.activeFocusItem;
            return item ? (item.text || item.veldoraIcon || "") : "";
        }
    }
}
'''
    veldora_island_file.write_text(veldora_island_source)
    veldora_settings = veldora_config/'quickshell/veldora/veldora-settings.json'
    veldora_preferences = json.loads(veldora_settings.read_text())
    veldora_preferences['wallpaper'] = str(veldora_root/'usr/share/veldora/theme/black-dragon.png')
    veldora_settings.write_text(json.dumps(veldora_preferences))
    veldora_lua = veldora_run/'veldora-test.lua'
    veldora_lua.write_text('hl.monitor({output="",mode="1920x1080@60",position="auto",scale=1})\n' +
        'hl.permission({binary="hl-virtual-keyboard-wtype",type="keyboard",mode="allow"})\n' +
        'hl.device({name="hl-virtual-keyboard-wtype",enabled=true,keybinds=true,resolve_binds_by_sym=true})\n'+
        'hl.config({input={resolve_binds_by_sym=true},misc={disable_hyprland_logo=true},animations={enabled=false},debug={enable_stdout_logs=true,disable_logs=false}})\n'+
        'dofile('+json.dumps(str(veldora_config/'hypr/veldora-theme.lua'))+')\n' +
        '\n'.join(line for line in (VELDORA_REPO/'shell/hyprland.lua').read_text().splitlines() if line.startswith('hl.bind(') and '--overview' in line)+'\n')
    veldora_env['PATH'] = str(veldora_root/'usr/local/bin')+':'+str(VELDORA_REPO/'build/isolated-tools/usr/bin')+':'+os.environ['PATH']
    veldora_env['XDG_DATA_DIRS'] = str(veldora_root/'usr/share')+':/usr/local/share:/usr/share'
    veldora_children = []
    veldora_log = (veldora_run/'veldora-compositor.log').open('w')
    veldora_shell_log = (veldora_run/'veldora-shell.log').open('w')
    try:
        veldora_tools = VELDORA_REPO/'build/isolated-tools/usr'
        veldora_parent_env = veldora_env.copy()
        veldora_parent_env.update({'LD_LIBRARY_PATH':str(veldora_tools/'lib'), 'WLR_BACKENDS':'headless','WLR_HEADLESS_OUTPUTS':'1','WLR_RENDERER':'gles2'})
        veldora_parent_config = veldora_run/'sway.conf'
        veldora_parent_config.write_text('output * mode 1920x1080\n')
        veldora_parent = subprocess.Popen([str(veldora_tools/'bin/sway'),'--unsupported-gpu','-c',str(veldora_parent_config)],env=veldora_parent_env,stdout=veldora_log,stderr=subprocess.STDOUT)
        veldora_children.append(veldora_parent)
        for _ in range(100):
            veldora_parent_sockets = [p for p in veldora_runtime.glob('wayland-*') if not p.name.endswith('.lock')]
            if veldora_parent_sockets: break
            if veldora_parent.poll() is not None: raise RuntimeError('Private Sway failed; see '+str(veldora_run))
            time.sleep(0.1)
        else: raise RuntimeError('Private Sway socket unavailable')
        veldora_env['WAYLAND_DISPLAY'] = veldora_parent_sockets[0].name
        veldora_parent_keyboard = subprocess.Popen(['wtype','-s','180000'],env=veldora_env,stdout=veldora_log,stderr=subprocess.STDOUT)
        veldora_children.append(veldora_parent_keyboard)
        time.sleep(0.3)
        veldora_env['LD_LIBRARY_PATH'] = str(VELDORA_REPO/'build/isolated-tools/aquamarine-build')
        veldora_compositor = subprocess.Popen(['Hyprland','-c',str(veldora_lua)],env=veldora_env,stdout=veldora_log,stderr=subprocess.STDOUT)
        veldora_children.append(veldora_compositor)
        for _ in range(100):
            veldora_sockets=list(veldora_runtime.glob('hypr/*/.socket.sock'))
            if veldora_sockets: break
            if veldora_compositor.poll() is not None: raise RuntimeError('Headless compositor exited; see '+str(veldora_run))
            time.sleep(0.1)
        else: raise RuntimeError('No isolated compositor socket')
        veldora_env['HYPRLAND_INSTANCE_SIGNATURE']=veldora_sockets[0].parent.name
        assert veldora_env['HYPRLAND_INSTANCE_SIGNATURE'] != os.environ.get('VELDORA_HOST_SIGNATURE')
        veldora_wayland = next(p for p in veldora_runtime.glob('wayland-*') if not p.name.endswith('.lock') and p not in veldora_parent_sockets)
        veldora_env['WAYLAND_DISPLAY']=veldora_wayland.name
        def veldora_cmd(*args):
            if args[0]=='wtype': args=(args[0],'-s','100',*args[1:],'-s','100')
            command_env=veldora_env.copy()
            return subprocess.check_output(args,env=command_env,text=True,stderr=subprocess.PIPE,timeout=15).strip()
        veldora_cmd('hyprctl','output','create','headless')
        for monitor in json.loads(veldora_cmd('hyprctl','monitors','-j')):
            if not monitor['name'].startswith('HEADLESS'):
                veldora_cmd('hyprctl','eval','hl.monitor({output='+json.dumps(monitor['name'])+',disabled=true})')
        time.sleep(0.2)
        veldora_keyboard = subprocess.Popen(['wtype','-s','180000'],env=veldora_env,stdout=veldora_shell_log,stderr=subprocess.STDOUT)
        veldora_children.append(veldora_keyboard)
        time.sleep(0.2)
        veldora_audio = subprocess.Popen(['pipewire','-c',str(VELDORA_REPO/'tests/veldora-pipewire.conf')],env=veldora_env,stdout=veldora_log,stderr=subprocess.STDOUT)
        veldora_children.append(veldora_audio)
        for _ in range(50):
            if (veldora_runtime/'pipewire-0').exists(): break
            time.sleep(0.1)
        veldora_cmd('pw-metadata','-n','default','0','default.audio.sink','{"name":"veldora-test-sink"}','Spa:String:JSON')
        veldora_shell = subprocess.Popen(['qs','-c','veldora','--no-color'],env=veldora_env,stdout=veldora_shell_log,stderr=subprocess.STDOUT)
        veldora_children.append(veldora_shell)
        for _ in range(70):
            try:
                json.loads(veldora_cmd('qs','ipc','-c','veldora','call','veldora','status'));break
            except (subprocess.CalledProcessError,ValueError):
                if veldora_shell.poll() is not None: raise RuntimeError('Shell failed; see '+str(veldora_run))
                time.sleep(0.1)
        else: raise RuntimeError('Shell IPC unavailable')
        print('ISOLATED_RUN='+str(veldora_run),flush=True)
        veldora_checks = []
        def check(name, condition):
            if not condition: raise AssertionError(name)
            veldora_checks.append(name); print('PASS: '+name,flush=True)
        def ipc(*args): return veldora_cmd('qs','ipc','-c','veldora','call','veldora',*args)
        def status(): return json.loads(ipc('status'))
        def key(name): veldora_cmd('wtype','-k',name); time.sleep(0.25)
        def capture(name):
            time.sleep(0.4); veldora_cmd('grim',str(veldora_run/('veldora-'+name+'.png')))
        def clients(): return json.loads(veldora_cmd('hyprctl','clients','-j'))
        def layers(): return [x['namespace'] for m in json.loads(veldora_cmd('hyprctl','layers','-j')).values() for level in m['levels'].values() for x in level]
        veldora_cmd('hyprctl','dismissnotify','-1')
        check('Shell maps bar and wallpaper without bottom dock', {'veldora-top','veldora-backdrop'}.issubset(layers()) and 'veldora-dock' not in layers())
        # These windows and synthetic input exist only in the private compositor.
        for cls,title in [('kitty','Veldora terminal one'),('kitty','Veldora terminal two'),('veldora-unlisted','Veldora unknown app')]:
            child = subprocess.Popen(['kitty','--class',cls,'--title',title,'-e','/bin/sh','-c','printf "Veldora isolated desktop test\\n"; sleep 180'],env=veldora_env,stdout=veldora_shell_log,stderr=subprocess.STDOUT)
            veldora_children.append(child)
            time.sleep(0.7)
        time.sleep(1)
        check('Running windows group and unknown apps remain accessible', any(a['id']=='kitty' and a['windows']==2 for a in status()['dockApps']) and any(a['id']=='window:veldora-unlisted' for a in status()['dockApps']))
        ipc('workspace','4'); time.sleep(0.3)
        key('Super_L'); time.sleep(0.5)
        check('Bare Windows/Super key opens overview through packaged wrapper', status()['overview'])
        capture('overview')
        initial_space=json.loads(veldora_cmd('hyprctl','activeworkspace','-j'))['id']
        key('Right'); key('Return')
        check('Overview arrows and Enter select workspace', json.loads(veldora_cmd('hyprctl','activeworkspace','-j'))['id']==initial_space+1 and not status()['overview'])
        ipc('overview'); time.sleep(0.25)
        veldora_cmd('wtype','Veldora terminal one'); capture('overview-search'); key('Return')
        check('Overview search focuses matching existing window', json.loads(veldora_cmd('hyprctl','activewindow','-j')).get('title')=='Veldora terminal one')
        ipc('overview'); time.sleep(0.2); key('Escape')
        check('Escape closes overview', not status()['overview'])
        ipc('island'); time.sleep(0.25)
        check('VelDock opens on Media', status()['page']=='Media' and status()['island']=='expanded')
        capture('island')
        for page in ['Audio','Events','Apps','Settings']:
            key('Right'); check('VelDock keyboard page '+page,status()['page']==page); capture('island-'+page.lower())
        for _ in range(16):
            key('Tab')
            if veldora_cmd('qs','ipc','-c','veldora','call','veldora-test-focus','label')=='Reduced motion': break
        else: raise AssertionError('Reduced motion unreachable by Tab')
        key('space')
        check('Reduced motion is keyboard accessible and persists',status()['reducedMotion'] and json.loads(veldora_settings.read_text())['reducedMotion'])
        key('Escape'); check('Escape collapses VelDock',status()['island']=='idle')
        veldora_cmd('notify-send','--app-name=Veldora-test','A quieter desktop','Events stay in VelDock after the popup expires.')
        time.sleep(0.3)
        check('Real D-Bus notification produces glance and history',status()['events']==1 and status()['island']=='glance' and 'veldora-notifications' in layers())
        capture('notification')
        time.sleep(5.2)
        check('Glance and popup expire, history remains',status()['island']=='idle' and status()['events']==1 and 'veldora-notifications' not in layers())
        ipc('privacy','true')
        check('Privacy clears history and sets privacy mode',status()['events']==0 and status()['privacy'])
        ipc('overview');check('Privacy blocks overview',not status()['overview'])
        veldora_cmd('notify-send','Private test','Must not be retained')
        time.sleep(0.2);check('Private notification is not retained',status()['events']==0)
        ipc('privacy','false');ipc('island');time.sleep(0.2)
        check('Privacy exit restores desktop',not status()['privacy'])
        ipc('controls');time.sleep(0.2);capture('controls')
        check('Control Center opens exclusively',status()['controls'] and status()['island']!='expanded')
        ipc('launcher');time.sleep(0.2)
        check('Launcher opens exclusively with real desktop entries',status()['launcher'] and not status()['controls'] and status()['applications']>0)
        key('Escape');check('Escape closes launcher',not status()['launcher'])
        ipc('close')
        media_state=veldora_run/'media-state.json'
        media=subprocess.Popen(['python',str(VELDORA_REPO/'tests/veldora_mpris_fixture.py'),str(media_state)],env=veldora_env,stdout=veldora_shell_log,stderr=subprocess.STDOUT)
        veldora_children.append(media);time.sleep(0.6)
        ipc('island');time.sleep(0.2)
        for _ in range(4):key('Left')
        for _ in range(16):
            key('Tab')
            if veldora_cmd('qs','ipc','-c','veldora','call','veldora-test-focus','label')=='Pause': break
        else: raise AssertionError('MPRIS Pause control unavailable')
        capture('island-media')
        key('space')
        check('MPRIS pause reaches private player',json.loads(media_state.read_text())['playing'] is False)
        key('Tab');key('space')
        check('MPRIS next reaches private player',json.loads(media_state.read_text())['track']==2)
        key('Escape')
        ipc('volume','0.45');time.sleep(0.3)
        print('AUDIO_STATUS='+ipc('status'),flush=True)
        (veldora_run/'pipewire-state.json').write_text(veldora_cmd('pw-dump'))
        check('Private null audio output responds',abs(status()['volume']-0.45)<0.02)
        ipc('volume','1.2');time.sleep(0.3)
        check('Shell volume caps at 100 percent',abs(status()['volume']-1)<0.01)
        ipc('volume','-0.5');time.sleep(0.3)
        check('Shell volume floors at zero',status()['volume']==0)
        ipc('workspace','4');time.sleep(0.2)
        # Verify responsive layout at a common laptop logical resolution.
        monitor=json.loads(veldora_cmd('hyprctl','monitors','-j'))[0]['name']
        veldora_cmd('hyprctl','eval','hl.monitor({output='+json.dumps(monitor)+',mode="1920x1080@60",position="auto",scale=1.5})')
        time.sleep(0.3);ipc('overview');capture('overview-scaled');ipc('close')
        check('Scaled output still maps overview', (veldora_run/'veldora-overview-scaled.png').is_file())
        print('SHELL_VERSION='+veldora_cmd('qs','--version'),flush=True)
        (veldora_run/'results.json').write_text(json.dumps({'checks':veldora_checks,'status':status(),'isoBoot':False},indent=2)+'\n')
        log=(veldora_run/'veldora-shell.log').read_text()
        check('No QML errors or binding warnings',not any(x in log for x in ['ReferenceError','TypeError','Binding loop','Unable to assign','Cannot assign','failed to load component']))
        print(log[-3000:],flush=True)
    finally:
        for veldora_child in reversed(veldora_children):
            if veldora_child.poll() is None:
                veldora_child.terminate()
                try: veldora_child.wait(timeout=5)
                except subprocess.TimeoutExpired: veldora_child.kill();veldora_child.wait()
        veldora_short.unlink();veldora_short_parent.rmdir()
        veldora_log.close();veldora_shell_log.close()
    return 0


if __name__=='__main__':
    raise SystemExit(veldora_main())
