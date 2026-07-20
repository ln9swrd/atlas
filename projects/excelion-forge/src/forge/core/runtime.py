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

    def _initialize_environment(self):
        """Initialize the execution environment."""
        # TODO: Implement actual environment initialization
        # This is where we would set up:
        # - Blender context handling
        # - Execution environments
        # - Resource management
        # - Configuration loading

        print("Initializing runtime environment...")

    def execute(self, task):
        """Execute a task within the Forge environment."""
        # TODO: Implement actual execution logic
        print(f"Executing task: {task}")

    def is_initialized(self):
        """Check if runtime is initialized."""
        return self._initialized

    def get_context(self):
        """Get the current execution context."""
        return self._context

