#!/usr/bin/env python3
"""Deterministic MPRIS service for the private desktop test bus, never the host."""
import json
import os
from pathlib import Path
import sys
from gi.repository import Gio, GLib

if os.environ.get('VELDORA_ISOLATED') != '1':
    raise SystemExit('This fixture requires the isolated test environment.')
output = Path(sys.argv[1])
state = {'playing': True, 'track': 1, 'calls': []}
root = 'org.mpris.MediaPlayer2'
player = root + '.Player'
props = {
    root: {'Identity': GLib.Variant('s','Veldora test player'), 'CanQuit':GLib.Variant('b',False),
           'CanRaise':GLib.Variant('b',False),'HasTrackList':GLib.Variant('b',False),
           'DesktopEntry':GLib.Variant('s','veldora-test-player'), 'SupportedUriSchemes':GLib.Variant('as',[]),'SupportedMimeTypes':GLib.Variant('as',[])},
    player: {'PlaybackStatus':GLib.Variant('s','Playing'),'Rate':GLib.Variant('d',1.0),
             'MinimumRate':GLib.Variant('d',1.0),'MaximumRate':GLib.Variant('d',1.0),
             'LoopStatus':GLib.Variant('s','None'),'Shuffle':GLib.Variant('b',False),'Volume':GLib.Variant('d',0.5),'Position':GLib.Variant('x',0),
             **{k:GLib.Variant('b',True) for k in ['CanControl','CanPlay','CanPause','CanGoNext','CanGoPrevious']},'CanSeek':GLib.Variant('b',False)}
}
def metadata():
    return GLib.Variant('a{sv}', {'mpris:trackid':GLib.Variant('o','/veldora/track/'+str(state['track'])),
        'xesam:title':GLib.Variant('s','Veldora test track '+str(state['track'])), 'xesam:artist':GLib.Variant('as',['Isolated media fixture'])})
props[player]['Metadata'] = metadata()
connection = Gio.bus_get_sync(Gio.BusType.SESSION, None)
def publish():
    props[player]['PlaybackStatus'] = GLib.Variant('s','Playing' if state['playing'] else 'Paused')
    props[player]['Metadata'] = metadata()
    output.write_text(json.dumps(state))
    connection.emit_signal(None,'/org/mpris/MediaPlayer2','org.freedesktop.DBus.Properties','PropertiesChanged',GLib.Variant('(sa{sv}as)',(player,props[player],[])))
def call(conn,sender,path,interface,method,parameters,invocation):
    state['calls'].append(method)
    if method=='PlayPause': state['playing']=not state['playing']
    elif method=='Play': state['playing']=True
    elif method in ['Pause','Stop']: state['playing']=False
    elif method=='Next': state['track']+=1
    elif method=='Previous': state['track']=max(1,state['track']-1)
    publish()
    invocation.return_value(None)
def get(conn,sender,path,interface,name): return props[interface].get(name)
xml='<node>'
for interface,values in props.items():
    xml+='<interface name="'+interface+'">'
    if interface==player:
        xml+=''.join('<method name="'+name+'"/>' for name in ['PlayPause','Play','Pause','Stop','Next','Previous'])
    xml+=''.join('<property name="'+name+'" type="'+v.get_type_string()+'" access="read"/>' for name,v in values.items())
    xml+='</interface>'
xml+='</node>'
info=Gio.DBusNodeInfo.new_for_xml(xml)
for interface in info.interfaces:
    connection.register_object('/org/mpris/MediaPlayer2',interface,call,get,None)
Gio.bus_own_name_on_connection(connection,root+'.veldora_test',Gio.BusNameOwnerFlags.NONE,None,None)
output.write_text(json.dumps(state))
GLib.MainLoop().run()
