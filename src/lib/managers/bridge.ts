import type { Feed } from "../feeds";

type BridgeMessage = {
  updateApplicationState: {
    update:
      | {
          title: { newTitle: string };
        }
      | { subtitle: { newSubtitle: string } };
  };

  fetchFeed: { url: string };
};

type BridgeEvent = {
  fetchedFeed: Feed;
  addFeed: never;
};

class JavaScriptBridge {
  nativeMessageHandlers = new Map<
    keyof BridgeEvent,
    ((data: BridgeEvent[keyof BridgeEvent]) => void)[]
  >();

  on<EventName extends keyof BridgeEvent>(
    event: EventName,
    callback: (data: BridgeEvent[EventName]) => void
  ) {
    if (!this.nativeMessageHandlers.has(event)) {
      this.nativeMessageHandlers.set(event, []);
    }
    this.nativeMessageHandlers.get(event)?.push(callback);
  }

  emit<EventName extends keyof BridgeEvent>(
    event: EventName,
    data: BridgeEvent[EventName]
  ) {
    this.nativeMessageHandlers.get(event)?.forEach((cb) => cb(data));
  }

  send<MessageName extends keyof BridgeMessage>(
    message: MessageName,
    data: BridgeMessage[MessageName]
  ) {
    if (
      window.webkit &&
      window.webkit.messageHandlers &&
      window.webkit.messageHandlers.mobile
    ) {
      window.webkit.messageHandlers.mobile.postMessage({
        type: message,
        ...data,
      });
    }
  }

  log(name: string, message?: string) {
    if (
      window.webkit &&
      window.webkit.messageHandlers &&
      window.webkit.messageHandlers.mobile
    ) {
      window.webkit.messageHandlers.mobile.postMessage({
        type: "log",
        name,
        message,
      });
    }
  }
}

export const javascriptBridge = new JavaScriptBridge();

window.JavaScriptBridge = javascriptBridge;
