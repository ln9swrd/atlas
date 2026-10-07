# MENOS 필수 개발·검증·Asset 프로그램 목록

작성일: 2026-10-07

## 목적
MENOS 개발, SQLite 데이터 검증, Python 테스트, VFX/SFX/BGM 제작, Runtime 검증에 필요한 최소 프로그램을 관리한다.

## 최종 설치 목록

| 프로그램 | 상태 | 확인 버전 |
|---|---|---|
| Godot 4.7.2 | INSTALLED | 4.7.2.stable |
| Git | INSTALLED | 설치 확인 |
| Git LFS | INSTALLED | 설치 확인 |
| Visual Studio Code | INSTALLED | 설치 확인 |
| Python | INSTALLED | 3.14.5 |
| pytest | INSTALLED | 9.1.1 |
| DB Browser for SQLite | INSTALLED | 3.13.1 |
| PowerToys | INSTALLED | 0.101.2362.0 |
| Everything | INSTALLED | 1.4.1.1032 |
| FFmpeg | INSTALLED | 설치 확인 |
| Audacity | INSTALLED | 4.0.1 |
| Blender | INSTALLED | 5.2.0 |
| Krita | INSTALLED | 5.3.4 |
| ImageMagick | INSTALLED | 7.1.2-31 Q16-HDRI |
| 7-Zip | INSTALLED | 19.00 |
| OBS Studio | INSTALLED | 32.2.2 |

## 용도
- Godot: MENOS Engine, Editor, PIE, Build
- Git/Git LFS: 소스와 대형 Asset 버전 관리
- VS Code: GDScript, 설정, 로그
- SQLite Browser: menos.sqlite 직접 검증
- Python/pytest: 자동화와 데이터 테스트
- Everything: 프로젝트 파일 검색
- PowerToys: Windows 작업 효율
- FFmpeg: BGM/SFX/영상 변환
- Audacity: SFX/BGM 편집
- Blender: 3D, Animation, VFX Asset
- Krita: 2D, Texture, VFX 이미지
- ImageMagick: 이미지 변환과 일괄 처리
- 7-Zip: Asset/Build 압축 관리
- OBS Studio: Editor/PIE Runtime 기록

## AI 토큰 사용
별도의 토큰 절감 프로그램은 설치하지 않는다. 필요한 파일만 선별하고 pytest/Godot 테스트로 실패 범위를 좁혀 AI에 전달하는 방식으로 관리한다.

## 작업 안전성
MENOS 기존 코드와 Asset은 수정하지 않았다.
작업 시작 전에 존재하던 projects/menos/godot/locale/editor_ui.csv.import 변경도 건드리지 않았다.
추가된 프로젝트 문서는 이 파일 하나다.

## 검증 기준
프로그램 설치 확인은 MENOS 기능 검증과 별개다.
CODE VERIFIED, BUILD VERIFIED, EDITOR VERIFIED, PIE VERIFIED는 실제 해당 검증을 수행했을 때만 부여한다.
pytest PASS는 PIE VERIFIED가 아니다.
