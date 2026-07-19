# Atlas Knowledge Base (지식 베이스)

이 문서는 Atlas 프로젝트에서 정의된 주요 규칙들의 아키텍처적 의도와 설계 이유(Rationale)를 누적하는 공유 저장소입니다.

---

## 1. Blender 규칙 의도

### Modifier Stack Order (Mirror ➔ Bevel ➔ Weighted Normal)
* **의도**: 셰이딩 품질 및 작업 대칭성 확보.
* **이유**:
  1. **Mirror**: 대칭 메쉬가 존재해야 Bevel 연산이 중심선 좌우에 균일하게 들어갑니다.
  2. **Bevel**: 모서리에 서포트 루프(Support Loop)를 자동으로 형성하여 현실적인 하이라이트 라인을 만듭니다.
  3. **Weighted Normal**: Bevel을 통해 나뉜 넓은 페이스의 법선 가중치를 기준으로 정점 노멀을 정렬하여, 원치 않는 셰이딩 왜곡(Shading Stretch)을 보정합니다. 따라서 반드시 가장 나중에 연산되어야 합니다.

### Pivot World Origin (0, 0, 0) 및 Transform Apply
* **의도**: 언리얼 엔진 임포트 및 월드 조립의 모듈화 보장.
* **이유**: Pivot 점이 원점`(0, 0, 0)`이 아닐 경우, 언리얼 임포트 시 로컬 피벗 위치가 깨져 모듈형 조립 스냅이 불가능해집니다. Scale을 `1.0`으로 고정하지 않으면 엔진 내부에서 충돌체 크기나 물리 연산 시 오차가 발생합니다.

---

## 2. Unreal Engine 규칙 의도

### Event Tick 사용 금지
* **의도**: 프레임 레이트 저하 및 CPU 병목 방지.
* **이유**: Event Tick은 매 프레임 실행되므로 미세한 연산도 60fps/120fps 환경에서는 엄청난 오버헤드가 됩니다. 프레임 종속적 로직은 타이머(Timer by Event/Function)나 이벤트 위임(Event Dispatchers)을 사용해야 합니다.

### Soft Object References 사용 권장
* **의도**: 메모리 로드 최적화 및 에셋 종속성 스파게티 방지.
* **이유**: Hard Reference를 쓰면 에셋 인스턴스를 인스턴스화할 때 참조된 모든 하위 에셋(텍스처, 사운드, 기타 메쉬)이 메모리에 강제로 풀 로드됩니다. Soft Reference를 사용하여 실제 사용 시점에 동적으로 비동기 로딩(`Async Load Asset`)해야 디바이스 가용 메모리를 유지할 수 있습니다.
