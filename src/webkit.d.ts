declare global {
  interface Window {
    JavaScriptBridge: {};

    webkit: {
      messageHandlers: {
        mobile: {
          postMessage: (
            data: { type: string } & Record<string, unknown>
          ) => void;
        };
      };
    };
  }
}

export {};
