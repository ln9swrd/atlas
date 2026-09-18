# P3-1d — contract.py Implement Matrix

Date: 2026-07-31  
Source: `core/contract.py` · `core/sdk.py` · inventory

## Interfaces

| Interface | Mock in sdk.py | Production impl | Used by tools/ | Notes |
|-----------|----------------|-----------------|----------------|-------|
| `IEventBus` | **Yes** `MockEventBus` | Partial `core/event_bus.py` | No direct | Async Spec; event_bus sync-ish |
| `IAIService` | **Yes** `MockAIService` | **None** | No | Spec only |
| `IMemoryService` | **Yes** `MockMemoryService` | Partial `core/memory.py` | No | Mock wraps AtlasMemory |
| `IKnowledgeService` | **Yes** `MockKnowledgeService` | **None** (rules KB files) | No | Product-flavored mocks |
| `IWorkflowService` | **Yes** `MockWorkflowService` | Partial taskbroker/execution | runner uses core modules directly | |
| `IResourceService` | **Yes** `MockResourceService` | Partial execution env | No | |
| `IReviewService` | **Yes** `MockReviewService` | Partial `core/review/` | runner subprocess review_engine | |
| `IAtlasSDK` | **Yes** `AtlasSDK` + `create_mock_sdk` | Facade only | audit path in runner | |
| `IApplication` | **No** | **None** | No | Plugin lifecycle Spec only |

## Summary

| Bucket | Count |
|--------|-------|
| Spec only (no real service) | IAIService, IApplication |
| Mock only (usable in tests) | All I* via create_mock_sdk |
| Partial real modules (not full interface) | event_bus, memory, decision, taskbroker, rules, review, execution |
| Wired daily ops | **tools/** domain_policy + atlas_runner (bypass full SDK) |

## P3 rule

- Do **not** rewrite SDK now.
- Production path of record for ops = `tools/` + `state/`.
- `contract.py` remains design SoR for future plugin host.
- Product-coupled knowledge mocks (blender/unreal strings) stay HOLD with product paths.

## Evidence

File read of `core/contract.py`, `core/sdk.py` 2026-07-31.
