"""
Tests for ConstitutionEnforcer (Atlas v2.4)
"""
import unittest
from core.rules.constitution_enforcer import ConstitutionEnforcer


class TestConstitutionEnforcer(unittest.TestCase):

    def setUp(self):
        self.enforcer = ConstitutionEnforcer()

    def test_verify_roi_gate_pass_recurrence(self):
        spec = {"name": "Auto FBX Export", "recurrence_count": 2, "time_saved_minutes": 15}
        res = self.enforcer.verify_roi_gate(spec)
        self.assertTrue(res["roi_passed"])
        self.assertEqual(res["status"], "APPROVED")

    def test_verify_roi_gate_pass_time(self):
        spec = {"name": "Auto Rig Validator", "recurrence_count": 1, "time_saved_minutes": 45}
        res = self.enforcer.verify_roi_gate(spec)
        self.assertTrue(res["roi_passed"])
        self.assertEqual(res["status"], "APPROVED")

    def test_verify_roi_gate_reject(self):
        spec = {"name": "Trivial Helper", "recurrence_count": 1, "time_saved_minutes": 10}
        res = self.enforcer.verify_roi_gate(spec)
        self.assertFalse(res["roi_passed"])
        self.assertEqual(res["status"], "REJECTED")

    def test_audit_agents_rule_file(self):
        sample_agents_md = """
# Rules for Minimizing Token Usage
1. Concise Responses

# Atlas Engineering Principles
1. ROI Gate
        """
        audit = self.enforcer.audit_agents_rule_file(sample_agents_md)
        self.assertTrue(audit["is_valid"])
        self.assertEqual(audit["status"], "PASS")


if __name__ == "__main__":
    unittest.main()
