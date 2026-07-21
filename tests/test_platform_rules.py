import unittest
import os
import sys
import json
import tempfile
import shutil

# Ensure repo root is in path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from core.rules.platform_rules import validate_state_schema, validate_python_syntax, validate_doc_links


class TestValidateStateSchema(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()

    def tearDown(self):
        shutil.rmtree(self.tmpdir)

    def test_valid_schema(self):
        state = {
            "platform_version": "1.0",
            "mode": "idle",
            "active_project": "Atlas",
            "current_phase": "Development",
            "task_states": []
        }
        path = os.path.join(self.tmpdir, "ATLAS_STATE.json")
        with open(path, "w", encoding="utf-8") as f:
            json.dump(state, f)
        self.assertTrue(validate_state_schema(self.tmpdir))

    def test_missing_key(self):
        state = {"platform_version": "1.0", "mode": "idle"}
        path = os.path.join(self.tmpdir, "ATLAS_STATE.json")
        with open(path, "w", encoding="utf-8") as f:
            json.dump(state, f)
        self.assertFalse(validate_state_schema(self.tmpdir))

    def test_missing_file(self):
        self.assertFalse(validate_state_schema(self.tmpdir))


class TestValidatePythonSyntax(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()
        os.makedirs(os.path.join(self.tmpdir, "core"))
        os.makedirs(os.path.join(self.tmpdir, "tools"))

    def tearDown(self):
        shutil.rmtree(self.tmpdir)

    def test_valid_syntax(self):
        with open(os.path.join(self.tmpdir, "core", "valid.py"), "w") as f:
            f.write("x = 1\n")
        self.assertTrue(validate_python_syntax(self.tmpdir))

    def test_invalid_syntax(self):
        with open(os.path.join(self.tmpdir, "core", "bad.py"), "w") as f:
            f.write("def foo(\n")
        self.assertFalse(validate_python_syntax(self.tmpdir))


class TestValidateDocLinks(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()
        os.makedirs(os.path.join(self.tmpdir, "docs"))

    def tearDown(self):
        shutil.rmtree(self.tmpdir)

    def test_valid_links(self):
        with open(os.path.join(self.tmpdir, "docs", "test.md"), "w") as f:
            f.write("[link](test.md)\n")
        self.assertTrue(validate_doc_links(self.tmpdir))

    def test_broken_link_still_passes(self):
        """Broken links produce warnings but do not fail the check."""
        with open(os.path.join(self.tmpdir, "test.md"), "w") as f:
            f.write("[broken](nonexistent.md)\n")
        self.assertTrue(validate_doc_links(self.tmpdir))


if __name__ == "__main__":
    unittest.main()
