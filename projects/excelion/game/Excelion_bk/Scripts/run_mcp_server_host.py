import unreal
import time

unreal.log("==================================================")
unreal.log("=== UNREAL MCP SERVER HOST RUNNING (PORT 55557) ===")
unreal.log("==================================================")

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    unreal.log("Unreal MCP Server host stopping...")
