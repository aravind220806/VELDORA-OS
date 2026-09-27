// Original Veldora UI event history. This is not an audit log or a trusted IPC API.
function veldoraNormalize(veldoraInput, veldoraNow) {
    const veldoraText = (v, n) => String(v === undefined || v === null ? "" : v).slice(0, n);
    const veldoraKind = ["notification", "media", "audio", "brightness", "system"].includes(veldoraInput.kind) ? veldoraInput.kind : "notification";
    const veldoraTtl = Number.isFinite(veldoraInput.ttl) ? Math.max(1000, Math.min(30000, veldoraInput.ttl)) : 5000;
    return {id:veldoraText(veldoraInput.id || veldoraNow,100), source:veldoraText(veldoraInput.source || "Desktop",80), kind:veldoraKind,
        title:veldoraText(veldoraInput.title,160), body:veldoraText(veldoraInput.body,1200), createdAt:veldoraNow, expiresAt:veldoraNow+veldoraTtl,
        progress:Number.isFinite(veldoraInput.progress) ? Math.max(0,Math.min(1,veldoraInput.progress)) : null,
        dedupeKey:veldoraText(veldoraInput.dedupeKey || veldoraInput.id || veldoraNow,120), trustLevel:"untrusted-application", actions:[]};
}
function veldoraInsert(veldoraHistory, veldoraEvent) {
    return [veldoraEvent].concat(veldoraHistory.filter(e => !(e.source === veldoraEvent.source && e.dedupeKey === veldoraEvent.dedupeKey))).slice(0,100);
}
function veldoraActive(veldoraHistory, veldoraNow, veldoraQuiet, veldoraPrivate, veldoraFullscreen) {
    if (veldoraQuiet || veldoraPrivate || veldoraFullscreen) return null;
    const veldoraPriority = {system:40,notification:30,audio:20,brightness:20,media:10};
    return veldoraHistory.filter(e => e.expiresAt > veldoraNow).sort((a,b) => veldoraPriority[b.kind]-veldoraPriority[a.kind] || b.createdAt-a.createdAt)[0] || null;
}
function veldoraRemove(veldoraHistory, veldoraId) { return veldoraHistory.filter(e => e.id !== String(veldoraId)); }
function veldoraRetained(veldoraHistory, veldoraNow) { return veldoraHistory.filter(e => veldoraNow-e.createdAt < 86400000); }
if (typeof module !== "undefined") module.exports = {veldoraNormalize,veldoraInsert,veldoraActive,veldoraRemove,veldoraRetained};
