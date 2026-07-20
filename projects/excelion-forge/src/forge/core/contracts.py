"""
EXCELION Forge - Core Contracts
"""
from typing import Protocol, Dict, Any

class ExecutionContract(Protocol):
    """
    Protocol defining the execution contract for EXCELION Forge.

    This contract specifies the interface that all execution components
    must follow to ensure consistency across the Forge system.
    """

    def execute(self, context: Dict[str, Any]) -> Dict[str, Any]:
        """
        Execute the component with given context.

        Args:
            context: Execution context containing parameters and state

        Returns:
            Result of execution
        """
        ...

    def validate(self, context: Dict[str, Any]) -> bool:
        """
        Validate the execution context.

        Args:
            context: Execution context to validate

        Returns:
            True if valid, False otherwise
        """
        ...

class ComponentContract(Protocol):
    """
    Protocol defining the component contract for EXCELION Forge.

    This contract specifies how components should be structured and interact
    within the Forge ecosystem.
    """

    def initialize(self) -> None:
        """Initialize the component."""
        ...

    def cleanup(self) -> None:
        """Clean up the component."""
        ...

    def get_name(self) -> str:
        """Get the name of the component."""
        ...

    def get_version(self) -> str:
        """Get the version of the component."""
        ...

