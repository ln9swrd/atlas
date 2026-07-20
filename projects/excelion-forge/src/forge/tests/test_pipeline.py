import unittest
from forge.core.compiler import ExecutionCompiler
from forge.core.validator import SchemaValidator
from forge.core.runtime import RuntimeDispatcher
from forge.core.registry import ExecutorRegistry
from forge.core.executors.python_executor import PythonExecutor
from forge.core.contracts import ExecutionResult

class TestExecutionPipeline(unittest.TestCase):
    def test_full_execution_pipeline(self):
        """Test the complete execution pipeline from request to result"""
        compiler = ExecutionCompiler()
        validator = SchemaValidator()
        
        registry = ExecutorRegistry()
        registry.register(
            "python_execution",
            PythonExecutor()
        )
        
        dispatcher = RuntimeDispatcher(registry)
        
        request = {
            "type": "python",
            "entrypoint": "main.py",
            "files": [
                {
                    "path": "main.py",
                    "content": "print('hello')"
                }
            ]
        }
        
        ir = compiler.compile(request)
        
        validated = validator.validate(ir)
        
        result = dispatcher.dispatch(validated)
        
        self.assertIsInstance(result, ExecutionResult)
        self.assertEqual(result.status, "success")
        # The Python executor should return a message containing the entrypoint
        self.assertIn("main.py", result.stdout)

if __name__ == '__main__':
    unittest.main()