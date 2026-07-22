"""
Atlas DevOS - Dynamic Agent Orchestrator (v1.3)
Autonomously schedules and dispatches optimal AI agents based on task bottlenecks and project environments.
"""
from typing import Dict, Any, List, Optional
import os
import json


class AgentOrchestrator:
    """
    Dynamic Agent Orchestrator for Atlas DevOS v1.3.
    Analyzes task bottlenecks and selects optimal agent assignments (Marie, Forge, Antigravity, Sera, Copilot).
    """

    def __init__(self, registry_path: Optional[str] = None):
        self.agent_capabilities = {
            "Forge": ["modeling", "rigging", "uv_mapping", "export", "unreal_setup"],
            "Marie": ["review", "qa", "pre_flight", "audit"],
            "Antigravity": ["architecture", "core_engine", "rules", "refactoring"],
            "Sera": ["documentation", "release_notes", "changelog"],
            "Copilot": ["code_generation", "unit_tests", "scripting"],
        }
        self.registry_path = registry_path

    def select_agent(self, task: Dict[str, Any]) -> str:
        """Select the best-matching agent for a given task specification."""
        focus_area = task.get("focus_area", "").lower()
        bottleneck = task.get("bottleneck", "").lower()
        category = task.get("category", "").lower()

        if "review" in bottleneck or "qa" in category or "audit" in focus_area:
            return "Marie"
        elif any(k in focus_area or k in category for k in ["modeling", "uv", "rigging", "materials", "unreal_setup"]):
            return "Forge"
        elif "rule" in focus_area or "arch" in bottleneck or "engine" in category:
            return "Antigravity"
        elif "doc" in focus_area or "note" in bottleneck:
            return "Sera"
        else:
            return "Copilot"

    def orchestrate_backlog(self, tasks: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """Process a list of backlog tasks and assign optimal agents."""
        scheduled_tasks = []
        for task in tasks:
            task_copy = dict(task)
            suggested_agent = self.select_agent(task_copy)
            task_copy["assigned_agent"] = suggested_agent
            task_copy["orchestration_status"] = "SCHEDULED"
            scheduled_tasks.append(task_copy)
        return scheduled_tasks

    def generate_orchestration_report(self, tasks: List[Dict[str, Any]]) -> Dict[str, Any]:
        """Generate summary report of agent load distribution."""
        scheduled = self.orchestrate_backlog(tasks)
        agent_distribution: Dict[str, int] = {}
        for t in scheduled:
            agent = t["assigned_agent"]
            agent_distribution[agent] = agent_distribution.get(agent, 0) + 1

        return {
            "total_tasks": len(tasks),
            "load_distribution": agent_distribution,
            "orchestrated_tasks": scheduled,
            "status": "HEALTHY",
        }
