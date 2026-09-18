# Tower Defense Project Design Baseline

## Project Baseline

- Engine: Godot 4.7.2
- Genre: 2D Top-down Tower Defense
- Purpose: textbook-style project for learning and validating Tower Defense development
- Asset direction: Spire series
- Input: mouse-centered
- Mode: single player
- Architecture: data-driven
- Development method: `Task -> Verify -> Done`
- Final runtime verification: performed by Master
- Git commit/push: never performed without Master approval

Godot 4.7.2 and MCP connection checks are environment checks only. They do not make any game development task `DONE`.

## Architecture

Planned project areas:

- `res://scenes`
- `res://scripts/core`
- `res://scripts/tower`
- `res://scripts/enemy`
- `res://scripts/combat`
- `res://scripts/wave`
- `res://scripts/economy`
- `res://data/towers`
- `res://data/enemies`
- `res://data/waves`
- `res://assets`
- `res://ui`

Primary data resources:

- `TowerData`
- `EnemyData`
- `WaveData`

Primary systems:

- `GameManager`
- `TowerManager`
- `EnemyManager`
- `WaveManager`
- `EconomyManager`

## Task Tree

### TD-00 Project Baseline

- T00-01 Environment Check
- T00-02 MCP Check
- T00-03 Git Baseline

### TD-01 Asset Baseline

- T01-01 Asset Inventory
- T01-02 Tower Asset Mapping
- T01-03 Enemy Asset Mapping
- T01-04 License Record

### TD-02 Core Architecture

- T02-01 Core Manager
- T02-02 TowerData
- T02-03 EnemyData
- T02-04 WaveData
- T02-05 Dependency Test

### TD-03 Map / Path

- T03-01 Ground
- T03-02 Path
- T03-03 Spawn
- T03-04 Goal
- T03-05 Path Test

### TD-04 Enemy System

- T04-01 Enemy Scene
- T04-02 Spawn
- T04-03 Movement
- T04-04 Health
- T04-05 Death
- T04-06 Goal Reach

### TD-05 Tower System

- T05-01 Tower Scene
- T05-02 TowerData Connection
- T05-03 Range Detection
- T05-04 Target Selection
- T05-05 Attack Timer

### TD-06 Combat System

- T06-01 Projectile
- T06-02 Projectile Movement
- T06-03 Hit
- T06-04 Damage
- T06-05 Death Integration

### TD-07 Wave System

- T07-01 Wave Definition
- T07-02 Spawner
- T07-03 Wave Completion
- T07-04 Next Wave

### TD-08 Economy System

- T08-01 Initial Gold
- T08-02 Tower Cost
- T08-03 Purchase
- T08-04 Kill Reward
- T08-05 Life
- T08-06 Game Over

### TD-09 Tower Upgrade

- T09-01 Upgrade Data
- T09-02 Upgrade Cost
- T09-03 Upgrade Stats
- T09-04 Visual Upgrade
- T09-05 Runtime Test

### TD-10 Enemy Variants

- T10-01 Basic
- T10-02 Fast
- T10-03 Tank
- T10-04 Flying
- T10-05 Boss

### TD-11 Tower Placement

- T11-01 Build Point
- T11-02 Select Point
- T11-03 Cost Check
- T11-04 Create Tower
- T11-05 Gold Deduction

### TD-12 UI

- T12-01 HUD
- T12-02 Start Wave
- T12-03 Tower Selection
- T12-04 Upgrade Button
- T12-05 Game Over
- T12-06 Victory

### TD-13 Difficulty / Balance

- Tower: damage, cost, range, attack speed
- Enemy: HP, speed, reward
- Wave: count, spawn interval
- Player: life

### TD-14 MVP Integration

- T14-01 New Game
- T14-02 Build Tower
- T14-03 Start Wave
- T14-04 Kill Enemy
- T14-05 Earn Gold
- T14-06 Upgrade Tower
- T14-07 Multiple Enemy Types
- T14-08 Life Reduction
- T14-09 Game Over
- T14-10 Victory

## Task Status Rules

Normal status flow:

`TODO -> READY -> IN PROGRESS -> VERIFY -> DONE`

Exception statuses:

- `BLOCKED`: progress cannot continue because of an external dependency or unresolved decision.
- `HOLD`: intentionally paused by Master.
- `FAILED`: verification or execution failed and the task is not complete.

`DONE` requires the task scope to be completed and its required verification to pass. Do not automatically begin the next task after a task reaches `DONE`.

## Verification Rules

Verification categories:

- `CODE`: source and data definitions are checked.
- `BUILD`: project/build validation is checked.
- `EDITOR`: editor-side setup or scene validation is checked.
- `PIE`: actual runtime play-in-editor behavior is checked.

When actual runtime behavior has not been directly checked, record `PIE: NOT VERIFIED`. Do not infer runtime verification from code inspection, build success, editor loading, or MCP connectivity.

Master performs final runtime verification. Reports must state only verification that was actually performed.

## Phase Gate

A phase may pass its gate only when:

1. Its tasks have reached the required status, with exceptions explicitly recorded.
2. Required `CODE`, `BUILD`, and `EDITOR` checks are complete where applicable.
3. Required `PIE` checks are directly performed or explicitly recorded as `NOT VERIFIED` when runtime was not checked.
4. Master accepts the result for final runtime verification.

An environment check, Godot version check, or MCP connection check does not by itself pass a game development phase gate.

## Agent 작업 원칙

- Execute only the current requested task.
- Do not start the next development task automatically.
- Inspect existing files before editing and make the smallest permitted change.
- Do not modify unrelated existing changes.
- Do not invent new systems, features, assets, or design decisions.
- Do not claim runtime verification without direct runtime evidence.
- Stop and report when the result differs from the requested scope.
- Do not commit or push without separate Master approval.

## Scope / Out of Scope

### In Scope

- Preserve this confirmed Tower Defense baseline, architecture, task tree, status rules, and verification rules in Git as documentation.

### Out of Scope

- Game code implementation
- Godot scene creation or modification
- Asset download or modification
- UI implementation
- Animation implementation
- Git commit
- Git push
- Additional feature design
- Canon changes
- Project structure changes
- Refactoring
- Performance optimization
- Starting the next task automatically

## 현재 진행 상태

- This document records the confirmed design baseline only.
- No game implementation task is considered complete.
- `TD-00` environment checks, including Godot 4.7.2 and MCP connectivity checks, are not equivalent to game task completion.
- Runtime behavior has not been directly verified in this documentation task: `PIE: NOT VERIFIED`.
- Git commit and push were not performed.
