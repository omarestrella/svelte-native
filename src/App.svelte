<script lang="ts">
  import { onMount, onDestroy } from "svelte";
  import { v4 as uuid } from "uuid";

  import "./app.css";
  import AddFeedModal from "./lib/components/AddFeedModal.svelte";
  import FeedItems from "./lib/components/FeedItems.svelte";
  import type { Feed } from "./lib/feeds";
  import { javascriptBridge } from "./lib/managers/bridge";

  let showAddFeed = false;

  let feed: Feed;

  onMount(() => {
    javascriptBridge.send("fetchFeed", {
      url: "https://feeds.arstechnica.com/arstechnica/index",
    });

    javascriptBridge.on("fetchedFeed", (data) => {
      feed = data;

      javascriptBridge.send("updateApplicationState", {
        update: {
          title: {
            newTitle: data.title,
          },
        },
      });
    });

    javascriptBridge.on("addFeed", () => {
      showAddFeed = true;
    });
  });
</script>

<main class="h-screen overflow-hidden">
  <FeedItems {feed} />

  <AddFeedModal bind:open={showAddFeed} />
</main>
