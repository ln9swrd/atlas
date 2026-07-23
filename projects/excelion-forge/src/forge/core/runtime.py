"""
EXCELION Forge - Core Runtime
"""

from typing import Dict, Any
from .contracts import ExecutionResult, ExecutionContext
from .factory import ContractFactory
from .registry import ExecutorRegistry

class RuntimeDispatcher:
    def __init__(self, registry: ExecutorRegistry):
        self.registry = registry
    
    def dispatch(
        self,
        ir: Dict[str, Any]
    ) -> ExecutionResult:
        contract = ContractFactory.create_execution_contract(
            ir["execution_contract"]
        )
        
        context = ExecutionContext(
            entrypoint=contract.entrypoint,
            files=contract.files,
            execution_type=contract.execution_type
        )
        
        executor = self.registry.get(
            contract.execution_type
        )

        if executor is None:
            raise ValueError(
                f"No executor registered: {contract.execution_type}"
            )
        return executor.execute(context)


class Runtime:
    """
    Runtime class for EXCELION Forge.

    This class manages the execution environment and lifecycle
    of the Forge development tools.
    """

    def __init__(self):
        """Initialize the Runtime."""
        self._initialized = False
        self._context = None

    def initialize(self):
        """Initialize the runtime environment."""
        if self._initialized:
            return

        # Initialize runtime components
        self._initialize_environment()
        self._initialized = True

    def initialize_environment(self, environment: Dict[str, Any]) -> bool:
        """Initialize pipeline execution environment parameters."""
        self.context.update(environment)
        return True

    def execute_pipeline(self, pipeline_config: Dict[str, Any]) -> Dict[str, Any]:
        """Execute asset pipeline and record status in context."""
        self.context["pipeline_config"] = pipeline_config
        return {"status": "SUCCESS", "context": self.context}

    def _initialize_environment(self):
        """Initialize the execution environment."""
        print("Initializing runtime environment...")

    def execute(self, task):
        """Execute a task within the Forge environment."""
        print(f"Executing task: {task}")

    def is_initialized(self):
        """Check if runtime is initialized."""
        return self._initialized

    def get_context(self):
        """Get the current execution context."""
        return self._context

