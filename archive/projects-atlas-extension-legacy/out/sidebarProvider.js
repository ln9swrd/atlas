"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AtlasSidebarProvider = void 0;
const vscode = require("vscode");
const fs = require("fs");
const path = require("path");
const child_process_1 = require("child_process");
class AtlasSidebarProvider {
    _extensionUri;
    static viewType = 'atlas.sidebarView';
    _view;
    _ollamaHost = 'http://192.168.219.254:11434';
    constructor(_extensionUri) {
        this._extensionUri = _extensionUri;
    }
    resolveWebviewView(webviewView, context, _token) {
        this._view = webviewView;
        webviewView.webview.options = {
            enableScripts: true,
            localResourceRoots: [this._extensionUri]
        };
        webviewView.webview.html = this._getHtmlForWebview(webviewView.webview);
        webviewView.webview.onDidReceiveMessage(async (data) => {
            switch (data.type) {
                case 'sendPrompt': {
                    this._handleUserPrompt(data.value);
                    break;
                }
                case 'executeCli': {
                    this._executeCliCommand(data.command);
                    break;
                }
            }
        });
    }
    async _handleUserPrompt(userPrompt) {
        if (!this._view) {
            return;
        }
        const config = vscode.workspace.getConfiguration('atlas');
        const ollamaHost = config.get('ollamaHost') || this._ollamaHost;
        const preferredModel = config.get('model') || 'qwen3:14b';
        const workspaceFolders = vscode.workspace.workspaceFolders;
        const rootPath = workspaceFolders ? workspaceFolders[0].uri.fsPath : '/mnt/d/Atlas';
        // 1. Load Git Context
        let contextStr = '=== WORKSPACE CONTEXT ===\n';
        const currentStatePath = path.join(rootPath, 'state', 'CURRENT_STATE.md');
        const agentsPath = path.join(rootPath, 'AGENTS.md');
        if (fs.existsSync(currentStatePath)) {
            contextStr += `\n--- CURRENT_STATE.md ---\n${fs.readFileSync(currentStatePath, 'utf8')}\n`;
        }
        if (fs.existsSync(agentsPath)) {
            contextStr += `\n--- AGENTS.md ---\n${fs.readFileSync(agentsPath, 'utf8')}\n`;
        }
        const systemPrompt = `You are Atlas Agent, an autonomous coding AI pair programming in Atlas DevOS.
You are powered by Qwen. Always use Chain-of-Thought (CoT) reasoning.

Rules:
1. Evidence-First: Verify facts via CLI or code.

Response Format:
<thought>
Step-by-step reasoning plan.
</thought>

<action>
{
  "type": "execute_cli" | "read_file" | "write_file" | "finish",
  "command": "string (for cli)",
  "path": "string (for file)",
  "content": "string (for write_file)",
  "message": "string (for finish)"
}
</action>
`;
        this._view.webview.postMessage({ type: 'addMessage', role: 'user', content: userPrompt });
        this._view.webview.postMessage({ type: 'setLoading', value: true });
        // 2. Execute via Python Orchestrator module using spawn -u for unbuffered real-time streaming & UTF-8
        let scriptPath = path.join(rootPath, 'tools', 'atlas_qwen_orchestrator.py');
        if (!fs.existsSync(scriptPath)) {
            const parentPath = path.dirname(rootPath);
            const fallbackPath = path.join(parentPath, 'tools', 'atlas_qwen_orchestrator.py');
            if (fs.existsSync(fallbackPath)) {
                scriptPath = fallbackPath;
            }
        }
        const pythonExecutable = process.platform === 'win32' ? 'python' : 'python3';
        const orchestratorCwd = path.dirname(path.dirname(scriptPath));
        const child = (0, child_process_1.spawn)(pythonExecutable, ['-u', scriptPath, userPrompt], {
            cwd: orchestratorCwd,
            env: {
                ...process.env,
                PYTHONIOENCODING: 'utf-8',
                PYTHONUNBUFFERED: '1',
                OLLAMA_HOST: ollamaHost,
                OLLAMA_MODEL: preferredModel
            }
        });
        let stdoutData = '';
        let stderrData = '';
        child.stdout.on('data', (data) => {
            const chunk = data.toString('utf-8');
            stdoutData += chunk;
            this._view?.webview.postMessage({ type: 'appendStream', content: chunk });
        });
        child.stderr.on('data', (data) => {
            stderrData += data.toString('utf-8');
        });
        child.on('error', (err) => {
            this._view?.webview.postMessage({ type: 'setLoading', value: false });
            this._view?.webview.postMessage({ type: 'addMessage', role: 'error', content: `Failed to start Python process (${pythonExecutable}): ${err.message}` });
        });
        child.on('close', (code) => {
            this._view?.webview.postMessage({ type: 'setLoading', value: false });
            const responseText = stdoutData || stderrData || `Process exited with code ${code}`;
            if (code !== 0 && !stdoutData) {
                this._view?.webview.postMessage({ type: 'addMessage', role: 'error', content: `Python Execution Error (Code ${code}):\n${stderrData}` });
            }
            else {
                this._view?.webview.postMessage({ type: 'addMessage', role: 'assistant', content: responseText });
                // Check for CLI action suggestions
                const cliMatch = responseText.match(/"type":\s*"execute_cli",\s*"command":\s*"([^"]+)"/);
                if (cliMatch && cliMatch[1]) {
                    this._view?.webview.postMessage({ type: 'suggestCli', command: cliMatch[1] });
                }
            }
        });
    }
    _executeCliCommand(command) {
        const workspaceFolders = vscode.workspace.workspaceFolders;
        const cwd = workspaceFolders ? workspaceFolders[0].uri.fsPath : '/mnt/d/Atlas';
        this._view?.webview.postMessage({ type: 'addMessage', role: 'system', content: `[CLI Running] ${command}` });
        (0, child_process_1.exec)(command, { cwd }, (error, stdout, stderr) => {
            const output = `Exit Code: ${error ? error.code : 0}\nSTDOUT:\n${stdout}\nSTDERR:\n${stderr}`;
            this._view?.webview.postMessage({ type: 'addMessage', role: 'system', content: `[CLI Output]\n${output}` });
        });
    }
    _getHtmlForWebview(webview) {
        const scriptUri = webview.asWebviewUri(vscode.Uri.joinPath(this._extensionUri, 'media', 'main.js'));
        const nonce = getNonce();
        return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline' ${webview.cspSource}; script-src 'nonce-${nonce}';">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Atlas Agent</title>
  <style>
    body { font-family: var(--vscode-font-family); padding: 10px; color: var(--vscode-foreground); background: var(--vscode-editor-background); box-sizing: border-box; }
    .chat-box { display: flex; flex-direction: column; gap: 10px; margin-bottom: 15px; max-height: 380px; overflow-y: auto; padding: 4px; }
    .msg { padding: 8px 12px; border-radius: 6px; font-size: 12px; white-space: pre-wrap; word-break: break-word; }
    .user { background: var(--vscode-button-background); color: var(--vscode-button-foreground); align-self: flex-end; }
    .assistant { background: var(--vscode-sidebar-background); border: 1px solid var(--vscode-widget-border); }
    .system { background: var(--vscode-editor-inactiveSelectionBackground); font-family: monospace; font-size: 11px; }
    .error { background: var(--vscode-inputValidation-errorBackground); border: 1px solid var(--vscode-inputValidation-errorBorder); }
    textarea { width: 100%; height: 65px; background: var(--vscode-input-background); color: var(--vscode-input-foreground); border: 1px solid var(--vscode-input-border); border-radius: 4px; padding: 8px; box-sizing: border-box; resize: vertical; }
    button { width: 100%; padding: 8px; margin-top: 6px; background: var(--vscode-button-background); color: var(--vscode-button-foreground); border: none; border-radius: 4px; cursor: pointer; font-weight: bold; }
    button:hover { background: var(--vscode-button-hoverBackground); }
    button:disabled { opacity: 0.5; cursor: not-allowed; }
    .cli-box { margin-top: 8px; padding: 8px; border: 1px dashed var(--vscode-button-background); border-radius: 4px; }
  </style>
</head>
<body>
  <h3>[Atlas Qwen3 Direct Agent]</h3>
  <div id="chat" class="chat-box"></div>
  <textarea id="promptInput" placeholder="Ask Atlas anything... (Press Enter to Send, Shift+Enter for New Line)"></textarea>
  <button id="sendBtn" type="button">Send Prompt</button>

  <script nonce="${nonce}" src="${scriptUri}"></script>
</body>
</html>`;
    }
}
exports.AtlasSidebarProvider = AtlasSidebarProvider;
function getNonce() {
    let text = '';
    const possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    for (let i = 0; i < 32; i++) {
        text += possible.charAt(Math.floor(Math.random() * possible.length));
    }
    return text;
}
//# sourceMappingURL=sidebarProvider.js.map