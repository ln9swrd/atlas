#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
build_addon.py

Excelion Forge Blender Addon 배포 파이프라인 스크립트.
주요 파이프라인 단계:
1. get_addon_version(): 애드온 버전 정보를 bl_info에서 동적 파싱
2. validate_version(): bl_info, pyproject.toml, CHANGELOG.md, README.md, Git Tag 간 버전 정합성 검증
3. validate_tests(): 유닛 테스트(Pytest) 실행 및 검증
4. collect_sources(): 소스 파일 및 배포 필수 문서 수집 (build/addon/excelion_forge/)
5. validate_structure(): 수집된 애드온 구조의 무결성 검증 (누락 리포트 기능 포함)
6. create_zip(): 배포용 최종 zip 아카이브 생성 (build/dist/excelion_forge_v{version}.zip)
"""

import os
import re
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path


def get_addon_version(init_file_path: Path) -> str:
    """__init__.py 파일에서 bl_info의 version 튜플을 안전하게 파싱하여 버전을 추출합니다."""
    print("Step 1: Extracting addon version...")
    if not init_file_path.exists():
        raise FileNotFoundError(f"__init__.py not found at: {init_file_path}")
        
    content = init_file_path.read_text(encoding="utf-8")
    
    # "version": (0, 2, 0) 형태 매칭
    version_match = re.search(r'"version"\s*:\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)', content)
    if not version_match:
        version_match = re.search(r"'version'\s*:\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)", content)
        
    if version_match:
        major, minor, patch = version_match.groups()
        version = f"{major}.{minor}.{patch}"
        print(f"-> Extracted version: {version}")
        return version
    else:
        print("Warning: Could not parse version from bl_info. Using default '0.0.0'.")
        return "0.0.0"


def get_git_tag() -> str | None:
    """현재 커밋에 정확히 매칭된 git tag가 있는 경우 가져옵니다."""
    try:
        result = subprocess.run(
            ["git", "describe", "--tags", "--exact-match"],
            capture_output=True,
            text=True,
            check=False
        )
        if result.returncode == 0:
            tag = result.stdout.strip()
            # v0.2.0 -> 0.2.0 로 변환
            if tag.startswith('v'):
                return tag[1:]
            return tag
    except Exception:
        pass
    return None


def validate_version(bl_version: str, pyproject_path: Path, changelog_path: Path, readme_path: Path) -> None:
    """bl_info 버전과 pyproject.toml, CHANGELOG.md, README.md, Git Tag 간 정합성을 검증합니다."""
    print("Step 2: Validating version consistency...")
    
    # 1. pyproject.toml 버전 검사
    if not pyproject_path.exists():
        raise FileNotFoundError(f"pyproject.toml not found at: {pyproject_path}")
    pyproject_content = pyproject_path.read_text(encoding="utf-8")
    py_version_match = re.search(r'version\s*=\s*["\']([^"\']+)["\']', pyproject_content)
    if not py_version_match:
        raise ValueError("Could not find version in pyproject.toml")
    py_version = py_version_match.group(1)
    
    # 2. CHANGELOG.md 버전 검사
    if not changelog_path.exists():
        raise FileNotFoundError(f"CHANGELOG.md not found at: {changelog_path}")
    changelog_content = changelog_path.read_text(encoding="utf-8")
    
    changelog_version_match = re.search(
        r'(?:>\s*Version\s*:\s*v|#\s*v)(\d+\.\d+(?:\.\d+)?)', changelog_content
    )
    if not changelog_version_match:
        raise ValueError("Could not find version in CHANGELOG.md")
    changelog_version = changelog_version_match.group(1)
    
    # 3. README.md 버전 검사 (존재 및 기재 시에만 체크)
    readme_version = None
    if readme_path.exists():
        readme_content = readme_path.read_text(encoding="utf-8")
        readme_version_match = re.search(
            r'(?:excelion[-_]forge|Version)\s*:\s*v?(\d+\.\d+(?:\.\d+)?)',
            readme_content,
            re.IGNORECASE
        )
        if readme_version_match:
            readme_version = readme_version_match.group(1)
            print(f"-> README.md version found: {readme_version}")
        else:
            print("-> README.md version not specified (skipping README version check).")
            
    # 4. Git Tag 검사 (존재 시에만 대조하여 릴리즈 정합성 보장)
    git_tag = get_git_tag()
    if git_tag:
        print(f"-> Active Git Tag found: v{git_tag}")
    else:
        print("-> No exact git tag found for this commit (skipping Git Tag version check).")
        
    # 정합성 딕셔너리 구성 (존재하는 값만 집계)
    versions = {
        "bl_info": bl_version,
        "pyproject": py_version
    }
    
    # CHANGELOG 버전의 메이저.마이너 부분을 bl_info 와 대조하여 호환성 확인 후 등록
    bl_parts = bl_version.split('.')
    cl_parts = changelog_version.split('.')
    if len(bl_parts) >= 2 and len(cl_parts) >= 2:
        if bl_parts[0] != cl_parts[0] or bl_parts[1] != cl_parts[1]:
            raise ValueError(
                f"Version mismatch! bl_info version '{bl_version}' is inconsistent with CHANGELOG.md version '{changelog_version}'"
            )
        versions["changelog"] = bl_version
    else:
        versions["changelog"] = changelog_version
        
    if readme_version:
        # README.md 도 메이저.마이너 일치 수준으로 비교
        rl_parts = readme_version.split('.')
        if len(bl_parts) >= 2 and len(rl_parts) >= 2:
            if bl_parts[0] != rl_parts[0] or bl_parts[1] != rl_parts[1]:
                raise ValueError(
                    f"Version mismatch! bl_info version '{bl_version}' is inconsistent with README.md version '{readme_version}'"
                )
            versions["readme"] = bl_version
        else:
            versions["readme"] = readme_version
            
    if git_tag:
        # Git Tag 도 메이저.마이너 일치 수준으로 비교
        gt_parts = git_tag.split('.')
        if len(bl_parts) >= 2 and len(gt_parts) >= 2:
            if bl_parts[0] != gt_parts[0] or bl_parts[1] != gt_parts[1]:
                raise ValueError(
                    f"Version mismatch! bl_info version '{bl_version}' is inconsistent with Git Tag 'v{git_tag}'"
                )
            versions["git_tag"] = bl_version
        else:
            versions["git_tag"] = git_tag
            
    # 고유값 검사 및 가독성 높은 에러 출력
    unique_versions = set(versions.values())
    if len(unique_versions) != 1:
        details = "\n".join(f"- {k}: {v}" for k, v in versions.items())
        raise ValueError(f"Version consistency check failed! Mismatched versions:\n{details}")
        
    print(f"-> Consistent release versions verified: {versions}")


def validate_tests() -> None:
    """유닛 테스트를 실행하여 모든 테스트가 통과하는지 검증합니다."""
    print("Step 3: Running unit tests (pytest)...")
    
    try:
        result = subprocess.run(
            ["uv", "run", "python", "-m", "pytest"],
            capture_output=True,
            text=True,
            check=False
        )
        
        if result.returncode != 0:
            print("--- Pytest stdout ---")
            print(result.stdout)
            print("--- Pytest stderr ---")
            print(result.stderr)
            raise RuntimeError(f"Unit tests failed with exit code {result.returncode}")
            
        print("-> All unit tests passed successfully.")
        
    except FileNotFoundError:
        print("-> 'uv' command not found, trying fallback python -m pytest...")
        result = subprocess.run(
            [sys.executable, "-m", "pytest"],
            capture_output=True,
            text=True,
            check=False
        )
        if result.returncode != 0:
            print(result.stdout)
            print(result.stderr)
            raise RuntimeError(f"Unit tests failed with exit code {result.returncode}")
        print("-> All unit tests passed successfully.")


def collect_sources(src_dir: Path, build_addon_dir: Path, project_root: Path) -> None:
    """배포에 필요한 소스 코드와 문서 리소스를 수집하여 build/addon/excelion_forge/에 복사합니다."""
    print(f"Step 4: Collecting sources from {src_dir} to {build_addon_dir}...")
    
    if build_addon_dir.exists():
        shutil.rmtree(build_addon_dir)
    build_addon_dir.mkdir(parents=True, exist_ok=True)
    
    ignore_patterns = shutil.ignore_patterns(
        "__pycache__",
        "*.pyc",
        "*.pyo",
        ".git*",
        ".DS_Store",
        "Thumbs.db",
        "*.blend1",
        "*.blend2",
        "*.blend@",
        "*.blend~",
        "*.autosave.blend"
    )
    
    # 1. 소스 디렉토리 복사
    shutil.copytree(src_dir, build_addon_dir, ignore=ignore_patterns, dirs_exist_ok=True)
    
    # 2. 추가 배포 파일 수집 (README.md, LICENSE)
    for filename in ["README.md", "LICENSE"]:
        src_file = project_root / filename
        if src_file.exists():
            print(f"-> Copying extra file: {filename}")
            shutil.copy2(src_file, build_addon_dir / filename)
        else:
            print(f"-> Info: Optional file '{filename}' not found at root, skipping.")


def validate_structure(addon_dir: Path) -> None:
    """수집된 애드온의 내부 파일 및 디렉토리 구조 무결성을 검증합니다."""
    print("Step 5: Validating addon structure...")
    
    required = [
        "__init__.py",
        "properties.py",
        "core",
        "operators",
        "ui",
        "utils"
    ]
    
    missing = []
    for path_name in required:
        target_path = addon_dir / path_name
        if not target_path.exists():
            missing.append(path_name)
            
    if missing:
        raise RuntimeError(f"Validation Failed: Missing addon files/directories: {missing}")
        
    print("-> Structure validation passed successfully.")


def create_zip(build_addons_root: Path, output_zip: Path, version: str) -> None:
    """build/addon/ 하위의 파일들을 패키징하여 build/dist/에 zip 파일로 저장합니다."""
    print(f"Step 6: Packaging zip archive to {output_zip}...")
    
    output_zip.parent.mkdir(parents=True, exist_ok=True)
    
    with zipfile.ZipFile(output_zip, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for file_path in build_addons_root.rglob('*'):
            if file_path.is_file():
                relative_path = file_path.relative_to(build_addons_root)
                arcname = Path("addons") / relative_path
                zipf.write(file_path, arcname)
                
    file_size_kb = output_zip.stat().st_size / 1024
    print(f"-> Addon zip created: {output_zip.name} ({file_size_kb:.2f} KB)")


def main() -> None:
    project_root = Path(__file__).resolve().parent.parent
    src_dir = project_root / "excelion_forge"
    build_dir = project_root / "build"
    build_addon_dir = build_dir / "addon" / "excelion_forge"
    dist_dir = build_dir / "dist"
    
    print("=== Start Excelion Forge Addon Build Pipeline ===")
    
    try:
        # 1. 버전 파싱
        version = get_addon_version(src_dir / "__init__.py")
        
        # 2. 버전 정합성 검증
        validate_version(
            bl_version=version,
            pyproject_path=project_root / "pyproject.toml",
            changelog_path=project_root / "docs" / "CHANGELOG.md",
            readme_path=project_root / "README.md"
        )
        
        # 3. 테스트 검증
        validate_tests()
        
        # 4. 소스 수집
        collect_sources(src_dir, build_addon_dir, project_root)
        
        # 5. 무결성 검증
        validate_structure(build_addon_dir)
        
        # 6. 압축 아카이브 생성
        output_zip = dist_dir / f"excelion_forge_v{version}.zip"
        create_zip(build_addon_dir.parent, output_zip, version)
        
        print("=== Build Pipeline Completed Successfully ===")
        
    except Exception as e:
        print(f"Build Failed: {e}")
        exit(1)


if __name__ == "__main__":
    main()
