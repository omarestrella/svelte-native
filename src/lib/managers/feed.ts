import { writable, type Writable } from "svelte/store";
import { javascriptBridge } from "./bridge";

class FeedManager {
  currentFeed: Writable<Feed | null> = writable(null);
  currentFeedItem: Writable<FeedItem | null> = writable(null);

  constructor() {
    javascriptBridge.on("fetchedFeed", this.onFetchedFeed);
  }

  fetchFeed(url: string) {
    javascriptBridge.send("fetchFeed", { url });
  }

  private onFetchedFeed = (feed: Feed) => {
    this.currentFeed.set(feed);

    javascriptBridge.send("updateApplicationState", {
      update: {
        title: {
          newTitle: feed.title,
        },
      },
    });
  };
}

export const feedManager = new FeedManager();

export type Feed = {
  title: string;
  items: FeedItem[];
};
export type FeedItem = {
  title: string;
  description: string;
  date: string;
  content: string;
  link: string;
};
