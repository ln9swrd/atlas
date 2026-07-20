import unittest
import sys
import os

sys.path.insert(
    0,
    os.path.join(os.path.dirname(__file__), '..')
)

from forge.core.runtime import RuntimeDispatcher
from forge.core.registry import ExecutorRegistry
from forge.executors.python_executor import PythonExecutor
from forge.core.executor import Executor
from forge.core.contracts import ExecutionStatus, ExecutionContext, ExecutionResult

class FailingExecutor(Executor):
    def execute(self, context: ExecutionContext) -> ExecutionResult:
        raise RuntimeError("boom")

class TestRuntimeDispatcher(unittest.TestCase):
    def setUp(self):
        self.registry = ExecutorRegistry()
        self.registry.register("python_execution", PythonExecutor())
        self.registry.register("failing", FailingExecutor())
        self.dispatcher = RuntimeDispatcher(self.registry)
    
    def test_dispatch_success(self):
        ir = {
            "execution_contract": {
                "execution_type": "python_execution",
                "entrypoint": "main.py",
                "files": ["main.py"]
            }
        }
        
        result = self.dispatcher.dispatch(ir)
        
        self.assertEqual(result.status, ExecutionStatus.SUCCESS)
        self.assertIsNotNone(result.stdout)
        self.assertIsNone(result.stderr)
        self.assertEqual(result.return_code, 0)
    
    def test_unknown_executor(self):
        ir = {
            "execution_contract": {
                "execution_type": "unknown",
                "entrypoint": "main.py",
                "files": []
            }
        }
        
        with self.assertRaises(ValueError):
            self.dispatcher.dispatch(ir)
    
    def test_executor_exception_handling(self):
        ir = {
            "execution_contract": {
                "execution_type": "failing",
                "entrypoint": "main.py",
                "files": []
            }
        }
        
        result = self.dispatcher.dispatch(ir)
        
        self.assertEqual(result.status, ExecutionStatus.ERROR)
        self.assertEqual(result.return_code, 1)
        self.assertIn("boom", result.stderr)

if __name__ == '__main__':
    unittest.main()