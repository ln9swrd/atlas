"""
Atlas DevOS - Cognitive Engine Module
Manages workspace context awareness, developer state observation, and decision integration.
"""
from typing import Dict, Any, List, Optional
import time


class CognitiveEngine:
    """
    Core Cognitive Architecture for Atlas DevOS.
    Perceives workspace state, tracks context evolution, and integrates decisions.
    """

    def __init__(self, initial_state: Optional[Dict[str, Any]] = None):
        self.state = initial_state or {
            "active_project": "Atlas",
            "developer_intent": "IDLE",
            "perceived_context": {},
            "last_updated": time.time()
        }
        self.observation_history: List[Dict[str, Any]] = []

    def observe_workspace(self, workspace_path: str, active_files: List[str]) -> Dict[str, Any]:
        """Observe active workspace changes and record observation state."""
        observation = {
            "timestamp": time.time(),
            "workspace": workspace_path,
            "active_files_count": len(active_files),
            "files": active_files
        }
        self.observation_history.append(observation)
        self.state["perceived_context"] = observation
        self.state["last_updated"] = time.time()
        return self.state

    def update_intent(self, intent: str) -> Dict[str, Any]:
        """Update current developer operational intent."""
        self.state["developer_intent"] = intent
        self.state["last_updated"] = time.time()
        return self.state

    def get_cognition_summary(self) -> Dict[str, Any]:
        """Return a structured summary of the cognitive state."""
        return {
            "status": "ACTIVE",
            "state": self.state,
            "total_observations": len(self.observation_history)
        }
