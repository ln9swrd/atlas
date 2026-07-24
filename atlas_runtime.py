import importlib.util
import os
from pathlib import Path

repo_root = os.path.dirname(os.path.abspath(__file__))
kernel_path = os.path.join(repo_root, "atlas-runtime", "kernel.py")

spec = importlib.util.spec_from_file_location("atlas_runtime_kernel", kernel_path)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

AtlasRuntime = module.AtlasRuntime
Session = module.Session
ServiceRegistry = module.ServiceRegistry
Event = module.Event
