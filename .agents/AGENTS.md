# Rules for Minimizing Token Usage

To minimize token usage and ensure highly efficient communication, the agent MUST strictly adhere to the following rules:

1. **Concise Responses**: Provide the shortest possible answers that are still complete and accurate. Avoid conversational fillers, introductory remarks, and pleasantries.
2. **Code-First**: Show the code changes or commands directly. Avoid wrapping code in lengthy explanations unless explicitly requested or highly complex.
3. **No Redundancy**: Do not summarize file edits or actions that are already clear from the code diffs or command outputs.
4. **Minimal Explanations**: Limit background context or design rationale to a maximum of 1-2 bullet points.
5. **No Placeholders**: Write fully functional code directly without verbose placeholders or templates.

# Atlas Engineering Principles

1. 실제 작업에서 반복적으로 발생한 문제를 먼저 기록한다.
2. 기존 Workflow, Rules, Checklists로 해결 가능한지 검토한다.
3. 해결되지 않을 때만 자동화를 추가한다.
4. 자동화는 Rule Engine과 Review Engine에 통합한다.
5. Metrics로 효과를 측정한다.
6. ROI가 없는 기능은 유지하지 않는다.
7. 새로운 자동화 및 도구는 실제 개발 과정에서 2회 이상 반복된 문제이거나 최소 30분 이상 단축이 검증된 작업에 한해서만 추가한다. (ROI Gate)
