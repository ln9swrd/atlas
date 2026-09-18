# 078. SERA v0.1 Repository Architecture 초안

## 핵심

- SERA = 플랫폼, EXCELION Forge = 첫 도메인 프로젝트.
- Forge의 Evidence·Runtime Verification·Context Preservation → SERA 플랫폼 자산으로 승격. Blender 종속은 Forge에 잔류.
- 구조: `architecture/`(Doctrine, ADR, principles) / `platform/core/` / `projects/EXCELION-Forge/` / tools / experiments / archive.
- 첫 작업 순서: OPERATING_DOCTRINE.md → PLATFORM_ARCHITECTURE.md → ADR-001 → git init.
- Doctrine 핵심 원칙: Evidence First, Runtime Verification, Context Preservation, Platform/Project 분리, Explicit Decision.
