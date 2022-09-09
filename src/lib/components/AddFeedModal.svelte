<script lang="ts">
  import { fade } from "svelte/transition";
  import { javascriptBridge } from "../managers/bridge";

  export let open = false;

  function attachFocus(el: HTMLDivElement) {
    const focusableEls: HTMLElement[] = Array.from(
      el.querySelectorAll(
        "a[href]:not([disabled]), button:not([disabled]), textarea:not([disabled]), input:not([disabled]), select:not([disabled])"
      )
    );

    const initialFocusableEl = focusableEls[0];
    const lastFocusableEl = focusableEls[focusableEls.length - 1];

    initialFocusableEl.focus();

    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key !== "Tab") {
        return;
      }

      if (event.shiftKey) {
        if (document.activeElement === initialFocusableEl) {
          lastFocusableEl.focus();
          event.preventDefault();
        }
      } else if (document.activeElement === lastFocusableEl) {
        initialFocusableEl.focus();
        event.preventDefault();
      }
    };

    el.addEventListener("keydown", onKeyDown);
    return {
      destroy() {
        el.removeEventListener("keydown", onKeyDown);
      },
    };
  }
</script>

<svelte:window
  on:keydown={(event) => {
    if (event.key === "Escape") {
      open = false;
    }
  }}
/>

{#if open}
  <div
    class="modal modal-bottom sm:modal-middle modal-open"
    use:attachFocus
    in:fade={{ duration: 175 }}
    out:fade={{ duration: 175 }}
  >
    <div class="modal-box grid grid-flow-row gap-2">
      <h3 class="font-bold text-lg">Add New Feed</h3>
      <div>
        <input class="input input-primary w-full" />
      </div>
      <div class="modal-action">
        <button class="btn">Add Feed</button>
        <button class="btn btn-secondary" on:click={() => (open = false)}
          >Close</button
        >
      </div>
    </div>
  </div>
{/if}
