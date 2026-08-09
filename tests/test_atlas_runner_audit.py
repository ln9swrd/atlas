import unittest

from tools import atlas_runner


class AtlasAuditTests(unittest.TestCase):
    def test_run_audit_returns_report_structure(self):
        report = atlas_runner.run_audit(base_dir='.')

        self.assertIn('overall_coverage', report)
        self.assertIn('components', report)
        self.assertIn('summary', report)
        self.assertIn('tests', report)
        self.assertTrue(isinstance(report['overall_coverage'], float))
        self.assertTrue(report['overall_coverage'] >= 0.0)
        self.assertTrue(report['overall_coverage'] <= 100.0)


if __name__ == '__main__':
    unittest.main()
