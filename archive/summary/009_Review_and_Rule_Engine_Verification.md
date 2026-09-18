# 009. Review / Rule Engine / WSL·Continue 환경 & 동기

---

## 1. VS Code + Continue를 WSL로 전환할 때

### settings.json (터미널만 바꾸는 설정)
```json
{
  "terminal.integrated.profiles.windows": {
    "WSL": {
      "path": "C:\\Windows\\System32\\wsl.exe"
    }
  },
  "terminal.integrated.defaultProfile.windows": "WSL"
}
```
→ VS Code 기본 터미널을 WSL로 바꾼다. **Continue 실행 환경을 바꾸는 설정은 아니다.**

### Continue가 따라가는 것
Continue는 **VS Code가 어떤 Remote 환경을 열고 있는가**를 따라간다.

| 연 방식 | Continue 실행 위치 |
|---------|-------------------|
| Windows에서 `D:\Atlas` 열기 | Windows (cmd/PowerShell) |
| WSL에서 폴더 열기 / Remote - WSL | WSL (bash) |

### 확인 방법
VS Code 좌측 아래:
- `WSL: Ubuntu` → Continue도 WSL
- 표시 없음 → Windows

---

## 2. Atlas 권장 구조

```
Windows
 └─ VS Code
      └─ Remote - WSL
           └─ Ubuntu
                └─ ~/Atlas   ← 권장 (WSL 내부)
                     └─ Continue
                          └─ Ollama (WSL)
```

| 방식 | 평가 |
|------|------|
| `/home/사용자/Atlas` (WSL 내부) | **권장** – 성능·inotify·Git·Docker 안정 |
| `/mnt/d/Atlas` (Windows 드라이브 마운트) | 가능하나 파일 감시·성능 이슈 가능 |

`D:\Atlas`에 그대로 두면 WSL 프로젝트가 아니다. 완전 전환 시 WSL 내부로 옮기는 것이 안정적.

---

## 3. 동기와 목표 (대화에서 드러난 맥락)

> "지금까지 살면서 내가 했던 말이 거짓말이 아니라는 걸 증명하고 싶어."

- **진짜 목표**: 게임을 끝까지 만들어 세상에 내놓는 것 (창작의 완성)
- Atlas는 그 목표에 더 빨리, 더 멀리 가기 위한 **도구**
- 순서: 가족 지키기 → 만들고 싶은 게임 완성 → 가능하면 상업적 성공

성공의 두 종류:
1. **시장 성공** – 운·타이밍 비중 큼
2. **창작의 완성** – 자신의 의지가 더 큰 비중, 남이 빼앗을 수 없는 성취

---

## 4. 한 줄 정리

기술적으로는 **Continue = VS Code Remote 환경을 따른다**. 터미널 설정만으로는 부족하고, Remote - WSL로 프로젝트를 열어야 한다.  
프로젝트 관점에서는 Atlas·게임·가족이 한 줄로 이어져 있으며, 당장의 환경 이슈는 그 긴 여정의 일부이다.
