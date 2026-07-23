from typing import Any, Callable, Dict, List, Optional
from core.contract import (
    IAtlasSDK,
    IEventBus,
    IAIService,
    IMemoryService,
    IKnowledgeService,
    IWorkflowService,
    IResourceService,
    IReviewService,
)


class AtlasSDK(IAtlasSDK):
    """Concrete implementation of the Unified SDK Facade."""

    def __init__(
        self,
        event: IEventBus,
        ai: IAIService,
        memory: IMemoryService,
        knowledge: IKnowledgeService,
        workflow: IWorkflowService,
        resource: IResourceService,
        review: IReviewService,
    ):
        self._event = event
        self._ai = ai
        self._memory = memory
        self._knowledge = knowledge
        self._workflow = workflow
        self._resource = resource
        self._review = review

    @property
    def event(self) -> IEventBus:
        return self._event

    @property
    def ai(self) -> IAIService:
        return self._ai

    @property
    def memory(self) -> IMemoryService:
        return self._memory

    @property
    def knowledge(self) -> IKnowledgeService:
        return self._knowledge

    @property
    def workflow(self) -> IWorkflowService:
        return self._workflow

    @property
    def resource(self) -> IResourceService:
        return self._resource

    @property
    def review(self) -> IReviewService:
        return self._review

    @classmethod
    def create_mock_sdk(cls) -> "AtlasSDK":
        """Factory method to bootstrap a fully functioning In-Memory Mock SDK."""
        return cls(
            event=MockEventBus(),
            ai=MockAIService(),
            memory=MockMemoryService(),
            knowledge=MockKnowledgeService(),
            workflow=MockWorkflowService(),
            resource=MockResourceService(),
            review=MockReviewService(),
        )


# =====================================================================
# In-Memory Mock Service Implementation for Testing & Early Integration
# =====================================================================


class MockEventBus(IEventBus):
    """Mock Event Bus recording subscriptions and publications in-memory."""

    def __init__(self):
        self.subscribers: Dict[str, List[Callable[[Dict[str, Any]], Any]]] = {}
        self.events_history: List[Dict[str, Any]] = []

    async def publish(self, event_type: str, payload: Dict[str, Any]) -> None:
        event = {"event_type": event_type, "payload": payload}
        self.events_history.append(event)
        if event_type in self.subscribers:
            for cb in self.subscribers[event_type]:
                try:
                    cb(payload)
                except Exception:
                    pass

    async def subscribe(self, event_type: str, callback: Callable[[Dict[str, Any]], Any]) -> str:
        self.subscribers.setdefault(event_type, []).append(callback)
        sub_id = f"sub_{event_type}_{len(self.subscribers[event_type])}"
        return sub_id

    async def unsubscribe(self, subscription_id: str) -> None:
        # Simplistic implementation for mock testing
        pass


class MockAIService(IAIService):
    """Mock AI Service providing simulated Gemini/Ollama responses."""

    async def request_reasoning(
        self, prompt: str, json_schema: Dict[str, Any], use_gpu: bool = False
    ) -> Dict[str, Any]:
        # Simply returns a mock structure complying with schema types
        mock_response = {}
        for key, val in json_schema.get("properties", {}).items():
            t = val.get("type")
            if t == "string":
                mock_response[key] = "mocked_string_val"
            elif t == "integer":
                mock_response[key] = 42
            elif t == "boolean":
                mock_response[key] = True
            elif t == "array":
                mock_response[key] = []
            else:
                mock_response[key] = None
        return mock_response

    async def get_agent_opinion(self, agent_name: str, context_payload: Dict[str, Any]) -> str:
        return f"[Mock Opinion from {agent_name}] Approved under DEV environment."


class MockMemoryService(IMemoryService):
    """Mock Memory Service keeping states in-memory."""

    def __init__(self):
        self.adrs: Dict[str, Dict[str, Any]] = {}
        self.session_state: Dict[str, Any] = {}

    async def get_adr(self, adr_id: str) -> Optional[Dict[str, Any]]:
        return self.adrs.get(adr_id)

    async def create_adr(self, adr_id: str, title: str, context: str, decision: str) -> bool:
        self.adrs[adr_id] = {
            "adr_id": adr_id,
            "title": title,
            "context": context,
            "decision": decision,
            "status": "Accepted",
        }
        return True

    async def set_session_state(self, key: str, val: Any) -> None:
        self.session_state[key] = val

    async def get_session_state(self, key: str) -> Any:
        return self.session_state.get(key)


class MockKnowledgeService(IKnowledgeService):
    """Mock Knowledge Service returning pre-defined rules."""

    async def query_best_practice(self, target_stage: str) -> List[str]:
        if "blender" in target_stage.lower():
            return ["Mirror -> Bevel -> Weighted Normal", "Transform Apply (scale=1.0)"]
        elif "unreal" in target_stage.lower():
            return ["Event Tick Ban", "Soft References for asset loading"]
        return ["Follow general naming patterns."]

    async def validate_naming_rule(self, asset_name: str, asset_type: str) -> bool:
        # Simplistic validation check
        if asset_type.lower() == "mesh" and not asset_name.startswith("SM_"):
            return False
        return True


class MockWorkflowService(IWorkflowService):
    """Mock Workflow Service managing tasks."""

    def __init__(self):
        self.tasks = {
            "TASK-001": {
                "id": "TASK-001",
                "description": "Mock initial modeling check",
                "status": "TODO",
                "depends_on": [],
            }
        }

    async def get_recommended_task(self) -> Optional[Dict[str, Any]]:
        for task in self.tasks.values():
            if task["status"] == "TODO":
                return task
        return None

    async def mark_task_status(self, task_id: str, status: str) -> bool:
        if task_id in self.tasks:
            self.tasks[task_id]["status"] = status
            return True
        return False

    async def check_dependencies(self, task_id: str) -> bool:
        if task_id in self.tasks:
            deps = self.tasks[task_id].get("depends_on", [])
            return all(self.tasks.get(d, {}).get("status") == "DONE" for d in deps)
        return True


class MockResourceService(IResourceService):
    """Mock Resource Service."""

    async def get_environment_info(self) -> Dict[str, Any]:
        return {
            "environment": "DEV_WORK",
            "capabilities": ["blender", "uv_mapping", "modeling"],
            "constraints": ["no_unreal"],
        }

    async def get_remaining_budget(self) -> int:
        return 180


class MockReviewService(IReviewService):
    """Mock Review Service."""

    async def submit_artifact_for_audit(self, filepath: str, stage: str) -> Dict[str, Any]:
        return {
            "filepath": filepath,
            "stage": stage,
            "status": "PASS",
            "score": 100,
            "log": "All validations simulated pass successfully.",
        }

    async def get_latest_scorecard(self, asset_name: str) -> Optional[Dict[str, Any]]:
        return {
            "asset_name": asset_name,
            "score": 100.0,
            "breakdown": {
                "Topology": 100,
                "Naming": 100,
                "UV": 100,
            },
        }
