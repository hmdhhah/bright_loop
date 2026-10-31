import pathlib
import subprocess
import sys
import unittest
sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from scheduler.config import poll_seconds

class SmokeTests(unittest.TestCase):
    def test_configuration(self):
        self.assertEqual(poll_seconds('30'), 30)
        for value in ('0', '-1', 'abc'):
            with self.assertRaises(ValueError):
                poll_seconds(value)

    def test_entrypoint_does_not_bill(self):
        result = subprocess.run([sys.executable, str(pathlib.Path(__file__).resolve().parents[1] / 'main.py')], capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('no billing operations performed', result.stdout)
