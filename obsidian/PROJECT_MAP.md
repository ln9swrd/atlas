# Project Map

This document outlines the structure, purpose, and relationships of projects within Atlas, aligned with the 87 conversation analysis in [[DETAILED_CONVERSATION_ANALYSIS.md]].

---

## Subsystem & Agent Architecture (SERA / Kraken Framework)

```
Atlas DevOS
│
├── SERA (Intelligence & Architecture Layer)
│   ├── Architectural Decision Records (ADR)
│   ├── Context Resolver & Dynamic Memory Window
│   └── Review & Rule Compliance Engine
│
├── Kraken (Autonomous Execution Layer)
│   ├── Autonomous Execution Runner (tools/atlas_runner.py)
│   ├── Priority Engine (Context-Aware Task Recommendation)
│   └── Verification & Testing System
│
└── Projects (Domain Projects Layer)
    ├── Exelion (3D Mech Action Game)
    │   └── Excelion Forge (Hybrid 3D Pipeline & Web Dashboard)
    ├── Coin-S (Quant Trading & Backtesting System)
    ├── PrintGuard (3D Printing Quality Control)
    └── Business Agent (Automated Workflow & Packaging Tool)
```

---

## Active Projects Map

| Project | Domain | Status | Key Artifacts / Location |
|---|---|---|---|
| **Atlas DevOS** | Dev Platform & Core OS | `IMPLEMENTED` | `core/`, `tools/`, `obsidian/Core/` |
| **Excelion Forge** | 3D Asset Pipeline | `IMPLEMENTED` | `projects/excelion-forge/` |
| **Exelion Game Core**| Unreal Engine 5 & Blender Mesh | `IN_PROGRESS` | `projects/excelion/` |
| **Coin-S** | Quant Strategy & Backtest | `PROPOSED / PLANNED` | `obsidian/Archive/Named Conversations/030_...md` |
| **PrintGuard** | 3D Print QA & Handover | `PROPOSED / PLANNED` | `obsidian/Archive/Named Conversations/031_...md` |
| **Business Agent** | Workflow Packaging & Monetization | `PROPOSED / PLANNED` | `obsidian/Archive/Named Conversations/086_...md` |

---

## Document References
- [[DETAILED_CONVERSATION_ANALYSIS.md]] (Full 87 Conversation Deep Analysis)
- [[ADR_CATALOG.md]] (Master Architecture Decision Records)
- [[AI_CONTEXT]]
- [[CURRENT_STATE]]
- [[DECISION_LOG]]
- [[OPERATING_DOCTRINE]]
