// SPDX-License-Identifier: GPL-3.0-or-later
// Pure event arbitration. This UI history is not a security audit log.
function text(value, limit) { return String(value === undefined || value === null ? "" : value).slice(0, limit); }
function normalize(input, now, trusted) {
    var kind = ["notification", "media", "audio", "brightness", "system", "job", "protection"].indexOf(input.kind) >= 0 ? input.kind : "notification";
    // Desktop notifications cannot assert a protection origin or trusted actions.
    if (!trusted && kind === "protection") kind = "notification";
    var severity = ["info", "warning", "critical"].indexOf(input.severity) >= 0 ? input.severity : "info";
    var ttl = Number(input.ttl);
    if (!isFinite(ttl)) ttl = 5000;
    ttl = Math.max(1000, Math.min(ttl, 30000));
    return {
        id: text(input.id || now, 100), source: text(input.source || "Desktop application", 80),
        kind: kind, severity: severity, createdAt: now, expiresAt: now + ttl,
        title: text(input.title, 160), body: text(input.body, 1200),
        progress: typeof input.progress === "number" && isFinite(input.progress) ? Math.max(0, Math.min(1, input.progress)) : null,
        actions: [], sensitive: input.sensitive !== false,
        dedupeKey: text(input.dedupeKey || input.id || now, 120),
        trustLevel: trusted ? "local-service" : "untrusted-application"
    };
}
function priority(event) {
    if (event.trustLevel === "local-service" && event.kind === "protection" && event.severity === "critical") return 60;
    if (event.trustLevel === "local-service" && event.kind === "system" && event.severity !== "info") return 50;
    if (event.kind === "job") return 40;
    if (event.kind === "notification") return 30;
    if (event.kind === "audio" || event.kind === "brightness") return 20;
    return 10;
}
function insert(history, event) {
    return [event].concat(history.filter(function(e) { return !(e.source === event.source && e.dedupeKey === event.dedupeKey); })).slice(0, 100);
}
function active(history, now, dnd, locked, fullscreen) {
    if (locked || fullscreen || dnd) return null;
    var live = history.filter(function(e) { return e.expiresAt > now; });
    live.sort(function(a, b) { return priority(b) - priority(a) || b.createdAt - a.createdAt; });
    return live[0] || null;
}
function passiveCritical(history, now) {
    return history.some(function(e) { return e.expiresAt > now && priority(e) === 60; });
}
function remove(history, id) { return history.filter(function(e) { return e.id !== String(id); }); }
function retained(history, now) { return history.filter(function(e) { return now - e.createdAt < 24 * 60 * 60 * 1000; }); }
if (typeof module !== "undefined") module.exports = {normalize, priority, insert, active, remove, retained, passiveCritical};
