import abc
from typing import Any, Callable, Dict, List, Optional


class IEventBus(abc.ABC):
    """Event Bus interface for pub-sub messaging within Atlas DevOS."""

    @abc.abstractmethod
    async def publish(self, event_type: str, payload: Dict[str, Any]) -> None:
        """Publish an event to all subscribers and append to event logs."""
        pass

    @abc.abstractmethod
    async def subscribe(self, event_type: str, callback: Callable[[Dict[str, Any]], Any]) -> str:
        """Subscribe to a specific event type and return unique subscription ID."""
        pass

    @abc.abstractmethod
    async def unsubscribe(self, subscription_id: str) -> None:
        """Cancel subscription using the ID."""
        pass


class IAIService(abc.ABC):
    """AI Runtime Interface for reasoning, model selection, and agent execution."""

    @abc.abstractmethod
    async def request_reasoning(
        self, prompt: str, json_schema: Dict[str, Any], use_gpu: bool = False
    ) -> Dict[str, Any]:
        """Request structured reasoning output (JSON) matching the given schema."""
        pass

    @abc.abstractmethod
    async def get_agent_opinion(self, agent_name: str, context_payload: Dict[str, Any]) -> str:
        """Retrieve opinion from a specific AI agent (e.g., Marie, Antigravity)."""
        pass


class IMemoryService(abc.ABC):
    """Interface for short-term session memory and long-term ADR storage."""

    @abc.abstractmethod
    async def get_adr(self, adr_id: str) -> Optional[Dict[str, Any]]:
        """Retrieve ADR entry by ID."""
        pass

    @abc.abstractmethod
    async def create_adr(self, adr_id: str, title: str, context: str, decision: str) -> bool:
        """Create and store a new ADR record."""
        pass

    @abc.abstractmethod
    async def set_session_state(self, key: str, val: Any) -> None:
        """Write key-value to runtime session memory."""
        pass

    @abc.abstractmethod
    async def get_session_state(self, key: str) -> Any:
        """Read key-value from runtime session memory."""
        pass


class IKnowledgeService(abc.ABC):
    """Interface for querying rules, best practices, and checking constraints."""

    @abc.abstractmethod
    async def query_best_practice(self, target_stage: str) -> List[str]:
        """Query relevant guidelines from knowledge base for a specific stage."""
        pass

    @abc.abstractmethod
    async def validate_naming_rule(self, asset_name: str, asset_type: str) -> bool:
        """Validate naming rule adherence for specific asset type."""
        pass


class IWorkflowService(abc.ABC):
    """Interface for managing tasks, state transitions, and priority recommendation."""

    @abc.abstractmethod
    async def get_recommended_task(self) -> Optional[Dict[str, Any]]:
        """Get the highest priority recommended task from Scheduler."""
        pass

    @abc.abstractmethod
    async def mark_task_status(self, task_id: str, status: str) -> bool:
        """Update task status in ATLAS_STATE."""
        pass

    @abc.abstractmethod
    async def check_dependencies(self, task_id: str) -> bool:
        """Check if all task dependencies are resolved."""
        pass


class IResourceService(abc.ABC):
    """Interface for querying hardware capabilities and time budget."""

    @abc.abstractmethod
    async def get_environment_info(self) -> Dict[str, Any]:
        """Get current resolved environment capabilities and constraints."""
        pass

    @abc.abstractmethod
    async def get_remaining_budget(self) -> int:
        """Get remaining time budget in minutes."""
        pass


class IReviewService(abc.ABC):
    """Interface for submitting verification reports and fetching scorecards."""

    @abc.abstractmethod
    async def submit_artifact_for_audit(self, filepath: str, stage: str) -> Dict[str, Any]:
        """Submit a newly created artifact path for Rule Engine validation."""
        pass

    @abc.abstractmethod
    async def get_latest_scorecard(self, asset_name: str) -> Optional[Dict[str, Any]]:
        """Get compiled scorecard for the asset."""
        pass


class IAtlasSDK(abc.ABC):
    """Unified SDK Interface (Facade) provided to Plugin Applications."""

    @property
    @abc.abstractmethod
    def event(self) -> IEventBus:
        pass

    @property
    @abc.abstractmethod
    def ai(self) -> IAIService:
        pass

    @property
    @abc.abstractmethod
    def memory(self) -> IMemoryService:
        pass

    @property
    @abc.abstractmethod
    def knowledge(self) -> IKnowledgeService:
        pass

    @property
    @abc.abstractmethod
    def workflow(self) -> IWorkflowService:
        pass

    @property
    @abc.abstractmethod
    def resource(self) -> IResourceService:
        pass

    @property
    @abc.abstractmethod
    def review(self) -> IReviewService:
        pass


class IApplication(abc.ABC):
    """Abstract interface defining the application lifecycle hooks in Atlas."""

    @abc.abstractmethod
    async def on_install(self) -> bool:
        """Called when application is registered/installed."""
        pass

    @abc.abstractmethod
    async def on_load(self) -> bool:
        """Called when application is loaded into runtime memory."""
        pass

    @abc.abstractmethod
    async def on_initialize(self, sdk: IAtlasSDK) -> bool:
        """Injects Kernel SDK Facade reference to initialised App."""
        pass

    @abc.abstractmethod
    async def on_execute(self, context: Dict[str, Any]) -> None:
        """Starts business workflows execution of the App."""
        pass

    @abc.abstractmethod
    async def on_suspend(self) -> bool:
        """Called before suspending execution."""
        pass

    @abc.abstractmethod
    async def on_resume(self) -> bool:
        """Called on resuming suspended state."""
        pass

    @abc.abstractmethod
    async def on_unload(self) -> bool:
        """Called on unloading from memory."""
        pass
