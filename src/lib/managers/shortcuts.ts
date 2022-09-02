import { javascriptBridge } from "./bridge";

type KeyboardShortcut = {
  key: string;
  modifiers: ("command" | "shift" | "option" | "ctrl")[];
};

export type Shortcut = {
  id: string;
  label: string;
  placement: "file" | "settings";
  keyboardShortcut: KeyboardShortcut;
  handler: () => void;
};

class ShortcutManager {
  shortcuts = new Map<string, Shortcut>();

  constructor() {
    javascriptBridge.on("callShortcut", ({ id }) => this.runShortcut(id));
  }

  registerShortcut(shortcut: Shortcut) {
    const bridgeShortcut = { ...shortcut };
    delete bridgeShortcut.handler;
    javascriptBridge.send("registerShortcut", bridgeShortcut);

    this.shortcuts.set(shortcut.id, shortcut);
  }

  removeShortcut(id: string) {
    javascriptBridge.send("removeShortcut", { id });
    this.shortcuts.delete(id);
  }

  runShortcut(id: string) {
    this.shortcuts.get(id)?.handler();
  }
}

export const shortcutManager = new ShortcutManager();
