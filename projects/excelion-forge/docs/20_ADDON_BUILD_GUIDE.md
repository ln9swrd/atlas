# Blender Addon 배포 빌드 가이드

이 문서는 개발 디렉토리의 Excelion Forge 애드온 소스를 Blender 표준 배포 구조(`addons/excelion_forge`)로 정형화하여 패키징하는 빌드 파이프라인의 아키텍처 및 사용 가이드입니다.

---

## 1. 개요 및 설계 의도

Blender 애드온은 배포 및 설치 시 `addons/` 디렉토리 하위에 위치해야 원활하게 작동합니다. 그러나 개발 도중에는 프로젝트 루트에 `excelion_forge/` 패키지가 존재하는 것이 개발 및 테스트 도구(Pytest, Pyrefly 등)와의 연동성에서 훨씬 유리합니다.

이러한 개발 편의성과 배포 규격 간의 불일치를 해소하기 위해 **빌드 격리식 패키징 방식**을 채택했습니다:
* 개발 단계: `project_root/excelion_forge/` 에서 직접 작업 및 테스트 수행.
* 빌드/배포 단계: `scripts/build_addon.py`를 실행하여 배포 표준 구조인 `addons/excelion_forge` 형태로 격리 가공하고 `.zip`으로 압축.

---

## 2. 빌드 디렉토리 구조

빌드 스크립트를 실행하면 프로젝트 루트에 `build/` 디렉토리가 자동 생성(또는 청소)되며 아래 구조로 패키징이 진행됩니다.

```text
project_root/
  ├── build/
  │    ├── addon/
  │    │    └── excelion_forge/          <-- 배포용 수집 원본 소스 복사본
  │    │         ├── core/
  │    │         ├── operators/
  │    │         ├── ui/
  │    │         ├── utils/
  │    │         ├── properties.py
  │    │         ├── __init__.py
  │    │         ├── README.md           <-- 복사된 프로젝트 정보
  │    │         └── LICENSE             <-- 복사된 라이선스 문서 (존재할 경우)
  │    └── dist/
  │         └── excelion_forge_v0.2.0.zip <-- 최종 배포 및 설치용 zip 패키지
```

* `build/` 폴더는 로컬 빌드 임시 출력이므로 `.gitignore`를 통해 Git 추적 대상에서 완전히 배제됩니다.

---

## 3. 빌드 파이프라인 단계

`scripts/build_addon.py` 스크립트는 안전한 배포 릴리즈와 릴리즈 문서 및 버전 태그 간의 정합성을 보장하기 위해 총 6가지 단계로 작동합니다.

1. **Step 1: Extracting Addon Version**
   - `excelion_forge/__init__.py` 내의 `bl_info` 튜플에서 `"version"` 값을 파싱하여 버전을 추출합니다. (예: `(0, 2, 0)` -> `"0.2.0"`)
2. **Step 2: Validating Version Consistency**
   - `bl_info`에서 추출한 버전과 `pyproject.toml`에 기재된 프로젝트 버전, `docs/CHANGELOG.md` 문서상의 릴리즈 버전 명세를 상호 검증합니다.
   - **Git Tag 연동 검증**: 만약 현재 커밋에 릴리즈 태그(`v*`)가 바인딩된 상태라면, Git Tag 정보 또한 추출하여 코드/문서 상의 버전 명세와 100% 매칭하는지 정합성을 강제 검사합니다.
   - 불일치가 발견되면 오류를 발생시키고 배포를 즉시 차단합니다.
3. **Step 3: Running Unit Tests**
   - 패키징 전 전체 테스트 슈트(`pytest`)를 실행하여 기능 정상 작동 여부를 검증합니다.
   - 단 하나라도 테스트가 실패하면 빌드가 즉시 중단되어 비정상적인 코드가 배포되는 위험을 원천 차단합니다.
4. **Step 4: Collecting Sources**
   - `excelion_forge/` 소스 코드 전체와 프로젝트 루트의 `README.md`, `LICENSE` 파일을 `build/addon/excelion_forge/` 경로로 수집합니다.
   - 복사 과정에서 `__pycache__`, `.git*`, `*.blend~` 등의 개발 부산물은 자동으로 필터링 및 제외됩니다.
5. **Step 5: Validating Addon Structure**
   - 수집된 복사본 내부에 필수 파일 및 서브폴더 구성 요소(`__init__.py`, `properties.py`, `core`, `operators`, `ui`, `utils`)가 유실 없이 잘 구성되었는지 엄격히 검증하며, 누락 시 누락 목록을 상세히 에러 메시지로 리포팅합니다.
6. **Step 6: Creating Zip Archive**
   - 수집 및 검증이 완료된 소스를 `build/dist/` 디렉토리 안에 `excelion_forge_v{version}.zip` 파일명으로 패키징 압축을 완료합니다.

---

## 4. 빌드 실행 방법

로컬 및 CI/CD 환경에서 배포용 zip을 생성하려면 아래 명령을 실행합니다.

### 4.1. uv를 사용하는 경우 (권장)
```bash
uv run python scripts/build_addon.py
```

### 4.2. 일반 Python 가상환경을 사용하는 경우
```bash
python scripts/build_addon.py
```
