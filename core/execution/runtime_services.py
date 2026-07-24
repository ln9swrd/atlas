import json
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

from core.execution.context_resolver import resolve_context
from core.execution.priority_engine import build_recommendation_payload
from core.execution.runtime_context import RuntimeContext
from core.execution.goal_registry import load_goal_registry, set_active_goal, sync_state_with_goal


def get_repo_root(base_dir=None):
    if base_dir is None:
        return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    return os.path.abspath(base_dir)


def run_script(script_relative_path, base_dir=None):
    base_dir = get_repo_root(base_dir)
    script_path = os.path.join(base_dir, script_relative_path)

    result = subprocess.run(
        [sys.executable, script_path],
        cwd=base_dir,
        capture_output=False,
    )
    return result.returncode


def load_atlas_state(base_dir=None):
    base_dir = get_repo_root(base_dir)
    state_path = os.path.join(base_dir, "ATLAS_STATE.json")
    if not os.path.exists(state_path):
        return {
            "platform_version": "1.0",
            "schema_version": "1.0",
            "mode": "idle",
            "active_project": "Excelion",
            "active_agents": ["Marie", "Antigravity", "Copilot", "Sera"],
            "current_phase": "Development",
            "last_started": None,
            "last_finished": None,
            "last_review": None,
            "active_goal": None,
            "current_goal_status": None,
            "last_goal_sync": None,
            "task_states": [],
            "current_task": None,
            "current_sprint": None,
        }

    with open(state_path, "r", encoding="utf-8") as f:
        return json.load(f)


def update_state_file(state_path, updates):
    if not os.path.exists(state_path):
        state_data = {
            "platform_version": "1.0",
            "schema_version": "1.0",
            "mode": "production",
            "active_project": "Excelion",
            "active_agents": ["Marie", "Antigravity", "Copilot", "Sera"],
            "current_phase": "Development",
            "last_started": None,
            "last_finished": None,
            "last_review": None,
            "task_states": [],
            "current_task": None,
            "current_sprint": None,
        }
    else:
        with open(state_path, "r", encoding="utf-8") as f:
            state_data = json.load(f)

    state_data.update(updates)
    with open(state_path, "w", encoding="utf-8") as f:
        json.dump(state_data, f, indent=2, ensure_ascii=False)
        f.write("\n")

    return state_data


def append_event_log(log_path, event_name, payload=None):
    os.makedirs(os.path.dirname(log_path), exist_ok=True)
    event_entry = {
        "timestamp": datetime.now().isoformat(timespec="seconds"),
        "event": event_name,
    }
    if payload:
        event_entry.update(payload)

    with open(log_path, "a", encoding="utf-8") as f:
        f.write(json.dumps(event_entry, ensure_ascii=False) + "\n")

    return event_entry


def load_current_sprint(base_dir, project_name="Excelion"):
    base_dir = get_repo_root(base_dir)
    goal_registry_path = os.path.join(base_dir, "GOAL_REGISTRY.json")
    active_goal = None
    if os.path.exists(goal_registry_path):
        try:
            with open(goal_registry_path, "r", encoding="utf-8") as f:
                reg_data = json.load(f)
                active_goal = reg_data.get("active_goal")
        except Exception:
            pass

    project_dir = os.path.join(base_dir, "projects", project_name.lower())
    goal_dir = os.path.join(project_dir, "goals")

    if active_goal and os.path.exists(goal_dir):
        active_goal_path = os.path.join(goal_dir, f"{active_goal}.md")
        if os.path.exists(active_goal_path):
            try:
                with open(active_goal_path, "r", encoding="utf-8") as handle:
                    content = handle.read()
                match = re.search(r"(Sprint-[A-Za-z0-9_-]+)", content)
                if match:
                    return match.group(1)
            except Exception:
                pass

    if os.path.exists(goal_dir):
        for filename in sorted(os.listdir(goal_dir), reverse=True):
            if not filename.endswith(".md"):
                continue
            goal_path = os.path.join(goal_dir, filename)
            try:
                with open(goal_path, "r", encoding="utf-8") as handle:
                    content = handle.read()
                match = re.search(r"(Sprint-[A-Za-z0-9_-]+)", content)
                if match:
                    return match.group(1)
            except Exception:
                continue

    sprints_dir = os.path.join(project_dir, "sprints")
    if os.path.exists(sprints_dir):
        for filename in sorted(os.listdir(sprints_dir), reverse=True):
            if filename.startswith("Sprint-") and filename.endswith(".md"):
                return filename[:-3]

    return "Sprint-001"


def load_sprint_tasks(base_dir, sprint_name, project_name="Excelion"):
    base_dir = get_repo_root(base_dir)
    project_dir = os.path.join(base_dir, "projects", project_name.lower())
    sprints_dir = os.path.join(project_dir, "sprints")
    candidates = [
        os.path.join(sprints_dir, f"{sprint_name}-tasklist.md"),
        os.path.join(sprints_dir, f"{sprint_name}.md"),
    ]

    for tasklist_path in candidates:
        if not os.path.exists(tasklist_path):
            continue
        try:
            with open(tasklist_path, "r", encoding="utf-8") as handle:
                lines = handle.readlines()
        except Exception:
            continue

        tasks = []
        in_table = False
        headers = []
        for line in lines:
            match = re.match(r"^\s*\d+\.\s*(?:(?P<id>[A-Z0-9-]+)\s*[—-]\s*)?(?P<title>.+)$", line)
            if match:
                title = match.group("title").strip()
                tasks.append({"id": match.group("id") or None, "title": title})
                continue

            if line.strip().startswith("|") and "|" in line:
                cells = [cell.strip() for cell in line.strip().split("|") if cell.strip()]
                if not in_table and any(header.lower() in ["id", "task", "description"] for header in cells):
                    in_table = True
                    headers = [header.lower() for header in cells]
                    continue
                if in_table and set(headers) and len(cells) >= len(headers):
                    row = {headers[i]: cells[i] for i in range(min(len(headers), len(cells)))}
                    task_id = row.get("id") or row.get("task") or row.get("description")
                    title = row.get("task") or row.get("description") or task_id
                    status = (row.get("status") or "").lower()
                    if status in ["done", "completed"]:
                        continue
                    if task_id and task_id != "---" and title:
                        tasks.append({"id": task_id, "title": title})
                    continue

        if tasks:
            return tasks

    return []


def build_runtime_context(base_dir, environment_id="DEV_HOME", project_name="Excelion", runtime_overrides=None, state=None):
    base_dir = get_repo_root(base_dir)
    env_path = os.path.join(base_dir, "ENVIRONMENTS.md")
    if not os.path.exists(env_path):
        env_path = os.path.join(base_dir, "docs", "process", "ENVIRONMENTS.md")
    context = resolve_context(environment_id, project_name, registry_path=env_path)

    overrides = runtime_overrides or {}
    resources = dict(context.resources or {})
    # Only set available_minutes when a non-None value is provided; coerce safely to int
    if "available_minutes" in overrides and overrides.get("available_minutes") is not None:
        try:
            resources["available_minutes"] = int(overrides["available_minutes"])
        except Exception:
            # fallback to existing or default behavior
            resources["available_minutes"] = resources.get("available_minutes") or 180
    if "energy" in overrides:
        resources["energy"] = overrides["energy"]
    if "focus" in overrides:
        resources["focus"] = overrides["focus"]
    if "meeting_day" in overrides:
        resources["meeting_day"] = overrides["meeting_day"]
    if "ai_quota" in overrides:
        resources["ai_quota"] = overrides["ai_quota"]

    constraints = list(context.constraints or [])
    for constraint in overrides.get("constraints", []) or []:
        if constraint not in constraints:
            constraints.append(constraint)

    user = dict(context.user or {})
    user.update(overrides.get("user", {}) or {})

    return RuntimeContext(
        environment=environment_id,
        project=project_name,
        time=dict(context.time or {}),
        capabilities=list(context.capabilities or []),
        constraints=constraints,
        resources=resources,
        user=user,
    )


def build_start_report(base_dir, environment_id="DEV_HOME", project_name="Excelion", runtime_overrides=None, state=None):
    base_dir = get_repo_root(base_dir)
    context = build_runtime_context(base_dir, environment_id=environment_id, project_name=project_name, runtime_overrides=runtime_overrides, state=state)
    payload = build_recommendation_payload(context, base_dir=base_dir, state=state)
    sprint_name = load_current_sprint(base_dir, project_name)
    sprint_tasks = load_sprint_tasks(base_dir, sprint_name, project_name)

    recommended_tasks = []
    for task in payload["selected_tasks"][:5]:
        recommended_tasks.append({
            "id": task.get("id"),
            "description": task.get("description"),
            "estimate": task.get("estimate") or task.get("est_time"),
            "est_time": task.get("est_time"),
            "focus_area": task.get("focus_area"),
            "source": task.get("source"),
            "environment": task.get("environment") or environment_id,
            "depends_on": task.get("depends_on") or [],
        })

    while len(recommended_tasks) < 5 and sprint_tasks:
        index = len(recommended_tasks)
        if index >= len(sprint_tasks):
            break
        next_task = sprint_tasks[index]
        recommended_tasks.append({
            "id": next_task.get("id"),
            "description": next_task.get("title"),
            "estimate": None,
            "est_time": None,
            "focus_area": None,
            "environment": environment_id,
            "depends_on": [],
            "source": "Sprint",
        })

    return {
        "environment": environment_id,
        "project": project_name,
        "current_sprint": sprint_name,
        "recommended_tasks": recommended_tasks,
        "planned_time": payload["accumulated_time"],
        "context": {
            "environment": context.environment,
            "available_minutes": context.resources.get("available_minutes"),
            "energy": context.resources.get("energy"),
        },
    }


def initialize_task_state(base_dir, report):
    base_dir = get_repo_root(base_dir)
    state_path = os.path.join(base_dir, "ATLAS_STATE.json")
    log_path = os.path.join(base_dir, "logs", "atlas_events.jsonl")
    os.makedirs(os.path.dirname(log_path), exist_ok=True)

    task_states = []
    for task in report.get("recommended_tasks", []):
        task_states.append({
            "id": task.get("id") or f"TASK-{len(task_states) + 1}",
            "description": task.get("description"),
            "status": "TODO",
            "priority": len(task_states) + 1,
            "estimate": task.get("estimate") or task.get("est_time"),
            "environment": task.get("environment") or report.get("environment"),
            "depends_on": task.get("depends_on") or [],
            "updated_at": datetime.now().isoformat(timespec="seconds"),
        })

    state_data = update_state_file(state_path, {
        "task_states": task_states,
        "current_task": task_states[0]["id"] if task_states else None,
        "current_sprint": report.get("current_sprint"),
        "mode": "planning",
        "last_started": datetime.now().isoformat(timespec="seconds"),
    })
    append_event_log(log_path, "task.state_initialized", {"count": len(task_states), "sprint": report.get("current_sprint")})
    return state_data


def sync_status_doc(base_dir):
    base_dir = get_repo_root(base_dir)
    status_path = os.path.join(base_dir, "docs", "PROJECT_STATUS.md")
    state_path = os.path.join(base_dir, "ATLAS_STATE.json")
    if not os.path.exists(status_path) or not os.path.exists(state_path):
        return

    try:
        with open(state_path, "r", encoding="utf-8") as f:
            state_data = json.load(f)

        today_str = datetime.today().strftime("%Y-%m-%d %H:%M:%S")
        status_block = [
            f"- Last Sync: `{today_str}`",
            f"- Project: `{state_data.get('active_project', 'Atlas')}`",
            f"- Mode: `{state_data.get('mode', 'unknown')}`",
            f"- Current Sprint: `{state_data.get('current_sprint', 'none')}`",
            f"- Current Task: `{state_data.get('current_task', 'none')}`",
            f"- Last Review: `{state_data.get('last_review', 'PASS')}`",
            "\n",
        ]

        with open(status_path, "r", encoding="utf-8") as f:
            lines = f.readlines()

        filtered_lines = []
        for line in lines:
            if line.startswith(tuple(["- Last Sync:", "- Project:", "- Mode:", "- Current Sprint:", "- Current Task:", "- Last Review:"])):
                continue
            filtered_lines.append(line)

        insert_at = None
        for idx, line in enumerate(filtered_lines):
            if line.strip() == "## 1. 현재 상태":
                insert_at = idx + 1
                break
        if insert_at is None:
            insert_at = 0
        while insert_at < len(filtered_lines) and filtered_lines[insert_at].strip() == "":
            insert_at += 1

        new_lines = filtered_lines[:insert_at] + [line + "\n" for line in status_block] + filtered_lines[insert_at:]

        with open(status_path, "w", encoding="utf-8") as f:
            f.writelines(new_lines)

        return True
    except Exception:
        return False
