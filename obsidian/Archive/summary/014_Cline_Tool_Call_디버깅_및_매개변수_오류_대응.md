# 014. VS Code Server / Copilot 오류 및 Ollama GPU 디버깅

---

## 1. VS Code Server + Copilot 모듈 누락 오류

### 증상
```
Cannot find module
.../.vscode-server/bin/<hash>/extensions/copilot/dist/tikTokenizerWorker.js
```

### 원인
- VS Code Server와 Copilot Extension 버전 불일치
- Extension 업데이트 중 파일 구조 변경 / 캐시 꼬임
- Continue 설치·VS Code 업데이트·WSL Server 재설치가 겹친 경우

### 해결 (우선순위)

**1순위 – VS Code Server 전체 재설치**
```bash
rm -rf ~/.vscode-server
# VS Code 종료 후 Remote-WSL 재접속 → Server 자동 재설치
```

**2순위 – Copilot만 재설치**
```bash
rm -rf ~/.vscode-server/extensions/github.copilot*
# Ctrl+Shift+P → Developer: Reload Window
# Extensions에서 Copilot 재설치
```

### 확인
```bash
ls ~/.vscode-server/bin/          # 폴더 개수 확인
code --version
```

---

## 2. Ollama GPU 사용 여부 판정

### 신뢰할 지표: `nvidia-smi`
```
RTX 3060 12GB
Memory-Usage : 11917MiB / 12288MiB
GPU-Util     : 99%
Power        : 129W
Process      : llama-server.exe
```
→ VRAM·사용률·전력·프로세스가 보이면 **GPU 추론 중**.

### `ollama ps`의 PROCESSOR 표시
Windows + WDDM 환경에서는 `100% CPU`처럼 잘못 나올 수 있음.  
**`nvidia-smi`를 신뢰**하는 것이 맞다.

### 주의
VRAM이 거의 한계(11.9/12GB)이면 컨텍스트 증가·다른 GPU 프로그램으로 응답이 급격히 느려지고, Atlas 같은 큰 프로젝트에서 타임아웃이 나기 쉽다.

---

## 3. 모델이 "사라졌을" 때

증상: `ollama show qwen3:32b` → `model not found`  
(이전에는 list에 있었고, nvidia-smi에는 llama-server가 돌고 있음)

### 확인 순서
```powershell
where.exe ollama
ollama list
ollama ps
echo $env:OLLAMA_MODELS
echo $env:OLLAMA_HOST
```

### 의심 시나리오
1. 다른 Ollama 서버에 연결 중 (`OLLAMA_HOST` 변경)
2. 모델 저장소 경로 변경 (`OLLAMA_MODELS`)
3. Ollama 업데이트로 모델 인덱스 꼬임

### 권장 구성 (당시)
1. WSL Ollama 제거 → **Windows Ollama 하나만** 사용
2. Cline에서 모델명 정확히 지정 (`qwen3:32b` 등)
3. 가능하면 요청 타임아웃 늘리기
4. 양자화 버전 확인: `ollama show <model>`
