<script type="ts">
  import type { FeedItem } from "../managers/feed";

  export let item: FeedItem;

  function getItemContent(item: FeedItem) {
    return item.content;
  }

  function updateContent(node: HTMLElement) {
    node.querySelectorAll("a").forEach((anchor) => {
      anchor.setAttribute("target", "_blank");
      anchor.setAttribute("rel", "noreferrer noopener");
    });

    return {};
  }
</script>

<div
  use:updateContent
  class="content prose sm:prose-sm lg:prose xl:prose-lg text-justify mb-4"
>
  {@html item.content}
</div>

<style>
  :global(.content .feedflare) {
    display: none;
  }
</style>
