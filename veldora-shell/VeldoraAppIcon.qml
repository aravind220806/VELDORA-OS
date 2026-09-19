import QtQuick
VeldoraIcon {
    property string veldoraAppId: ""
    text: {
        const veldoraName = veldoraAppId.toLowerCase();
        if (/kitty|foot|terminal|konsole/.test(veldoraName)) return "terminal";
        if (/code|studio|editor|antigravity/.test(veldoraName)) return "code";
        if (/chrome|firefox|browser|chromium/.test(veldoraName)) return "language";
        if (/dolphin|file|nautilus|thunar/.test(veldoraName)) return "folder";
        if (/music|spotify|audio/.test(veldoraName)) return "music_note";
        if (/video|mpv|vlc/.test(veldoraName)) return "movie";
        if (/discord|telegram|signal|slack|chat/.test(veldoraName)) return "chat_bubble";
        if (/setting|control/.test(veldoraName)) return "tune";
        if (/photo|image|gimp/.test(veldoraName)) return "image";
        return "deployed_code";
    }
    color: VeldoraTokens.colors.text
}
