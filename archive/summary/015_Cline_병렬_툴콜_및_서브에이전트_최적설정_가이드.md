# 015. Cline 병렬 툴콜 / Subagents 최적 설정 가이드

> **원칙**  
> 문제 추적 중에는 **변수를 줄인다**. 안정화 후에 기능을 하나씩 켠다.

---

## 1. 타임아웃 vs Tool Call 실패

### Ollama request timed out (30s)
```
Cline이 파일 읽기 성공
  → 프롬프트 생성
  → Ollama에 전달
  → 30초 안에 첫 응답 없음 → 타임아웃 → 재시도
```

원인 후보:
1. Ollama 느림 (CPU 실행 / 메모리 부족 / GPU 미사용) – 가장 흔함
2. 모델 미설치 또는 잘못된 태그
3. Cline timeout이 너무 짧음
4. Ollama 서버 비정상

확인:
```bash
ollama list
ollama ps
ollama run qwen3:8b "hello"   # 첫 글자까지 몇 초?
```
- 3~10초 → Cline 설정 쪽 의심
- 30초 이상 → Ollama 실행 환경 문제

### repeated tool call failures
모델이 답변을 못한 것이 아니라, **Cline이 Tool 호출을 여러 번 실패하고 중단**한 것.

```
Tool Call 생성 → 실패 → 재시도 → … → 중단
```

Qwen3 + Cline에서 Tool Calling 형식/템플릿이 맞지 않으면 Tool Loop에 빠질 수 있음.

---

## 2. 디버깅 중 권장 설정 (모두 OFF)

| 설정 | 추천 | 이유 |
|------|------|------|
| **Subagents** | OFF | 요청·Context·Tool Call 수 증가, 세션 복잡도↑ |
| **Native Tool Call** | OFF | 모델 네이티브 형식 의존 → 실패 시 원인 분리 어려움 |
| **Parallel Tool Calling** | OFF | 동시 Tool 실행 → Ollama 부하·실패 복잡화 |

추가:
- 한 번에 하나의 요청만
- Auto approve는 필요한 것만
- Context Window: 8K~16K로 시험 (너무 크게 잡지 않기)
- 같은 프롬프트 반복 실행 자제

---

## 3. 안정화 후 켜는 순서

1. 기본 (모두 OFF) → 정상?
2. Native Tool Call만 ON → 정상?
3. Parallel Tool Calling만 ON → 정상?
4. 마지막으로 Subagents ON

어느 옵션에서 문제가 시작되는지 정확히 찾을 수 있다.

---

## 4. Atlas 개발 단계에서의 Subagents

큰 프로젝트에서는 문서 조사 / 코드 분석 / 테스트 생성을 병렬로 나눌 때 유용할 수 있다.  
다만 **지금은 성능·안정성 검증이 우선** → 안정화 후 필요 시 활성화.

---

## 5. 원인 가설 우선순위 (당시)

1. Cline Tool Calling ↔ Qwen3 조합 문제 ⭐⭐⭐⭐⭐
2. 큰 Context + Timeout으로 세션 꼬임 ⭐⭐⭐⭐
3. Ollama 버전 regression ⭐⭐⭐
4. GPU 문제 ⭐

→ Ollama는 살아 있고, **Cline ↔ Ollama 통신 / Tool Calling 계층**으로 원인이 좁혀진 상태.
