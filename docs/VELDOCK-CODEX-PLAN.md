# VELDORA OS â€” Obsidian Storm / VelDock implementation plan

Prepared for Aravind V â€¢ 14 September 2026

## 1. Product direction

Build an original, polished Arch/Hyprland cybersecurity desktop around **VelDock**, a compact top-center island that expands into contextual controls. Use end-4's existing Quickshell foundation and service integrations, with Veldora's own visual language and engagement workflow.

The reference image establishes a near-black desktop, dramatic central artwork, separated top pills, small workspace controls, and substantial empty space. Preserve this restraint. The unique identity comes from a storm/dragon motif, consistent motion, a distinctive island silhouette, and useful security workflows. The supplied artwork is visual reference; use original or redistribution-cleared artwork for shipped images.

Competitive objective: make common cybersecurity tasks faster, clearer, and more reliable. â€œBeat Kaliâ€ is a product ambition, not a verified claim. A theme cannot establish distribution maturity. Measure workflow time, tool compatibility, failure recovery, update quality, and hardware reliability before publishing comparisons.

Initial audience: students, CTF players, developers, and web-security learners. Expand to professional engagements, blue-team work, forensics, reverse engineering, and wireless labs after the foundations pass release gates.

## 2. Verified repository baseline

Inspected VELDORA commit `d8cfeed2b407117a8bf99858f9cf674698516bd3`.

| Existing source | What it establishes | Plan implication |
|---|---|---|
| `vendor/end4/UPSTREAM.md` | end-4 pinned to `97c5bc651f68092351b24aaa935af708b1e04514`; shapes submodule recorded | Preserve the pin; upgrades must be explicit and tested |
| `vendor/end4/dots/.config/quickshell/ii/` | Vendored Quickshell modules and desktop services | Extend existing services instead of implementing duplicates |
| `shell/end4/shell.qml` | Custom entry point loads `IllogicalImpulseFamily` | Keep one production shell architecture |
| `shell/end4/modules/ii/bar/VeldoraIsland.qml` | 30px pill, animated width, notification/media/OSD connections, five-second dismissal | A prototype exists; implement a proper event model and inline expansion |
| `shell/end4/modules/ii/bar/BarContent.qml` | Workspace and resource pills, center island, right status/tray | Evolve this composition; fix collisions and misleading status icons |
| `shell/end4-config.json` | Bottom dock disabled, AI policy disabled, wallpaper theming enabled | VelDock is the top island; retain no permanent bottom dock by default |
| `archiso-profile/airootfs/usr/local/bin/veldora-shell` | Default starts `qs -c ii`; `--legacy` starts GTK | README's GTK-first description is stale relative to startup code |
| `scripts/prepare-profile.sh` | Copies pinned upstream, then overlays Veldora modifications | Keep upstream and local customization separate |
| `workbench/core.py` | 20 tool definitions, engagement folders, evidence hashing, basic system checks | Extend real functionality; do not replace it with decorative dashboards |
| `docs/VALIDATION.md` | Records earlier GTK/headless checks; ISO/hardware checks remain unverified | Historical checks do not prove the current QML shell or ISO works |

The current island stores body/icon fields but renders only a title; clicks toggle upstream sidebars rather than expanding an inline card. `detailOpen` is not an implemented details surface. The bar's Bluetooth icon is static, and Wi-Fi enablement alone is not connection health. Correct these distinctions.

No code was executed to verify runtime, hardware, security protections, or an ISO during preparation of this plan. This document is an implementation specification.

## 3. Original visual system: Obsidian Storm

| Token | Default | Use |
|---|---|---|
| Canvas | `#07090D` | Wallpaper negative space |
| Surface | `#11151C` | Island and panels |
| Raised surface | `#1A202B` | Hover, cards, selection backgrounds |
| Primary text | `#E8EEF5` | Main labels |
| Secondary text | `#A4AFBE` | Metadata |
| Storm cyan | `#52D6E8` | Focus, selection, active progress |
| Violet | `#8E82F0` | Optional secondary accent, sparingly |
| Success | `#72D6A0` | Confirmed successful operations |
| Warning | `#F0BC67` | Action needed |
| Critical | `#F06A78` | Failed protections or critical errors |

Offer an optional **Ember** accent preset (`#E76D68`) inspired by the screenshot's red detail. Keep warning/error states distinguishable by labels and icons. Avoid red decoration that resembles a permanent alert.

Use Noto Sans for the shell, JetBrains Mono for commands and technical data, and one consistent icon family. Validate font/icon availability in the image. Body labels 13â€“14 logical pixels; metadata 12; panel headings 17â€“20. Use an 8px spacing rhythm, 1px restrained borders, 12px window corners, and 20â€“24px expanded panel corners. Verify text contrast against actual translucent backgrounds.

Top layout: left workspaces, center VelDock, right connectivity/audio/battery/privacy. Show advanced metrics on demand; do not recreate a wall of permanently updating numbers. Default workspace display uses occupied workspaces plus the current workspace, with an option for all ten.

Keep the center artwork unobstructed. Create a separate branding asset brief for an original abstract dragon/storm sigil; no borrowed character is required. Ship a static wallpaper first, with optional animation deferred. Theme foot, GTK, launcher, notifications, lock screen, and settings from shared tokens. Keep wallpaper-derived color optional so arbitrary wallpapers cannot destroy the default identity.

Motion: 180â€“240ms expand/collapse, 120â€“160ms hover, no continuous glow or bouncing. Width/height changes must not jitter text. Reduced-motion mode removes morphing; battery mode reduces blur. High-contrast mode uses opaque surfaces.

## 4. VelDock behavior contract

Starting dimensions are logical pixels and must adapt to available screen geometry.

| State | Approximate size | Contents and behavior |
|---|---|---|
| Idle | 180â€“220 Ã— 34 | Small Veldora mark, time; optional active engagement indicator |
| Glance | 260â€“380 Ã— 44 | One event with icon, concise text, optional progress |
| Expanded | 420â€“480 Ã— 240â€“420 | Context card, details, actions, recent events; scroll when necessary |
| Launcher | Same anchored panel, up to 520 high | Search applications/tools, favorites, recent tools |
| Attention | Glance plus persistent badge | Trustworthy critical event; detail on explicit interaction |

Clamp dimensions to the monitor work area and available width between side pills. Collapse optional side content before allowing overlap. For narrow screens, show a compact icon/time trigger and open a bounded panel. Support 1366Ã—768, 1920Ã—1080, ultrawide, and 125â€“200% scaling.

### Input and window behavior

- Left-click or `Super+I`: expand/collapse the island itself. Escape returns focus to the previously focused application.
- Hover: tooltip only; never grab keyboard focus. An event must not interrupt terminal typing.
- Tabs and arrow keys navigate controls; Enter activates. Provide visible focus and meaningful accessible names; verify accessibility with the actual runtime.
- `Super+Space`: preserve application search. `Super+S`: preserve Workbench. Optional additional shortcuts must be checked for existing conflicts.
- User-opened details remain open until dismissed; transient timers must not close a panel being read.
- Keep the reserved top strip stable. Render expanded content in an anchored layer surface with correct input regions; transparent areas must not block application clicks.
- Default to a single primary-monitor island. Secondary monitors get minimal bars; an optional follow-focus mode moves the island without replaying events.
- Fullscreen: hide routine overlays. Lock screen: suppress message contents, engagement names, targets, and sensitive notifications. On unlock, show counts before revealing details.

### Event model and arbitration

Create a typed internal event model: `id`, `source`, `kind`, `severity`, `createdAt`, `expiresAt`, `title`, `body`, `progress`, `actions`, `sensitive`, `dedupeKey`, and `trustLevel`. Separate event history, active transient event, user-selected card, and service health.

Priority: trusted protection failures > action-required system events > user job completion > ordinary notifications > media changes > idle. DND suppresses routine popups; trusted critical items may leave a passive indicator without forcing focus. Coalesce volume changes and notification replacements; bound the queue to 100 items and expire stale events. Distinguish transient UI expiry from persistent audit retention.

Render untrusted content as plain text; limit field lengths and sanitize links. Desktop applications can imitate names and icons, so ordinary notifications must never gain Sentinel trust or security-action buttons. Privileged actions resolve through authenticated service APIs, never notification-provided shell strings.

### Context cards in implementation order

1. Media: metadata, cover fallback, play/pause/next, real MPRIS state.
2. Audio/brightness: live values, mute state, disabled controls if hardware is absent.
3. Notifications: replacement/close semantics, history, DND, clear privacy controls.
4. Connectivity: actual connection state, VPN connection name, reconnect/status links. â€œConnectedâ€ does not mean â€œleak-proof.â€
5. Engagement: name, elapsed timer, workspace switch, open notes, evidence action.
6. Jobs: real queued/running/completed/failed/cancelled states, logs and elapsed time. Use indeterminate progress when tools cannot report a trustworthy percentage.
7. Sentinel: explainable local findings with source, time, evidence, and remediation. Display unavailable/unknown states explicitly.

## 5. Architecture and integration boundaries

Keep **Hyprland + Quickshell/QML** for the desktop. Reuse pinned end-4 services for MPRIS, audio, battery, notifications, network, tray, and app search after checking their actual APIs. Do not add AGS, Electron, or another notification daemon to the default session.

Retain Python for Workbench domain operations. Add a small unprivileged service interface for engagement/job events when required. Use D-Bus for desktop integration; version the API and validate types. Keep the current GTK Workbench usable while a QML presentation layer is introduced incrementally. Do not port working domain logic solely for visual consistency.

Introduce Rust only for a later long-lived Sentinel service where its reliability and privilege boundary justify the maintenance cost. Security services run separately from the shell. Use narrowly scoped system services and OS-backed authorization for privileged operations. A cosmetic confirmation dialog or voice phrase is not authentication.

Use event signals for updates. Sensors may use low-frequency, adaptive polling; avoid subprocesses on each frame. A local SQLite store may hold bounded event/job metadata; engagement evidence remains in explicit user folders. Logs are not magically tamper-proof against the account or root that owns them.

Suggested new files, adjusted to the pinned upstream's conventions:

| Path | Responsibility |
|---|---|
| `shell/end4/modules/veldora/theme/` | Theme tokens and reusable controls |
| `shell/end4/modules/veldora/veldock/` | State controller, island surface, cards, event queue |
| `shell/end4/modules/veldora/services/` | Veldora adapters and trusted service bridge |
| `workbench/` | Existing core plus engagement persistence and job lifecycle |
| `companion/` | Later Sentinel services, separate privilege boundaries |
| `docs/architecture/` | Shell choice, event contract, security model, upstream process |
| `tests/` | State, IPC, input, integration, and boot regression checks |

Keep `VeldoraIsland.qml` as a compatibility wrapper while moving behavior into components. Modify `BarContent.qml` to consume shared tokens and real service states. Update `veldora-shell --toggle` to open VelDock rather than the generic sidebar. Avoid editing vendored files when an overlay can express the change. Retain upstream notices and record changes; resolve licensing for original code/assets before distribution.

## 6. Cybersecurity product features

| Audience | Useful workflow | Priority |
|---|---|---|
| Learner / CTF player | Guided tool search, local lab profiles, timer, notes, writeup skeleton | First release |
| Web-security practitioner | Engagement scope, browser/proxy workspace, VPN status, captured evidence | First release |
| Developer | Terminal/editor/browser layout, project launch, explicit repository checks | First release |
| Blue team | Local posture checks, service failures, readable event timeline | Following release |
| Forensics / reversing | Evidence manifests, hashes, tool bundles, disposable analysis VMs | Following release |
| Wireless practitioner | Adapter capability checks and separately installed wireless bundle | After hardware validation |

**Tool Center:** extend the existing catalog with executable detection, installed version, source/package, launch mode, docs, dependencies and missing-tool guidance. Verify package names in the target repositories. Initial categories: network, web, CTF, forensics, reversing, passwords, wireless, defensive tools. Offer optional bundles; show size and changes before package operations. Do not enable a large third-party repository silently or mix incompatible distribution package sources.

**Engagement Profiles:** preserve current private folder behavior. Store scope, notes, captures, evidence, reports, environment requirements and a workspace layout. Profile switching must be transactional: if a VPN or lab fails, show the partial state and undo or retain explicitly; never pretend activation succeeded. Scope notes organize work but do not by themselves enforce network boundaries.

**Lab isolation:** prefer VMs for untrusted malware/kernel-level experiments. Rootless containers can support selected reproducible user-space tools but are not equivalent isolation. Default vulnerable lab networks to isolated/host-only connectivity. Expose start, stop, reset, resource usage and cleanup. Make hardware passthrough and its limitations explicit.

**Evidence workflow:** keep SHA-256 hashing, add provenance/time/tool-version metadata and a manifest, preserve originals, and export report skeletons. Hashes demonstrate byte consistency, not authenticity or a complete chain of custody. Allow users to redact sensitive content before export.

**Sentinel progression:** start with observation of failed services, storage pressure, network listeners and firewall state. Add tested USBGuard integration and targeted integrity checks later. Display enabled, disabled, unsupported, unknown and failed as distinct states. Defer voice control, face recognition, broad intrusion-detection claims and autonomous remediation until a reviewed threat model and recovery tests exist. No LLM is required in the security decision path.

**Privacy:** make clipboard history opt-in or clearly disclosed during first run, with pause/clear and expiry. Current compositor startup launches cliphist unconditionally; review that default. Never claim all passwords can be detected automatically. Keep cloud/AI integrations disabled unless explicitly enabled. VPN kill-switch claims require routing, IPv4/IPv6, DNS, reconnect and suspend tests; cosmetic toggles are insufficient.

## 7. Implementation phases and completion gates

### Phase 0 â€” Establish a reproducible baseline

Audit startup, copied dependency trees, config schema, packages, licensing records and test scope. Reconcile README with QML startup; label legacy GTK tests. Record exact versions and upstream hash. Run existing static/unit checks where supported and capture an actual current QML session. Confirm notification ownership and a working fallback session.

Done: fresh profile preparation succeeds, pinned dependencies are accounted for, current shell starts or its specific blockers are documented, and no future feature is described as shipped.

### Phase 1 â€” Theme and geometry

Implement shared tokens, Obsidian/Ember presets, top-pill layout, truthful status indicators, and basic accessibility. Apply consistent styling to shell/terminal/launcher/lock surface. Preserve configurable wallpaper and avoid modifying host dotfiles during development.

Done: screenshots at target resolutions/scales show no collisions, clipping or unreadable text; keyboard focus and reduced motion work.

### Phase 2 â€” Production VelDock

Implement event queue and state model, inline expansion, focus restoration, bounded input regions, media/OSD/notification cards, monitor handling and fullscreen behavior. Make the old toggle command compatible.

Done: rapid notifications, long text, missing artwork, unavailable devices and player changes work without exceptions; transient events never steal input; only the intended surface receives clicks.

### Phase 3 â€” Workbench integration

Add the tool catalog presentation, engagement selector/timer, typed job lifecycle and evidence actions. Keep existing core behavior and permissions. Restrict process launch to validated argv; never interpolate scope or filenames into shell commands. Cancellation must target only the managed job/process group. Limit concurrency and bound log storage.

Done: create/reopen an engagement, launch a real tool, report its actual exit status, cancel a managed job, hash an artifact, and export a report. No fabricated progress, scan results or system-health scores.

### Phase 4 â€” Defensive services and labs

Introduce read-only Sentinel findings, failure/reconnect handling, isolated lab lifecycle and a reviewed privileged API. Add enforcement only with tests and a recovery mechanism. A disconnected observer must show â€œunavailable,â€ never an all-clear badge.

Done: a simulated service failure produces an explained event; notification spoofing cannot invoke trusted actions; service downtime does not crash the desktop; lab traffic isolation is verified.

### Phase 5 â€” Distribution release engineering

Build the ISO and test BIOS/UEFI, networking, sound, suspend/resume and recovery. Verify Intel/AMD/NVIDIA and hybrid graphics on named hardware. Keep live-session credentials/passwordless sudo out of any installed-system configuration. A disk installer is a separate milestone requiring VM disk-layout and recovery testing, not a theme deliverable.

Record package versions, artifact checksums, build inputs and release notes. Stage updates before stable promotion. Publish source/license notices and distinguish reproducible input tracking from demonstrated bit-for-bit builds. Secure Boot remains unsupported until a signed boot chain is actually implemented and tested.

Done: published claims match the tested matrix; a clean VM boots the image; upgrades and fallback startup succeed; unresolved blockers are visible.

## 8. Performance and verification

Targets below are provisional engineering budgets, not measured results. Baseline on an i5 13th-gen / 16GB / RTX 2050 hybrid laptop, and also an integrated-GPU system. Keep the discrete GPU asleep when possible; no always-on AI, video wallpaper or sensor dashboard.

| Metric | Initial target | Measurement |
|---|---|---|
| Idle shell CPU | Below 1% of one logical CPU averaged over 5 minutes | Settled desktop, fixed services, document tool convention |
| Shell memory | At or below 300MiB PSS | Include Quickshell and its helper processes; exclude compositor and user apps |
| Input to first visible feedback | p95 below 100ms | Timestamp interaction and first rendered response |
| Expand/collapse animation | Consistent 60fps on target hardware | Frame-time capture; reduce effects if needed |
| Session stability | No crash in an 8-hour mixed-use run | Notifications, suspend, device changes and media |
| Event flood | 100 events in 10 seconds without unbounded growth | Verify dedupe, expiry, capped history and responsiveness |

If a target is missed, profile before rewriting. Report observed results instead of changing targets to imply success.

Test priority: state transitions and replacement IDs; trusted/untrusted event separation; malformed IPC; engagement traversal/symlink protection; managed-job cancellation; notification-owner conflicts; monitor hotplug; keyboard-only interaction; lock privacy; missing services; profile staging; boot smoke tests. Retain useful existing tests, updating expectations only when the intended behavior changes. The previous layout test expects no dock and a very narrow idle pill; update it to distinguish the new top VelDock from a bottom application dock.

Competitive validation: run the same explicitly versioned workflow on Veldora and a specified Kali image on comparable hardware: boot to usable desktop, establish a lab, find/launch a tool, switch engagement, capture evidence, export a report and recover from failure. Record task completion, elapsed time, failures, resource use and tool version compatibility. Do not publish blanket superiority claims from screenshots or a single benchmark.

## 9. Codex execution prompt

Copy this into Codex with this document present in the repository:

> Work in aravind220806/VELDORA-OS. Read AGENTS.md if present and docs/VELDOCK-CODEX-PLAN.md. Implement the Obsidian Storm desktop and VelDock in the existing pinned end-4 Quickshell integration. Start by checking the current repository state and validating the actual startup path; the README may describe older GTK behavior. Preserve user changes and inspect the upstream APIs before coding.
>
> Deliver phases 0â€“2 first as a coherent, working desktop increment. Use shared theme tokens, original Veldora styling, an explicit island state/event model, real media/audio/notification integration, responsive monitor geometry, keyboard navigation, focus restoration and reduced motion. Keep normal events from stealing focus. Keep the bottom dock disabled by default. Make Super+I and veldora-shell --toggle expand VelDock itself. Reuse existing services and retain the legacy shell as an explicit fallback until the QML replacement is verified.
>
> Use the reference's dark negative space and separated top pills. Default to graphite and restrained cyan; provide the Ember preset. Do not ship unlicensed reference artwork. Avoid decorative fake telemetry, hard-coded connected/protected states and simulated scan results.
>
> Keep local changes in shell/end4 overlays, preserve upstream notices and pins, and update profile preparation where needed. Do not run upstream setup over the host configuration. Build and preview in an isolated session or staging directory. Run existing relevant checks and add meaningful state/input/integration tests. Capture actual screenshots at 1366Ã—768 and 1920Ã—1080 plus fractional scaling if the runtime supports it. Document checks that require unavailable hardware instead of claiming success.
>
> Update the implementation status and validation record. Report changed files, observed behavior, test results and unresolved limitations. Do not claim an ISO was boot-tested unless it was. After the desktop increment, proceed through Workbench, defensive services and release engineering in the documented order when those phases are requested. Treat disk installation and privileged system changes as explicit operations with a reviewed recovery path.

## 10. Sources

- [VELDORA-OS repository](https://github.com/aravind220806/VELDORA-OS), local checkout at the commit recorded above.
- [Veldora pinned upstream record](https://github.com/aravind220806/VELDORA-OS/blob/d8cfeed2b407117a8bf99858f9cf674698516bd3/vendor/end4/UPSTREAM.md).
- [Current island implementation](https://github.com/aravind220806/VELDORA-OS/blob/d8cfeed2b407117a8bf99858f9cf674698516bd3/shell/end4/modules/ii/bar/VeldoraIsland.qml).
- [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland), repository metadata and root tree checked through GitHub; implementation details inspected from the vendored pinned source.

All dimensions, budgets, roadmap features and architecture changes beyond the baseline are proposals, not claims about upstream capabilities or shipped Veldora features.
