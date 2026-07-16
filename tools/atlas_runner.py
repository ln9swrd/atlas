import os
import sys
import subprocess
from datetime import datetime

def run_script(script_relative_path):
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    script_path = os.path.join(base_dir, script_relative_path)
    
    result = subprocess.run(
        [sys.executable, script_path],
        capture_output=False
    )
    return result.returncode

def start_day():
    print("========================================")
    print("           ATLAS RUNNER: START")
    print("========================================")
    
    # Run priority engine
    code = run_script("core/execution/priority_engine.py")
    if code != 0:
        print("[ERROR] Failed to start priority engine.")
        sys.exit(code)
        
    print("[RUNNER] Priority task dashboard successfully initialized.")

def finish_day():
    print("========================================")
    print("          ATLAS RUNNER: FINISH")
    print("========================================")
    
    # 1. Run Pre-flight rule check
    print("[RUNNER] Initiating pre-flight validation check...")
    rule_code = run_script("core/rules/rule_engine.py")
    if rule_code != 0:
        print("\n[CRITICAL ERROR] Pre-flight validation failed. Cannot finish day.")
        sys.exit(rule_code)
        
    # 2. Run Review engine
    print("[RUNNER] Rule checks passed. Generating quality scorecard...")
    review_code = run_script("core/review/review_engine.py")
    if review_code != 0:
        print("[ERROR] Quality review failed.")
        sys.exit(review_code)
        
    # 3. Post-execution log generation and dashboard completion
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    execution_readme_path = os.path.join(base_dir, "core", "execution", "README.md")
    
    if os.path.exists(execution_readme_path):
        with open(execution_readme_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # Parse today's recommended tasks and change [ ] to [x]
        updated_content = content
        task_rows = []
        for line in content.splitlines():
            if "| **" in line and "`" in line and "[ ]" in line:
                updated_line = line.replace("[ ]", "[x]")
                updated_content = updated_content.replace(line, updated_line)
                
        # Append today's log to Execution Log
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
    
    print("========================================")
    print(">>> ATLAS RUNNER: PROCESS SUCCESSFULLY FINISHED <<<")
    print("========================================")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python tools/atlas_runner.py [start|finish]")
        sys.exit(1)
        
    command = sys.argv[1].lower()
    if command == "start":
        start_day()
    elif command == "finish":
        finish_day()
    else:
        print(f"Unknown command: {command}")
        print("Usage: python tools/atlas_runner.py [start|finish]")
        sys.exit(1)
