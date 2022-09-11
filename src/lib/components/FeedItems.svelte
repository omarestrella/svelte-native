<script lang="ts">
  import { feedManager, type Feed } from "../managers/feed";

  export let feed: Feed | undefined;

  let { currentFeedItem } = feedManager;
</script>

<div class="feed-items h-full w-full overflow-auto border-r border-base-300">
  {#if feed?.items}
    {#each feed.items as feedItem}
      {@const isActive = $currentFeedItem?.link === feedItem.link}
      <button
        class="
          feed-item text-left grid grid-rows-1 gap-1 p-2 border-b border-base-300
          outline-1 outline-primary
          {isActive && 'bg-secondary text-neutral'}
        "
        on:click={() => feedManager.currentFeedItem.set(feedItem)}
      >
        <h2 class="title text-sm font-bold">{feedItem.title}</h2>
        <h4 class="description text-xs">{@html feedItem.description}</h4>
      </button>
    {/each}
  {/if}
</div>

<style>
  .feed-item {
    outline-offset: -3px;
  }
</style>
