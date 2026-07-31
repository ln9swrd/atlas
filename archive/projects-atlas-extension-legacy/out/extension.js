"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.activate = activate;
exports.deactivate = deactivate;
const vscode = require("vscode");
const sidebarProvider_1 = require("./sidebarProvider");
function activate(context) {
    console.log('Atlas DevOS Local AI Agent Extension is now active!');
    const provider = new sidebarProvider_1.AtlasSidebarProvider(context.extensionUri);
    context.subscriptions.push(vscode.window.registerWebviewViewProvider(sidebarProvider_1.AtlasSidebarProvider.viewType, provider));
    context.subscriptions.push(vscode.commands.registerCommand('atlas.openChat', () => {
        vscode.commands.executeCommand('workbench.view.extension.atlas-activity-bar');
    }));
}
function deactivate() { }
//# sourceMappingURL=extension.js.map