<script lang="ts">
  import { onMount, onDestroy } from "svelte";
  import { v4 as uuid } from "uuid";

  import "./app.css";
  import { javascriptBridge } from "./lib/managers/bridge";

  let showMessage = false;
  let feed = "";

  onMount(() => {
    javascriptBridge.send("fetchFeed", {
      url: "https://feeds.arstechnica.com/arstechnica/index",
    });

    javascriptBridge.on("fetchedFeed", (data) => {
      feed = JSON.stringify(data, null, 2);
      javascriptBridge.log("client", feed);
    });
  });
</script>

<main>
  <h1 class="text-4xl">Vite + Svelte</h1>

  <div>
    Title: <input
      class="input input-primary"
      on:input={({ currentTarget: { value } }) => {
        javascriptBridge.send("updateApplicationState", {
          update: {
            title: {
              newTitle: value,
            },
          },
        });
      }}
    />
    <br />
    Subtitle:
    <input
      class="input input-primary"
      on:input={({ currentTarget: { value } }) => {
        javascriptBridge.send("updateApplicationState", {
          update: {
            subtitle: {
              newSubtitle: value,
            },
          },
        });
      }}
    />
  </div>

  {#if showMessage}
    <p>gotta add new feed support?</p>
  {/if}

  {#if feed}
    <p>{feed}</p>
  {/if}
</main>

<style>
  main {
    width: 100%;
    height: 100%;
  }
</style>
