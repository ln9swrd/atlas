# GIT WORKFLOW (Git 운영 규칙)

> Status : Draft
> Version : 0.1
> Last Updated : 2026-07-01

---

# 문서의 목적

이 문서는 EXCELION 프로젝트의 Git 및 GitHub 운영 규칙을 정의한다.

Git은 단순한 백업 도구가 아니라 프로젝트의 변경 이력을 관리하고 개발 진행 상황을 추적하는 시스템으로 사용한다.

---

# 기본 원칙

모든 변경 사항은 Git으로 관리한다.

다음 원칙을 따른다.

* 작은 단위로 Commit
* 기능 단위로 Branch
* Issue 기반 개발
* 문서와 코드의 동기화

---

# 브랜치 전략

프로젝트는 다음 브랜치를 사용한다.

```text
main
develop
feature/*
fix/*
hotfix/*
release/*
```

---

## main

항상 안정적인 상태를 유지한다.

언제든지 실행 가능한 버전만 존재한다.

---

## develop

다음 버전을 개발하는 브랜치이다.

기능 개발이 완료되면 develop으로 병합한다.

---

## feature

새로운 기능을 개발한다.

예시

```text
feature/player-movement
feature/lock-on
feature/mega-cannon
feature/heat-system
```

---

## fix

버그를 수정한다.

예시

```text
fix/animation
fix/collision
```

---

## release

출시 준비를 위한 브랜치이다.

버그 수정 외의 새로운 기능은 추가하지 않는다.

---

## hotfix

출시 이후 긴급 수정이 필요한 경우 사용한다.

---

# Commit 규칙

하나의 Commit은 하나의 목적만 가진다.

좋은 예

```text
feat: Add player movement

feat: Implement lock-on system

fix: Correct boost animation

refactor: Split Health Component

docs: Update Mission Design

test: Add animation validator
```

---

# Commit 금지

다음과 같은 Commit은 금지한다.

```text
update

modify

test

asdf

123
```

Commit 메시지만 보고 변경 내용을 이해할 수 있어야 한다.

---

# Issue 운영

모든 개발은 Issue에서 시작한다.

Issue에는 다음 내용을 포함한다.

* 목적
* 완료 조건
* 관련 문서
* 예상 작업 시간

---

# Issue 예시

```text
#021 Player Movement

목적

기본 이동 시스템 구현

완료 조건

- 이동 가능
- 회전 가능
- 애니메이션 연동

관련 문서

Gameplay
Prototype
```

---

# Milestone

Issue는 반드시 하나의 Milestone에 포함한다.

예시

```text
Milestone 0

움직이는 EXCELION

Milestone 1

Prototype

Milestone 2

Vertical Slice

Milestone 3

Steam Demo
```

---

# Pull Request

혼자 개발하더라도 Pull Request를 사용한다.

Pull Request는 코드 검토 기록으로 활용한다.

포함 내용

* 변경 내용
* 테스트 결과
* 관련 Issue

---

# Version 규칙

Semantic Versioning을 따른다.

```text
v0.1.0

v0.2.0

v0.3.1

v1.0.0
```

---

# Tag

다음 시점마다 Tag를 생성한다.

* Prototype
* Vertical Slice
* Steam Demo
* Early Access
* Release

---

# Git Ignore

Git으로 관리하지 않는다.

* Binaries
* Intermediate
* Saved
* DerivedDataCache
* Build Output
* Cache

---

# Commit 주기

가능하면 하루에 여러 번 Commit한다.

작업 종료 시 반드시 Commit한다.

기능 완료 시 반드시 Push한다.

---

# Release

Release Note에는 다음 내용을 포함한다.

* 추가된 기능
* 수정된 기능
* 알려진 문제
* 다음 목표

---

# 백업 원칙

GitHub는 백업이 아니다.

중요 자료는 별도의 저장 장치에도 백업한다.

---

# 프로젝트 원칙

Git 기록은 프로젝트의 역사이다.

나중에 코드를 이해하는 가장 중요한 자료가 된다.
