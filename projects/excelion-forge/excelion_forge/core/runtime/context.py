from __future__ import annotations

from typing import Optional
from .protocol import BpyRuntimeProtocol


class RuntimeContext:
    """Simple injector that holds the active runtime implementation.

    Code in the pipeline should accept a ``RuntimeContext`` (or receive it
    through other DI means) and use ``ctx.runtime`` for all bpy interactions.
    """

    def __init__(self, runtime: BpyRuntimeProtocol):
        self.runtime: BpyRuntimeProtocol = runtime

    def set_runtime(self, runtime: BpyRuntimeProtocol) -> None:
        self.runtime = runtime

    def get_runtime(self) -> BpyRuntimeProtocol:
        return self.runtime
