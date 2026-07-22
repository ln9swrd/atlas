import unittest

from core.execution.context_resolver import resolve_context


class ContextResolverTests(unittest.TestCase):
    def test_resolve_context_builds_runtime_context(self):
        context = resolve_context('DEV_WORK', 'Excelion', registry_path='ENVIRONMENTS.md')
        self.assertEqual(context.environment, 'DEV_WORK')
        self.assertEqual(context.project, 'Excelion')
        self.assertIn('timestamp', context.time)
        self.assertIn('blender', context.capabilities)


if __name__ == '__main__':
    unittest.main()
