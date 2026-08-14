#!/usr/bin/env python3
# Copyright Excelion. All Rights Reserved.
# Lightweight Stdio MCP Server for Unreal Engine 5.4 Remote Control API

import sys
import json
import urllib.request
import urllib.error
import os

def log_debug(msg):
    sys.stderr.write(f"[Unreal-MCP] {msg}\n")
    sys.stderr.flush()

def get_target_hosts():
    if "UNREAL_HOST" in os.environ:
        return [os.environ["UNREAL_HOST"]]
    
    ports = [3010, 30010]
    hosts = []
    for port in ports:
        hosts.append(f"http://127.0.0.1:{port}")
        hosts.append(f"http://localhost:{port}")
    try:
        if os.path.exists("/etc/resolv.conf"):
            with open("/etc/resolv.conf", "r") as f:
                for line in f:
                    if "nameserver" in line:
                        wsl_ip = line.split()[1]
                        for port in ports:
                            hosts.append(f"http://{wsl_ip}:{port}")
    except Exception:
        pass
    return hosts

def make_unreal_request(endpoint, payload=None, method="PUT"):
    target_hosts = get_target_hosts()
    last_error = None
    data = json.dumps(payload).encode('utf-8') if payload else None
    headers = {'Content-Type': 'application/json'}

    for base_url in target_hosts:
        url = f"{base_url}{endpoint}"
        req = urllib.request.Request(url, data=data, headers=headers, method=method)
        try:
            with urllib.request.urlopen(req, timeout=2) as response:
                res_body = response.read().decode('utf-8')
                return json.loads(res_body) if res_body else {"status": "ok"}
        except urllib.error.URLError as e:
            last_error = f"Failed to connect to Unreal Engine at {url}: {str(e)}"
        except Exception as e:
            last_error = str(e)
            
    return {"error": last_error or "Could not reach Unreal Engine Remote Control API"}

TOOLS_SPEC = [
    {
        "name": "unreal_ping",
        "description": "Ping Unreal Engine 5.4 Web Remote Control API to check connectivity.",
        "inputSchema": {
            "type": "object",
            "properties": {}
        }
    },
    {
        "name": "unreal_get_property",
        "description": "Read a property value from an actor/object in the active Unreal level.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "object_path": {"type": "string", "description": "Asset or Actor path (e.g. /Game/Maps/TestMap.TestMap:PersistentLevel.BP_ExcelionCharacter_C_1)"},
                "property_name": {"type": "string", "description": "Property name (e.g. MaxHealth, MoveSpeed)"}
            },
            "required": ["object_path", "property_name"]
        }
    },
    {
        "name": "unreal_set_property",
        "description": "Modify a property value on an actor/object in the active Unreal level.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "object_path": {"type": "string", "description": "Asset or Actor path"},
                "property_name": {"type": "string", "description": "Property name to set"},
                "property_value": {"description": "New property value (string, float, int, or object)"}
            },
            "required": ["object_path", "property_name", "property_value"]
        }
    },
    {
        "name": "unreal_call_function",
        "description": "Invoke a function on an actor/object in the active Unreal level.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "object_path": {"type": "string", "description": "Target Object Path"},
                "function_name": {"type": "string", "description": "Function name to call"},
                "parameters": {"type": "object", "description": "Function input parameters payload"}
            },
            "required": ["object_path", "function_name"]
        }
    },
    {
        "name": "unreal_execute_python",
        "description": "Execute a Python script string inside the active Unreal Editor session.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "script": {"type": "string", "description": "Python code string to execute"}
            },
            "required": ["script"]
        }
    }
]

def handle_tool_call(name, args):
    if name == "unreal_ping":
        res = make_unreal_request("/remote/info", method="GET")
        if "error" in res:
            return {"content": [{"type": "text", "text": f"Unreal Connection Failed: {res['error']}. Make sure Remote Control API plugin is enabled and Unreal Editor is running."}]}
        return {"content": [{"type": "text", "text": f"Unreal Engine Remote Control Connected Successfully!\nInfo: {json.dumps(res, indent=2)}"}]}
    elif name == "unreal_get_property":
        payload = {
            "objectPath": args.get("object_path"),
            "propertyName": args.get("property_name"),
            "access": "READ"
        }
        res = make_unreal_request("/remote/object/property", payload, method="PUT")
        return {"content": [{"type": "text", "text": json.dumps(res, indent=2)}]}
    elif name == "unreal_set_property":
        payload = {
            "objectPath": args.get("object_path"),
            "propertyName": args.get("property_name"),
            "propertyValue": args.get("property_value"),
            "access": "WRITE"
        }
        res = make_unreal_request("/remote/object/property", payload, method="PUT")
        return {"content": [{"type": "text", "text": json.dumps(res, indent=2)}]}
    elif name == "unreal_call_function":
        payload = {
            "objectPath": args.get("object_path"),
            "functionName": args.get("function_name"),
            "parameters": args.get("parameters", {})
        }
        res = make_unreal_request("/remote/object/call", payload, method="PUT")
        return {"content": [{"type": "text", "text": json.dumps(res, indent=2)}]}
    elif name == "unreal_execute_python":
        payload = {
            "objectPath": "/Script/PythonScriptPlugin.Default__PyTestObject",
            "functionName": "ExecutePythonScript",
            "parameters": {"Script": args.get("script")}
        }
        res = make_unreal_request("/remote/object/call", payload, method="PUT")
        return {"content": [{"type": "text", "text": json.dumps(res, indent=2)}]}
    else:
        return {"content": [{"type": "text", "text": f"Unknown tool: {name}"}], "isError": True}

def main():
    log_debug("Starting Stdio MCP Server for Unreal Engine...")
    while True:
        try:
            line = sys.stdin.readline()
            if not line:
                break
            req = json.loads(line.strip())
            method = req.get("method")
            msg_id = req.get("id")

            if method == "initialize":
                res = {
                    "jsonrpc": "2.0",
                    "id": msg_id,
                    "result": {
                        "protocolVersion": "2024-11-05",
                        "capabilities": {"tools": {}},
                        "serverInfo": {"name": "unreal-mcp-server", "version": "1.0.0"}
                    }
                }
                sys.stdout.write(json.dumps(res) + "\n")
                sys.stdout.flush()
            elif method == "notifications/initialized":
                pass
            elif method == "tools/list":
                res = {
                    "jsonrpc": "2.0",
                    "id": msg_id,
                    "result": {"tools": TOOLS_SPEC}
                }
                sys.stdout.write(json.dumps(res) + "\n")
                sys.stdout.flush()
            elif method == "tools/call":
                params = req.get("params", {})
                tool_name = params.get("name")
                tool_args = params.get("arguments", {})
                tool_res = handle_tool_call(tool_name, tool_args)
                res = {
                    "jsonrpc": "2.0",
                    "id": msg_id,
                    "result": tool_res
                }
                sys.stdout.write(json.dumps(res) + "\n")
                sys.stdout.flush()
            else:
                if msg_id is not None:
                    res = {
                        "jsonrpc": "2.0",
                        "id": msg_id,
                        "error": {"code": -32601, "message": "Method not found"}
                    }
                    sys.stdout.write(json.dumps(res) + "\n")
                    sys.stdout.flush()
        except Exception as e:
            log_debug(f"Error handling message: {e}")

if __name__ == "__main__":
    main()
