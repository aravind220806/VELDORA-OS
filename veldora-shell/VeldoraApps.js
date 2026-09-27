// Original desktop-entry matching. Unknown windows remain available in the dock.
function veldoraKey(value) { return String(value || "").toLowerCase().replace(/\.desktop$/, ""); }
function veldoraFind(veldoraApps, veldoraClass) {
    const veldoraNeedle = veldoraKey(veldoraClass);
    if (!veldoraNeedle) return null;
    return veldoraApps.find(a => veldoraKey(a.id) === veldoraNeedle || veldoraKey(a.startupClass) === veldoraNeedle)
        || veldoraApps.find(a => veldoraKey(a.id).split('.').pop() === veldoraNeedle) || null;
}
function veldoraGroup(veldoraApps, veldoraPins, veldoraWindows) {
    const veldoraResult = [];
    for (const veldoraId of veldoraPins) {
        const veldoraApp = veldoraApps.find(a => a.id === veldoraId);
        if (veldoraApp && !veldoraResult.some(a => a.id === veldoraId)) veldoraResult.push({id:veldoraId,name:veldoraApp.name,entry:veldoraApp,windows:[],pinned:true});
    }
    for (const veldoraWindow of veldoraWindows) {
        const veldoraClass = veldoraWindow.lastIpcObject.class || (veldoraWindow.wayland ? veldoraWindow.wayland.appId : "") || veldoraWindow.lastIpcObject.initialClass || "";
        const veldoraEntry = veldoraFind(veldoraApps, veldoraClass);
        const veldoraId = veldoraEntry ? veldoraEntry.id : "window:" + (veldoraClass || veldoraWindow.address);
        let veldoraGroup = veldoraResult.find(a => a.id === veldoraId);
        if (!veldoraGroup) { veldoraGroup={id:veldoraId,name:veldoraEntry ? veldoraEntry.name : veldoraClass || "Application",entry:veldoraEntry,windows:[],pinned:false}; veldoraResult.push(veldoraGroup); }
        veldoraGroup.windows.push(veldoraWindow);
    }
    return veldoraResult;
}
if (typeof module !== "undefined") module.exports = {veldoraKey,veldoraFind,veldoraGroup};
