"""
Tests for EnvironmentResolver (Atlas v2.3)
"""
import unittest
from core.execution.environment_resolver import EnvironmentResolver, EnvironmentContext


class TestEnvironmentResolver(unittest.TestCase):

    def setUp(self):
        self.resolver = EnvironmentResolver()

    def test_resolve_dev_work(self):
        ctx = self.resolver.resolve_environment("DEV_WORK", "Excelion")
        self.assertEqual(ctx.env_name, "DEV_WORK")
        self.assertEqual(ctx.active_project, "Excelion")
        self.assertIn("blender_path", ctx.toolchain)
        self.assertTrue(self.resolver.validate_environment(ctx))

    def test_resolve_dev_home(self):
        ctx = self.resolver.resolve_environment("DEV_HOME", "Excelion")
        self.assertEqual(ctx.env_name, "DEV_HOME")
        self.assertIn("unreal_path", ctx.toolchain)
        self.assertTrue(self.resolver.validate_environment(ctx))


if __name__ == "__main__":
    unittest.main()
