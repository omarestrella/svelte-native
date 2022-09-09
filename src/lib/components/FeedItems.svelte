<script lang="ts">
  import type { Feed } from "../feeds";

  export let feed: Feed | undefined;
</script>

<div class="feed-items h-full w-80 overflow-auto border-r border-base-300">
  {#if feed?.items}
    {#each feed.items as feedItem}
      <button
        class="
          feed-item text-left grid grid-rows-1 gap-1 p-2 border-b border-base-300
          outline-1 outline-primary
        "
      >
        <h2 class="title text-sm font-bold">{feedItem.title}</h2>
        <h4 class="description text-xs">{feedItem.description}</h4>
      </button>
    {/each}
  {/if}
</div>

<style>
  .feed-item {
    outline-offset: -3px;
  }
</style>
