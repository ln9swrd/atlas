# MENOS Content Editor — 구현·검증 기준 및 결정사항

작성일: 2026-10-08
상태: CANON / Master께서 2026-10-08 승인하셨습니다.

## 1. 목적

Content Editor 메뉴별 구현·검증에 필요한 결정사항을 한 문서로 관리한다.
과거 장문 요구사항은 archive에 보존하며, 이 문서를 현재 작업의 요약 기준으로 사용한다.

대상 메뉴:
MAP / STAGE / MISSION / CAMPAIGN / FACTION / ROBOT / UNIT / TOWER / BUILDING / SKILL / CATALOG / VFX / SFX / BGM / VOICE

Settings / Language / Quit은 Runtime User Settings 영역으로 별도 관리한다.

## 2. 공통 P0 Authoring Contract

모든 Content Editor 메뉴의 최소 완료 기준:

Edit → Validate → Save → Reload → Verify

**Master 승인 Canon:**
- Duplicate ID는 저장을 거부합니다.
- 참조 중인 데이터는 삭제하지 않습니다.
- P0에서는 ID 변경을 허용하지 않습니다.
- 자동 참조 갱신을 사용하지 않습니다.
- Save 실패/Reload 실패 시 기존 정상 데이터를 보존합니다.
- Dirty 상태에서 Reload/Close 시 미저장 변경을 명확히 처리합니다.
- Editor Preview PASS는 Save/Loader/Runtime PASS가 아닙니다.
- Background/자동화 PASS는 PIE VERIFIED가 아닙니다.

## 3. 메뉴별 현재 기준

| 메뉴 | P0 구현·검증 | 현재 결정 필요 |
|---|---|---|
| MAP | CRUD, reference protection, 좌표/경계, Save→Reload→Runtime Map Load | 고급 Lock/Template는 후순위 |
| STAGE | Definition, Map/Mission/Wave 참조, Save→Reload, Runtime Stage entry | Replay/Restart/Seed 등은 P1 |
| MISSION | 3개 Type, Type별 필드, Time Limit, 참조/저장 검증 | `target_id`는 Legacy/Deprecated 필드로 보존하며 P0 Runtime 계약에서는 사용하지 않음 |
| CAMPAIGN | Ordered Stage, 참조 검증, Save→Reload, 전체 Stage sequence | Chapter/Story Runtime 여부 |
| FACTION | ID, Name, registry/reference, Save→Reload | Color의 Runtime 의미, Alliance/Hostility Runtime 계약 |
| ROBOT | ID/Faction/Stats/Visual/Skill refs, Save→Reload, 최소 Runtime load | Command A/P/H/M 및 Skill AUTO Runtime 계약 |
| UNIT | ID/Faction/Role/Combat/Visual, Save→Reload, Spawn/AI | 6번째 Role |
| TOWER | Definition, target, attack, Level 2, Visual, Runtime | EMP 중첩/재적용/Upgrade 영향 |

**CANON - TOWER Animation Asset Contract (2026-10-09)**
- sprite_anim is Required.
- idle, attack, hit, death are Optional.
- projectile_anim is Optional.
- State-specific animation becomes Required only when the corresponding Tower Runtime consumption contract is explicitly established.
| BUILDING | Base/Gate/Repair 기본 구조, Save→Reload | Repair 규칙, Gate failure policy, ownership |
| SKILL | 현재 구조/참조 확인 | Execution/Effect/Cost/Cooldown/Animation Runtime 계약 |
| CATALOG | Asset registration, metadata, validation, references, Save→Reload, Object Runtime display | Anchor/Pivot/Frame Runtime contract; Scale is owned by Runtime Object / Presentation |
| VFX | P0 Definition/Validator/Editor/Runtime instance smoke | 추가 Production 범위 |
| SFX | P0 Definition/Validator/Editor/Adapter/runtime event | Master 청취 Production Acceptance |
| BGM | P0 context binding/Editor/Controller/validator | crossfade 및 전체 coverage 여부 |
| VOICE | P0 pilot/Editor/Wave-start trigger | Dialogue/Subtitle authority 및 확장 시점 |

## 4. Master 결정이 필요한 항목

### A. 즉시 결정 — 공통 기반

**Master 승인 완료 — 2026-10-08**

1. 공통 Authoring Contract — **CANON**
   - Edit → Validate → Save → Reload → Verify를 P0 공통 기준으로 적용합니다.
   - Save/Reload/Dirty/Delete/ID/Recovery 규칙을 P0 공통 기준으로 적용합니다.

2. ID 변경·삭제 정책 — **CANON**
   - P0에서는 ID 변경을 허용하지 않습니다.
   - 참조 중인 데이터는 삭제하지 않습니다.
   - 자동 참조 갱신을 사용하지 않습니다.
   - Migration/Redirect는 필요할 경우 별도의 Master 결정을 거칩니다.

3. Localization 기준 언어 — **UNRESOLVED**
   - 이 항목은 이번 승인 범위에서 Canon으로 확정하지 않는다.
   - 실제 Localization 구현 전 별도 결정한다.

### B. 실제 Runtime 검증 직전에 결정

4. Mission `target_id` — **CANON: Deprecated**
   - 기존 Authoring/SQLite 필드는 호환성을 위해 유지합니다.
   - P0 Runtime은 `target_id`를 읽거나 목표 판정에 사용하지 않습니다.
   - 현재 Mission 목표는 `primary_type` 및 Stage/Encounter/Wave 구성에 의해 결정됩니다.
   - 향후 실제 Target 식별자가 필요한 경우 별도의 Master 결정으로 Runtime 계약을 정의합니다.
5. Unit 6번째 Role.
6. Robot Command/Skill Runtime 계약.
7. Tower EMP 규칙.
8. Building Repair Factory 규칙.
9. Skill Runtime Contract.
10. Catalog Visual Asset Runtime Contract — Anchor / Pivot / Frame / Scale
   - Scale is explicitly excluded from the Visual Asset definition; Runtime Object / Presentation owns contextual scale.

### C. 후순위 결정

11. Campaign Chapter/Story Runtime.
12. Faction Color의 Runtime 의미.
13. VFX/SFX/BGM/VOICE Production Acceptance 범위.
14. Production Gate 상태 모델.
15. Asset Editor 통합 UI 범위.
16. Wave/Encounter/Enemy Group/Reward의 독립 Editor 분리 여부.
17. Editor UI Localization 적용 시점.

## 5. 검증 우선순위

새 기능을 늘리기보다 다음 E2E의 판별력을 우선한다.

1. MAP — CRUD / Reference / Save→Reload / Runtime Load
2. CATALOG → ROBOT — Visual Asset Save→Reload→Runtime display
3. CATALOG → UNIT — 동일
4. CATALOG → TOWER — 동일
5. STAGE → MISSION → MAP → Wave/Enemy Runtime
6. CAMPAIGN → Stage sequence → Victory/Defeat
7. VFX/SFX/BGM/VOICE — 각 P0 technical path
8. 필요한 경우 Master의 실제 PIE acceptance

## 6. 구현 완료 판정

메뉴 하나를 구현 완료로 판정하려면 최소한:
- Editor entry 존재
- Definition/Repository/Loader 경로 확인
- Validation 확인
- Save→Reload 확인
- 참조 무결성 확인
- Runtime 소비 메뉴는 최소 E2E 확인

Production Ready는 별도 Master Acceptance이며 자동으로 승격하지 않는다.

## 7. 책임 경계

- Content Editor: 콘텐츠의 존재와 구성.
- Gameplay/Runtime: 콘텐츠의 실행 규칙.
- Settings: 사용자 환경 설정.
- Localization Data: 번역 문자열.
- Content Definition: Localization String ID 참조.
- Asset/Catalog: Source → Visual Asset → Map Asset의 Authoring.
- Object Editor: Robot/Unit/Tower/Building Gameplay Definition.

동일 데이터를 여러 시스템이 중복 소유하지 않는다.

## 8. 문서 정리 정책

현재 기준 문서:
- 이 문서: Content Editor 구현/검증/결정사항 요약
- MENU_GAMEPLAY_INTEGRATED_DEVELOPMENT_PLAN.md: 전체 Gameplay/Content 통합 개발계획
- MENOS_MASTER_REFERENCE.md: 프로젝트 Master Reference
- BGM/SFX/VOICE_PRODUCTION_PIPELINE.md: 각 Presentation 도메인 상세

역사 문서는 삭제하지 않고 다음 위치에 보존:
- docs/archive/content-editor/CONTENT_EDITOR_RUNTIME_AUTHORING_REQUIREMENTS.historical.md
- docs/archive/content-editor/ASSET_EDITOR_CONSOLIDATION_PROPOSAL.historical.md
- docs/archive/content-editor/gameplay_content_settings_boundary_proposal.historical.md

Settings는 독립 Runtime Settings 문서로 유지한다.

## 9. 현재 판정

CONFIRMED:
- Content Editor는 15개 Authoring 메뉴로 구성된다.
- 메뉴별 구현 상태와 Runtime 의미의 확정 수준이 서로 다르다.
- 공통 Authoring 기준과 ID 정책이 여러 메뉴의 검증에 직접 영향을 준다.
- Settings는 Content Editor와 별도 책임이다.

CANON:
- 공통 Authoring Contract를 P0 전체 메뉴에 적용합니다.
- P0에서는 ID 변경을 허용하지 않으며, 참조 중인 데이터는 삭제하지 않고, 자동 참조 갱신을 사용하지 않습니다.

PROPOSAL:
- Localization은 별도 결정 전까지 구현을 확장하지 않는다.
- 나머지 Runtime 결정은 실제 검증 직전에 최소 범위로 결정한다.
- 성공한 메뉴는 추가 확장 없이 STOP한다.

UNVERIFIED:
- 모든 메뉴의 최신 foreground/PIE 상태.
- 각 메뉴의 Production Acceptance.
- 아직 Canon으로 승인되지 않은 위 결정사항.

OUT OF SCOPE:
- 새 메뉴 추가
- Story/Dialogue 선행 구현
- Production Lock 전체 구현
- 전체 Audio/Voice asset expansion
- Commit/Push

## 10. 기준선

**역사적 기준선 스냅샷 (문서 작성 시점: 2026-10-08; 현재 저장소 상태가 아님)**

HEAD: `6a5ec357`

Branch: `main`

이번 정리는 문서 구조만 변경했다. 코드/Asset/SQLite는 변경하지 않았다. 현재 기준선은 작업 시작 시점의 Git 상태와 `state/CURRENT_STATE.md`에서 확인한다.

## GUI Verification Tooling Decision — 2026-10-08

| 항목 | 결정 | 근거 |
|---|---|---|
| mss | 유지 | 대형 듀얼 모니터 화면에서 필요한 영역만 캡처하고 축소 가능 |
| pyautogui | 유지 | Godot 실제 GUI 클릭/키 입력 확인 |
| winapp CLI | 보조 유지 | Godot 창 탐색, DPI/물리 좌표 및 창 단위 진단 |
| pywinauto | 제거 | Godot 내부 Control이 UIA/Win32 child control로 노출되지 않음 |

**최소 GUI E2E 결과:** ROBOT → UNIT → TOWER Editor 진입 및 RELOAD 동작 PASS.

**검증 경계:** GUI Editor 검증은 PIE VERIFIED를 자동 승격하지 않는다. Master의 실제 Runtime acceptance는 별도 검증으로 유지한다.


## 2026-10-09 ? Unit/Tower Visual Asset P0 E2E Gate

**STATUS - PASS**

- UNIT representative Asset `unit.basic.default`: GUI edit ? SAVE -> RELOAD ? fresh Runtime visual observation ? restoration completed.
- TOWER representative Asset `tower.rail.default`: GUI edit ? SAVE -> RELOAD ? fresh Runtime visual observation ? restoration completed.
- Runtime consumers were independently confirmed as Unit `default_image` and Tower `sprite_anim`, resolved through `VisualAssetResolver`.
- CODE / DATA-PERSISTENCE / EDITOR verification: PASS.
- Runtime screen observation: PASS.
- Master final PIE acceptance: NOT VERIFIED and remains a separate gate.
- This does not imply completion of every Unit/Tower Visual Asset.
