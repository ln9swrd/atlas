# 079. Continue·Ollama·Antigravity 성능비교

## 핵심

- 차이는 Qwen3 모델이 아니라 **에이전트 환경 전체**(컨텍스트·저장소 탐색·상태 관리·검증 루프).
- Qwen3+Continue = 똑똑한 개발자+터미널 / Antigravity = PM+아키텍트+개발자 팀.
- 결론: 프로젝트 구조(Atlas/SERA)는 유지, 모델·런타임은 Antigravity 최대 활용.
- 병목은 토큰 창 → **필요한 Context만 선택 로딩**이 SERA의 핵심 과제.
- SERA = 큰 기억이 아니라 **기억 관리 능력**(무엇을 항상 기억/필요할 때 로드/버릴지).
