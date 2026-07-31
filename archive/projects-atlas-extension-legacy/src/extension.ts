import * as vscode from 'vscode';
import { AtlasSidebarProvider } from './sidebarProvider';

export function activate(context: vscode.ExtensionContext) {
  console.log('Atlas DevOS Local AI Agent Extension is now active!');

  const provider = new AtlasSidebarProvider(context.extensionUri);

  context.subscriptions.push(
    vscode.window.registerWebviewViewProvider(AtlasSidebarProvider.viewType, provider)
  );

  context.subscriptions.push(
    vscode.commands.registerCommand('atlas.openChat', () => {
      vscode.commands.executeCommand('workbench.view.extension.atlas-activity-bar');
    })
  );
}

export function deactivate() {}
