import json
import tempfile
import unittest
from pathlib import Path

from core.execution.environment_registry import load_environment_registry, set_active_environment
from core.execution.environment_resolver import resolve_environment


class EnvironmentRegistryTests(unittest.TestCase):
    def test_load_environment_registry_reads_known_environments(self):
        registry = load_environment_registry('ENVIRONMENTS.md')
        self.assertIn('DEV_WORK', registry)
        self.assertIn('DEV_HOME', registry)

    def test_set_active_environment_updates_state(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            state_path = Path(tmpdir) / 'ATLAS_STATE.json'
            state_path.write_text('{}\n', encoding='utf-8')
            state = set_active_environment(state_path, 'DEV_WORK')
            self.assertEqual(state['active_environment'], 'DEV_WORK')

    def test_resolve_environment_builds_runtime_context(self):
        context = resolve_environment('DEV_WORK', registry_path='ENVIRONMENTS.md')
        self.assertEqual(context['environment'], 'DEV_WORK')
        self.assertIn('blender', context['capabilities'])
        self.assertIn('no_gpu', context['constraints'])


if __name__ == '__main__':
    unittest.main()
