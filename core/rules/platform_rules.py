import os
import sys
import json
import ast
import re

def validate_state_schema(base_dir):
    """Validates ATLAS_STATE.json structure and essential schema fields."""
    state_path = os.path.join(base_dir, "ATLAS_STATE.json")
    if not os.path.exists(state_path):
        print("[FAIL] ATLAS_STATE.json missing.")
        return False

    required_keys = ["platform_version", "mode", "active_project", "current_phase", "task_states"]
    try:
        with open(state_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        for key in required_keys:
            if key not in data:
                print(f"[FAIL] Missing required key '{key}' in ATLAS_STATE.json")
                return False
        print("[PASS] ATLAS_STATE.json schema validated.")
        return True
    except Exception as e:
        print(f"[FAIL] ATLAS_STATE.json parsing error: {e}")
        return False

def validate_python_syntax(base_dir):
    """Validates syntax of all Python source files in core/ and tools/."""
    targets = [os.path.join(base_dir, "core"), os.path.join(base_dir, "tools")]
    all_valid = True
    count = 0

    for target in targets:
        if not os.path.exists(target):
            continue
        for root, _, files in os.walk(target):
            for file in files:
                if file.endswith(".py"):
                    full_path = os.path.join(root, file)
                    count += 1
                    try:
                        with open(full_path, "r", encoding="utf-8") as f:
                            code = f.read()
                        ast.parse(code)
                    except SyntaxError as se:
                        print(f"[FAIL] Syntax error in {file}: {se}")
                        all_valid = False

    if all_valid:
        print(f"[PASS] Python syntax validated across {count} files.")
    return all_valid

def validate_doc_links(base_dir):
    """Validates existence of local file links in root and docs/ markdown files."""
    link_pattern = re.compile(r"\[([^\]]+)\]\(([^)]+)\)")
    doc_paths = []
    
    for file in os.listdir(base_dir):
        if file.endswith(".md"):
            doc_paths.append(os.path.join(base_dir, file))
            
    docs_dir = os.path.join(base_dir, "docs")
    if os.path.exists(docs_dir):
        for root, _, files in os.walk(docs_dir):
            for file in files:
                if file.endswith(".md"):
                    doc_paths.append(os.path.join(root, file))

    missing_links = 0
    total_links = 0

    for doc_path in doc_paths:
        doc_dir = os.path.dirname(doc_path)
        try:
            with open(doc_path, "r", encoding="utf-8") as f:
                content = f.read()
            matches = link_pattern.findall(content)
            for text, target in matches:
                if target.startswith(("http://", "https://", "#", "file://")):
                    continue
                total_links += 1
                target_clean = target.split("#")[0]
                if not target_clean:
                    continue
                resolved = os.path.normpath(os.path.join(doc_dir, target_clean))
                if not os.path.exists(resolved):
                    print(f"[WARN] Broken link in {os.path.basename(doc_path)}: '{target}' -> '{resolved}'")
                    missing_links += 1
        except Exception:
            pass

    if missing_links == 0:
        print(f"[PASS] All {total_links} relative markdown links validated.")
        return True
    else:
        print(f"[WARN] Document link check completed with {missing_links} warnings out of {total_links} links.")
        return True  # Warnings do not block execution

def run_platform_rules():
    """Runs all Atlas DevOS Platform Pre-flight rules."""
    print("\n" + "="*50)
    print("       ATLAS DEVOS PLATFORM PRE-FLIGHT CHECK")
    print("="*50)
    
    base_dir = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    
    c1 = validate_state_schema(base_dir)
    c2 = validate_python_syntax(base_dir)
    c3 = validate_doc_links(base_dir)

    all_passed = c1 and c2 and c3
    print("="*50)
    if all_passed:
        print(">>> ALL DEVOS PLATFORM RULES PASSED <<<")
        print("="*50 + "\n")
    else:
        print(">>> DEVOS PLATFORM PRE-FLIGHT FAILED <<<")
        print("="*50 + "\n")
    return all_passed

if __name__ == "__main__":
    success = run_platform_rules()
    if not success:
        sys.exit(1)
