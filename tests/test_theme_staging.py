"""Ensure ISO generation cannot follow staged paths into another directory."""
import importlib.util
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('veldora_integrate', ROOT/'veldora-shell/veldora-integrate.py')
theme = importlib.util.module_from_spec(spec)
spec.loader.exec_module(theme)


class ThemeStagingTests(unittest.TestCase):
    def test_rejects_home_or_arbitrary_root(self):
        with self.assertRaises(ValueError):
            theme.veldora_generate(Path.home())

    def test_rejects_symlinked_root(self):
        with tempfile.TemporaryDirectory(dir=ROOT/'build') as run:
            run = Path(run)
            (run/'actual').mkdir()
            (run/'airootfs').symlink_to(run/'actual', target_is_directory=True)
            (run/'profiledef.sh').touch()
            with self.assertRaises(ValueError):
                theme.veldora_generate(run/'airootfs')

    def test_rejects_config_escape_without_writing_target(self):
        with tempfile.TemporaryDirectory(dir=ROOT/'build') as run:
            run = Path(run)
            (run/'profiledef.sh').touch()
            config = run/'airootfs/etc/skel/.config'
            config.mkdir(parents=True)
            outside = run/'outside'
            outside.mkdir()
            (config/'quickshell').symlink_to(outside, target_is_directory=True)
            with self.assertRaises(ValueError):
                theme.veldora_generate(run/'airootfs')
            self.assertEqual(list(outside.iterdir()), [])
