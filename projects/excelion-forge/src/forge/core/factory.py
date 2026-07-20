"""
EXCELION Forge - Core Factory
"""

class Factory:
    """
    Factory class for creating core components of EXCELION Forge.

    This factory is responsible for initializing and configuring
    the various systems needed for the Forge development environment.
    """

    def __init__(self):
        """Initialize the Factory."""
        self._initialized = False
        self._components = {}

    def initialize(self):
        """Initialize all core components."""
        if self._initialized:
            return

        # Initialize core components
        self._initialize_core_components()
        self._initialized = True

    def _initialize_core_components(self):
        """Initialize the core components of Forge."""
        # TODO: Implement actual initialization logic
        # This is where we would initialize:
        # - Validation systems
        # - Execution compilers
        # - Runtime environments
        # - UI components

        print("Initializing core components...")

    def get_component(self, component_name):
        """Get a specific component by name."""
        return self._components.get(component_name)

    def register_component(self, component_name, component):
        """Register a component."""
        self._components[component_name] = component

    def is_initialized(self):
        """Check if factory is initialized."""
        return self._initialized

# Package version
__version__ = "0.1.0"

# Export public API
__all__ = [
    "Factory"
]

