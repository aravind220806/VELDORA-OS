<div align="center">

```

 _   _ _____ _    ______ ___________  ___    _____ _____ 
| | | |  ___| |   |  _  \  _  | ___ \/ _ \  |  _  /  ___|
| | | | |__ | |   | | | | | | | |_/ / /_\ \ | | | \ `--. 
| | | |  __|| |   | | | | | | |    /|  _  | | | | |`--. \
\ \_/ / |___| |___| |/ /\ \_/ / |\ \| | | | \ \_/ /\__/ /
 \___/\____/\_____/___/  \___/\_| \_\_| |_/  \___/\____/ 
                                                          
                     ___  ____ 
                    / _ \/ ___|
                   | | | \___ \
                   | |_| |___) |
                    \___/|____/ 

```

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=500&size=18&pause=800&color=39FF14&background=0D1117&center=true&vCenter=true&width=800&lines=root%40veldora%3A~%24+whoami;an+arch-based+os+for+developers+%26+cybersecurity+pros;root%40veldora%3A~%24+cat+status.txt;system+online.+sentinel+active.+ready." alt="Typing SVG" />

<br>

<img src="https://img.shields.io/badge/version-0.1--dev-39FF14?style=for-the-badge&labelColor=0D1117"/>
<img src="https://img.shields.io/badge/base-arch%20linux-39FF14?style=for-the-badge&labelColor=0D1117&logo=archlinux&logoColor=39FF14"/>
<img src="https://img.shields.io/badge/arch-x86__64-39FF14?style=for-the-badge&labelColor=0D1117"/>
<img src="https://img.shields.io/badge/status-in%20development-39FF14?style=for-the-badge&labelColor=0D1117"/>

<br><br>

<img src="https://img.shields.io/github/stars/aravind220806/VELDORA-OS?style=flat-square&color=39FF14&labelColor=0D1117"/>
<img src="https://img.shields.io/github/forks/aravind220806/VELDORA-OS?style=flat-square&color=39FF14&labelColor=0D1117"/>
<img src="https://img.shields.io/github/issues/aravind220806/VELDORA-OS?style=flat-square&color=39FF14&labelColor=0D1117"/>
<img src="https://img.shields.io/github/last-commit/aravind220806/VELDORA-OS?style=flat-square&color=39FF14&labelColor=0D1117"/>

</div>

<br>

```
root@veldora:~$ neofetch
```

```text
        /\          root@veldora
       /  \         ------------
      /    \        OS: Veldora OS x86_64
     /------\       Base: Arch Linux (rolling)
    /        \      DE: Hyprland (Wayland)
   /   ARCH   \     Shell: zsh
  /------------\    Companion: Sentinel [ACTIVE]
 /              \   Island: Veldora Island [ON]
/________________\  Theme: Terminal / Dark
                     Security: USBGuard, Sentinel, LUKS
                     Uptime: building since 2026
```

<br>

## 📑 `$ ls sections/`

<details>
<summary><code>$ cat toc.md</code></summary>

- [`about.txt`](#-cat-abouttxt)
- [`compare.sh`](#-veldora-os-vs-others)
- [`highlights.log`](#-highlightslog)
- [`desktop.conf`](#-desktopconf)
- [`island.service`](#-veldora-islandservice)
- [`performance.bench`](#-performancebench)
- [`security.audit`](#-securityaudit)
- [`sentinel.daemon`](#-sentineldaemon----your-companion)
- [`devtools.list`](#-devtoolslist)
- [`pentest.list`](#-pentestlist-optional)
- [`features/`](#-features)
- [`limitations.txt`](#-limitationstxt)
- [`pacman.sh`](#-pacmansh)
- [`requirements.spec`](#-requirementsspec)
- [`install.sh`](#-installsh)
- [`tree`](#-tree)
- [`roadmap.todo`](#-roadmaptodo)
- [`faq.md`](#-faqmd)
- [`contributing.md`](#-contributingmd)
- [`support.md`](#-supportmd)
- [`license.txt`](#-licensetxt)
- [`stars.graph`](#-starsgraph)
- [`credits.txt`](#-creditstxt)

</details>

<br>

## 📖 `$ cat about.txt`

```text
Veldora OS is a clean, lightweight, and performance-focused operating system
based on Arch Linux — built for developers, cybersecurity professionals,
ethical hackers, students, and Linux enthusiasts.

It delivers a beautiful terminal-first desktop experience while providing
powerful tools for development, cybersecurity, learning, and daily
productivity.
```

<br>

## 🆚 `$ ./compare.sh --distro=all`

```text
$ ./compare.sh --distro=all

FEATURE                          VELDORA OS   KALI   PARROT   BLACKARCH
------------------------------------------------------------------------
base                             arch         deb    deb      arch
desktop                          hyprland     multi  multi    minimal
sentinel companion (rules-ai)    [ x ]        [   ]  [   ]    [   ]
veldora island ui                [ x ]        [   ]  [   ]    [   ]
usb default-deny                 [ x ]        [   ]  [   ]    [   ]
offline voice interface          [ x ]        [   ]  [   ]    [   ]
face-aware lock (crowd-safe)     [ x ]        [   ]  [   ]    [   ]
themed gui installer             [ x ]        [ x ]  [ x ]    [   ]
ctf workflow tooling             [ x ]        [   ]  [   ]    [   ]
idle-performance-first design    [ x ]        [ ~ ]  [ ~ ]    [ ~ ]
------------------------------------------------------------------------
note: kali/parrot/blackarch remain mature, trusted distros.
      this reflects what's different about veldora's approach,
      not a claim it replaces them for every use case.
```

<br>

## ✨ `$ cat highlights.log`

```text
[OK] beautiful terminal-first desktop
[OK] lightweight & fast
[OK] security focused by default
[OK] developer ready out of the box
[OK] cybersecurity ready
[OK] rolling release
[OK] optimized performance
[OK] veldora island — dynamic status ui
[OK] sentinel — offline companion, zero ai in security path
```

<br>

## 🖥️ `$ desktop.conf`

```yaml
ui:            modern, terminal-inspired
theme:         dark
animations:    smooth
startup:       fast
layout:        clean
wallpapers:    curated
workflow:      responsive
```

<br>

## 🏝️ `$ veldora-island.service`

```text
$ systemctl status veldora-island

● veldora-island.service - Dynamic status island
   Loaded: enabled
   Active: active (running)

A pill-shaped, always-on-top status island at the top of the screen —
Veldora OS's take on the Dynamic Island concept, built natively into the
desktop shell (AGS/Astal) instead of bolted on as a widget.

  > notifications expand smoothly into the island, not stacked as popups
  > media controls, VPN/connection status, quick system indicators
  > sentinel status/alerts render directly here — idle pulse when normal,
    animated expansion when something needs attention
  > shrinks to a minimal pill when idle, expands only when relevant
  > click to expand into full detail without leaving your current window
```

<br>

## ⚡ `$ performance.bench`

```text
[BENCH] kernel config ............ optimized
[BENCH] ram usage ................ low
[BENCH] package manager .......... fast (pacman)
[BENCH] storage ................... ssd-optimized
[BENCH] kernel version ............ latest
[BENCH] update channel ............ stable rolling
```

<br>

## 🔐 `$ security.audit`

```text
[PASS] latest security updates
[PASS] secure repositories
[PASS] firewall ready
[PASS] privacy focused
[PASS] reliable package verification
```

<br>

## 🤖 `$ sentinel.daemon` — Your Companion

```

 ___ ___ _  _ _____ ___ _  _ ___ _    
/ __| __| \| |_   _|_ _| \| | __| |   
\__ \ _|| .` | | |  | || .` | _|| |__ 
|___/___|_|\_| |_| |___|_|\_|___|____|

```

<div align="center">

<img src="https://img.shields.io/badge/ai-rules--based%2C%20not%20llm-39FF14?style=for-the-badge&labelColor=0D1117"/>
<img src="https://img.shields.io/badge/runs-100%25%20offline-39FF14?style=for-the-badge&labelColor=0D1117"/>

</div>

```text
$ sentinel --status

[*] sentinel is watching. no ai/llm in any security decision.
[*] every check is deterministic: threshold -> check -> response.

  > health      cpu/gpu temp, battery, disk smart, ram/swap, failed services
  > intrusion   file integrity, malware heuristics, boot integrity checks,
                local evidence collection on detection
  > access      usb default-deny, camera locked to trusted processes
  > face-sentry optional webcam lock/unlock (howdy), crowd-false-lock-safe
  > voice/text  original persona, tiered confirmation on anything sensitive
  > lives in    veldora island — alerts surface at the top of your screen,
                never buried in a separate app
```

<br>

## 👨‍💻 `$ devtools.list`

<div align="center">

<img src="https://skillicons.dev/icons?i=git,python,rust,java,nodejs,docker,vscode&perline=7"/>

<br><br>

<img src="https://img.shields.io/badge/GCC-0D1117?style=flat-square&logo=gnu&logoColor=39FF14"/>
<img src="https://img.shields.io/badge/Clang-0D1117?style=flat-square&logo=llvm&logoColor=39FF14"/>

</div>

<br>

## 🛡️ `$ pentest.list --optional`

<div align="center">

![Nmap](https://img.shields.io/badge/-nmap-0D1117?style=flat-square&logo=nmap&logoColor=39FF14)
![Wireshark](https://img.shields.io/badge/-wireshark-0D1117?style=flat-square&logo=wireshark&logoColor=39FF14)
![Burp Suite](https://img.shields.io/badge/-burpsuite-0D1117?style=flat-square&logo=burpsuite&logoColor=39FF14)
![Metasploit](https://img.shields.io/badge/-metasploit-0D1117?style=flat-square&logo=metasploit&logoColor=39FF14)
![Aircrack--ng](https://img.shields.io/badge/-aircrack--ng-0D1117?style=flat-square&logo=linux&logoColor=39FF14)
![SQLMap](https://img.shields.io/badge/-sqlmap-0D1117?style=flat-square&logo=sqlite&logoColor=39FF14)
![Gobuster](https://img.shields.io/badge/-gobuster-0D1117?style=flat-square&logo=go&logoColor=39FF14)
![Hydra](https://img.shields.io/badge/-hydra-0D1117?style=flat-square&logo=hydra&logoColor=39FF14)
![Nikto](https://img.shields.io/badge/-nikto-0D1117?style=flat-square&logo=perl&logoColor=39FF14)
![John the Ripper](https://img.shields.io/badge/-john%20the%20ripper-0D1117?style=flat-square&logo=hackaday&logoColor=39FF14)

</div>

<br>

## 📦 `$ features/`

`$ ls -la features/` — full feature set, grouped by category. Click a section to `cd` into it.

<details>
<summary><code>installer/ & first-boot/</code></summary>
<br>

```text
> themed installer (gui/tui) — disk setup, luks encryption (optional
  recovery-key generation), btrfs subvolumes (@, @home, @snapshots)
> automatic hardware detection: cpu microcode, gpu driver stack
  (nvidia/amd/intel + hybrid switching), wireless chipset drivers
  (incl. monitor-mode), fan control, keyboard backlight, touchpad
  gestures, battery profiles — detected once at install, zero
  ongoing background cost
> package profile: full / minimal / custom
> bootloader choice (systemd-boot / grub / refind) with
  snapshot-aware boot entries
> custom boot splash — your logo, your accent color, choice of
  animation style
> login screen with matching theme, optional face-unlock at login
> one accent color, chosen once, flows through boot splash,
  bootloader, login, desktop shell, and sentinel's ui
```

</details>

<details>
<summary><code>veldora-island/ & shell/</code></summary>
<br>

```text
> dynamic island-style status pill for notifications, media,
  companion alerts
> themed top bar, sidebar, dock — categorized tool launcher
  (recon/web/pwn/forensics/wireless) instead of a flat app grid
> workspaces pre-bound to tool categories, scratchpad terminal
```

</details>

<details>
<summary><code>sentinel/ — health & threat-detection/</code></summary>
<br>

```text
> live system health monitoring — event-driven wherever possible,
  near-zero idle cost
> file integrity monitoring, malware heuristic scoring, boot
  integrity verification
> local flood/ddos defense (rate-limiting, temporary local ip
  banning), botnet-misuse detection
> ram-anomaly detection with safe remediation (one-click restart,
  never blind auto-kill)
> evidence collection + auto-generated incident report for
  cert-in/cybercrime.gov.in — local-only, never any action against
  a remote system
```

</details>

<details>
<summary><code>access-control/</code></summary>
<br>

```text
> usb: default-deny (usbguard) — new devices blocked until approved
> camera: locked to a whitelist of trusted apps, active-use indicator
> face-sentry (howdy, offline): auto-lock on unrecognized face,
  tuned against false locks in public spaces, password fallback
  always available
```

</details>

<details>
<summary><code>voice/ & text/</code></summary>
<br>

```text
> original tactical-radio-style persona, offline voice pipeline
  (wake word, stt, tts) — no cloud calls
> voice app-launching with fuzzy matching for imperfect speech
> tiered confirmation — everyday commands instant, high-risk
  actions need a verification step (defeats simple voice-replay)
> every voice command has a matching typed command
```

</details>

<details>
<summary><code>ctf/ & engagement/</code></summary>
<br>

```text
> auto flag-detector for common ctf flag formats, logged w/ context
> voice-started challenge timers, auto session notes, writeup
  skeleton on completion
> engagement profiles — one command swaps vpn, notes folder,
  workspace layout, network identity
> snapshot prompt before risky commands (dd, rm -rf, disk ops)
```

</details>

<details>
<summary><code>network/ & opsec/</code></summary>
<br>

```text
> mac address + hostname randomization on every connection
> tor toggle, vpn-chaining support, real kill switch (drop traffic
  on tunnel-down instead of leaking your real ip)
> dns leak protection, optional ram-only session mode, metadata
  stripping on export
> apparmor profiles by default, secure boot support, optional
  hardened browser profile
```

</details>

<details>
<summary><code>mascot/</code></summary>
<br>

```text
> original animated companion character reacting to system state —
  idle, alert, success, error, scanning — living in veldora island
```

</details>

<details>
<summary><code>backup/ sync/ updates/</code></summary>
<br>

```text
> scheduled btrfs snapshots w/ automatic cleanup
> encrypted config/dotfiles backup, one-command "clone this setup"
> self-hosted (never cloud) encrypted sync across your own machines
> staged updates — verified in a snapshot before becoming permanent
```

</details>

<details>
<summary><code>accessibility/ & qol/</code></summary>
<br>

```text
> quiet hours — alerts logged, not voiced, for focused work/recording
> screen-recording auto-blur for sensitive on-screen info
> session-length wellbeing nudges
```

</details>

<br>

## ⚠️ `$ cat limitations.txt`

```text
$ cat limitations.txt

veldora os is built to be honest about what it can and can't do —
no security product should overclaim.

[!] usb killer protection
    sentinel stops rogue-keyboard/rogue-storage attacks, but CANNOT
    stop a usb killer electrical/voltage attack — hardware problem,
    needs an optically isolated hub or port blocker

[!] attacker attribution
    incident reports include ip/whois lookups — identifies the
    NETWORK an attack came from, not necessarily the person. treat
    as an investigative lead, not confirmed identity

[!] face-unlock
    webcam-based (howdy) is more spoofable than dedicated depth
    sensors like face id. liveness checks reduce this but don't
    match depth-sensor security. password fallback always available

[!] no counter-attack capability, by design
    sentinel detects, blocks, and logs locally. it never scans,
    exploits, or acts against a remote attacker's system —
    unauthorized access-back is illegal even if attacked first

[!] no ai/llm in security decisions
    every health/security check is deterministic rule-based logic,
    intentionally — predictable and auditable, but won't
    "understand" novel attacks outside its rule set
```

<br>

## 📦 `$ pacman.sh`

```bash
# update the system
sudo pacman -Syu

# install a package
sudo pacman -S package-name
```

<br>

## 💻 `$ cat requirements.spec`

```text
             MINIMUM              RECOMMENDED
CPU          dual core            quad core
RAM          2 GB                 8 GB
STORAGE      20 GB                50 GB SSD
SYSTEM       64-bit               64-bit + modern gpu
```

<br>

## 📥 `$ ./install.sh`

```bash
#!/bin/bash
# veldora-os installer

1. download the veldora os iso
2. create a bootable usb
3. boot from usb
4. launch the installer
5. follow the installation wizard
6. reboot and enjoy veldora os
```

<br>

## 📂 `$ tree`

```text
VeldoraOS/
├── airootfs/
├── assets/
├── efiboot/
├── isolinux/
├── packages.x86_64
├── pacman.conf
├── profiledef.sh
└── README.md
```

<br>

## 🛣️ `$ cat roadmap.todo`

```text
[ ] custom branding
[ ] custom iso
[ ] custom wallpapers
[ ] boot splash
[ ] gui installer
[ ] veldora island (dynamic island-style ui)
[ ] sentinel companion (system health, security, voice)
[ ] veldora store
[ ] driver manager
[ ] snapshot utility
[ ] gaming edition
[ ] developer edition
[ ] cybersecurity edition
```

<br>

## ❓ `$ cat faq.md`

<details>
<summary><code>Q: is veldora os beginner friendly?</code></summary>
<br>

```
A: yes. designed to be easy to use while remaining powerful.
```
</details>

<details>
<summary><code>Q: is it based on arch linux?</code></summary>
<br>

```
A: yes.
```
</details>

<details>
<summary><code>Q: does it receive rolling updates?</code></summary>
<br>

```
A: yes.
```
</details>

<br>

## 🤝 `$ cat contributing.md`

```text
$ cat contributing.md

contributions are welcome — veldora os is built in the open.

  [bug]     open an issue with steps to reproduce, your hardware,
            and any relevant logs
  [feature] open a feature request issue before a large pr, so we
            can align on direction first
  [code]    fork -> feature branch -> pull request. smaller,
            focused prs are easier to review than one large one
  [docs]    doc fixes and clarifications always welcome, no issue
            needed for small typo/wording fixes

code of conduct: be respectful, be constructive, assume good faith.
harassment, discrimination, or personal attacks are not tolerated.
disagree with an idea, not with a person.
```

<br>

## 🤝 `$ cat support.md`

```text
found a bug or have a suggestion?
-> open an issue in the official repository.
```

<br>

---

## ⚖️ `$ cat license.txt --section=trademark`

```text
please respect the work behind veldora os.
```

**Veldora OS Branding**

The Veldora OS name, logo, artwork, wallpapers, icons, documentation, screenshots, and
official branding are the intellectual property of the **Veldora OS Project**. These original
assets are **not** released for unrestricted reuse.

<table>
<tr>
<td valign="top" width="50%">

```diff
- YOU MAY NOT
- copy/reuse the name for another os
- copy, imitate, or redistribute the logo
- remove copyright notices
- rebrand veldora os as your own project
- claim veldora os or its assets as your own work
- use veldora os branding without written permission
```

</td>
<td valign="top" width="50%">

```diff
+ YOU MAY
+ download official releases
+ report bugs
+ suggest improvements
+ share links to the official project
+ write articles/reviews with proper attribution
```

</td>
</tr>
</table>

**Third-Party Software**: Veldora OS includes software from many open-source projects. Each
third-party component remains licensed under its own license. This notice applies only to the
original Veldora OS branding, artwork, documentation, and other original project assets.

<br>

## 📜 `$ cat license.txt`

```text
original veldora os branding, artwork, documentation, and project
assets are © 2026 veldora os project. all rights reserved for the
veldora os name, logo, and branding.

third-party software included with veldora os remains subject to
its respective license.
```

<br>

## ⭐ `$ stars.graph`

<div align="center">

<a href="https://star-history.com/#aravind220806/VELDORA-OS&Date">
  <img src="https://api.star-history.com/svg?repos=aravind220806/VELDORA-OS&type=Date&theme=dark" width="70%"/>
</a>

</div>

<br>

## ❤️ `$ cat credits.txt`

```text
special thanks to:
  > arch linux
  > linux kernel developers
  > gnu project
  > open source community
  > everyone supporting veldora os
```

<br>

<div align="center">

```
root@veldora:~$ echo "Built with <3 by the Veldora OS Project"
Built with <3 by the Veldora OS Project

root@veldora:~$ _
```

**© 2026 Veldora OS Project**

</div>
