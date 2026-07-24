<div align="center">

<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=0:1a1a2e,25:2D1B69,50:5B3E9A,75:2CB1FF,100:1a1a2e&height=220&section=header&text=VELDORA%20OS&fontSize=60&fontColor=2CB1FF&animation=fadeIn&fontAlignY=38&desc=Forged%20in%20the%20Storm&descAlignY=58&descAlign=50&descColor=7F5AF0"/>

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=20&pause=700&color=2CB1FF&vCenter=true&width=850&lines=root%40veldora%3A~%24+./awaken.sh;%5B*%5D+storm+detected...+summoning+kernel;%5B*%5D+sentinel+online.+wards+active.;%5B%2B%5D+veldora+os+has+awakened.;an+arch-based+os+for+developers+%26+cybersecurity+pros." alt="Typing SVG" />

<br>

<img src="https://img.shields.io/static/v1?label=version&message=0.1-dev&color=2CB1FF&style=flat-square&labelColor=1a1a2e"/>
<img src="https://img.shields.io/static/v1?label=base&message=Arch%20Linux&color=7F5AF0&style=flat-square&labelColor=1a1a2e"/>
<img src="https://img.shields.io/static/v1?label=arch&message=x86_64&color=2CB1FF&style=flat-square&labelColor=1a1a2e"/>
<img src="https://img.shields.io/static/v1?label=status&message=in%20development&color=7F5AF0&style=flat-square&labelColor=1a1a2e"/>

<br><br>

<img src="https://img.shields.io/github/stars/aravind220806/VELDORA-OS?style=flat-square&color=2CB1FF&labelColor=1a1a2e"/>
<img src="https://img.shields.io/github/forks/aravind220806/VELDORA-OS?style=flat-square&color=7F5AF0&labelColor=1a1a2e"/>
<img src="https://img.shields.io/github/issues/aravind220806/VELDORA-OS?style=flat-square&color=2CB1FF&labelColor=1a1a2e"/>
<img src="https://img.shields.io/github/last-commit/aravind220806/VELDORA-OS?style=flat-square&color=7F5AF0&labelColor=1a1a2e"/>

</div>

<br>

```
root@veldora:~$ neofetch
```

```text
        ⚡ /\ ⚡          root@veldora
         /  \            ------------
        / /\ \           OS: Veldora OS x86_64
       / /  \ \          Base: Arch Linux (rolling)
      /--STORM--\        DE: Hyprland (Wayland)
     /   DRAGON   \      Shell: zsh
    /--------------\     Companion: Sentinel [ACTIVE]
   /                \    Island: Veldora Island [ON]
  /__________________\   Theme: Storm / Dark-Violet
       ⚡        ⚡        Security: USBGuard, Sentinel, LUKS
                          Uptime: forged since 2026
```

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:1a1a2e,50:2CB1FF,100:1a1a2e&height=3&width=1000"/>

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
- [`stats.live`](#-statslive)
- [`stars.graph`](#-starsgraph)
- [`credits.txt`](#-creditstxt)

</details>

<br>

## 📖 `$ cat about.txt`

```text
Veldora OS is a clean, lightweight, and storm-fast operating system based on
Arch Linux — built for developers, cybersecurity professionals, ethical
hackers, students, and Linux enthusiasts.

Named for the storm — the OS aims to feel like one: fast to boot, sharp to
use, and quietly powerful underneath. It delivers a beautiful terminal-first
desktop experience while providing serious tools for development,
cybersecurity, learning, and daily productivity.
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
[OK] beautiful storm-dark, terminal-first desktop
[OK] lightweight & fast
[OK] security focused by default
[OK] developer ready out of the box
[OK] cybersecurity ready
[OK] rolling release
[OK] optimized performance
[OK] veldora island — dynamic status ui
[OK] sentinel — offline companion, zero ai in security path
```

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:1a1a2e,50:7F5AF0,100:1a1a2e&height=3&width=1000"/>

<br>

## 🖥️ `$ desktop.conf`

```yaml
ui:            terminal-inspired, storm-dark
theme:         violet / electric-blue on near-black
animations:    smooth
startup:       fast
layout:        clean
wallpapers:    curated (storm & lightning motifs)
workflow:      responsive
```

<br>

## 🏝️ `$ veldora-island.service`

```text
$ systemctl status veldora-island

● veldora-island.service - Dynamic status island
   Loaded: enabled
   Active: active (running) ⚡

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

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:1a1a2e,50:2CB1FF,100:1a1a2e&height=3&width=1000"/>

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
          ⚡
      .-'   '-.
     /  o   o   \
    |     ^      |     SENTINEL
     \   \_/    /      watching. always.
      '-.___.-'
        |   |
       ⚡     ⚡
```

<div align="center">

<img src="https://img.shields.io/static/v1?label=ai&message=rules-based%2C%20not%20llm&color=2CB1FF&style=flat-square&labelColor=1a1a2e"/>
<img src="https://img.shields.io/static/v1?label=runs&message=100%25%20offline&color=7F5AF0&style=flat-square&labelColor=1a1a2e"/>

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

<img src="https://img.shields.io/badge/GCC-1a1a2e?style=flat-square&logo=gnu&logoColor=2CB1FF"/>
<img src="https://img.shields.io/badge/Clang-1a1a2e?style=flat-square&logo=llvm&logoColor=2CB1FF"/>

</div>

<br>

## 🛡️ `$ pentest.list --optional`

<div align="center">

![Nmap](https://img.shields.io/static/v1?label=&message=Nmap&color=1a1a2e&style=flat-square&labelColor=1a1a2e)
![Wireshark](https://img.shields.io/static/v1?label=&message=Wireshark&color=1a1a2e&style=flat-square&labelColor=1a1a2e&logo=wireshark&logoColor=2CB1FF)
![Burp Suite](https://img.shields.io/static/v1?label=&message=Burp%20Suite&color=1a1a2e&style=flat-square&labelColor=1a1a2e)
![Metasploit](https://img.shields.io/static/v1?label=&message=Metasploit&color=1a1a2e&style=flat-square&labelColor=1a1a2e)
![Aircrack--ng](https://img.shields.io/static/v1?label=&message=Aircrack-ng&color=1a1a2e&style=flat-square&labelColor=1a1a2e)
![SQLMap](https://img.shields.io/static/v1?label=&message=SQLMap&color=1a1a2e&style=flat-square&labelColor=1a1a2e)
![Gobuster](https://img.shields.io/static/v1?label=&message=Gobuster&color=1a1a2e&style=flat-square&labelColor=1a1a2e&logo=go&logoColor=2CB1FF)
![Hydra](https://img.shields.io/static/v1?label=&message=Hydra&color=1a1a2e&style=flat-square&labelColor=1a1a2e)
![Nikto](https://img.shields.io/static/v1?label=&message=Nikto&color=1a1a2e&style=flat-square&labelColor=1a1a2e&logo=perl&logoColor=2CB1FF)
![John the Ripper](https://img.shields.io/static/v1?label=&message=John%20the%20Ripper&color=1a1a2e&style=flat-square&labelColor=1a1a2e)

</div>

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:1a1a2e,50:5B3E9A,100:1a1a2e&height=3&width=1000"/>

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
    sensors. liveness checks reduce this but don't match
    depth-sensor security. password fallback always available

[!] no counter-attack capability, by design
    sentinel detects, blocks, and logs locally. it never scans,
    exploits, or acts against a remote attacker's system —
    unauthorized access-back is illegal even if attacked first

[!] no ai/llm in security decisions
    every health/security check is deterministic rule-based logic,
    intentionally — predictable and auditable, but won't
    "understand" novel attacks outside its rule set
```

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:1a1a2e,50:2CB1FF,100:1a1a2e&height=3&width=1000"/>

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

<img src="https://capsule-render.vercel.app/api?type=rect&color=0:1a1a2e,50:7F5AF0,100:1a1a2e&height=3&width=1000"/>

<br>

## 📊 `$ stats.live`

<div align="center">

<img width="49%" src="https://github-readme-stats.vercel.app/api?username=aravind220806&show_icons=true&theme=tokyonight&hide_border=true&bg_color=1a1a2e&title_color=2CB1FF&icon_color=7F5AF0&text_color=c9d1d9"/>
<img width="49%" src="https://github-readme-stats.vercel.app/api/top-langs/?username=aravind220806&layout=compact&theme=tokyonight&hide_border=true&bg_color=1a1a2e&title_color=2CB1FF&text_color=c9d1d9"/>

<img width="65%" src="https://streak-stats.demolab.com?user=aravind220806&theme=tokyonight&hide_border=true&background=1a1a2e&stroke=2CB1FF&ring=7F5AF0&fire=2CB1FF&currStreakLabel=2CB1FF"/>

</div>

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

<img width="100%" src="https://capsule-render.vercel.app/api?type=waving&color=0:1a1a2e,25:2CB1FF,50:5B3E9A,75:2D1B69,100:1a1a2e&height=180&section=footer&animation=twinkling"/>

</div>
