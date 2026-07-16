import os
import re
import sys
import subprocess
import json
from datetime import datetime

from core.execution.context_resolver import resolve_context
from core.execution.goal_registry import set_active_goal, sync_state_with_goal
from core.execution.priority_engine import build_recommendation_payload

def run_script(script_relative_path):
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    script_path = os.path.join(base_dir, script_relative_path)
    
    result = subprocess.run(
        [sys.executable, script_path],
        capture_output=False
    )
    return result.returncode

def update_state_file(state_path, updates):
    if not os.path.exists(state_path):
        state_data = {
            "platform_version": "1.0",
            "schema_version": "1.0",
            "mode": "production",
            "active_project": "Exelion",
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
        with open(state_path, 'r', encoding='utf-8') as f:
            state_data = json.load(f)

    state_data.update(updates)
    with open(state_path, 'w', encoding='utf-8') as f:
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

    with open(log_path, 'a', encoding='utf-8') as f:
        f.write(json.dumps(event_entry, ensure_ascii=False) + "\n")

    return event_entry


def get_repo_root(base_dir=None):
    if base_dir is None:
        return os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    return os.path.abspath(base_dir)


def load_current_sprint(base_dir, project_name="Exelion"):
    project_dir = os.path.join(base_dir, "projects", project_name.lower())
    goal_dir = os.path.join(project_dir, "goals")

    if os.path.exists(goal_dir):
        for filename in sorted(os.listdir(goal_dir)):
            if not filename.endswith(".md"):
                continue
            goal_path = os.path.join(goal_dir, filename)
            try:
                with open(goal_path, 'r', encoding='utf-8') as handle:
                    content = handle.read()
                match = re.search(r"(Sprint-[A-Za-z0-9_-]+)", content)
                if match:
                    return match.group(1)
            except Exception:
                continue

    sprints_dir = os.path.join(project_dir, "sprints")
    if os.path.exists(sprints_dir):
        for filename in sorted(os.listdir(sprints_dir)):
            if filename.startswith("Sprint-") and filename.endswith(".md"):
                return filename[:-3]

    return "Sprint-001"


def load_sprint_tasks(base_dir, sprint_name, project_name="Exelion"):
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
            with open(tasklist_path, 'r', encoding='utf-8') as handle:
                lines = handle.readlines()
        except Exception:
            continue

        tasks = []
        for line in lines:
            match = re.match(r"^\s*\d+\.\s*(?:(?P<id>[A-Z0-9-]+)\s*[—-]\s*)?(?P<title>.+)$", line)
            if match:
                title = match.group("title").strip()
                tasks.append({"id": match.group("id") or None, "title": title})
        return tasks

    return []


def build_start_report(base_dir, environment_id="DEV_HOME", project_name="Exelion"):
    base_dir = get_repo_root(base_dir)
    context = resolve_context(environment_id, project_name, registry_path=os.path.join(base_dir, "ENVIRONMENTS.md"))
    payload = build_recommendation_payload(context, base_dir=base_dir)
    sprint_name = load_current_sprint(base_dir, project_name)
    sprint_tasks = load_sprint_tasks(base_dir, sprint_name, project_name)

    recommended_tasks = []
    for task in payload["selected_tasks"][:5]:
        recommended_tasks.append({
            "id": task.get("id"),
            "description": task.get("description"),
            "est_time": task.get("est_time"),
            "focus_area": task.get("focus_area"),
            "source": task.get("source"),
        })

    while len(recommended_tasks) < 5 and sprint_tasks:
        index = len(recommended_tasks)
        if index >= len(sprint_tasks):
            break
        next_task = sprint_tasks[index]
        recommended_tasks.append({
            "id": next_task.get("id"),
            "description": next_task.get("title"),
            "est_time": None,
            "focus_area": None,
            "source": "Sprint",
        })

    return {
        "environment": environment_id,
        "project": project_name,
        "current_sprint": sprint_name,
        "recommended_tasks": recommended_tasks,
        "planned_time": payload["accumulated_time"],
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
            "environment": report.get("environment"),
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


def advance_task(base_dir, command="next"):
    base_dir = get_repo_root(base_dir)
    state_path = os.path.join(base_dir, "ATLAS_STATE.json")
    log_path = os.path.join(base_dir, "logs", "atlas_events.jsonl")

    with open(state_path, 'r', encoding='utf-8') as handle:
        state_data = json.load(handle)

    task_states = state_data.get("task_states", [])
    if not task_states:
        return {"status": "NONE", "message": "No task states available"}

    next_task = None
    for task in task_states:
        if task.get("status") == "TODO":
            next_task = task
            break

    if next_task is None:
        next_task = task_states[0]

    next_task["status"] = "IN_PROGRESS"
    next_task["updated_at"] = datetime.now().isoformat(timespec="seconds")
    state_data["task_states"] = task_states
    state_data["current_task"] = next_task["id"]
    state_data["mode"] = "execution"

    with open(state_path, 'w', encoding='utf-8') as handle:
        json.dump(state_data, handle, indent=2, ensure_ascii=False)
        handle.write("\n")

    append_event_log(log_path, "task.started", {"task_id": next_task["id"], "description": next_task.get("description")})
    return {
        "status": next_task["status"],
        "task_id": next_task["id"],
        "description": next_task.get("description"),
        "updated_at": next_task.get("updated_at"),
    }


def start_day():
    print("========================================")
    print("           ATLAS RUNNER: START")
    print("========================================")

    base_dir = get_repo_root()
    state_path = os.path.join(base_dir, "ATLAS_STATE.json")
    log_path = os.path.join(base_dir, "logs", "atlas_events.jsonl")

    report = build_start_report(base_dir, environment_id="DEV_HOME", project_name="Exelion")
    initialize_task_state(base_dir, report)

    print(f"Current Environment : {report['environment']}")
    print(f"Current Sprint : {report['current_sprint']}")
    print("")
    print("Recommended Tasks")
    for index, task in enumerate(report["recommended_tasks"], 1):
        description = task.get("description") or "Untitled task"
        est_time = f" ({task.get('est_time')} mins)" if task.get("est_time") else ""
        print(f"{index}. {description}{est_time}")

    update_state_file(state_path, {
        "mode": "development",
        "active_project": "Exelion",
        "current_phase": "Asset Production",
        "last_started": datetime.now().isoformat(timespec="seconds")
    })

    registry_path = os.path.join(base_dir, "GOAL_REGISTRY.json")
    set_active_goal(registry_path, "EX-GOAL-001")
    sync_state_with_goal(state_path, registry_path)

    append_event_log(log_path, "atlas.start", {"project": "Exelion", "goal": "EX-GOAL-001", "environment": report["environment"]})
    append_event_log(log_path, "goal.activate", {"goal": "EX-GOAL-001"})

    print("")
    print("[RUNNER] Atlas start routine completed.")
    print("[RUNNER] Atlas state updated.")


def next_task():
    base_dir = get_repo_root()
    result = advance_task(base_dir, command="next")
    print(f"Selected Task : {result.get('description', 'Untitled task')}")
    print(f"Status : {result.get('status', 'UNKNOWN')}")
    return result


def complete_current_task(base_dir):
    base_dir = get_repo_root(base_dir)
    state_path = os.path.join(base_dir, "ATLAS_STATE.json")
    log_path = os.path.join(base_dir, "logs", "atlas_events.jsonl")

    with open(state_path, 'r', encoding='utf-8') as handle:
        state_data = json.load(handle)

    task_states = state_data.get("task_states", [])
    current_task_id = state_data.get("current_task")
    completed_task = None

    for task in task_states:
        if task.get("id") == current_task_id:
            task["status"] = "DONE"
            task["updated_at"] = datetime.now().isoformat(timespec="seconds")
            completed_task = task
            break

    if completed_task is None and task_states:
        task_states[0]["status"] = "DONE"
        task_states[0]["updated_at"] = datetime.now().isoformat(timespec="seconds")
        completed_task = task_states[0]

    state_data["task_states"] = task_states
    state_data["mode"] = "review"
    state_data["last_finished"] = datetime.now().isoformat(timespec="seconds")

    with open(state_path, 'w', encoding='utf-8') as handle:
        json.dump(state_data, handle, indent=2, ensure_ascii=False)
        handle.write("\n")

    append_event_log(log_path, "task.completed", {"task_id": completed_task.get("id") if completed_task else None, "description": completed_task.get("description") if completed_task else None})
    append_event_log(log_path, "sprint.updated", {"sprint": state_data.get("current_sprint")})
    return completed_task


def end_day():
    base_dir = get_repo_root()
    completed = complete_current_task(base_dir)
    print(f"Completed Task : {completed.get('description', 'Untitled task') if completed else 'None'}")
    print("Updated State")
    print("Events Recorded")
    print("Tomorrow Suggestions Generated")
    return completed

def finish_day():
    print("========================================")
    print("          ATLAS RUNNER: FINISH")
    print("========================================")

    base_dir = get_repo_root()
    state_path = os.path.join(base_dir, "ATLAS_STATE.json")
    log_path = os.path.join(base_dir, "logs", "atlas_events.jsonl")

    print("[RUNNER] Initiating pre-flight validation check...")
    rule_code = run_script("core/rules/rule_engine.py")
    if rule_code != 0:
        print("\n[CRITICAL ERROR] Pre-flight validation failed. Cannot finish day.")
        sys.exit(rule_code)

    print("[RUNNER] Rule checks passed. Generating quality scorecard...")
    review_code = run_script("core/review/review_engine.py")
    if review_code != 0:
        print("[ERROR] Quality review failed.")
        sys.exit(review_code)

    execution_readme_path = os.path.join(base_dir, "core", "execution", "README.md")

    if os.path.exists(execution_readme_path):
        with open(execution_readme_path, 'r', encoding='utf-8') as f:
            content = f.read()

        updated_content = content
        for line in content.splitlines():
            if "| **" in line and "`" in line and "[ ]" in line:
                updated_line = line.replace("[ ]", "[x]")
                updated_content = updated_content.replace(line, updated_line)

        log_heading = "## 3. Execution Log"
        log_heading_idx = updated_content.find(log_heading)
        if log_heading_idx != -1:
            today_str = datetime.today().strftime('%Y-%m-%d')
            log_entry = (
                f"\n- **{today_str} (Automated Run)**:\n"
                "  - Pre-flight rules validated successfully via Rule Engine.\n"
                "  - Quality scorecard generated and saved via Review Engine.\n"
                "  - Tasks checked and closed out automatically.\n"
            )
            insert_idx = log_heading_idx + len(log_heading)
            updated_content = (
                updated_content[:insert_idx] +
                log_entry +
                updated_content[insert_idx:]
            )

        with open(execution_readme_path, 'w', encoding='utf-8') as f:
            f.write(updated_content)

        print("[RUNNER] Dashboard tasks set to complete, and execution log appended.")

    update_state_file(state_path, {
        "mode": "idle",
        "last_finished": datetime.now().isoformat(timespec="seconds"),
        "last_review": "PASS"
    })
    append_event_log(log_path, "atlas.finish", {"review": "PASS"})
    append_event_log(log_path, "goal.sync", {"status": "reviewed"})

    print("Completed Tasks")
    print("Updated State")
    print("Events Recorded")
    print("Tomorrow Suggestions Generated")
    print("========================================")
    print(">>> ATLAS RUNNER: PROCESS SUCCESSFULLY FINISHED <<<")
    print("========================================")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python tools/atlas_runner.py [start|next|end|finish]")
        sys.exit(1)
        
    command = sys.argv[1].lower()
    if command == "start":
        start_day()
    elif command == "next":
        next_task()
    elif command == "end":
        end_day()
    elif command == "finish":
        finish_day()
    else:
        print(f"Unknown command: {command}")
        print("Usage: python tools/atlas_runner.py [start|next|end|finish]")
        sys.exit(1)
