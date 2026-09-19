#!/usr/bin/env python3
"""Stage Veldora in an Archiso root. Never access or configure the host desktop."""
import argparse
import configparser
import io
import json
from pathlib import Path
import shutil

VELDORA_SOURCE = Path(__file__).resolve().parent


def veldora_ini(veldora_sections):
    veldora_config = configparser.ConfigParser(interpolation=None)
    veldora_config.optionxform = str
    veldora_config.read_dict(veldora_sections)
    veldora_buffer = io.StringIO()
    veldora_config.write(veldora_buffer)
    return veldora_buffer.getvalue()


def veldora_generate(veldora_root):
    veldora_root = Path(veldora_root).resolve()
    if veldora_root.name != 'airootfs' or not (veldora_root.parent/'profiledef.sh').is_file():
        raise ValueError('Destination must be a prepared Archiso profile/airootfs directory.')
    if veldora_root.is_symlink():
        raise ValueError('The staged root must not be a symlink.')
    veldora_manifest = []

    def veldora_write(veldora_relative, veldora_content):
        veldora_path = veldora_root/veldora_relative
        if not veldora_path.resolve().is_relative_to(veldora_root):
            raise ValueError('A staged path escapes the ISO root: ' + str(veldora_path))
        veldora_path.parent.mkdir(parents=True, exist_ok=True)
        veldora_path.write_text(veldora_content)
        veldora_manifest.append('/' + veldora_relative)

    veldora_t = json.loads((VELDORA_SOURCE/'veldora-tokens.json').read_text())
    veldora_c = veldora_t['colors']
    veldora_r = veldora_t['radius']
    veldora_config = 'etc/skel/.config/'
    veldora_shell = veldora_config + 'quickshell/veldora/'
    (veldora_root/veldora_shell).mkdir(parents=True, exist_ok=True)
    for veldora_file in sorted(VELDORA_SOURCE.glob('Veldora*.qml')):
        veldora_write(veldora_shell + veldora_file.name, veldora_file.read_text())
    for veldora_name in ['qmldir', 'veldora-entry.qml', 'veldora-hardware.py', 'veldora-tokens.json', 'veldora-settings.json']:
        veldora_write(veldora_shell + veldora_name, (VELDORA_SOURCE/veldora_name).read_text())
    veldora_write(veldora_shell + 'shell.qml', (VELDORA_SOURCE/'veldora-entry.qml').read_text())
    # Original scale geometry; the rendering opacity comes from the shared tokens.
    veldora_svg = (VELDORA_SOURCE/'veldora-scales.svg').read_text()
    import re
    veldora_svg = re.sub(r'stroke="#[0-9A-Fa-f]{6}"', 'stroke="'+veldora_c['text']+'"', veldora_svg)
    veldora_write(veldora_shell + 'veldora-scales.svg', veldora_svg)
    veldora_accent = veldora_c['accent']
    veldora_border = veldora_accent[1:] + format(round(veldora_t['effects']['activeBorderOpacity']*255),'02x')
    veldora_shadow = veldora_t['shadow']['color'][1:] + format(round(veldora_t['shadow']['opacity']*255),'02x')
    veldora_write(veldora_config+'hypr/veldora-theme.lua', f'''-- Generated from veldora-tokens.json, inside the ISO only.
hl.env("XCURSOR_THEME", "{veldora_t['cursor']}")
hl.env("XCURSOR_SIZE", "{veldora_t['sizes']['cursor']}")
hl.config({{
    general = {{ gaps_in = {veldora_t['spacing']['xs']}, gaps_out = {veldora_t['spacing']['sm']}, border_size = 1,
        col = {{ active_border = "rgba({veldora_border})", inactive_border = "rgba(00000000)" }} }},
    decoration = {{ rounding = {veldora_r['window']}, rounding_power = 2,
        blur = {{ enabled = true, size = 6, passes = 3 }},
        shadow = {{ enabled = true, range = {veldora_t['shadow']['blur']}, offset = {{0, {veldora_t['shadow']['offsetY']}}}, color = "rgba({veldora_shadow})" }} }}
}})
hl.curve("veldora-soft", {{ type = "bezier", points = {{ {{0.175, 0.885}}, {{0.32, 1.275}} }} }})
for _, veldora_leaf in ipairs({{"windows", "layers", "workspaces", "fade"}}) do
    hl.animation({{ leaf = veldora_leaf, enabled = true, speed = {veldora_t['animation']['duration']/100}, bezier = "veldora-soft" }})
end
hl.layer_rule({{ match = {{ namespace = "^veldora-(top|dock|controls|notifications|osd|launcher)$" }}, blur = true, ignore_alpha = 0.5, no_anim = true }})
''')
    veldora_css = '/* Generated from veldora-tokens.json for the ISO. */\n'
    for veldora_name, veldora_color in {
        'accent_color':veldora_accent, 'accent_bg_color':veldora_accent, 'accent_fg_color':veldora_c['background'],
        'window_bg_color':veldora_c['background'], 'window_fg_color':veldora_c['text'],
        'view_bg_color':veldora_c['surface'], 'view_fg_color':veldora_c['text'],
        'headerbar_bg_color':veldora_c['surfaceHigh'], 'headerbar_fg_color':veldora_c['text'],
        'card_bg_color':veldora_c['surfaceHigh'], 'card_fg_color':veldora_c['text'],
        'popover_bg_color':veldora_c['surfaceHigh'], 'popover_fg_color':veldora_c['text'],
        'sidebar_bg_color':veldora_c['surface'], 'sidebar_fg_color':veldora_c['text'],
        'destructive_color':veldora_c['danger'], 'theme_selected_bg_color':veldora_accent,
        'theme_selected_fg_color':veldora_c['background']}.items():
        veldora_css += f'@define-color {veldora_name} {veldora_color};\n'
    veldora_css += f'''window, window.background, decoration {{ border-radius: {veldora_r['window']}px; }}
button, entry, searchentry {{ border-radius: {veldora_r['pill']}px; }}
selection, button.suggested-action {{ background-color: @accent_bg_color; color: @accent_fg_color; }}
'''
    for veldora_gtk in ['gtk-3.0','gtk-4.0']:
        veldora_write(veldora_config+veldora_gtk+'/gtk.css', veldora_css)
        veldora_write(veldora_config+veldora_gtk+'/settings.ini', veldora_ini({'Settings':{
            'gtk-application-prefer-dark-theme':'1', 'gtk-theme-name':'Adwaita-dark',
            'gtk-font-name':veldora_t['font']['text']+' 10', 'gtk-cursor-theme-name':veldora_t['cursor'],
            'gtk-cursor-theme-size':str(veldora_t['sizes']['cursor'])}}))
    veldora_write(veldora_config+'kitty/kitty.conf', f'''# Generated from veldora-tokens.json.
font_family monospace
background {veldora_c['background']}
foreground {veldora_c['text']}
selection_background {veldora_accent}
selection_foreground {veldora_c['background']}
cursor {veldora_accent}
background_opacity {veldora_t['effects']['terminalOpacity']}
window_padding_width {veldora_t['sizes']['terminalPadding']}
window_margin_width 0
''')
    veldora_write(veldora_config+'foot/foot.ini', f'''# Generated from veldora-tokens.json.
[main]
pad={veldora_t['sizes']['terminalPadding']}x{veldora_t['sizes']['terminalPadding']}
[colors]
alpha={veldora_t['effects']['terminalOpacity']}
background={veldora_c['background'][1:]}
foreground={veldora_c['text'][1:]}
selection-background={veldora_accent[1:]}
selection-foreground={veldora_c['background'][1:]}
''')
    veldora_write(veldora_config+'fuzzel/fuzzel.ini', f'''# Generated from veldora-tokens.json.
[main]
font={veldora_t['font']['text']}:size=12
[colors]
background={veldora_c['background'][1:]}ee
text={veldora_c['text'][1:]}ff
selection={veldora_accent[1:]}ff
selection-text={veldora_c['background'][1:]}ff
border={veldora_accent[1:]}66
[border]
radius={veldora_r['card']}
width=1
''')
    veldora_write(veldora_config+'hypr/hyprlock.conf', f'''# Generated Veldora lock surface; authentication uses Hyprlock PAM.
background {{
    monitor =
    color = rgb({veldora_c['background'][1:]})
}}
input-field {{
    monitor =
    size = 280, 54
    rounding = {veldora_r['pill']}
    outline_thickness = 1
    outer_color = rgb({veldora_accent[1:]})
    inner_color = rgb({veldora_c['surfaceHigh'][1:]})
    font_color = rgb({veldora_c['text'][1:]})
    placeholder_text = Password
}}
''')
    def veldora_rgb(veldora_hex):
        return ','.join(str(int(veldora_hex[i:i+2],16)) for i in (1,3,5))
    veldora_sections = {'General':{'ColorScheme':'Veldora','Name':'Veldora','AccentColor':veldora_rgb(veldora_accent),'widgetStyle':'Breeze'}}
    for veldora_role in ['Window','View','Button','Tooltip','Complementary','Header','Selection']:
        veldora_sections['Colors:'+veldora_role] = {
            'BackgroundNormal':veldora_rgb(veldora_accent if veldora_role=='Selection' else veldora_c['surfaceHigh']),
            'BackgroundAlternate':veldora_rgb(veldora_c['background']),
            'ForegroundNormal':veldora_rgb(veldora_c['background'] if veldora_role=='Selection' else veldora_c['text']),
            'ForegroundInactive':veldora_rgb(veldora_c['textDim']),
            'ForegroundLink':veldora_rgb(veldora_accent), 'DecorationFocus':veldora_rgb(veldora_accent),
            'DecorationHover':veldora_rgb(veldora_accent)}
    veldora_palette = veldora_ini(veldora_sections)
    veldora_write(veldora_config+'kdeglobals', veldora_palette)
    veldora_write('usr/share/color-schemes/Veldora.colors', veldora_palette)
    veldora_wallpaper = veldora_root/'usr/share/veldora/theme/black-dragon.png'
    veldora_wallpaper.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(VELDORA_SOURCE.parent/'shell/theme/black-dragon.png', veldora_wallpaper)
    veldora_manifest.append('/usr/share/veldora/theme/black-dragon.png')
    veldora_write('usr/share/veldora/veldora-image-files.json', json.dumps(veldora_manifest,indent=2)+'\n')
    return veldora_manifest


if __name__ == '__main__':
    veldora_parser = argparse.ArgumentParser(description=__doc__)
    veldora_parser.add_argument('--root', required=True, type=Path, help='Prepared profile/airootfs staging directory')
    veldora_args = veldora_parser.parse_args()
    for veldora_path in veldora_generate(veldora_args.root):
        print(veldora_args.root/veldora_path.lstrip('/'))
