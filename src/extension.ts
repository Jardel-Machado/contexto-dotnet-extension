import * as vscode from 'vscode';
import * as path from 'path';

export function activate(context: vscode.ExtensionContext) {
  let disposable = vscode.commands.registerCommand('extension.createContext', () => {
    const scriptPath = path.join(context.extensionPath, 'scripts', 'CriarContexto.ps1');

    const terminal = vscode.window.createTerminal("Criar Contexto .NET");
    terminal.sendText(`powershell -ExecutionPolicy Bypass -File "${scriptPath}"`);
    terminal.show();
  });

  context.subscriptions.push(disposable);
}

export function deactivate() {}