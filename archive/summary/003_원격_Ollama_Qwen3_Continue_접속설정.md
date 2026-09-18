# 003. 원격 Ollama + Qwen3 → Continue 접속 설정

> **목표**  
> 집 메인 PC(Ollama + Qwen3)에 보조 PC의 Continue(VS Code)로 원격 접속

---

## 1. 기본 구성

```
[집 메인 PC]                    [집 보조 PC]
Ollama + Qwen3                  VS Code + Continue
     │                                │
  11434 포트  ──── LAN ────  HTTP API ─┘
```

- 메인 PC: GPU 추론 서버 역할
- 보조 PC: 개발 터미널 역할 (성능 크게 중요하지 않음)

---

## 2. 메인 PC 설정 (Ollama 네트워크 개방)

### Windows 환경변수
```
OLLAMA_HOST=0.0.0.0:11434
```

또는
```
set OLLAMA_HOST=0.0.0.0:11434
ollama serve
```

### 방화벽
- TCP 11434 허용

### 확인
메인 PC IP 예: `192.168.219.254`

보조 PC에서 테스트:
```
curl http://192.168.219.254:11434/api/tags
```
성공하면 네트워크·API 정상.

---

## 3. Continue 설정 (보조 PC)

### Continue 2.0.0 기준 올바른 config.yaml

```yaml
name: Home Ollama
version: 1.0.0
schema: v1

models:
  - name: Qwen3 Coder
    provider: ollama
    model: qwen3-coder:latest
    apiBase: http://192.168.219.254:11434
    roles:
      - chat
      - edit
      - apply

  - name: Qwen3 Autocomplete
    provider: ollama
    model: qwen2.5-coder:1.5b-base
    apiBase: http://192.168.219.254:11434
    roles:
      - autocomplete
```

**중요**
- `localhost`가 한 글자도 있으면 안 됨
- Continue 2.0은 `version`과 `schema: v1` 필수
- 설정 후 **VS Code 완전 종료 → 재실행** 필요

### 설정 파일 위치 확인
```
Ctrl + Shift + P → Continue: Open Config
```
열리는 파일의 **전체 경로**가 실제 수정한 파일과 일치하는지 확인.

---

## 4. 다른 장소에서 접속할 때

LAN이 아닌 경우 다음 중 하나 사용 (안전):
- Tailscale
- ZeroTier
- WireGuard

예: Tailscale IP `100.64.10.20` → `http://100.64.10.20:11434`

---

## 5. 문제 해결 체크리스트

| 증상 | 원인 | 조치 |
|------|------|------|
| "Install Ollama" 표시 | Continue가 localhost를 보고 있음 | apiBase를 원격 IP로 수정 |
| 설정 반영 안 됨 | config.yaml을 읽지 않음 / 버전 형식 불일치 | version·schema 추가, VS Code 재시작 |
| 네트워크 오류 | 방화벽 또는 OLLAMA_HOST 미설정 | 0.0.0.0:11434 + TCP 11434 허용 |

### 디버깅 순서
1. `curl` / `Invoke-RestMethod`로 API 정상 여부 확인
2. Continue Output 로그 확인 (`View → Output → Continue`)
3. Continue 버전 확인 (2.0.0 등)
4. 실제 로드되는 config 파일 경로 확인

---

## 6. Atlas 관점에서의 의미

이 구성은 Atlas 개발에 특히 적합하다.

- 메인 PC = AI 서버 (Qwen3, GPU 추론)
- 보조 PC = 개발 터미널 (VS Code + Continue + Git)
- 코드는 어디서든 작성하고, 추론은 항상 메인 GPU에서 처리
