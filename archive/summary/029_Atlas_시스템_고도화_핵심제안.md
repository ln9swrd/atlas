# 029. Atlas 시스템 고도화 / PrintGuard 정체성

## 핵심

- 네트워크 연결은 필수가 아님. 슬라이싱은 오프라인 가능. G-code 생성은 연산 중심(슬라이서 PC) vs 실행 중심(프린터).
- PrintGuard 정체성: **Pre-flight QA / Print Confidence**. 슬라이서 대체 아님.
- 원칙: Never replace slicer / Preserve original / Explainable / Reversible / User final decision / Explain every decision.
- 아키텍처: Input → Analysis → Rule Engine → Risk Assessment → Optimization(optional) → Output.
- 핵심 자산은 GUI/Parser가 아니라 **Rule Database**(PG-COM/FDM/SLA Rule ID).
- 다음: Rule Book 먼저 → 이후 STL Loader·CLI PoC. MVP = `printguard analyze model.stl` → Confidence + Critical/Warning + Recommendation.
