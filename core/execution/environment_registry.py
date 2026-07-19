import json
from pathlib import Path
from datetime import datetime


def load_environment_registry(path=None):
    if path is None:
        base_dir = Path(__file__).resolve().parents[2]
        path = base_dir / "ENVIRONMENTS.md"
    else:
        path = Path(path)

    if not path.exists():
        return {}

    content = path.read_text(encoding="utf-8")
    environments = {}
    current = None
    current_key = None

    for line in content.splitlines():
        stripped = line.strip()
        if not stripped:
            continue

        if stripped.startswith("### "):
            current = stripped[4:].strip()
            current_key = None
            environments[current] = {"id": current, "role": "", "capabilities": [], "limitations": [], "assigned_tasks": []}
        elif stripped.startswith("## "):
            current = stripped[3:].strip()
            current_key = None
            environments[current] = {"id": current, "role": "", "capabilities": [], "limitations": [], "assigned_tasks": []}
        elif current:
            if stripped.startswith("Role:"):
                environments[current]["role"] = stripped.split(":", 1)[1].strip()
            elif stripped == "Capabilities:":
                current_key = "capabilities"
            elif stripped == "Limitations:":
                current_key = "limitations"
            elif stripped == "Assigned Tasks:":
                current_key = "assigned_tasks"
            elif stripped.startswith("- ") and current_key is not None:
                environments[current][current_key].append(stripped[2:].strip())

    return environments


def set_active_environment(state_path=None, environment_id=None):
    if state_path is None:
        base_dir = Path(__file__).resolve().parents[2]
        state_path = base_dir / "ATLAS_STATE.json"
    else:
        state_path = Path(state_path)

    state = {}
    if state_path.exists():
        state = json.loads(state_path.read_text(encoding="utf-8"))

    if environment_id is not None:
        state["active_environment"] = environment_id
        state["last_environment_sync"] = datetime.now().isoformat(timespec="seconds")

    state_path.write_text(json.dumps(state, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return state
