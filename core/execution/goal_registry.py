import json
import os
from pathlib import Path
from datetime import datetime


def load_goal_registry(path=None):
    if path is None:
        base_dir = Path(__file__).resolve().parents[2]
        path = base_dir / "GOAL_REGISTRY.json"
    else:
        path = Path(path)

    if not path.exists():
        return {
            "active_goal": None,
            "completed_goals": [],
            "next_goal": None,
            "goals": {},
        }

    with path.open("r", encoding="utf-8") as handle:
        data = json.load(handle)

    if not isinstance(data, dict):
        return {
            "active_goal": None,
            "completed_goals": [],
            "next_goal": None,
            "goals": {},
        }

    data.setdefault("active_goal", None)
    data.setdefault("completed_goals", [])
    data.setdefault("next_goal", None)
    data.setdefault("goals", {})
    return data


def save_goal_registry(registry, path=None):
    if path is None:
        base_dir = Path(__file__).resolve().parents[2]
        path = base_dir / "GOAL_REGISTRY.json"
    else:
        path = Path(path)

    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        json.dump(registry, handle, indent=2, ensure_ascii=False)
        handle.write("\n")

    return registry


def set_active_goal(path=None, goal_id=None):
    registry = load_goal_registry(path)
    if goal_id is None:
        return registry

    registry["active_goal"] = goal_id
    registry.setdefault("goals", {})[goal_id] = {
        "goal_id": goal_id,
        "status": "Active",
        "updated_at": datetime.now().isoformat(timespec="seconds"),
    }
    save_goal_registry(registry, path)
    return registry


def sync_state_with_goal(state_path=None, registry_path=None):
    if state_path is None:
        base_dir = Path(__file__).resolve().parents[2]
        state_path = base_dir / "ATLAS_STATE.json"
    else:
        state_path = Path(state_path)

    registry = load_goal_registry(registry_path)
    active_goal = registry.get("active_goal")

    state = {}
    if state_path.exists():
        with state_path.open("r", encoding="utf-8") as handle:
            state = json.load(handle)

    state["active_goal"] = active_goal
    state["current_goal_status"] = "Active" if active_goal else "Idle"
    state["last_goal_sync"] = datetime.now().isoformat(timespec="seconds")

    state_path.parent.mkdir(parents=True, exist_ok=True)
    with state_path.open("w", encoding="utf-8") as handle:
        json.dump(state, handle, indent=2, ensure_ascii=False)
        handle.write("\n")

    return state
