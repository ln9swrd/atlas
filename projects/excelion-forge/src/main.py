"""
EXCELION Forge - Main Entry Point
"""

import sys
import os

# Add the project root to Python path
project_root = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, project_root)

def main():
    """Main entry point for EXCELION Forge."""
    print("EXCELION Forge initialized")
    
    # Initialize core systems
    try:
        from src.forge.core.factory import Factory
        from src.forge.core.runtime import Runtime

        # Create factory instance
        factory = Factory()

        # Initialize runtime
        runtime = Runtime()

        print("Forge core systems initialized successfully")

    except Exception as e:
        print(f"Error initializing Forge: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()