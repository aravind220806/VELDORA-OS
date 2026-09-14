"""Local workbench operations. No shell evaluation or implicit privileged actions."""
from dataclasses import dataclass
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess


@dataclass(frozen=True)
class Tool:
    name: str
    category: str
    package: str
    argv: tuple[str, ...]
    description: str
    gui: bool = False


TOOLS = (
    Tool('Nmap', 'Network', 'nmap', ('nmap', '--help'), 'Host discovery and service assessment'),
    Tool('Wireshark', 'Network', 'wireshark-qt', ('wireshark',), 'Inspect packet captures visually', True),
    Tool('tcpdump', 'Network', 'tcpdump', ('tcpdump', '--help'), 'Capture and inspect network traffic'),
    Tool('dig', 'Network', 'bind', ('dig', '-h'), 'Investigate DNS records'),
    Tool('Whois', 'Network', 'whois', ('whois', '--help'), 'Registration and network ownership'),
    Tool('socat', 'Network', 'socat', ('socat', '-h'), 'Connect streams in a controlled lab'),
    Tool('SQLmap', 'Web', 'sqlmap', ('sqlmap', '-h'), 'Assess SQL injection in authorized applications'),
    Tool('Nikto', 'Web', 'nikto', ('nikto', '-Help'), 'Inspect web server configuration'),
    Tool('Aircrack-ng', 'Wireless', 'aircrack-ng', ('aircrack-ng', '--help'), 'Analyze wireless captures'),
    Tool('iw', 'Wireless', 'iw', ('iw', 'help'), 'Inspect wireless interfaces and capabilities'),
    Tool('Hashcat', 'Passwords', 'hashcat', ('hashcat', '--help'), 'Audit password hashes offline'),
    Tool('John the Ripper', 'Passwords', 'john', ('john', '--help'), 'Assess password strength offline'),
    Tool('Sleuth Kit', 'Forensics', 'sleuthkit', ('fls', '-V'), 'Examine filesystem evidence'),
    Tool('TestDisk', 'Forensics', 'testdisk', ('testdisk', '--help'), 'Filesystem and partition recovery'),
    Tool('Binwalk', 'Forensics', 'binwalk', ('binwalk', '--help'), 'Inspect firmware and embedded files'),
    Tool('YARA', 'Forensics', 'yara', ('yara', '--help'), 'Match files against detection rules'),
    Tool('GDB', 'Reverse engineering', 'gdb', ('gdb', '--help'), 'Debug native programs'),
    Tool('radare2', 'Reverse engineering', 'radare2', ('r2', '-h'), 'Disassemble and analyze binaries'),
    Tool('strace', 'Reverse engineering', 'strace', ('strace', '-h'), 'Trace process system calls'),
    Tool('ltrace', 'Reverse engineering', 'ltrace', ('ltrace', '--help'), 'Trace dynamic library calls'),
)


def find_tools(query='', category='All'):
    return [t for t in TOOLS if (category == 'All' or t.category == category)
            and query.casefold() in f'{t.name} {t.description} {t.category}'.casefold()]


def launch(tool, cwd=None):
    if tool not in TOOLS:
        raise ValueError('Unknown tool')
    if not shutil.which(tool.argv[0]):
        raise FileNotFoundError(f'{tool.name} is unavailable. Package: {tool.package}')
    argv = list(tool.argv) if tool.gui else ['foot', '--hold', '--title', tool.name, '--', *tool.argv]
    return subprocess.Popen(argv, cwd=cwd, start_new_session=True)


def create_engagement(root, name, scope):
    if not re.fullmatch(r'[a-zA-Z0-9][a-zA-Z0-9_-]{0,63}', name):
        raise ValueError('Use 1–64 letters, numbers, underscores or hyphens; start with a letter or number.')
    if not scope.strip():
        raise ValueError('Record the authorized scope before creating an engagement.')
    root = Path(root).expanduser()
    root.mkdir(parents=True, exist_ok=True, mode=0o700)
    path = root / name
    path.mkdir(mode=0o700)  # Never overwrite or follow an existing engagement.
    try:
        for folder in ('evidence', 'captures', 'notes', 'reports'):
            (path / folder).mkdir(mode=0o700)
        files = {
            'engagement.json': json.dumps({'name': name, 'scope': scope.strip(),
                'created': datetime.now(timezone.utc).isoformat(), 'version': 1}, indent=2) + '\n',
            'notes/README.md': '# Investigation notes\n\n## Timeline (UTC)\n\n## Observations\n\n',
            'reports/report.md': '# Assessment report\n\n## Scope\n\n' + scope.strip() +
                '\n\n## Executive summary\n\n## Methodology\n\n## Findings\n\n'
                '### Finding title\n\n- Severity:\n- Evidence:\n- Impact:\n- Remediation:\n\n## Limitations\n\n',
        }
        for name, content in files.items():
            with (path / name).open('x') as stream:
                os.fchmod(stream.fileno(), 0o600)
                stream.write(content)
    except Exception:
        shutil.rmtree(path)
        raise
    return path


def hash_evidence(path):
    """Stream large artifacts without loading them into memory; never modify input."""
    digest = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            digest.update(block)
    return digest.hexdigest()


def system_checks():
    checks = []
    for title, argv in (
        ('Failed system services', ['systemctl', '--failed', '--no-pager', '--plain']),
        ('Listening TCP / UDP sockets', ['ss', '-lntu']),
        ('Active network connections', ['nmcli', '-t', '-f', 'NAME,TYPE,DEVICE', 'connection', 'show', '--active']),
        ('Firewall service state (not a ruleset audit)', ['systemctl', 'is-active', 'nftables.service']),
    ):
        try:
            result = subprocess.run(argv, capture_output=True, text=True, timeout=8)
            output = (result.stdout + result.stderr).strip()
            checks.append((title, output or f'Exited with status {result.returncode}'))
        except (OSError, subprocess.TimeoutExpired) as error:
            checks.append((title, f'Unavailable: {error}'))
    return checks
