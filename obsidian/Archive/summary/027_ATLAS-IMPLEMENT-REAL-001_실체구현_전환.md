# 027. ATLAS-IMPLEMENT-REAL-001 실체구현 전환

## 핵심

- 목표: 문서 → 실행 가능한 Python 스켈레톤.
- 구조: `atlas/{main, core, runtime, memory, config}` + tests.
- 첫 성공 기준: `python -m atlas` → Boot 메시지 → ONLINE.
- 다음: Boot Sequence (Lifecycle, Registry, Shutdown).
- 원칙: 실행된다 / 상태 가진다 / 저장된다 / 다시 시작된다.
- Cleanup은 분석만, 삭제·이동은 승인 후. 마리=판단, Cline=실행, GitHub=기록.
