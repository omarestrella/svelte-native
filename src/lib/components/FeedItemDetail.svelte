<script lang="ts">
  import type { FeedItem } from "../managers/feed";
  import FeedItemContent from "./FeedItemContent.svelte";

  export let item: FeedItem;
</script>

<div class="mt-4 h-auto w-full flex flex-col gap-2">
  <h1 class="text-2xl font-extrabold">
    {item.title}
  </h1>

  <div class="text-sm">
    {item.date}
  </div>

  <FeedItemContent {item} />
</div>
