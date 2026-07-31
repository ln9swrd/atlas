#!/usr/bin/env python3
"""
Atlas Qwen Orchestrator (optional; primary surface = Cline per D15)
- Ollama chat + tool loop
- Domain blacklist aligned with AGENTS.md / D17
- WORKSPACE_ROOT: ATLAS_ROOT env or parent of tools/
"""

import sys
import os
import json
import re
import urllib.request
import urllib.error
import subprocess
from pathlib import Path

OLLAMA_HOST = os.environ.get("OLLAMA_HOST", "http://192.168.219.254:11434")

# Repo root: env wins, else directory containing tools/
_TOOLS_DIR = Path(__file__).resolve().parent
WORKSPACE_ROOT = Path(os.environ.get("ATLAS_ROOT", str(_TOOLS_DIR.parent))).resolve()

# AGENTS BLACK + scratch deny-on-tool (sandbox not auto-loaded)
FORBIDDEN_DIRECTORIES = ["archive", "obsidian", "node_modules", ".git", "scratch"]

SYSTEM_PROMPT = """You are Atlas Agent, an autonomous coding AI pair programming with the USER in Atlas DevOS.
You are powered by Qwen. You must maximize your reasoning capabilities using Chain-of-Thought (CoT).
Always communicate with the USER in Korean in your final finish message or explanations.

CRITICAL INSTRUCTIONS:
1. Evidence-First Rule: NEVER guess or finish early based on past documents when the user asks for a CLI command (e.g. `ls`, `pwd`, `git`, `find`, `pytest`). You MUST execute the CLI command first using `execute_cli`.
2. Do NOT select `finish` action until you have executed the required CLI or file read actions to collect real evidence.
3. Structure your thought process carefully inside <thought> tags before taking any action.
4. Never read or write under archive/, obsidian/, node_modules/, .git/, or scratch/.

RESPONSE FORMAT:
You MUST format your responses using the following tags:
<thought>
Analyze the user's intent. If the user provided a CLI command or asked to inspect the system, state that you MUST execute the CLI tool first.
</thought>

<action>
Choose EXACTLY ONE tool action in valid JSON format:
Option A: Execute a CLI command
{
  "type": "execute_cli",
  "command": "ls -al"
}

Option B: Read a file
{
  "type": "read_file",
  "path": "state/CURRENT_STATE.md"
}

Option C: Write or modify a file
{
  "type": "write_file",
  "path": "path/to/file.py",
  "content": "file content here"
}

Option D: Complete the task
{
  "type": "finish",
  "message": "사용자에게 전달할 한국어 최종 답변 요약"
}
</action>
"""


def check_ollama_connection():
    url = f"{OLLAMA_HOST}/api/tags"
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Atlas-Orchestrator"})
        with urllib.request.urlopen(req, timeout=5) as resp:
            if resp.status == 200:
                data = json.loads(resp.read().decode())
                models = [m.get("name") for m in data.get("models", [])]
                sys.stderr.write(f"[+] Connected to Ollama at {OLLAMA_HOST}\n")
                sys.stderr.write(f"[+] Workspace: {WORKSPACE_ROOT}\n")
                sys.stderr.write(f"[+] Available Models ({len(models)}): {', '.join(models)}\n")
                return models
    except Exception as e:
        sys.stderr.write(f"[-] Failed to connect to Ollama at {OLLAMA_HOST}: {e}\n")
        return []


def validate_file_access(target_path: str) -> bool:
    normalized = target_path.replace("\\", "/").lower()
    for forbidden in FORBIDDEN_DIRECTORIES:
        if f"/{forbidden}/" in f"/{normalized}/" or normalized.startswith(f"{forbidden}/"):
            return False
    return True


def resolve_context(user_prompt: str) -> str:
    prompt_lower = user_prompt.lower().strip()
    simple_cli_keywords = ["ls", "pwd", "git", "hi", "hello", "안녕", "현재 위치"]
    if any(prompt_lower.startswith(kw) or prompt_lower == kw for kw in simple_cli_keywords):
        return "=== CONTEXT: TARGETED SLIM SCOPE ===\n[Simple Query Mode: Minimal Context Active]"

    context_str = "=== CONTEXT: TARGETED SCOPE ===\n"
    agents_path = WORKSPACE_ROOT / "AGENTS.md"
    current_state_path = WORKSPACE_ROOT / "state" / "CURRENT_STATE.md"

    if agents_path.exists():
        context_str += f"\n--- AGENTS.md ---\n{agents_path.read_text(encoding='utf-8')}\n"
    if current_state_path.exists():
        context_str += f"\n--- CURRENT_STATE.md ---\n{current_state_path.read_text(encoding='utf-8')}\n"

    return context_str


def call_ollama_chat_stream(model_name: str, messages: list):
    url = f"{OLLAMA_HOST}/api/chat"
    payload = {
        "model": model_name,
        "messages": messages,
        "stream": True,
        "options": {"temperature": 0.3},
    }
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers={"Content-Type": "application/json"})

    full_response = ""
    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            for line in resp:
                if line:
                    chunk = json.loads(line.decode("utf-8"))
                    delta = chunk.get("message", {}).get("content", "")
                    if delta:
                        full_response += delta
                        sys.stdout.write(delta)
                        sys.stdout.flush()
    except Exception as e:
        sys.stderr.write(f"[-] Ollama Stream Error: {e}\n")

    return full_response


def execute_action(action: dict) -> str:
    action_type = action.get("type")

    if action_type == "execute_cli":
        cmd = action.get("command", "")
        if any(forbidden in cmd.lower() for forbidden in FORBIDDEN_DIRECTORIES):
            return "[Access Denied] Command targets forbidden directory (archive/obsidian/node_modules/.git/scratch)."

        sys.stderr.write(f"[+] Executing CLI: {cmd}\n")
        try:
            res = subprocess.run(
                cmd, shell=True, capture_output=True, text=True, timeout=60, cwd=str(WORKSPACE_ROOT)
            )
            out = res.stdout if res.stdout else res.stderr
            return out if out else "Command executed cleanly with no output."
        except Exception as e:
            return f"CLI Execution Error: {e}"

    elif action_type == "read_file":
        filepath = action.get("path", "")
        if not validate_file_access(filepath):
            return f"[Access Denied] Path '{filepath}' is in forbidden blacklisted zone."

        full_path = WORKSPACE_ROOT / filepath
        if not full_path.exists():
            return f"Error: File '{filepath}' does not exist."
        try:
            return full_path.read_text(encoding="utf-8")
        except Exception as e:
            return f"Error reading file: {e}"

    elif action_type == "write_file":
        filepath = action.get("path", "")
        if not validate_file_access(filepath):
            return f"[Access Denied] Cannot write to blacklisted zone '{filepath}'."

        content = action.get("content", "")
        full_path = WORKSPACE_ROOT / filepath
        try:
            full_path.parent.mkdir(parents=True, exist_ok=True)
            full_path.write_text(content, encoding="utf-8")
            return f"Successfully written to '{filepath}'."
        except Exception as e:
            return f"Error writing file: {e}"

    elif action_type == "finish":
        return f"TASK_COMPLETED: {action.get('message', '')}"

    return f"Unknown action type: {action_type}"


def parse_action_json(response_text):
    match = re.search(r"<action>(.*?)</action>", response_text, re.DOTALL)
    if match:
        json_str = match.group(1).strip()
        try:
            return json.loads(json_str)
        except Exception as e:
            print(f"[-] JSON parse error: {e}")
            return None
    return None


def run_orchestrator(user_prompt, model_name=None):
    models = check_ollama_connection()
    if not models:
        print("[-] Cannot proceed without Ollama connection.")
        return

    if not model_name:
        env_model = os.environ.get("OLLAMA_MODEL")
        if env_model:
            model_name = env_model
        else:
            qwen_preferred = [m for m in models if "qwen3:14b" in m.lower()]
            if qwen_preferred:
                model_name = qwen_preferred[0]
            else:
                qwen_models = [m for m in models if "qwen" in m.lower()]
                model_name = qwen_models[0] if qwen_models else models[0]

    sys.stderr.write(f"[+] Using Model: {model_name}\n")

    context = resolve_context(user_prompt)
    messages = [
        {"role": "system", "content": SYSTEM_PROMPT + "\n\n" + context},
        {"role": "user", "content": user_prompt},
    ]

    max_steps = 10
    for step in range(1, max_steps + 1):
        sys.stderr.write(f"\n=================== STEP {step}/{max_steps} ===================\n")
        try:
            response = call_ollama_chat_stream(model_name, messages)
            sys.stdout.flush()

            messages.append({"role": "assistant", "content": response})

            action = parse_action_json(response)
            if not action:
                print("[-] No valid <action> JSON block found in response.", flush=True)
                break

            if action.get("type") == "finish":
                print(f"\n[★] Task Finished: {action.get('message')}", flush=True)
                break

            tool_output = execute_action(action)
            feedback_msg = f"Tool Output for Action ({action.get('type')}):\n{tool_output}"
            messages.append({"role": "user", "content": feedback_msg})

        except Exception as e:
            print(f"[-] Step Error: {e}", flush=True)
            break


if __name__ == "__main__":
    if len(sys.argv) > 1:
        prompt = sys.argv[1]
    else:
        prompt = "현재 git status와 state/CURRENT_STATE.md 상태를 점검하고 요약해줘."

    run_orchestrator(prompt)
