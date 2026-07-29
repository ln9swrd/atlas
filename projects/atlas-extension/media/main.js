(function () {
  const vscode = acquireVsCodeApi();
  const chat = document.getElementById('chat');
  const input = document.getElementById('promptInput');
  const sendBtn = document.getElementById('sendBtn');

  function send() {
    const text = input.value.trim();
    if (text) {
      vscode.postMessage({ type: 'sendPrompt', value: text });
      input.value = '';
    }
  }

  sendBtn.addEventListener('click', function (e) {
    e.preventDefault();
    send();
  });

  input.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      send();
    }
  });

  let activeAssistantMsgDiv = null;

  window.addEventListener('message', function (event) {
    const msg = event.data;
    switch (msg.type) {
      case 'addMessage': {
        const div = document.createElement('div');
        div.className = 'msg ' + msg.role;
        div.textContent = msg.content;
        chat.appendChild(div);
        chat.scrollTop = chat.scrollHeight;
        activeAssistantMsgDiv = null;
        break;
      }
      case 'appendStream': {
        if (!activeAssistantMsgDiv) {
          activeAssistantMsgDiv = document.createElement('div');
          activeAssistantMsgDiv.className = 'msg assistant';
          chat.appendChild(activeAssistantMsgDiv);
        }
        activeAssistantMsgDiv.textContent += msg.content;
        chat.scrollTop = chat.scrollHeight;
        break;
      }
      case 'suggestCli': {
        const cliDiv = document.createElement('div');
        cliDiv.className = 'cli-box';
        cliDiv.innerHTML = '<p>Suggested CLI: <code>' + msg.command + '</code></p>';
        chat.appendChild(cliDiv);
        chat.scrollTop = chat.scrollHeight;
        activeAssistantMsgDiv = null;
        break;
      }
      case 'setLoading': {
        sendBtn.disabled = msg.value;
        sendBtn.textContent = msg.value ? 'Thinking (Qwen3)...' : 'Send Prompt';
        break;
      }
    }
  });
})();
