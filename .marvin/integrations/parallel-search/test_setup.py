"""Run with python3 .marvin/integrations/parallel-search/test_setup.py."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).with_name("setup.sh")


class SetupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.log = self.root / "calls.jsonl"
        cli = self.root / "claude"
        cli.write_text(f"#!{sys.executable}\n" + '''
import json, os, sys
with open(os.environ["CALL_LOG"], "a") as log:
    log.write(json.dumps(sys.argv[1:]) + "\\n")
if sys.argv[1:3] == ["mcp", "get"]:
    sys.exit(0 if os.environ.get("EXISTING") == "1" else 1)
if sys.argv[1:3] == ["mcp", "add"]:
    sys.exit(int(os.environ.get("ADD_EXIT", "0")))
''')
        cli.chmod(0o755)

    def run_setup(self, answers, **settings):
        env = {**os.environ, "PATH": str(self.root),
               "CALL_LOG": str(self.log), **settings}
        result = subprocess.run(["/bin/bash", str(SCRIPT)], input=answers,
                                text=True, capture_output=True, env=env, timeout=10)
        calls = [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []
        return result, [call for call in calls if call[1] != "get"]

    def test_fresh_default_and_local_scope(self):
        for choice, scope in [("\n", "user"), ("2\n", "local")]:
            with self.subTest(scope=scope):
                self.log.unlink(missing_ok=True)
                result, calls = self.run_setup(choice)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(calls, [
                    ["mcp", "remove", "parallel-search", "--scope", scope],
                    ["mcp", "add", "parallel-search", "--scope", scope,
                     "--transport", "http", "https://search.parallel.ai/mcp",
                     "--header", "User-Agent: maven-template/parallel-search"],
                ])

    def test_existing_settings_require_opt_in(self):
        for answers in ["1\n\n", "1\nn\n", "2\n"]:
            with self.subTest(answers=answers):
                self.log.unlink(missing_ok=True)
                result, calls = self.run_setup(answers, EXISTING="1")
                self.assertEqual(result.returncode, 0)
                self.assertEqual(calls, [])
                self.assertIn("Keeping the existing configuration", result.stdout)

    def test_confirmed_replacement_uses_selected_scope(self):
        result, calls = self.run_setup("2\ny\n", EXISTING="1")
        self.assertEqual(result.returncode, 0)
        self.assertEqual(len(calls), 2)
        for call in calls:
            self.assertEqual(call[3:5], ["--scope", "local"])

    def test_invalid_or_missing_selection_never_mutates(self):
        for answers in ["3\n", "garbage\n", ""]:
            with self.subTest(answers=answers):
                self.log.unlink(missing_ok=True)
                result, calls = self.run_setup(answers)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(calls, [])

    def test_registration_failure_is_not_success(self):
        result, _ = self.run_setup("1\n", ADD_EXIT="7")
        self.assertEqual(result.returncode, 7)
        self.assertNotIn("You're all set!", result.stdout)

    def test_missing_claude(self):
        (self.root / "claude").unlink()
        result, calls = self.run_setup("1\n")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(calls, [])
        self.assertIn("Claude Code not found", result.stdout)


if __name__ == "__main__":
    unittest.main()
