<script>
  import {flashMessageStore} from '../stores';
</script>

<style>
  .area {
    position: fixed;
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
    width: 100%;
    height: 100%;
    pointer-events: none;
    z-index: 2;
  }

  .message {
    background-color: rgb(250, 250, 250);
    border: 1px solid rgb(130, 130, 130);
    border-radius: 0.8em;
    max-width: 60vw;
    margin: 0 auto 1em;
    padding: 0.8em;
    pointer-events: auto;
  }
</style>

{#if $flashMessageStore.length}
  <div class="area">
    {#each $flashMessageStore as { message }}
      <div class="message">{message}</div>
    {/each}
  </div>
{/if}
