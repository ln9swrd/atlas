# 004. ATLAS-VERIFY-007 및 Continue 실행환경

> **핵심**  
> "구현되었다"는 주장과 "실제로 검증되었다"는 사실을 분리한다.

---

## 1. ATLAS-VERIFY-007 상태 판정

| 항목 | 상태 |
|------|------|
| 구현 Claim | `CLAIMED` |
| 실제 검증 | `UNVERIFIED` |
| 다음 단계 | 실행 기반 증거 수집 후 `VERIFIED` 또는 `FAILED` 판정 |

### 원칙
- 파일이 존재한다는 사실만으로 구현 완료라고 판단하지 않는다.
- 각 요구사항마다 **Claim / Evidence / Verification Result**를 분리한다.
- 실행 증거가 없는 항목은 반드시 `UNVERIFIED`로 분류한다.

### 검증에 필요한 증거 예시
- 실제 파일을 읽었다
- 필요한 메서드가 존재한다
- 각 메서드를 실행했다
- 예상 결과를 얻었다
- 생성된 artifact를 다시 읽었다
- 상태 기록이 실제로 남았다

---

## 2. Continue 실행 환경 미스터리

### 현재 의심되는 구조
```
Windows Host
├── Docker Desktop
├── WSL2 (Ubuntu)
│    └── /mnt/d/Atlas   ← 실제 작업공간
└── VS Code
     └── Remote - WSL
          ├── Workspace = /mnt/d/Atlas
          ├── Terminal = WSL
          └── Continue ???  ← 실행 위치 확인 필요
               └── Agent Tool → 실제 실행 주체 ???
```

가능한 실행 경로:
- A. VS Code(WSL) → Continue(WSL) → WSL Shell
- B. VS Code(WSL) → Continue(Windows Host) → PowerShell
- C. VS Code(WSL) → Continue → Docker Container → Shell
- D. VS Code(WSL) → Continue → Remote Agent Host → 별도 환경

**Qwen이 "Windows PowerShell"이라고 주장한 것만으로는 실제 executor를 확정할 수 없다.**

---

## 3. 진단 순서 (재설치 전에 할 것)

1. **VS Code가 진짜 WSL 모드인지 확인**  
   왼쪽 아래 `WSL: Ubuntu` 표시 여부

2. **Continue 확장 설치 위치 확인**  
   Extensions → Continue → `Local` / `WSL: Ubuntu` 중 어디에 설치되어 있는지

3. **Continue Agent Tool 실행 위치 확인**  
   - Windows라면: `$env:OS`
   - WSL이라면: `uname -a` / `cat /etc/os-release`

4. **VS Code 통합 터미널 vs Continue Tool 비교**  
   둘 다 `pwd` / `uname -a` 실행 → 결과가 다르면 컨텍스트가 분리된 것

---

## 4. Continue 재설치에 대한 판단

**지금은 재설치하지 말 것.**

| 항목 | 재설치 영향 |
|------|-------------|
| `D:\Atlas` / `/mnt/d/Atlas` 소스 코드 | 영향 없음 |
| Git 저장소 | 영향 없음 |
| Ollama / Qwen 모델 | 영향 없음 |
| Continue config.yaml / 모델 설정 / Agent 설정 | **백업 권장** |
| Continue 대화 기록 | 보존 여부 확인 필요 |

### 백업 명령 (PowerShell)
```powershell
Copy-Item "$env:USERPROFILE\.continue" "$env:USERPROFILE\.continue.backup" -Recurse
```

`C:\Users\ln9swrd\.continue` 안에 `D:\Atlas` 프로젝트 자체가 저장되어 있는 것은 아님.  
Continue의 설정·캐시·세션 데이터만 있을 수 있음.

---

## 5. Atlas 철학과의 연결

> Atlas에서는 **코드가 존재하는 것**과 **시스템이 작동하는 것**은 별개의 사실이다.

이번 작업은 그 둘을 분리하는 시험대이다.  
검증 엔진을 만들었다는 Claim을, 검증 엔진이 실제로 검증 가능한지 다시 검증하는 **자기검증 루프**로 들어가야 한다.
