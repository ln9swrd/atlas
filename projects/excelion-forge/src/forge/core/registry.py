from typing import Dict, Optional
from .executor import Executor

class ExecutorRegistry:
    def __init__(self):
        self._executors: Dict[str, Executor] = {}
    
    def register(self, name: str, executor: Executor):
        self._executors[name] = executor
    
    def get(self, name: str) -> Optional[Executor]:
        return self._executors.get(name)