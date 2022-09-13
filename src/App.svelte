<script lang="ts">
  import { onMount, onDestroy } from "svelte";
  import { v4 as uuid } from "uuid";

  import "./app.css";
  import AddFeedModal from "./lib/components/AddFeedModal.svelte";
  import FeedItems from "./lib/components/FeedItems.svelte";
  import { feedManager, type Feed } from "./lib/managers/feed";
  import { javascriptBridge } from "./lib/managers/bridge";
  import FeedItemContent from "./lib/components/FeedItemContent.svelte";
  import { setDarkTheme, setLightTheme } from "./utils/theme";
  import FeedItemDetail from "./lib/components/FeedItemDetail.svelte";

  let showAddFeed = false;

  let { currentFeed, currentFeedItem } = feedManager;

  onMount(() => {
    javascriptBridge.on("addFeed", () => {
      showAddFeed = true;
    });

    javascriptBridge.on("colorSchemeChanged", (color: "light" | "dark") => {
      if (color === "light") {
        setLightTheme();
      } else {
        setDarkTheme();
      }
    });

    feedManager.fetchFeed("https://feeds.arstechnica.com/arstechnica/index");
  });
</script>

<main class="h-screen overflow-hidden">
  <div class="flex h-full">
    <div class="w-80 h-full">
      <FeedItems feed={$currentFeed} />
    </div>

    {#if $currentFeedItem}
      <div
        class="flex flex-1 flex-col items-center w-auto h-full overflow-auto px-8"
      >
        <FeedItemDetail item={$currentFeedItem} />
      </div>
    {/if}
  </div>

  <AddFeedModal bind:open={showAddFeed} />
</main>
