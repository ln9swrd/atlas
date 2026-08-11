# P2 R5 Project Policy Review — 2026-08-11

기준점(정리 후): `4431e3a7…`  
감사 HEAD: `87569e11…`  
선행: `POLICY_HOLD_SURVEY` · `MAIN_STATE_FINAL_AUDIT`  
역할: **조사 + 문서화만** (삭제·이동·rename·submodule **0**)

---

## 공통 조사 결과

| 검사 | 결과 |
|------|------|
| tools / tests / .github 참조 | **0** (4개 전부) |
| projects/excelion 참조 | **0** |
| state/PROJECT_MAP | HOLD unregistered (ACTIVE 금지) |
| projects/README.md | 실험/벤더 표기만 |
| CI | unittest only · R5 미포함 |

→ Atlas **운영 SoR(`tools/` `core/` `tests/` `state/`) 비의존**.

단, “참조 0”만으로 즉시 REMOVE하지 않음 — 출처·실익·분리 비용을 아래 반영.

---

## 1. projects/3GUpbit/

| 항목 | 내용 |
|------|------|
| 규모 | ~600K · 9 files |
| 성격 | **개인 실험** — Beeware/toga 데스크톱 UI + Upbit API 키 설정(`config.ini` / `dbconfig.py`) |
| README | **없음** |
| 실행 | toga `App('3GUpbit')` · 완성도 낮음(주석 다수) |
| 최근 로그 | 이관/정리 커밋 · 제품 연동 없음 |
| Atlas 필요성 | **없음** (거래소 UI ≠ DevOS/Excelion) |
| 독립성 | 높음 · monorepo 필수 아님 |
| 민감 | `config.ini` 패턴상 키 자리 — 유출 주의(내용 검증은 별도) |

| 권고 | **EXTERNALIZE 또는 ARCHIVE** |
|------|------------------------------|
| Risk | Low–Med (키 파일 존재 가능) |
| 즉시 REMOVE | 가능하나 이력·키 백업 확인 후 |
| Master 승인 | **예** |

---

## 2. projects/aws-mcp/

| 항목 | 내용 |
|------|------|
| 규모 | ~2.2M · 8 files (이미지 포함) |
| 성격 | **벤더 복사본** — 원본 `RafalWilinski/aws-mcp` (README clone URL) |
| 스택 | Node/TS · pnpm · Claude Desktop용 AWS MCP |
| package.json | `chatwithcloud-mcp` |
| Atlas 필요성 | **없음** (AWS 자격·Claude Desktop 로컬 도구) |
| 독립성 | 완전 외부 제품 · monorepo에 둘 실익 없음 |
| 실행 | Atlas CI와 무관 · 로컬 AWS 자격 필요 |

| 권고 | **EXTERNALIZE** (별도 레포 또는 upstream만 사용) / **ARCHIVE** |
|------|------|
| Risk | Low (런타임 무) · Med 용량 |
| 즉시 REMOVE | 가능 (upstream 존재) |
| Master 승인 | **예** |

---

## 3. projects/blender-mcp-main/

| 항목 | 내용 |
|------|------|
| 규모 | ~612K · 12 files |
| 성격 | **벤더 BlenderMCP** (Claude 등 ↔ Blender socket, 대표 포트 9876) |
| 스택 | Python · uv · `src/blender_mcp/server.py` (~951 LOC) |
| README | upstream Blender MCP 문서 |
| Atlas/Excelion | **코드 참조 0** · Excelion 파이프라인(Blender→UE)과 **미연결** |
| 독립성 | 외부 도구 복사 |

| 권고 | **EXTERNALIZE / ARCHIVE** |
|------|---------------------------|
| Risk | Low |
| Master 승인 | **예** |

---

## 4. projects/blender-open-mcp/

| 항목 | 내용 |
|------|------|
| 규모 | ~216K · 15 files (+ tests 3) |
| 성격 | **Ollama 연동 Blender MCP** (open models) |
| 스택 | Python · `blender_open_mcp` v2.0.0 · FastMCP + Ollama HTTP |
| 저자 메타 | Nirajan Dhakal (pyproject) |
| 이력 | root submodule → `projects/` 이동 흔적 |
| Atlas 참조 | **0** |

| 권고 | **EXTERNALIZE / ARCHIVE** |
|------|---------------------------|
| Risk | Low |
| Master 승인 | **예** |

---

## blender-mcp-main ↔ blender-open-mcp 비교

| | blender-mcp-main | blender-open-mcp |
|--|------------------|------------------|
| LLM 경로 | Claude Desktop 등 외부 MCP 클라이언트 | **Ollama 로컬** 명시 |
| 패키지명 | `blender_mcp` | `blender_open_mcp` |
| server.py | ~951 LOC | ~1043 LOC |
| tests | 없음(트리) | `tests/` 3파일 |
| canonical | **없음** (둘 다 벤더·Atlas 미사용) | 동일 |
| 중복 | 같은 Blender socket MCP 계열 · **둘 다 monorepo 불필요** | |

권고: **둘 다** Atlas 밖 처리. 하나 고를 제품 요구 없음 → merge 불필요.  
Excelion이 Blender MCP를 쓸 경우 **신규 정식 연동**을 projects/excelion 쪽에서 설계 (현 복사본 승격 비권장).

---

## 종합 표

| Project | Atlas 참조 | CI | Runtime | 독립성 | 권고 | Risk |
|---------|------------|-----|---------|--------|------|------|
| `3GUpbit/` | 0 | 0 | 0 | 높음(실험) | **ARCHIVE / EXTERNALIZE** | Low–Med |
| `aws-mcp/` | 0 | 0 | 0 | 완전 외부 | **EXTERNALIZE / ARCHIVE** | Low |
| `blender-mcp-main/` | 0 | 0 | 0 | 벤더 | **EXTERNALIZE / ARCHIVE** | Low |
| `blender-open-mcp/` | 0 | 0 | 0 | 벤더 | **EXTERNALIZE / ARCHIVE** | Low |

### 분류 요약

| 분류 | 대상 |
|------|------|
| 즉시 제거 가능 (승인 후) | 4개 모두 (upstream/실험 · SoR 비의존) |
| archive 권고 | 4개 — `archive/projects-unregistered/` 일괄 이동 옵션 |
| 외부 분리 권고 | aws-mcp · blender-* (원 upstream 사용 권장) · 3GUpbit는 개인 레포 |
| Atlas 유지 권고 | **없음** |
| 추가 조사 필요 | 3GUpbit `config.ini` 실키 여부(보안)만 선택적 |

### Master 정책 옵션 (실행은 승인 후)

1. **ARCHIVE 일괄** → `archive/projects-unregistered/{name}/`  
2. **REMOVE** (트리에서 삭제, 이력 보존)  
3. **HOLD 유지** (현 상태 · ACTIVE 금지 유지)

권장: **1 (ARCHIVE)** — 실수 복구 쉬움 · monorepo 루트/projects 혼입 해소.

---

## 보호 영역

excelion / `_template` / vision: **조사만 · 변경 0**

## 이번 작업

삭제·이동·rename·submodule: **0**  
문서만 추가.

## 다음

Master가 옵션 1/2/3 선택 후 별도 실행 지시.
