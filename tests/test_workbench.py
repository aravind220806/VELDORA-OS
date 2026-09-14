import hashlib
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'workbench'))
from core import TOOLS, create_engagement, find_tools, hash_evidence, launch, system_checks


class WorkbenchTests(unittest.TestCase):
    def test_search_and_category(self):
        self.assertEqual([t.name for t in find_tools('DNS', 'Network')], ['dig'])
        self.assertEqual(find_tools('DNS', 'Forensics'), [])
        self.assertEqual(find_tools('no-such-tool'), [])

    def test_private_workspace_and_no_overwrite(self):
        with tempfile.TemporaryDirectory() as root:
            path = create_engagement(root, 'lab-01', 'localhost only')
            self.assertEqual(path.stat().st_mode & 0o777, 0o700)
            self.assertEqual((path / 'engagement.json').stat().st_mode & 0o777, 0o600)
            self.assertIn('localhost only', (path / 'reports/report.md').read_text())
            with self.assertRaises(FileExistsError):
                create_engagement(root, 'lab-01', 'changed')
            self.assertIn('localhost only', (path / 'engagement.json').read_text())

    def test_reject_traversal_and_empty_scope(self):
        with tempfile.TemporaryDirectory() as root:
            for name in ('../escape', '/tmp/escape', '.', 'a/b', '$(id)', '-option', ''):
                with self.assertRaises(ValueError):
                    create_engagement(root, name, 'lab')
            with self.assertRaises(ValueError):
                create_engagement(root, 'lab', ' ')
            self.assertEqual(list(Path(root).iterdir()), [])

    def test_existing_symlink_not_followed(self):
        with tempfile.TemporaryDirectory() as root:
            outside = Path(root) / 'outside'
            outside.mkdir()
            (Path(root) / 'lab').symlink_to(outside)
            with self.assertRaises(FileExistsError):
                create_engagement(root, 'lab', 'lab')
            self.assertEqual(list(outside.iterdir()), [])

    def test_hash_stream_and_read_only(self):
        with tempfile.TemporaryDirectory() as root:
            path = Path(root) / 'evidence'
            content = b'veldora' * 300000
            path.write_bytes(content)
            self.assertEqual(hash_evidence(path), hashlib.sha256(content).hexdigest())
            self.assertEqual(path.read_bytes(), content)

    @patch('core.subprocess.Popen')
    @patch('core.shutil.which', return_value='/usr/bin/nmap')
    def test_launch_has_no_shell_or_target(self, which, popen):
        launch(TOOLS[0], '/tmp')
        args, kwargs = popen.call_args
        self.assertEqual(args[0][-2:], ['nmap', '--help'])
        self.assertNotIn('shell', kwargs)
        self.assertEqual(kwargs['cwd'], '/tmp')

    @patch('core.shutil.which', return_value=None)
    def test_missing_tool(self, which):
        with self.assertRaises(FileNotFoundError):
            launch(TOOLS[0])

    @patch('core.subprocess.run', side_effect=FileNotFoundError('missing'))
    def test_checks_degrade_without_utilities(self, run):
        result = system_checks()
        self.assertEqual(len(result), 4)
        self.assertTrue(all('Unavailable' in output for _, output in result))
