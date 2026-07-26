import os
import json
import logging
from datetime import datetime, timezone, timedelta
import argparse

# Constants
STATUS_TODO = "TODO"
STATUS_IN_PROGRESS = "IN_PROGRESS"
STATUS_DONE = "DONE"

def configure_logging():
    logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

def load_state(base_dir):
    state_path = os.path.join(base_dir, "ATLAS_STATE.json")
    try:
        with open(state_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except FileNotFoundError:
        logging.error(f"State file not found: {state_path}")
        return {"task_states": []}
    except json.JSONDecodeError as e:
        logging.error(f"Error decoding state file: {e}")
        return {"task_states": []}

def save_state(base_dir, state_data):
    state_path = os.path.join(base_dir, "ATLAS_STATE.json")
    try:
        with open(state_path, 'w', encoding='utf-8') as f:
            json.dump(state_data, f, indent=2)
    except IOError as e:
        logging.error(f"Error saving state file: {e}")

def is_task_ready(task, task_states):
    if not task.get("depends_on"):
        return True
    return all(dep in [t["id"] for t in task_states if t["status"] == "DONE"] for dep in task["depends_on"])

def advance_task(base_dir, command="next"):
    base_dir = get_repo_root(base_dir)
    state_data = load_state(base_dir)
    task_states = state_data.get("task_states", [])
    
    if not task_states:
        logging.warning("No task states available")
        return {"status": "NONE", "message": "No task states available"}
    
    next_task = None
    for task in task_states:
        if task.get("status") == STATUS_TODO and is_task_ready(task, task_states):
            next_task = task
            break
    
    if not next_task:
        logging.warning("No ready tasks found")
        return {"status": "NONE", "message": "No ready tasks"}
    
    next_task["status"] = STATUS_IN_PROGRESS
    next_task["started_at"] = datetime.now(timezone.utc).isoformat()
    save_state(base_dir, state_data)
    logging.info(f"Advanced task {next_task['id']} to IN_PROGRESS")
    return next_task

def get_repo_root(base_dir=None):
    if base_dir:
        return os.path.abspath(base_dir)

    return os.path.abspath(
        os.path.dirname(__file__)
    )

def main():
    parser = argparse.ArgumentParser(description="ATLAS Runner")
    parser.add_argument("command", choices=["start", "next", "end", "finish", "status"], help="Command to execute")
    args = parser.parse_args()
    
    configure_logging()
    #base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    #base_dir = os.path.abspath(os.path.dirname(__file__))
    base_dir = get_repo_root()
    
    if args.command == "status":
        state_data = load_state(base_dir)
        task_states = state_data.get("task_states", [])
        for task in task_states:
            print(f"Task {task['id']}: {task['status']}")
        return
    
    if args.command in ["start", "next"]:
        result = advance_task(base_dir, args.command)
        print(json.dumps(result, indent=2))
        return
    
    if args.command == "finish":
        # Implementation for finish command
        pass

if __name__ == "__main__":
    main()