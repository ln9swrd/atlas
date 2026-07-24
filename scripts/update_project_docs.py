import json
import os
from datetime import datetime

BASE_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

PROJECT_OVERVIEW = os.path.join(BASE_DIR, "PROJECT_OVERVIEW.md")
PROJECT_STATUS = os.path.join(BASE_DIR, "docs", "PROJECT_STATUS.md")
EXCELION_BACKLOG = os.path.join(BASE_DIR, "projects", "excelion", "backlog.json")
SPRINT_TASKLIST = os.path.join(BASE_DIR, "projects", "excelion", "sprints", "Sprint-004-tasklist.md")
SPRINT_REPORT = os.path.join(BASE_DIR, "projects", "excelion", "sprints", "Sprint-004-report.md")


def load_backlog():
    with open(EXCELION_BACKLOG, "r", encoding="utf-8") as f:
        return json.load(f)


def build_task_summary(backlog):
    lines = ["| ID | Description | Target Stage | Estimated Time | Environment | Status |", "| --- | --- | --- | --- | --- | --- |"]
    for item in backlog:
        task_id = item.get("id", "UNKNOWN")
        desc = item.get("description", "-")
        stage = item.get("target_stage", "-")
        est = item.get("est_time", "-")
        environment = "DEV_WORK (Company PC)" if "Blender" in stage or "UV" in stage else "DEV_HOME (Home PC)"
        status = "Pending"
        lines.append(f"| {task_id} | {desc} | {stage} | {est} | {environment} | {status} |")
    return "\n".join(lines)


def update_project_overview(backlog):
    if not os.path.exists(PROJECT_OVERVIEW):
        return

    with open(PROJECT_OVERVIEW, "r", encoding="utf-8") as f:
        content = f.read()

    if "## 4. 지금까지 한 일" not in content:
        return

    summary = build_task_summary(backlog)
    marker = "## 5. 지금 진행 중인 방향"
    updated_content = content

    if "### 현재 주요 백로그" in content:
        start = content.index("### 현재 주요 백로그")
        end = content.find("## 5.", start)
        updated_content = content[:start] + "### 현재 주요 백로그\n\n" + summary + "\n\n" + content[end:]
    else:
        insert_at = content.index(marker)
        updated_content = content[:insert_at] + "### 현재 주요 백로그\n\n" + summary + "\n\n" + content[insert_at:]

    with open(PROJECT_OVERVIEW, "w", encoding="utf-8") as f:
        f.write(updated_content)


def update_project_status(backlog):
    if not os.path.exists(PROJECT_STATUS):
        return

    with open(PROJECT_STATUS, "r", encoding="utf-8") as f:
        content = f.read()

    task_summary = build_task_summary(backlog)
    if "### 현재 작업" in content:
        start = content.index("### 현재 작업")
        end = content.find("## 4.", start)
        updated_content = content[:start] + "### 현재 작업\n\n" + task_summary + "\n\n" + content[end:]
    else:
        updated_content = content + "\n### 현재 작업\n\n" + task_summary + "\n"

    with open(PROJECT_STATUS, "w", encoding="utf-8") as f:
        f.write(updated_content)


def update_sprint_report(backlog):
    if not os.path.exists(SPRINT_REPORT):
        return

    now = datetime.now().strftime("%Y-%m-%d")
    with open(SPRINT_REPORT, "r", encoding="utf-8") as f:
        content = f.read()

    if "### Current Backlog Snapshot" in content:
        start = content.index("### Current Backlog Snapshot")
        end = content.find("## Risks and Blockers", start)
        section = "### Current Backlog Snapshot\n\n" + build_task_summary(backlog) + "\n\n"
        updated_content = content[:start] + section + content[end:]
    else:
        insert_at = content.index("## Risks and Blockers")
        updated_content = content[:insert_at] + "### Current Backlog Snapshot\n\n" + build_task_summary(backlog) + "\n\n" + content[insert_at:]

    with open(SPRINT_REPORT, "w", encoding="utf-8") as f:
        f.write(updated_content)


def main():
    backlog = load_backlog()
    update_project_overview(backlog)
    update_project_status(backlog)
    update_sprint_report(backlog)
    print("Project documents updated.")


if __name__ == "__main__":
    main()
