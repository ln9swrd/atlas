# AI Development Rules

This document is the project constitution for AI agents operating in Atlas.
It defines non-negotiable guardrails for environment changes and external application handling.

## Rule 001
Never modify the development environment without explicit approval.

This includes:
- apt install
- apt update
- pip install
- pip uninstall
- uv add
- winget
- choco
- docker pull
- git clone
- system configuration
- OS-level changes
- container or VM changes
- package manager or runtime upgrades

Environment changes require user approval.

## Rule 002
Blender and Unreal Engine are external applications.

Atlas must communicate through Connectors or MCP.

Atlas must never install external DCC applications.

## Enforcement
- Cline, Copilot, Qwen, and other AI agents operating in this repository must treat these rules as binding.
- If a requested action would violate these rules, the agent must stop, explain the issue, and ask for approval before proceeding.
- For asset work, Atlas should use already available local installations or approved external workflows rather than installing new tools.
- When Blender or Unreal work is requested, the agent must follow these rules and avoid modifying the environment or installing new DCC tools unless explicitly approved.
