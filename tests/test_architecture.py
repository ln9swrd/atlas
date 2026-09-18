import os
import sys
import ast
import unittest
from pathlib import Path


class ArchitectureTests(unittest.TestCase):
    def test_execution_module_does_not_depend_on_context(self):
        root = Path(__file__).resolve().parents[1]
        execution_path = root / 'core' / 'execution' / 'priority_engine.py'
        tree = ast.parse(execution_path.read_text(encoding='utf-8'))
        imports = [node for node in ast.walk(tree) if isinstance(node, ast.ImportFrom)]
        imported_modules = {node.module for node in imports if node.module}
        self.assertNotIn('core.context', imported_modules)

    def test_context_module_is_available(self):
        root = Path(__file__).resolve().parents[1]
        context_path = root / 'core' / 'context' / 'runtime_context.py'
        self.assertTrue(context_path.exists())


if __name__ == '__main__':
    unittest.main()
