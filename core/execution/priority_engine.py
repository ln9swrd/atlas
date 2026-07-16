import os
import re
import json

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

def run_priority_engine():
    # base_dir points to workspace root
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    bottleneck_path = os.path.join(base_dir, "core", "workflow", "bottleneck_analysis.md")
    execution_readme_path = os.path.join(base_dir, "core", "execution", "README.md")
    registry_path = os.path.join(base_dir, "core", "config", "agent_registry.json")

    # Load backlogs: Atlas and any active projects in projects/
    backlog_files = {
        "Atlas": os.path.join(base_dir, "core", "execution", "atlas_backlog.json")
    }

    projects_dir = os.path.join(base_dir, "projects")
    if os.path.exists(projects_dir):
        for proj in os.listdir(projects_dir):
            proj_path = os.path.join(projects_dir, proj)
            if os.path.isdir(proj_path) and proj.lower() != "templates":
                backlog_path = os.path.join(proj_path, "backlog.json")
                if os.path.exists(backlog_path):
                    backlog_files[proj.capitalize()] = backlog_path

    # 1. Parse Bottleneck Scores
    bottleneck_scores = parse_bottleneck_scores(bottleneck_path)

    # 2. Read Backlogs
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

    # 3. Calculate priority scores (ROI)
    scored_tasks = []
    for task in backlog:
        stage = task.get("target_stage", "")
        bottleneck_score = bottleneck_scores.get(stage, 50) # default to 50 if not matched
        
        # Priority Score = (Bottleneck Score * Projected Gain) / Est. Time
        priority = (bottleneck_score * task["projected_gain"]) / task["est_time"]
        
        task_data = task.copy()
        task_data["bottleneck_score"] = bottleneck_score
        task_data["priority_score"] = round(priority, 2)
        scored_tasks.append(task_data)

    # Sort tasks by priority score descending
    scored_tasks.sort(key=lambda x: x["priority_score"], reverse=True)

    # 4. Fit into Time Budget
    # Read time budget from README.md or default to 180 mins
    time_budget = 180
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
        if accumulated_time + task["est_time"] <= time_budget:
            selected_tasks.append(task)
            accumulated_time += task["est_time"]
            total_impact += (task["projected_gain"] * (task["bottleneck_score"] / 100.0))

    # 5. Format the markdown table for README.md
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

    impact_percentage = round(total_impact, 1)
    markdown_table_lines.append("")
    markdown_table_lines.append(f"* **Total Planned Time**: {accumulated_time} minutes")
    markdown_table_lines.append(f"* **Expected Completion Impact**: `+{impact_percentage}%` (Based on bottleneck relief)")
    markdown_table_lines.append("")

    new_recommended_section = "\n".join(markdown_table_lines)

    # Update core/execution/README.md
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

    # 6. Print Start Day Screen
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

if __name__ == "__main__":
    run_priority_engine()
