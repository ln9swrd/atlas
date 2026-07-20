BPY Abstraction — 첫 마이그레이션 PR 안내
=========================================

목표
----
- 코드베이스에서 `bpy` 의존을 런타임 어댑터를 통해 분리하여 테스트 가능성 확보

이 PR에 포함할 최소 변경
-----------------------
1. `excelion_forge/core/runtime` 추가 (이미 추가됨):
   - `protocol.py`, `context.py`, `adapter.py`, `fake_adapter.py`

2. `PipelineContext`에 `runtime` 주입 필드 추가 (이미 적용됨)

3. 파이프라인·유틸에서 런타임 사용 예시 적용
   - `core/pipeline/progress.py`: `set_runtime` 사용으로 Blender `wm` 접근을 런타임을 통해 안전하게 처리

4. 테스트 마이그레이션 (권장 우선순위)
   - 유닛 테스트에서 `bpy`를 전역 모듈로 mocking 하는 대신 `FakeBpyAdapter`를 주입
   - 예: 테스트에서 `from excelion_forge.core.runtime import FakeBpyAdapter` 사용
     ```py
     runtime = FakeBpyAdapter()
     ctx = PipelineContext()
     ctx.set_runtime(runtime)
     # pipeline code should read ctx.get_runtime() or ctx.runtime
     ```

변경 범위 권장 순서 (작은 PR 순)
--------------------------------
1. 인프라 PR (this PR): runtime 패키지 + PipelineContext 변경 + ProgressManager 변경
2. 테스트 PRs (분리된 소규모 PR들):
   - `tests/test_serializer.py`의 bpy mocking 제거(혹은 축소)
   - `tests/test_fix_manager.py`를 Fake 사용 방식으로 전환
   - 통합 테스트(`tests/integration/test_blender_validation.py`)는 블렌더 환경에서만 동작하도록 유지
3. Operators/Properties 리팩터(선택): 블렌더 UI 레이어는 `bpy` 직접 사용 유지 가능 — core 로직만 분리

PR 본문 예시
-------------
Title: Introduce bpy runtime abstraction and PipelineContext runtime injection

Summary:
- Add `excelion_forge.core.runtime` with `BpyRuntimeProtocol`, `BpyAdapter`, and `FakeBpyAdapter`.
- Add `runtime` injection to `PipelineContext`.
- Allow `ProgressManager` to use runtime for Blender `window_manager` integration.

Why:
- Decouple core pipeline and validation logic from Blender-specific `bpy` API to improve testability and enable headless CI.

Checklist:
- [x] Add runtime package
- [x] Add PipelineContext.runtime and accessors
- [x] Update ProgressManager to accept runtime
- [ ] Provide sample test migration for one unit test
- [ ] Document follow-up PRs for migrating remaining tests

Notes / Migration tips
---------------------
- Keep UI-level code (operators, property groups, panels) using `bpy` directly; only move core logic that needs to run under pytest without Blender.
- The `FakeBpyAdapter` must match the minimal surface used by tests; extend it incrementally.
