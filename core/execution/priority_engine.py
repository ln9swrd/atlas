import os
import re
import json

from core.execution.context_resolver import resolve_context
from core.execution.priority_rules import build_rules


def load_project_lifecycle(lifecycle_path):
    """Load project lifecycle statuses from a JSON file, if present."""
    if not os.path.exists(lifecycle_path):
        return {}

    try:
        with open(lifecycle_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as exc:
        print(f"Warning: Failed to load project lifecycle config: {exc}")
        return {}

    if not isinstance(data, dict):
        return {}
    return data


def collect_backlog_files(base_dir, lifecycle_path=None):
    """Collect backlog files for projects that are active enough to be recommended."""
    backlog_files = {}
    lifecycle = load_project_lifecycle(lifecycle_path or os.path.join(base_dir, "core", "config", "project_lifecycle.json"))

    atlas_backlog = os.path.join(base_dir, "core", "execution", "atlas_backlog.json")
    if os.path.exists(atlas_backlog):
        atlas_status = lifecycle.get("Atlas", {}).get("status", "active")
        if atlas_status != "maintenance":
            backlog_files["Atlas"] = atlas_backlog

    projects_dir = os.path.join(base_dir, "projects")
    if os.path.exists(projects_dir):
        for proj in sorted(os.listdir(projects_dir)):
            proj_path = os.path.join(projects_dir, proj)
            if os.path.isdir(proj_path) and proj.lower() != "templates":
                backlog_path = os.path.join(proj_path, "backlog.json")
                if not os.path.exists(backlog_path):
                    continue
                status = lifecycle.get(proj.capitalize(), {}).get("status", "active")
                if status != "maintenance":
                    backlog_files[proj.capitalize()] = backlog_path

    return backlog_files


def parse_bottleneck_scores(bottleneck_path):
    """
    Parses workflow/bottleneck_analysis.md to extract stage names and their bottleneck scores.
    """
    scores = {}
    if not os.path.exists(bottleneck_path):
        print(f"Warning: Bottleneck analysis file not found at {bottleneck_path}")
        return scores

    # Regex to match: | **Blender - 리깅** | 5 | 4 | 4 | 4 | 2 | `19` | **`76` 점** |
    row_pattern = re.compile(r"\|\s*\*\*([^*]+)\*\*\s*\|[^|]+\|[^|]+\|[^|]+\|[^|]+\|[^|]+\|[^|]+\|\s*\*\*\s*`(\d+)`\s*점\*\*")

    with open(bottleneck_path, 'r', encoding='utf-8') as f:
        for line in f:
            match = row_pattern.search(line)
            if match:
                stage = match.group(1).strip()
                score = int(match.group(2))
                scores[stage] = score
                
    return scores

def get_assignee_for_task(task, registry_path):
    """
    Dynamically maps a task to an agent based on capability registry.
    """
    if not os.path.exists(registry_path):
        # Fallback default assignment
        return "Antigravity" if "automation" in task.get("focus_area", "") else "Human + Forge"

    try:
        with open(registry_path, 'r', encoding='utf-8') as f:
            registry = json.load(f)
    except Exception as e:
        print(f"Warning: Failed to load agent registry: {e}")
        return "Antigravity" if "automation" in task.get("focus_area", "") else "Human + Forge"

    focus_area = task.get("focus_area", "").lower()
    category = task.get("category", "").lower()

    # Match capability
    for entry in registry:
        agent_name = entry.get("agent", "")
        capabilities = [c.lower() for c in entry.get("capabilities", [])]
        if focus_area in capabilities or any(c in category for c in capabilities):
            if agent_name == "Forge":
                return "Human + Forge"
            return agent_name

    # Default logic if no capability matches
    return "Antigravity" if "automation" in focus_area else "Human + Forge"

def build_recommendation_payload(context, base_dir=None, state=None):
    if base_dir is None:
        base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

    bottleneck_path = os.path.join(base_dir, "core", "workflow", "bottleneck_analysis.md")
    execution_readme_path = os.path.join(base_dir, "core", "execution", "README.md")
    registry_path = os.path.join(base_dir, "core", "config", "agent_registry.json")

    lifecycle_path = os.path.join(base_dir, "core", "config", "project_lifecycle.json")
    backlog_files = collect_backlog_files(base_dir, lifecycle_path=lifecycle_path)

    constraints = set(getattr(context, 'constraints', []) or [])
    rules = build_rules(context)
    resources = getattr(context, 'resources', {}) or {}
    state = state or {}
    task_states = state.get("task_states", []) if isinstance(state, dict) else []
    completed_ids = {task.get("id") for task in task_states if task.get("status") == "DONE"}

    bottleneck_scores = parse_bottleneck_scores(bottleneck_path)

    backlog = []
    for source, path in backlog_files.items():
        if os.path.exists(path):
            try:
                with open(path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    for item in data:
                        item["source"] = source
                        backlog.append(item)
            except Exception as e:
                print(f"Warning: Failed to load {source} backlog from {path}: {e}")

    scored_tasks = []
    for task in backlog:
        stage = task.get("target_stage", "")
        bottleneck_score = bottleneck_scores.get(stage, 50)
        priority = (bottleneck_score * task["projected_gain"]) / task["est_time"]

        task_data = task.copy()
        task_data["bottleneck_score"] = bottleneck_score
        task_data["priority_score"] = round(priority, 2)
        scored_tasks.append(task_data)

    scored_tasks.sort(key=lambda x: x["priority_score"], reverse=True)

    time_budget = int(resources.get("available_minutes", 180))
    if os.path.exists(execution_readme_path):
        with open(execution_readme_path, 'r', encoding='utf-8') as f:
            content = f.read()
            budget_match = re.search(r"\*\s*\*Time Budget\*:\s*(\d+)\s*Hours", content)
            if budget_match:
                time_budget = int(budget_match.group(1)) * 60

    selected_tasks = []
    accumulated_time = 0
    total_impact = 0.0

    for task in scored_tasks:
        task_caps = set()
        if task.get("focus_area"):
            task_caps.add(task["focus_area"].lower())
        if task.get("category"):
            task_caps.add(task["category"].lower())

        if task.get("environment") and context.environment and task["environment"] != context.environment:
            continue
        if task.get("depends_on"):
            unmet_dependencies = [dependency for dependency in task.get("depends_on", []) if dependency not in completed_ids]
            if unmet_dependencies:
                continue
        if task.get("est_time", 0) > time_budget:
            continue

        if "no_unreal" in constraints and "unreal" in task_caps:
            continue
        if "no_gpu" in constraints and any(token in task_caps for token in {"ai", "gpu", "render"}):
            continue
        if any(rule[0] == 'prefer_wrap_up' for rule in rules) and 'documentation' in task_caps:
            selected_tasks.append(task)
            accumulated_time += task['est_time']
            total_impact += (task['projected_gain'] * (task['bottleneck_score'] / 100.0))
            continue

        if accumulated_time + task["est_time"] <= time_budget:
            selected_tasks.append(task)
            accumulated_time += task["est_time"]
            total_impact += (task["projected_gain"] * (task["bottleneck_score"] / 100.0))

    return {
        "selected_tasks": selected_tasks,
        "time_budget": time_budget,
        "accumulated_time": accumulated_time,
        "total_impact": total_impact,
        "impact_percentage": round(total_impact, 1),
        "registry_path": registry_path,
    }


def recommend(context):
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    bottleneck_path = os.path.join(base_dir, "core", "workflow", "bottleneck_analysis.md")
    execution_readme_path = os.path.join(base_dir, "core", "execution", "README.md")
    registry_path = os.path.join(base_dir, "core", "config", "agent_registry.json")

    payload = build_recommendation_payload(context, base_dir=base_dir)
    selected_tasks = payload["selected_tasks"]
    time_budget = payload["time_budget"]
    impact_percentage = payload["impact_percentage"]

    markdown_table_lines = [
        "## 2. Today's Recommended Tasks",
        "",
        "Atlas suggests the following task breakdown based on active bottlenecks and priorities:",
        "",
        "| # | Task Description | Est. Time | Assignee | Focus Area | Status |",
        "| :-: | :--- | :-: | :-: | :--- | :---: |"
    ]

    for idx, task in enumerate(selected_tasks, 1):
        assignee = get_assignee_for_task(task, registry_path)
        source_prefix = f"[{task['source']}] " if "source" in task else ""
        markdown_table_lines.append(
            f"| **{idx}** | {source_prefix}{task['description']} | {task['est_time']} mins | {assignee} | `{task['focus_area']}` | `[ ]` |"
        )

    markdown_table_lines.append("")
    markdown_table_lines.append(f"* **Total Planned Time**: {payload['accumulated_time']} minutes")
    markdown_table_lines.append(f"* **Expected Completion Impact**: `+{impact_percentage}%` (Based on bottleneck relief)")
    markdown_table_lines.append("")

    new_recommended_section = "\n".join(markdown_table_lines)

    if os.path.exists(execution_readme_path):
        with open(execution_readme_path, 'r', encoding='utf-8') as f:
            readme_content = f.read()

        section_start_idx = readme_content.find("## 2. Today's Recommended Tasks")
        if section_start_idx != -1:
            next_section_idx = readme_content.find("## 3. Execution Log")
            if next_section_idx != -1:
                updated_content = (
                    readme_content[:section_start_idx] +
                    new_recommended_section +
                    "\n\n---\n\n" +
                    readme_content[next_section_idx:]
                )
                with open(execution_readme_path, 'w', encoding='utf-8') as f:
                    f.write(updated_content)
                print("Successfully updated execution/README.md with recommended tasks.")

    print("\n" + "="*40)
    print("              ATLAS DAILY")
    print("="*40)
    print(f"개발 가능 시간  : {time_budget // 60}시간 ({time_budget}분)")
    print("\n오늘 추천 작업:")
    for idx, task in enumerate(selected_tasks, 1):
        print(f"  {idx}. {task['description']} ({task['est_time']}분)")
    print(f"\n예상 진행률 향상: +{impact_percentage}%")
    print("예상 완료일     : 2027-02-18 (예정)")
    print("\n[주의] Rig 작업 전 Export 금지")
    print("="*40 + "\n")


def run_priority_engine():
    context = resolve_context('DEV_WORK', 'Exelion', registry_path=os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), 'ENVIRONMENTS.md'))
    recommend(context)


if __name__ == "__main__":
    run_priority_engine()
