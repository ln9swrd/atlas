from ..contracts import ExecutionContext, ExecutionResult

class PythonExecutor:
    def execute(
        self,
        context: ExecutionContext
    ) -> ExecutionResult:
        return ExecutionResult(
            status="success",
            stdout=f"Executed {context.entrypoint}"
        )