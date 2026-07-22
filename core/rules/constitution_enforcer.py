"""
Atlas DevOS - Constitution Rule Enforcer (v2.4)
Enforces Atlas Engineering Principles and ROI Gate compliance on project changes.
"""
from typing import Dict, Any, List
import os
import re


class ConstitutionEnforcer:
    """
    Enforces Atlas Engineering Principles:
    1. Problem recurrence check (at least 2 occurrences or 30+ min savings).
    2. Review engine & Rule engine integration.
    3. ROI Gate verification.
    """

    def __init__(self, agents_md_path: Optional[str] = None):
        self.agents_md_path = agents_md_path

    def verify_roi_gate(self, feature_spec: Dict[str, Any]) -> Dict[str, Any]:
        """
        Verify if a new automation feature satisfies the ROI Gate rule:
        - Must solve a problem that recurred >= 2 times, OR
        - Must save >= 30 minutes of development time.
        """
        recurrence_count = feature_spec.get("recurrence_count", 0)
        time_saved_minutes = feature_spec.get("time_saved_minutes", 0)
        feature_name = feature_spec.get("name", "Unnamed Feature")

        is_passed = recurrence_count >= 2 or time_saved_minutes >= 30

        findings = []
        if not is_passed:
            findings.append({
                "rule": "ROIGateRule",
                "severity": "REJECT",
                "message": f"Feature '{feature_name}' failed ROI Gate: recurrence ({recurrence_count}) < 2 and time saved ({time_saved_minutes}m) < 30m.",
            })

        return {
            "feature_name": feature_name,
            "roi_passed": is_passed,
            "recurrence_count": recurrence_count,
            "time_saved_minutes": time_saved_minutes,
            "findings": findings,
            "status": "APPROVED" if is_passed else "REJECTED",
        }

    def audit_agents_rule_file(self, content: str) -> Dict[str, Any]:
        """Check if AGENTS.md rules include token minimization and Atlas engineering principles."""
        has_token_rules = "Token Usage" in content or "Concise Responses" in content
        has_atlas_principles = "Atlas Engineering Principles" in content or "ROI Gate" in content

        is_valid = has_token_rules and has_atlas_principles

        return {
            "has_token_rules": has_token_rules,
            "has_atlas_principles": has_atlas_principles,
            "is_valid": is_valid,
            "status": "PASS" if is_valid else "FAIL",
        }
