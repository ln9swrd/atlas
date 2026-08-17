# STATUS REPORT - Phase 3: REALTIME VERIFICATION (RUNNING)

## 📋 수집된 정보

### Editor Status
| 항목 | 값 |
|------|-----|
| UnrealEditor PID | 7268 |
| RUNNING | YES |
| Project | Excelion.uproject |

### PIE Status
| 항목 | 값 |
|------|-----|
| RUNNING | UNKNOWN (Master 직접 확인 필요) |
| World Active | WAITING_FOR_TEST |

### Player Spawn
| 항목 | 상태 |
|------|------|
| GameMode Spawned | PENDING_MASTER_VERIFICATION |
| PlayerController | PENDING_MASTER_VERIFICATION |
| PlayerPawn | PENDING_MASTER_VERIFICATION |
| Pawn Class | `BP_ExcelionCharacter` (EXPECTED) |

### Runtime Character Settings
| 항목 | 값 | 상태 |
|------|-----|------|
| bOrientRotationToMovement | UNKNOWN | C++ Default / Need Runtime Read |
| RotationRate | UNKNOWN | Runtime Value Needed |
| bUseControllerDesiredRotation | UNKNOWN | Runtime Value Needed |
| bUseControllerRotationYaw | UNKNOWN | Runtime Value Needed |
| bUseControllerRotationPitch | UNKNOWN | Runtime Value Needed |
| bUseControllerRotationRoll | UNKNOWN | Runtime Value Needed |

### Input Runtime State
| 항목 | 값 | 상태 |
|------|-----|------|
| InputComponent Class | UInputComponent | EXPECTED |
| PlayerInput Class | UPlayerInput (or nullptr) | PENDING_RUNTIME |
| EnhancedInput Enabled | PENDING_LOG_CHECK |
| IA_Move Binding | /Game/Input/IA_Move | FILE EXISTS |
| IMC_Default Active | /Game/Input/IMC_Default | FILE EXISTS |
| Legacy MOVE-AXIS log | NOT FOUND YET | Need Editor Output Check |

### WASD Observation Table (Master Test Required)
| Key | 이동 | 회전 | 비고 | 상태 |
|-----|------|------|------|------|
| W | ⏳ | ⏳ | 전진/회전 관찰 필요 | WAITING |
| A | ⏳ | ⏳ | 좌측/회전 관찰 필요 | WAITING |
| S | ⏳ | ⏳ | 후진/회전 관찰 필요 | WAITING |
| D | ⏳ | ⏳ | 우측/회전 관찰 필요 | WAITING |

### Core Questions Status
| 판정 항목 | 현재 상태 | 근거 여부 |
|----------|-----------|-----------|
| **P0**: bOrientRotationToMovement 회전 발생? | UNKNOWN | Runtime证据证明 필요 |
| **P1**: Enhanced + Legacy Input 동시 호출? | UNKNOWN | Log/Behavior 관찰 필요 |
| **P2**: Blueprint 추가 회전 로직 존재? | UNKNOWN | Actual Behavior 관찰 필요 |

## 🔍 수집 가능한 데이터 (Master 테스트 시)

### 1. Editor Output 로그 검색 대상
```text
Search for: [MOVE-AXIS], EnhancedInput, MoveForward, SetupPlayerInputComponent
Location: Editor Output Log Window OR Saved/Logs/EditorOutput.log
```

### 2. Runtime Character 읽기 방법 (가능하면)
Python via UE Python API:
```python
# Get character from PIE world
character = unreal.EditorLevelLibrary.get_actor_by_class(unreal.BP_ExcelionCharacter)
if character:
    cm = character.CharacterMovement
    print(f"bOrientRotationToMovement: {cm.bOrientRotationToMovement}")
    print(f"RotationRate: Yaw={cm.RotationRate.Yaw}, Pitch={cm.RotationRate.Pitch}")
```

### 3. Master 직접 관찰 사항 (중요)
Master 가 PIE 에서 다음을 확인하세요:
- ✅ 캐릭터가 Spawn 되었는지
- ✅ W 키 누를 때 전진하는지 (회전 없이)
- ✅ A/D 키로 좌우로 이동되는지
- ✅ S 키 후진 되는지
- ✅ 카메라/캐릭터가 예상치 못한 방향으로 회전하지는지

## ⚠️ Known Limitations

### 자동화 제한 사항
1. **UnrealEditor UI 자동화 불가**: Python/win32gui 신뢰성 낮음
2. **Runtime 값 직접 읽기 어렵다**: Read-Only Editor 에서 UE Python API 접근 제한됨
3. **PIE World State 확인 불가**: Log 만으로 PIE World 유무 판정 어려움

### 대체 방법
Master 가 직접 관찰해 주실 것을 요청함:
- WASD 동작 결과를 말씀해 주세요
- 캐릭터 Spawn 상태 확인
- Editor Output 로그에서 이상한 메시지 없는지 확인

## 📌 현재 결정 (Pending Master Test)

```text
VERIFIED:
  - Editor Process Running: YES (PID 7268)
  - Input Assets Exist: YES (IMC_Default, IA_Move, etc.)
  - C++ Auto-Load Code: PRESENT

NOT VERIFIED:
  - PIE Running State: UNKNOWN
  - Character Spawned: PENDING_MASTER_TEST
  - WASD Behavior: WAITING_FOR_OBSERVATION
  - Runtime Settings: NOT READ (Read-Only Limitation)
  - EnhancedInput Active: LOG CHECK NEEDED
  - Legacy Input Fallback: FILE EXISTS (Behavior Unknown)

UNKNOWN:
  - bOrientRotationToMovement (Runtime): Need Behavior Observation
  - P0 (Rotation Issue Root Cause): WAITING_FOR_BEHAVIOR_DATA
  - P1 (Dual Input Active): BEHAVIOR DEPENDENT
  - P2 (BP Rotation Logic): BEHAVIOR DEPENDENT
```

## ✅ 다음 단계

### Master 가 진행해 주실 테스트:
1. PIE 에서 `W`, `A`, `S`, `D` 키 순서로 눌러보기
2. 각 키에 대한 동작 설명하기
3. Editor Output 로그 창 확인 (MOVE-AXIS 같은 로그 있는지)
4. 캐릭터 Spawn되었는지 여부 알려주기

### Master 가 말씀해 주시면:
```text
예시 응답:
"W → 전진하고, 카메라도 회전함"
"A → 좌측으로 이동함"
"S → 후진함"
"D → 우측 이동함"
```

이 결과로 다음 판정을 수행합니다.

---

**업데이트 시각**: 2026-08-17 12:30 (PIE Running Phase)  
**상태**: WAITING_FOR_MASTER_INPUT_TEST  
**제한**: Read-Only, Runtime Data Collection Limited