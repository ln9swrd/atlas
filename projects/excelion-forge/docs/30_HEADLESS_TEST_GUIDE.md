# Blender Headless 통합 테스트 가이드 및 PoC 보고서

이 문서는 디스플레이 서버가 존재하지 않는 서버 환경(CI/CD 등)에서 Blender 3D 내장 파이썬 환경을 구동하여 Excelion Forge 애드온의 무결성을 검증하기 위한 Headless 실행 구조 및 PoC(Proof of Concept) 조사 보고서입니다.

---

## 1. PoC 조사 및 핵심 아키텍처

### 1.1. `bpy` 모듈 Import 방식 분석
Blender 기능을 Python 스크립트에서 활용하기 위해 `bpy` 모듈을 임포트하는 데는 두 가지 방식이 있습니다.

1. **독립형 Python 패키지 설치 (`pip install bpy`)**
   - **장점**: 일반 파이썬 환경에서 직관적인 라이브러리 형태로 쓸 수 있습니다.
   - **단점**: 파이썬 특정 마이너 버전에 매우 엄격히 종속되며, 컴파일 바이너리가 불안정하여 Blender 최신 5.x 릴리즈 버전의 완전한 기능을 보장하지 못합니다.
2. **Blender 공식 바이너리를 통한 구동 (권장 & 채택)**
   - **장점**: 실제 Blender 핵심 및 모든 API가 내장된 공식 런타임을 사용하므로 100% 호환성을 유지합니다.
   - **방식**: `blender --background <file.blend> --python <script.py>`
   - **결정**: Excelion Forge의 통합 테스트는 이 공식 바이너리 구동 방식을 채택하여 동작합니다.

### 1.2. Headless 실행 시의 Context 제약 및 해결 방안
디스플레이 모니터가 연결되지 않은 CLI/Headless 환경(`--background` 또는 `-b` 플래그)에서는 윈도우 매니저나 3D 뷰포트 영역의 UI Context 정보가 존재하지 않습니다.
이로 인해 Blender UI나 오퍼레이터가 `bpy.context`에서 활성 윈도우나 영역을 조회할 때 `None` 관련 에러를 던지기 쉽습니다.

* **우회 패턴 (PoC 완료)**:
  - Excelion Forge의 오퍼레이터 poll 로직은 단지 실행 컨텍스트의 유무만 확인하도록 단순화하였습니다.
  - 통합 테스트 진입점(`tests/integration/test_blender_validation.py`)에서는 활성 대상을 강제로 바인딩하여 실행을 돕습니다:
    ```python
    # 검증 대상 오브젝트 조회
    obj = bpy.data.objects.get(armature_name)
    # 뷰 레이어에서 액티브 오브젝트로 명시적 강제 바인딩
    bpy.context.view_layer.objects.active = obj
    # 컨텍스트를 충족시킨 후 오퍼레이터 수행
    bpy.ops.excelion_forge.validate_active_rig()
    ```
  - 이 패턴을 통해 GUI가 아예 켜지지 않은 100% CLI 모드에서도 오퍼레이터의 검증 동작이 안정적으로 구동됨을 입증했습니다.

---

## 2. GitHub Actions 및 Linux Runner 호환성

### 2.1. Linux 가용성 검증
GitHub Actions의 기본 가상 환경인 `ubuntu-latest`에서도 별도의 X11/Xvfb 디스플레이 가상 서버 설정 없이, Blender 공식 바이너리의 `--background` 플래그 단독 작동으로 통합 테스트를 완벽하게 구동할 수 있습니다.

### 2.2. CI/CD 내 Blender 설치 및 경로 셋업
CI 러너에서 Blender 5.x를 확보하기 위해 아래의 단순 Shell 명령어를 Workflow 단계로 추가하여 완벽히 호환을 완료합니다.

```yaml
- name: Install Blender 5.0 (Linux x64)
  run: |
    # 공식 아카이브에서 Linux x64 타르볼 다운로드
    wget -q https://download.blender.org/release/Blender5.0/blender-5.0.0-linux-x64.tar.xz
    
    # 압축 해제
    tar -xf blender-5.0.0-linux-x64.tar.xz
    
    # 실행 바이너리가 위치한 폴더를 GitHub Runner의 PATH 환경 변수에 등록
    echo "${{ github.workspace }}/blender-5.0.0-linux-x64" >> $GITHUB_PATH
```

---

## 3. 통합 테스트 실행 명령어

### 3.1. 로컬 환경 실행 (Windows PowerShell 예시)
```powershell
& "C:\Program Files\Blender Foundation\Blender 5.0\blender.exe" `
    --background tests/blend_samples/valid_rig.blend `
    --python tests/integration/test_blender_validation.py
```

### 3.2. 일괄 회귀 테스트 통합 실행
```bash
# 전체 5개 샘플에 대해 순차적으로 백그라운드 블렌더를 기동하여 검증 수행
python tests/integration/run_all.py
```
* 이 스크립트는 자체적으로 바이너리를 스캔하여 누락된 에셋이 있을 경우 `tests/blend_samples/generate_samples.py`를 호출하여 재성성하고, 전체 일괄 패스를 검증합니다.
