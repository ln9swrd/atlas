import unittest

from core.execution.runtime_context import RuntimeContext
from core.execution.priority_rules import build_rules
from core.execution.context_resolver import resolve_context


class RuntimeContextTests(unittest.TestCase):
    def test_runtime_context_is_immutable(self):
        context = RuntimeContext(environment='DEV_WORK', project='Exelion')
        with self.assertRaises(AttributeError):
            context.environment = 'DEV_HOME'

    def test_priority_rules_are_created_from_context(self):
        resolved = resolve_context('DEV_WORK', 'Exelion', registry_path='ENVIRONMENTS.md')
        rules = build_rules(resolved)
        self.assertIsInstance(rules, list)


if __name__ == '__main__':
    unittest.main()
